import 'dart:math';

import 'models/note_model.dart';

import 'models/tuning_status.dart';

class PitchConverter {
  // Nota de referencia estándar: A4 = 440 Hz

  static const double standardA4 = 440.0;

  // Nombres de las 12 notas cromáticas

  static const List<String> _noteNames = [
    'C',

    'C#',

    'D',

    'D#',

    'E',

    'F',

    'F#',

    'G',

    'G#',

    'A',

    'A#',

    'B',
  ];

  /// Convierte una frecuencia en Hz a un modelo [NoteModel]

  static NoteModel? getNoteFromFrequency(
    double frequency, {

    double referenceA4 = standardA4,
  }) {
    if (frequency <= 0) return null;

    // Fórmula para calcular la distancia en semitonos desde A4

    final semitonesFromA4 = 12 * (log(frequency / referenceA4) / log(2));

    final roundedSemitones = semitonesFromA4.round();

    // Cálculo de la frecuencia teórica perfecta para la nota más cercana

    final targetFrequency = referenceA4 * pow(2, roundedSemitones / 12);

    // Cálculo de la desviación en cents (1 semitono = 100 cents)

    final centsDifference = 1200 * (log(frequency / targetFrequency) / log(2));

    // Índice de A4 en la escala cromática es 9 (A)

    // MIDI note number para A4 es 69

    final midiNumber = 69 + roundedSemitones;

    final noteIndex = (midiNumber % 12 + 12) % 12;

    final octave = (midiNumber / 12).floor() - 1;

    final noteName = _noteNames[noteIndex];

    // Determinar el estado de afinación (tolerancia de +- 5 cents)

    TuningStatus status;

    if (centsDifference.abs() <= 5) {
      status = TuningStatus.inTune;
    } else if (centsDifference < -5) {
      status = TuningStatus.flat;
    } else {
      status = TuningStatus.sharp;
    }

    return NoteModel(
      name: noteName,

      octave: octave,

      targetFrequency: targetFrequency,

      currentFrequency: frequency,

      centsOffset: centsDifference,

      status: status,
    );
  }
}
