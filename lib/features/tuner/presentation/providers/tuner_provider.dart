import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/audio_pitch_service.dart';

import '../../domain/models/note_model.dart';

import '../../domain/pitch_converter.dart';

import 'tuner_settings_provider.dart';

final audioPitchServiceProvider = Provider<AudioPitchService>((ref) {
  final service = AudioPitchService();

  ref.onDispose(() => service.dispose());

  return service;
});

class TunerState {
  final bool isListening;

  final NoteModel? currentNote;

  final bool isAutoMode;

  final int
  activeStringNumber; // Cuerda seleccionada manualmente o detectada (1 a 6)

  TunerState({
    required this.isListening,

    this.currentNote,

    this.isAutoMode = true,

    this.activeStringNumber = 5,
  });

  TunerState copyWith({
    bool? isListening,

    NoteModel? currentNote,

    bool? isAutoMode,

    int? activeStringNumber,
  }) {
    return TunerState(
      isListening: isListening ?? this.isListening,

      currentNote: currentNote ?? this.currentNote,

      isAutoMode: isAutoMode ?? this.isAutoMode,

      activeStringNumber: activeStringNumber ?? this.activeStringNumber,
    );
  }
}

class TunerNotifier extends StateNotifier<TunerState> {
  final AudioPitchService _audioPitchService;
  final Ref _ref;

  StreamSubscription<double>? _pitchSubscription;

  // Evita reconstruir toda la pantalla en cada detección de pitch (que puede
  // llegar 20-40 veces por segundo). Limitamos las actualizaciones de UI a
  // ~12 por segundo, suficiente para que se vea fluido pero sin saturar el
  // hilo principal con recolecciones de basura constantes (lo que causaba
  // el congelamiento progresivo).
  DateTime _lastUiUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _uiUpdateInterval = Duration(milliseconds: 80);

  TunerNotifier(this._audioPitchService, this._ref)
    : super(TunerState(isListening: false));

  /// Inicia o detiene la escucha del micrófono

  Future<void> toggleListening() async {
    if (state.isListening) {
      await _audioPitchService.stopListening();

      await _pitchSubscription?.cancel();

      state = state.copyWith(isListening: false, currentNote: null);
    } else {
      await startListening();
    }
  }

  /// Inicia la escucha continua

  Future<void> startListening() async {
    if (state.isListening) return;

    final started = await _audioPitchService.startListening();

    if (started) {
      state = state.copyWith(isListening: true);

      _pitchSubscription = _audioPitchService.pitchStream.listen((frequency) {
        final now = DateTime.now();
        if (now.difference(_lastUiUpdate) < _uiUpdateInterval) return;
        _lastUiUpdate = now;

        final note = PitchConverter.getNoteFromFrequency(frequency);

        if (note != null) {
          int stringNum = state.activeStringNumber;

          // En Modo Automático, detectamos la cuerda activa según la octava

          if (state.isAutoMode) {
            stringNum = _mapNoteToStringNumber(note.name, note.octave);
          }

          state = state.copyWith(
            currentNote: note,

            activeStringNumber: stringNum,
          );
        }
      });
    }
  }

  /// Cambia entre Modo Automático y Manual

  void toggleAutoMode(bool value) {
    state = state.copyWith(isAutoMode: value);
  }

  /// Cambia manualmente la cuerda seleccionada (en modo manual)

  void selectString(int stringNum) {
    state = state.copyWith(
      activeStringNumber: stringNum,

      isAutoMode: false, // Pasa a modo manual al tocar una cuerda
    );
  }

  /// Identifica la cuerda (1 a N) según la afinación actualmente aplicada
  /// (ver [tunerSettingsProvider]). Compara por nombre de nota + octava,
  /// igual que antes, pero ahora contra la lista de cuerdas de la
  /// afinación activa en vez de una tabla EADGBE fija — así Drop D,
  /// afinaciones abiertas, etc. detectan la cuerda correcta.
  int _mapNoteToStringNumber(String noteName, int octave) {
    final tuning = _ref.read(tunerSettingsProvider).appliedTuning;

    for (final tunedString in tuning.strings) {
      if (tunedString.noteName == noteName && tunedString.octave == octave) {
        return tunedString.number;
      }
    }

    // No coincide exactamente con ninguna cuerda de la afinación activa:
    // conservamos la cuerda seleccionada anteriormente.
    return state.activeStringNumber;
  }

  @override
  void dispose() {
    _pitchSubscription?.cancel();

    super.dispose();
  }
}

final tunerProvider = StateNotifierProvider<TunerNotifier, TunerState>((ref) {
  final audioService = ref.watch(audioPitchServiceProvider);

  return TunerNotifier(audioService, ref);
});
