/// Las 12 notas cromáticas usando sostenidos (igual convención que el resto
/// de la app). El índice de cada nota en esta lista es su "altura" 0-11.
const List<String> kChromaticNotes = [
  'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
];

const Map<String, String> kNoteNamesEs = {
  'C': 'Do',
  'C#': 'Do#',
  'D': 'Re',
  'D#': 'Re#',
  'E': 'Mi',
  'F': 'Fa',
  'F#': 'Fa#',
  'G': 'Sol',
  'G#': 'Sol#',
  'A': 'La',
  'A#': 'La#',
  'B': 'Si',
};

enum ChordQuality { major, minor, dominant7, minor7, sus4, dim }

extension ChordQualityX on ChordQuality {
  /// Etiqueta corta mostrada en el selector de calidad.
  String get label {
    switch (this) {
      case ChordQuality.major:
        return 'Mayor';
      case ChordQuality.minor:
        return 'Menor';
      case ChordQuality.dominant7:
        return '7ma';
      case ChordQuality.minor7:
        return 'm7';
      case ChordQuality.sus4:
        return 'Sus4';
      case ChordQuality.dim:
        return 'Dim';
    }
  }

  /// Sufijo usado para armar el símbolo del acorde, ej. "Am", "C7", "Dsus4".
  String get symbolSuffix {
    switch (this) {
      case ChordQuality.major:
        return '';
      case ChordQuality.minor:
        return 'm';
      case ChordQuality.dominant7:
        return '7';
      case ChordQuality.minor7:
        return 'm7';
      case ChordQuality.sus4:
        return 'sus4';
      case ChordQuality.dim:
        return 'dim';
    }
  }

  /// Nombre en español, ej. "Mayor", "Menor".
  String spanishQualityName() {
    switch (this) {
      case ChordQuality.major:
        return 'Mayor';
      case ChordQuality.minor:
        return 'Menor';
      case ChordQuality.dominant7:
        return 'Dominante 7';
      case ChordQuality.minor7:
        return 'Menor 7';
      case ChordQuality.sus4:
        return 'Suspendido 4ta';
      case ChordQuality.dim:
        return 'Disminuido';
    }
  }
}

enum StringStatus { muted, open, fretted }

/// Estado de una cuerda dentro de una digitación concreta.
///
/// [fret] es el número de traste ABSOLUTO (no relativo a [ChordVariation.startFret]),
/// para que tanto el diagrama como el sintetizador de audio puedan usarlo
/// directamente sin recalcular offsets.
class StringPosition {
  final StringStatus status;
  final int fret;
  final int finger; // 1-4; 0 si no aplica (abierta o muteada)

  const StringPosition.muted()
    : status = StringStatus.muted,
      fret = 0,
      finger = 0;

  const StringPosition.open()
    : status = StringStatus.open,
      fret = 0,
      finger = 0;

  const StringPosition.fretted(this.fret, this.finger)
    : status = StringStatus.fretted;
}

/// Una digitación concreta de un acorde (puede haber varias por acorde:
/// posición abierta, cejilla forma E, forma A, etc.).
class ChordVariation {
  final String label;

  /// Primer traste visible en la ventana de 4 trastes del diagrama.
  final int startFret;

  /// 6 posiciones, de la 6ta cuerda (Mi grave) a la 1ra (mi agudo).
  final List<StringPosition> strings;

  const ChordVariation({
    required this.label,
    this.startFret = 1,
    required this.strings,
  });
}

class ChordEntry {
  final String rootNote; // 'A', 'A#', ... (usa sostenidos)
  final ChordQuality quality;
  final String intervalsLabel; // "A • C • E (Tónica • 3ra m • 5ta J)"
  final List<ChordVariation> variations;

  const ChordEntry({
    required this.rootNote,
    required this.quality,
    required this.intervalsLabel,
    required this.variations,
  });

  String get symbol => '$rootNote${quality.symbolSuffix}';

  String get spanishName =>
      '${kNoteNamesEs[rootNote] ?? rootNote} ${quality.spanishQualityName()}';
}
