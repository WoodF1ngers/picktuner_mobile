import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import 'metronome_sound_presets.dart';

class MetronomeState {
  final int bpm;
  final int timeSignature; // 2, 3, 4, 6
  final int currentBeat; // 0 a (timeSignature - 1)
  final bool isPlaying;
  final bool isMuted;
  final String soundPresetId;

  MetronomeState({
    this.bpm = 120,
    this.timeSignature = 4,
    this.currentBeat = 0,
    this.isPlaying = false,
    this.isMuted = false,
    this.soundPresetId = 'ableton',
  });

  String get soundPresetName => metronomePresetById(soundPresetId).name;

  String get tempoMarking {
    if (bpm <= 59) return 'Largo (40–59)';
    if (bpm <= 76) return 'Adagio (60–76)';
    if (bpm <= 107) return 'Andante (77–107)';
    if (bpm <= 120) return 'Moderato (108–120)';
    if (bpm <= 167) return 'Allegro (121–167)';
    if (bpm <= 200) return 'Vivace (168–200)';
    return 'Presto (201–240)';
  }

  MetronomeState copyWith({
    int? bpm,
    int? timeSignature,
    int? currentBeat,
    bool? isPlaying,
    bool? isMuted,
    String? soundPresetId,
  }) {
    return MetronomeState(
      bpm: bpm ?? this.bpm,
      timeSignature: timeSignature ?? this.timeSignature,
      currentBeat: currentBeat ?? this.currentBeat,
      isPlaying: isPlaying ?? this.isPlaying,
      isMuted: isMuted ?? this.isMuted,
      soundPresetId: soundPresetId ?? this.soundPresetId,
    );
  }
}

class MetronomeNotifier extends StateNotifier<MetronomeState> {
  final SoLoud _soloud = SoLoud.instance;

  // Cada muestra se decodifica UNA sola vez al cargar el preset y queda
  // residente en memoria; reproducir después (`_soloud.play`) solo dispara
  // una voz nueva sobre el PCM ya decodificado — es lo que elimina las
  // llamadas repetidas a Codec2Client (decodificación por click) que
  // causaban el lag y las ráfagas de ticks atrasados.
  AudioSource? _normalSource;
  AudioSource? _accentSource;
  bool _audioReady = false;

  // Generación de carga: si el usuario cambia de preset mientras el
  // anterior todavía está cargando, la carga vieja se descarta sola al
  // terminar en vez de pisar el preset que el usuario realmente quiere.
  int _loadGeneration = 0;
  Future<void>? _pendingLoad;

  // --- Scheduler de reloj absoluto (anti-deriva) ---
  // En vez de reprogramar un Timer relativo "de aquí a X ms" cada vez
  // (que acumula atraso si algo se demora), anclamos un tiempo objetivo
  // absoluto en microsegundos sobre un Stopwatch, y un loop corto de
  // verificación dispara el beat en cuanto se cumple ese objetivo. Un
  // atraso puntual de un tick nunca se arrastra al siguiente.
  final Stopwatch _stopwatch = Stopwatch();
  int? _nextBeatMicros;
  Timer? _schedulerTimer;
  static const Duration _pumpInterval = Duration(milliseconds: 15);
  static const int _resyncThresholdMicros = 500000; // 500ms

  // Evita que toques repetidos de play/pausa disparen temporizadores
  // duplicados o dejen el estado a medio camino mientras se procesa.
  bool _isTogglingPlay = false;

  final List<DateTime> _tapTimes = [];

  MetronomeNotifier() : super(MetronomeState()) {
    _pendingLoad = _init();
  }

