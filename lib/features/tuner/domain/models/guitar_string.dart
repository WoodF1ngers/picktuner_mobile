// lib/features/tuner/domain/models/guitar_string.dart
class GuitarString {
  final int number; // 1 a 6
  final String noteName; // p. ej. "A"
  final String noteNameSpanish; // p. ej. "La"
  final String octaveNotation; // p. ej. "A₂"
  final double targetFrequency; // p. ej. 110.00
  final bool isLeft; // true para D, A, E; false para G, B, E

  const GuitarString({
    required this.number,
    required this.noteName,
    required this.noteNameSpanish,
    required this.octaveNotation,
    required this.targetFrequency,
    required this.isLeft,
  });
}
