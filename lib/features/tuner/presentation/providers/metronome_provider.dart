import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MetronomeState {
  final int bpm;
  final int timeSignature; // 2, 3, 4, 6
  final int currentBeat; // 0 a (timeSignature - 1)
  final bool isPlaying;
  final bool isMuted;

  MetronomeState({
    this.bpm = 120,
    this.timeSignature = 4,
    this.currentBeat = 0,
    this.isPlaying = false,
    this.isMuted = false,
  });

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
  }) {
    return MetronomeState(
      bpm: bpm ?? this.bpm,
      timeSignature: timeSignature ?? this.timeSignature,
      currentBeat: currentBeat ?? this.currentBeat,
      isPlaying: isPlaying ?? this.isPlaying,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class MetronomeNotifier extends StateNotifier<MetronomeState> {
  Timer? _timer;
  final List<DateTime> _tapTimes = [];

  // `AudioPool` precarga VARIAS instancias reproductoras del mismo sonido y
  // las va rotando en cada reproducción.
  //
  // Antes usábamos un único AudioPlayer por sonido (modo lowLatency) y lo
  // reutilizábamos en cada tick. Ese es un bug conocido y documentado del
  // paquete `audioplayers`: al llamar a play() repetidamente sobre la MISMA
  // instancia mientras el sonido anterior sigue "activo" internamente, el
  // plugin ignora la llamada en silencio a partir de la 2da o 3ra vez — por
  // eso solo sonaban los primeros pulsos y luego nada. AudioPool resuelve
  // esto de raíz porque cada tick puede tomar una instancia distinta y
  // libre del pool, sin depender de que la anterior ya haya "terminado".
  AudioPool? _accentPool;
  AudioPool? _normalPool;
  bool _audioReady = false;

  MetronomeNotifier() : super(MetronomeState()) {
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      _accentPool = await AudioPool.createFromAsset(
        path: 'sounds/tick_accent.wav',
        maxPlayers: 5, //aumenta cuántas reproducciones pueden solaparse al mismo tiempo, sin costo real de rendimiento.
      );
      _normalPool = await AudioPool.createFromAsset(
        path: 'sounds/tick_normal.wav',
        maxPlayers: 5, //aumenta cuántas reproducciones pueden solaparse al mismo tiempo, sin costo real de rendimiento.
      );
      _audioReady = true;
    } catch (e) {
      debugPrint('Error inicializando audio del metrónomo: $e');
    }
  }

  void setBpm(int newBpm) {
    final clampedBpm = newBpm.clamp(40, 240);
    state = state.copyWith(bpm: clampedBpm);
    if (state.isPlaying) {
      _startTimer();
    }
  }

  void adjustBpm(int delta) {
    setBpm(state.bpm + delta);
  }

  void setTimeSignature(int signature) {
    state = state.copyWith(timeSignature: signature, currentBeat: 0);
    if (state.isPlaying) {
      _startTimer();
    }
  }

  void togglePlay() {
    if (state.isPlaying) {
      _stopTimer();
      state = state.copyWith(isPlaying: false, currentBeat: 0);
    } else {
      state = state.copyWith(isPlaying: true, currentBeat: 0);
      _playClickSound(isAccent: true);
      _startTimer();
    }
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void registerTap() {
    final now = DateTime.now();
    _tapTimes.add(now);

    _tapTimes.removeWhere((time) => now.difference(time).inMilliseconds > 3000);

    if (_tapTimes.length >= 2) {
      final List<int> intervals = [];
      for (int i = 1; i < _tapTimes.length; i++) {
        intervals.add(_tapTimes[i].difference(_tapTimes[i - 1]).inMilliseconds);
      }
      final double avgInterval =
          intervals.reduce((a, b) => a + b) / intervals.length;
      final int calculatedBpm = (60000 / avgInterval).round();

      setBpm(calculatedBpm);
    }
  }

  void _startTimer() {
    _stopTimer();
    final intervalMs = ((60 / state.bpm) * 1000).round();
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) => _tick());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    final nextBeat = (state.currentBeat + 1) % state.timeSignature;
    state = state.copyWith(currentBeat: nextBeat);

    if (!state.isMuted) {
      _playClickSound(isAccent: nextBeat == 0);
    }
  }

  void _playClickSound({required bool isAccent}) {
    if (state.isMuted || !_audioReady) return;

    final pool = isAccent ? _accentPool : _normalPool;

    // start() toma una instancia libre del pool (o crea una nueva si hace
    // falta) en vez de reusar siempre la misma, evitando el bug de
    // silencio en reproducciones repetidas.
    pool?.start();
  }

  @override
  void dispose() {
    _stopTimer();
    _accentPool?.dispose();
    _normalPool?.dispose();
    super.dispose();
  }
}

final metronomeProvider =
    StateNotifierProvider<MetronomeNotifier, MetronomeState>((ref) {
      return MetronomeNotifier();
    });
