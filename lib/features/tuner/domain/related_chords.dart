import 'chord_database.dart';
import 'models/chord_models.dart';

class RelatedChord {
  final ChordEntry entry;
  final String relationLabel;

  const RelatedChord({required this.entry, required this.relationLabel});
}

/// Calcula acordes relacionados usando teoría musical básica (tono relativo,
/// IV grado, dominante V7). Solo aplica a acordes Mayor/Menor, que son la
/// base tonal de una tonalidad; para otras calidades no hay una relación
/// de tonalidad única y clara, así que se omite en vez de inventar una.
List<RelatedChord> computeRelatedChords(ChordEntry entry) {
  final int rootIndex = kChromaticNotes.indexOf(entry.rootNote);
  if (rootIndex == -1) return const [];

  String noteAt(int semitoneOffset) {
    final idx = (rootIndex + semitoneOffset) % 12;
    return kChromaticNotes[idx];
  }

  final List<({String note, ChordQuality quality, String label})> targets;

  if (entry.quality == ChordQuality.minor) {
    targets = [
      (note: noteAt(3), quality: ChordQuality.major, label: 'Relativo Mayor'),
      (note: noteAt(5), quality: ChordQuality.minor, label: '4to Grado (iv)'),
      (
        note: noteAt(7),
        quality: ChordQuality.dominant7,
        label: 'Dominante (V7)',
      ),
    ];
  } else if (entry.quality == ChordQuality.major) {
    targets = [
      (note: noteAt(9), quality: ChordQuality.minor, label: 'Relativo menor'),
      (note: noteAt(5), quality: ChordQuality.major, label: '4to Grado (IV)'),
      (
        note: noteAt(7),
        quality: ChordQuality.dominant7,
        label: 'Dominante (V7)',
      ),
    ];
  } else {
    return const [];
  }

  final List<RelatedChord> result = [];
  for (final target in targets) {
    final relatedEntry = ChordDatabase.lookup(target.note, target.quality);
    if (relatedEntry != null) {
      result.add(RelatedChord(entry: relatedEntry, relationLabel: target.label));
    }
  }
  return result;
}
