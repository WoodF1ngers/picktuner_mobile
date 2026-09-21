import 'tuning_status.dart';

class NoteModel {
  final String name; // Ej: "A", "E", "C#"
  final int octave; // Ej: 4
  final double targetFrequency; // Ej: 440.0 Hz
  final double currentFrequency; // Ej: 442.3 Hz
  final double centsOffset; // Desviación de -50 a +50
  final TuningStatus status;

  const NoteModel({
    required this.name,
    required this.octave,
    required this.targetFrequency,
    required this.currentFrequency,
    required this.centsOffset,
    required this.status,
  });

  String get formattedNote => '$name$octave';
}
