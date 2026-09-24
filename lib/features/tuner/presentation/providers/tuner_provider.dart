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
  final int activeStringNumber; // 1 a 6
  final Set<int> tunedStrings; // Cuerdas afinadas con éxito
  final double tuningProgress; // Progreso de llenado de 0.0 a 1.0

  TunerState({
    required this.isListening,
    this.currentNote,
    this.isAutoMode = true,
    this.activeStringNumber = 5,
    Set<int>? tunedStrings,
    this.tuningProgress = 0.0,
  }) : tunedStrings = tunedStrings ?? {};

  TunerState copyWith({
    bool? isListening,
    NoteModel? currentNote,
    bool? isAutoMode,
    int? activeStringNumber,
    Set<int>? tunedStrings,
    double? tuningProgress,
  }) {
    return TunerState(
      isListening: isListening ?? this.isListening,
      currentNote: currentNote ?? this.currentNote,
      isAutoMode: isAutoMode ?? this.isAutoMode,
      activeStringNumber: activeStringNumber ?? this.activeStringNumber,
      tunedStrings: tunedStrings ?? this.tunedStrings,
      tuningProgress: tuningProgress ?? this.tuningProgress,
    );
  }
}

class TunerNotifier extends StateNotifier<TunerState> {
  final AudioPitchService _audioPitchService;
  final Ref _ref;

  StreamSubscription<double>? _pitchSubscription;
  Timer? _progressTimer;

  static const double inTuneToleranceCents = 4.0;
  static const double totalSeconds = 3.0;
  static const double delaySeconds = 1.5; // Tiempo de espera inicial
  static const int tickMs = 50; // Frecuencia de actualización (50ms)

  DateTime _lastUiUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _uiUpdateInterval = Duration(milliseconds: 50);

  // Rastrea la última cuerda para la que se inició el filling, para detectar cambios
  int? _fillingForString;

  TunerNotifier(this._audioPitchService, this._ref)
    : super(TunerState(isListening: false));

  Future<void> toggleListening() async {
    if (state.isListening) {
      await _audioPitchService.stopListening();
      await _pitchSubscription?.cancel();
      _stopProgressTimer();
      state = state.copyWith(
        isListening: false,
        currentNote: null,
        tuningProgress: 0.0,
      );
    } else {
      await startListening();
    }
  }

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

          if (state.isAutoMode) {
            stringNum = _mapNoteToStringNumber(note.name, note.octave);
          }

          _evaluateInTuneStatus(stringNum, note.centsOffset);

          state = state.copyWith(
            currentNote: note,
            activeStringNumber: stringNum,
          );
        } else {
          _decayProgress();
        }
      });
    }
  }

  void _evaluateInTuneStatus(int stringNumber, double centsOffset) {
    final bool isInRange = centsOffset.abs() <= inTuneToleranceCents;

    // Si la cuerda activa cambió, detener cualquier temporizador anterior y reiniciar progreso
    if (_fillingForString != stringNumber) {
      _stopProgressTimer();
      _fillingForString = stringNumber;
      state = state.copyWith(tuningProgress: 0.0);
    }

    if (isInRange) {
      if (state.tunedStrings.contains(stringNumber)) return;
      _startOrContinueFilling(stringNumber);
    } else {
      _decayProgress();
    }
  }

  void _startOrContinueFilling(int stringNumber) {
    if (_progressTimer != null && _progressTimer!.isActive) return;

    _fillingForString = stringNumber;

    // Arrancar la medición con retardo desde cero cuando se detecta afinación
    double accumulatedTime = state.tuningProgress > 0.0
        ? (state.tuningProgress * (totalSeconds - delaySeconds) + delaySeconds)
        : 0.0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: tickMs), (
      timer,
    ) {
      accumulatedTime += (tickMs / 1000.0);

      if (accumulatedTime < delaySeconds) {
        // En la fase de retardo (0.0s a 1.5s), el progreso visible se mantiene en 0.0
        if (state.tuningProgress != 0.0) {
          state = state.copyWith(tuningProgress: 0.0);
        }
      } else {
        // En la fase de carga (1.5s a 3.0s), calcula el progreso visible (0.0 a 1.0)
        final double progress =
            ((accumulatedTime - delaySeconds) / (totalSeconds - delaySeconds))
                .clamp(0.0, 1.0);

        state = state.copyWith(tuningProgress: progress);

        if (progress >= 1.0) {
          _markStringAsTuned(stringNumber);
        }
      }
    });
  }

  void _decayProgress() {
    _stopProgressTimer();

    if (state.tuningProgress > 0.0) {
      // Temporizador para revertir / vaciar suavemente el progreso
      _progressTimer = Timer.periodic(const Duration(milliseconds: tickMs), (
        timer,
      ) {
        final double newProgress = (state.tuningProgress - 0.08).clamp(
          0.0,
          1.0,
        );
        state = state.copyWith(tuningProgress: newProgress);

        if (newProgress <= 0.0) {
          _stopProgressTimer();
        }
      });
    }
  }

  void _markStringAsTuned(int stringNumber) {
    _stopProgressTimer();
    _fillingForString = null;
    final newTunedSet = Set<int>.from(state.tunedStrings)..add(stringNumber);
    state = state.copyWith(tunedStrings: newTunedSet, tuningProgress: 1.0);
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  /// Resetea completamente el progreso y el estado afinado de todos los badges.
  /// Llamado, por ejemplo, al hacer scroll hacia arriba en la pantalla.
  void resetAllBadges() {
    _stopProgressTimer();
    _fillingForString = null;
    state = state.copyWith(tunedStrings: {}, tuningProgress: 0.0);
  }

  void toggleAutoMode(bool value) {
    _stopProgressTimer();
    _fillingForString = null;
    state = state.copyWith(isAutoMode: value, tuningProgress: 0.0);
  }

  void selectString(int stringNum) {
    _stopProgressTimer();
    _fillingForString = null;
    state = state.copyWith(
      activeStringNumber: stringNum,
      isAutoMode: false,
      tuningProgress: 0.0,
    );
  }

  void resetTunedState() {
    _stopProgressTimer();
    _fillingForString = null;
    state = state.copyWith(tunedStrings: {}, tuningProgress: 0.0);
  }

  int _mapNoteToStringNumber(String noteName, int octave) {
    final tuning = _ref.read(tunerSettingsProvider).appliedTuning;

    for (final tunedString in tuning.strings) {
      if (tunedString.noteName == noteName && tunedString.octave == octave) {
        return tunedString.number;
      }
    }
    return state.activeStringNumber;
  }

  @override
  void dispose() {
    _stopProgressTimer();
    _pitchSubscription?.cancel();
    super.dispose();
  }
}

final tunerProvider = StateNotifierProvider<TunerNotifier, TunerState>((ref) {
  final audioService = ref.watch(audioPitchServiceProvider);
  return TunerNotifier(audioService, ref);
});
