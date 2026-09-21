import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/audio_pitch_service.dart';

import '../../domain/models/note_model.dart';

import '../../domain/pitch_converter.dart';

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

  StreamSubscription<double>? _pitchSubscription;

  TunerNotifier(this._audioPitchService)
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

  /// Identifica la cuerda (1 a 6) para la afinación estándar de guitarra EADGBE

  int _mapNoteToStringNumber(String noteName, int octave) {
    final fullNote = '$noteName$octave';

    switch (fullNote) {
      case 'E2':
        return 6; // 6ª Cuerda (E Grave)

      case 'A2':
        return 5; // 5ª Cuerda (A)

      case 'D3':
        return 4; // 4ª Cuerda (D)

      case 'G3':
        return 3; // 3ª Cuerda (G)

      case 'B3':
        return 2; // 2ª Cuerda (B)

      case 'E4':
        return 1; // 1ª Cuerda (E Agudo)

      default:
        return state.activeStringNumber; // Conserva la anterior si no encaja exactamente
    }
  }

  @override
  void dispose() {
    _pitchSubscription?.cancel();

    super.dispose();
  }
}

final tunerProvider = StateNotifierProvider<TunerNotifier, TunerState>((ref) {
  final audioService = ref.watch(audioPitchServiceProvider);

  return TunerNotifier(audioService);
});