  Future<void> _init() async {
    try {
      if (!_soloud.isInitialized) {
        await _soloud.init();
      }
      await _loadPreset(state.soundPresetId);
    } catch (e, st) {
      debugPrint('Error inicializando el motor de audio del metrónomo: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> selectSoundPreset(String presetId) async {
    if (presetId == state.soundPresetId && _audioReady) return;

    final wasPlaying = state.isPlaying;
    state = state.copyWith(soundPresetId: presetId);

    _pendingLoad = _loadPreset(presetId);
    await _pendingLoad;

    // Si el metrónomo seguía sonando mientras cargaba, no hace falta hacer
    // nada más: el scheduler nunca se detuvo, solo empezará a usar el
    // sonido nuevo en el próximo beat que dispare.
    if (wasPlaying && !state.isPlaying) {
      // Algo detuvo la reproducción mientras tanto (p. ej. togglePlay
      // concurrente); no la reanudamos por nuestra cuenta.
    }
  }

  Future<void> _loadPreset(String presetId) async {
    final generation = ++_loadGeneration;
    _audioReady = false;

    final preset = metronomePresetById(presetId);
    final oldNormal = _normalSource;
    final oldAccent = _accentSource;

    try {
      final normal = await _soloud.loadAsset('assets/${preset.normalAsset}');
      final accent = await _soloud.loadAsset('assets/${preset.accentAsset}');

      if (generation != _loadGeneration) {
        // Se seleccionó otro preset mientras este cargaba: estas fuentes ya
        // no sirven, se liberan sin tocar el estado actual.
        await _soloud.disposeSource(normal);
        await _soloud.disposeSource(accent);
        return;
      }

      _normalSource = normal;
      _accentSource = accent;
      _audioReady = true;

      // Las fuentes viejas se liberan DESPUÉS de que las nuevas ya están
      // activas, para no dejar una ventana sin sonido disponible.
      if (oldNormal != null) await _soloud.disposeSource(oldNormal);
      if (oldAccent != null) await _soloud.disposeSource(oldAccent);

      debugPrint('Audio del metrónomo listo: ${preset.name}');
    } catch (e, st) {
      if (generation == _loadGeneration) _audioReady = false;
      debugPrint('Error cargando preset de audio (${preset.name}): $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> _ensureAudioReady() async {
    final pending = _pendingLoad;
    if (pending != null) await pending;
    if (!_audioReady) {
      _pendingLoad = _loadPreset(state.soundPresetId);
      await _pendingLoad;
    }
  }

  void setBpm(int newBpm) {
    final clamped = newBpm.clamp(40, 240);
    if (clamped == state.bpm) return;
    // El cambio de tempo toma efecto a partir del PRÓXIMO beat: no
    // recalculamos el objetivo ya anclado, así el pulso actual no se
    // "estira" ni se corta de forma abrupta — se siente natural.
    state = state.copyWith(bpm: clamped);
  }

  void adjustBpm(int delta) => setBpm(state.bpm + delta);

  void setTimeSignature(int signature) {
    if (signature == state.timeSignature) return;
    state = state.copyWith(timeSignature: signature, currentBeat: 0);
  }

  Future<void> togglePlay() async {
    if (_isTogglingPlay) return; // ignora toques repetidos mientras procesa
    _isTogglingPlay = true;
    try {
      if (state.isPlaying) {
        _stopScheduler();
        state = state.copyWith(isPlaying: false, currentBeat: 0);
        return;
      }

      await _ensureAudioReady();
      if (state.isPlaying) return; // por si algo más ya lo puso en marcha

      // El primer clic suena de inmediato al presionar play (no espera al
      // primer ciclo del scheduler); el scheduler se encarga de todos los
      // pulsos siguientes.
      state = state.copyWith(isPlaying: true, currentBeat: 0);
      if (!state.isMuted) {
        _playClick(isAccent: true);
      }
      _startScheduler();
    } finally {
      _isTogglingPlay = false;
    }
  }

  void toggleMute() => state = state.copyWith(isMuted: !state.isMuted);

  void registerTap() {
    final now = DateTime.now();
    _tapTimes.add(now);
    _tapTimes.removeWhere((t) => now.difference(t).inMilliseconds > 3000);

    if (_tapTimes.length >= 2) {
      final intervals = <int>[
        for (int i = 1; i < _tapTimes.length; i++)
          _tapTimes[i].difference(_tapTimes[i - 1]).inMilliseconds,
      ];
      final avg = intervals.reduce((a, b) => a + b) / intervals.length;
      setBpm((60000 / avg).round());
    }
  }

  // --- Scheduler ---

  void _startScheduler() {
    _stopwatch
      ..reset()
      ..start();
    // El beat 0 ya se disparó manualmente en togglePlay(); el próximo
    // objetivo es un intervalo completo a partir de ahora.
    _nextBeatMicros = (60000000 / state.bpm).round();
    _schedulerTimer?.cancel();
    _schedulerTimer = Timer.periodic(_pumpInterval, (_) => _pump());
  }

  void _stopScheduler() {
    _schedulerTimer?.cancel();
    _schedulerTimer = null;
    _stopwatch.stop();
    _nextBeatMicros = null;
  }

  void _pump() {
    if (!state.isPlaying || _nextBeatMicros == null) return;

    final nowMicros = _stopwatch.elapsedMicroseconds;
    if (nowMicros < _nextBeatMicros!) return;

    _fireBeat();

    final intervalMicros = (60000000 / state.bpm).round();
    int next = _nextBeatMicros! + intervalMicros;

    // Si el atraso acumulado es enorme (app pausada en segundo plano, un
    // stall largo, etc.) no intentamos "recuperar" disparando una ráfaga
    // de beats perdidos: resincronizamos directo al presente.
    if (nowMicros - next > _resyncThresholdMicros) {
      next = nowMicros + intervalMicros;
    }
    _nextBeatMicros = next;
  }

  void _fireBeat() {
    final nextBeat = (state.currentBeat + 1) % state.timeSignature;
    state = state.copyWith(currentBeat: nextBeat);
    if (!state.isMuted) {
      _playClick(isAccent: nextBeat == 0);
    }
  }

  void _playClick({required bool isAccent}) {
    if (!_audioReady) return;
    final source = isAccent ? _accentSource : _normalSource;
    if (source == null) return;
    // Fire-and-forget: reproduce una voz nueva sobre la muestra ya
    // decodificada en memoria. No se espera (no hace falta) y nunca
    // bloquea el siguiente pulso del scheduler.
    _soloud.play(source);
  }

  @override
  void dispose() {
    _stopScheduler();
    if (_normalSource != null) _soloud.disposeSource(_normalSource!);
    if (_accentSource != null) _soloud.disposeSource(_accentSource!);
    super.dispose();
  }
}

final metronomeProvider =
    StateNotifierProvider<MetronomeNotifier, MetronomeState>((ref) {
      return MetronomeNotifier();
    });
