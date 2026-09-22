import 'dart:math';

/// Notas cromáticas usando sostenidos, igual convención que PitchConverter.
const List<String> kChromaticNotes = [
  'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
];

/// Nombres "bemol" usados solo para mostrar (ej. afinación Eb estándar),
/// aunque internamente todo se maneja con sostenidos.
const Map<String, String> kFlatDisplayNames = {
  'D#': 'Eb',
  'G#': 'Ab',
  'C#': 'Db',
  'F#': 'Gb',
  'A#': 'Bb',
};

/// Calcula la frecuencia exacta (Hz) de una nota en temperamento igual,
/// con A4 = [a4] como referencia. Es la operación inversa exacta de
/// `PitchConverter.getNoteFromFrequency`, así que cualquier cuerda definida
/// aquí es consistente con lo que el afinador reconoce como "afinado".
double noteFrequency(String noteName, int octave, {double a4 = 440.0}) {
  final noteIndex = kChromaticNotes.indexOf(noteName);
  final midiNumber = (octave + 1) * 12 + noteIndex;
  final semitonesFromA4 = midiNumber - 69;
  return a4 * pow(2, semitonesFromA4 / 12);
}

/// Una cuerda dentro de una afinación concreta.
class TunedString {
  final int number; // 1 (más aguda) a N (más grave)
  final String noteName; // 'E', 'D#', etc. (siempre con sostenidos)
  final int octave;
  final bool isLeft; // lado del clavijero en el diagrama 3+3

  const TunedString({
    required this.number,
    required this.noteName,
    required this.octave,
    required this.isLeft,
  });

  double get targetFrequency => noteFrequency(noteName, octave);

  String get displayName => kFlatDisplayNames[noteName] ?? noteName;

  String get label => '$displayName$octave';
}

class InstrumentTuning {
  final String id;
  final String displayLabel; // "Estándar (E A D G B E)"
  final List<TunedString> strings;

  const InstrumentTuning({
    required this.id,
    required this.displayLabel,
    required this.strings,
  });
}

class InstrumentGroup {
  final String id;
  final String name; // "Guitarra (6 Cuerdas)"
  final String subtitle; // "5 afinaciones disponibles"
  final List<InstrumentTuning> tunings;

  /// Si es `false`, el grupo se muestra en la UI (tal como en el diseño)
  /// pero seleccionar una de sus afinaciones no tiene efecto real todavía:
  /// solo existe la digitación de guitarra de 6 cuerdas por ahora.
  final bool isFunctional;

  const InstrumentGroup({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.tunings,
    this.isFunctional = false,
  });
}
