import 'models/chord_models.dart';

/// Banco de acordes con digitaciones estándar y verificadas.
///
/// No incluye todas las combinaciones de raíz x calidad: solo se agregan
/// acordes con una digitación real y conocida (posición abierta o cejilla
/// estándar). Es preferible mostrar "no disponible" a inventar una
/// digitación incorrecta — en música eso induce a error a quien practica.
class ChordDatabase {
  ChordDatabase._();

  // Utiliza instancias constantes reales:
  static const _s = StringPosition.muted();
  static const _o = StringPosition.open();

  static final Map<String, ChordEntry> _entries = {
    // ---------------------------------------------------------------
    // MAYORES
    // ---------------------------------------------------------------
    'C|major': const ChordEntry(
      rootNote: 'C',
      quality: ChordQuality.major,
      intervalsLabel: 'C • E • G (Tónica • 3ra M • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _s,
            StringPosition.fretted(3, 3),
            StringPosition.fretted(2, 2),
            _o,
            StringPosition.fretted(1, 1),
            _o,
          ],
        ),
      ],
    ),
    'D|major': const ChordEntry(
      rootNote: 'D',
      quality: ChordQuality.major,
      intervalsLabel: 'D • F# • A (Tónica • 3ra M • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _s,
            _s,
            _o,
            StringPosition.fretted(2, 1),
            StringPosition.fretted(3, 3),
            StringPosition.fretted(2, 2),
          ],
        ),
      ],
    ),
    'E|major': const ChordEntry(
      rootNote: 'E',
      quality: ChordQuality.major,
      intervalsLabel: 'E • G# • B (Tónica • 3ra M • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _o,
            StringPosition.fretted(2, 2),
            StringPosition.fretted(2, 3),
            StringPosition.fretted(1, 1),
            _o,
            _o,
          ],
        ),
      ],
    ),
    'G|major': const ChordEntry(
      rootNote: 'G',
      quality: ChordQuality.major,
      intervalsLabel: 'G • B • D (Tónica • 3ra M • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            StringPosition.fretted(3, 2),
            StringPosition.fretted(2, 1),
            _o,
            _o,
            _o,
            StringPosition.fretted(3, 3),
          ],
        ),
      ],
    ),
    'A|major': const ChordEntry(
      rootNote: 'A',
      quality: ChordQuality.major,
      intervalsLabel: 'A • C# • E (Tónica • 3ra M • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _s,
            _o,
            StringPosition.fretted(2, 1),
            StringPosition.fretted(2, 2),
            StringPosition.fretted(2, 3),
            _o,
          ],
        ),
      ],
    ),
    'F|major': const ChordEntry(
      rootNote: 'F',
      quality: ChordQuality.major,
      intervalsLabel: 'F • A • C (Tónica • 3ra M • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Cejilla (forma E)',
          startFret: 1,
          strings: [
            StringPosition.fretted(1, 1),
            StringPosition.fretted(3, 3),
            StringPosition.fretted(3, 4),
            StringPosition.fretted(2, 2),
            StringPosition.fretted(1, 1),
            StringPosition.fretted(1, 1),
          ],
        ),
      ],
    ),
    'B|major': const ChordEntry(
      rootNote: 'B',
      quality: ChordQuality.major,
      intervalsLabel: 'B • D# • F# (Tónica • 3ra M • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Cejilla (forma A)',
          startFret: 2,
          strings: [
            _s,
            StringPosition.fretted(2, 1),
            StringPosition.fretted(4, 3),
            StringPosition.fretted(4, 4),
            StringPosition.fretted(4, 4),
            StringPosition.fretted(2, 1),
          ],
        ),
      ],
    ),

    // ---------------------------------------------------------------
    // MENORES
    // ---------------------------------------------------------------
    'A|minor': const ChordEntry(
      rootNote: 'A',
      quality: ChordQuality.minor,
      intervalsLabel: 'A • C • E (Tónica • 3ra m • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _s,
            _o,
            StringPosition.fretted(2, 2),
            StringPosition.fretted(2, 3),
            StringPosition.fretted(1, 1),
            _o,
          ],
        ),
      ],
    ),
    'D|minor': const ChordEntry(
      rootNote: 'D',
      quality: ChordQuality.minor,
      intervalsLabel: 'D • F • A (Tónica • 3ra m • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _s,
            _s,
            _o,
            StringPosition.fretted(2, 2),
            StringPosition.fretted(3, 3),
            StringPosition.fretted(1, 1),
          ],
        ),
      ],
    ),
    'E|minor': const ChordEntry(
      rootNote: 'E',
      quality: ChordQuality.minor,
      intervalsLabel: 'E • G • B (Tónica • 3ra m • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _o,
            StringPosition.fretted(2, 2),
            StringPosition.fretted(2, 3),
            _o,
            _o,
            _o,
          ],
        ),
      ],
    ),
    'C|minor': const ChordEntry(
      rootNote: 'C',
      quality: ChordQuality.minor,
      intervalsLabel: 'C • D# • G (Tónica • 3ra m • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Cejilla (forma Am)',
          startFret: 3,
          strings: [
            _s,
            StringPosition.fretted(3, 1),
            StringPosition.fretted(5, 3),
            StringPosition.fretted(5, 4),
            StringPosition.fretted(4, 2),
            StringPosition.fretted(3, 1),
          ],
        ),
      ],
    ),
    'G|minor': const ChordEntry(
      rootNote: 'G',
      quality: ChordQuality.minor,
      intervalsLabel: 'G • A# • D (Tónica • 3ra m • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Cejilla (forma Em)',
          startFret: 3,
          strings: [
            StringPosition.fretted(3, 1),
            StringPosition.fretted(5, 3),
            StringPosition.fretted(5, 4),
            StringPosition.fretted(3, 1),
            StringPosition.fretted(3, 1),
            StringPosition.fretted(3, 1),
          ],
        ),
      ],
    ),
    'B|minor': const ChordEntry(
      rootNote: 'B',
      quality: ChordQuality.minor,
      intervalsLabel: 'B • D • F# (Tónica • 3ra m • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Cejilla (forma Am)',
          startFret: 2,
          strings: [
            _s,
            StringPosition.fretted(2, 1),
            StringPosition.fretted(4, 3),
            StringPosition.fretted(4, 4),
            StringPosition.fretted(3, 2),
            StringPosition.fretted(2, 1),
          ],
        ),
      ],
    ),

    // ---------------------------------------------------------------
    // DOMINANTES 7
    // ---------------------------------------------------------------
    'G|dominant7': const ChordEntry(
      rootNote: 'G',
      quality: ChordQuality.dominant7,
      intervalsLabel: 'G • B • D • F (Tónica • 3ra M • 5ta J • 7ma m)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            StringPosition.fretted(3, 3),
            StringPosition.fretted(2, 2),
            _o,
            _o,
            _o,
            StringPosition.fretted(1, 1),
          ],
        ),
      ],
    ),
    'C|dominant7': const ChordEntry(
      rootNote: 'C',
      quality: ChordQuality.dominant7,
      intervalsLabel: 'C • E • G • A# (Tónica • 3ra M • 5ta J • 7ma m)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _s,
            StringPosition.fretted(3, 3),
            StringPosition.fretted(2, 2),
            StringPosition.fretted(3, 4),
            StringPosition.fretted(1, 1),
            _o,
          ],
        ),
      ],
    ),
    'D|dominant7': const ChordEntry(
      rootNote: 'D',
      quality: ChordQuality.dominant7,
      intervalsLabel: 'D • F# • A • C (Tónica • 3ra M • 5ta J • 7ma m)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _s,
            _s,
            _o,
            StringPosition.fretted(2, 3),
            StringPosition.fretted(1, 1),
            StringPosition.fretted(2, 2),
          ],
        ),
      ],
    ),
    'E|dominant7': const ChordEntry(
      rootNote: 'E',
      quality: ChordQuality.dominant7,
      intervalsLabel: 'E • G# • B • D (Tónica • 3ra M • 5ta J • 7ma m)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _o,
            StringPosition.fretted(2, 2),
            _o,
            StringPosition.fretted(1, 1),
            _o,
            _o,
          ],
        ),
      ],
    ),
    'A|dominant7': const ChordEntry(
      rootNote: 'A',
      quality: ChordQuality.dominant7,
      intervalsLabel: 'A • C# • E • G (Tónica • 3ra M • 5ta J • 7ma m)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _s,
            _o,
            StringPosition.fretted(2, 2),
            _o,
            StringPosition.fretted(2, 3),
            _o,
          ],
        ),
      ],
    ),
    'B|dominant7': const ChordEntry(
      rootNote: 'B',
      quality: ChordQuality.dominant7,
      intervalsLabel: 'B • D# • F# • A (Tónica • 3ra M • 5ta J • 7ma m)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _s,
            StringPosition.fretted(2, 2),
            StringPosition.fretted(1, 1),
            StringPosition.fretted(2, 3),
            _o,
            StringPosition.fretted(2, 4),
          ],
        ),
      ],
    ),

    // ---------------------------------------------------------------
    // MENOR 7
    // ---------------------------------------------------------------
    'A|minor7': const ChordEntry(
      rootNote: 'A',
      quality: ChordQuality.minor7,
      intervalsLabel: 'A • C • E • G (Tónica • 3ra m • 5ta J • 7ma m)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _s,
            _o,
            StringPosition.fretted(2, 2),
            _o,
            StringPosition.fretted(1, 1),
            _o,
          ],
        ),
      ],
    ),
    'E|minor7': const ChordEntry(
      rootNote: 'E',
      quality: ChordQuality.minor7,
      intervalsLabel: 'E • G • B • D (Tónica • 3ra m • 5ta J • 7ma m)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [_o, StringPosition.fretted(2, 2), _o, _o, _o, _o],
        ),
      ],
    ),
    'D|minor7': const ChordEntry(
      rootNote: 'D',
      quality: ChordQuality.minor7,
      intervalsLabel: 'D • F • A • C (Tónica • 3ra m • 5ta J • 7ma m)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _s,
            _s,
            _o,
            StringPosition.fretted(2, 2),
            StringPosition.fretted(1, 1),
            StringPosition.fretted(1, 1),
          ],
        ),
      ],
    ),

    // ---------------------------------------------------------------
    // SUS4
    // ---------------------------------------------------------------
    'D|sus4': const ChordEntry(
      rootNote: 'D',
      quality: ChordQuality.sus4,
      intervalsLabel: 'D • G • A (Tónica • 4ta J • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _s,
            _s,
            _o,
            StringPosition.fretted(2, 1),
            StringPosition.fretted(3, 2),
            StringPosition.fretted(3, 3),
          ],
        ),
      ],
    ),
    'A|sus4': const ChordEntry(
      rootNote: 'A',
      quality: ChordQuality.sus4,
      intervalsLabel: 'A • D • E (Tónica • 4ta J • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _s,
            _o,
            StringPosition.fretted(2, 1),
            StringPosition.fretted(2, 2),
            StringPosition.fretted(3, 3),
            _o,
          ],
        ),
      ],
    ),
    'E|sus4': const ChordEntry(
      rootNote: 'E',
      quality: ChordQuality.sus4,
      intervalsLabel: 'E • A • B (Tónica • 4ta J • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _o,
            StringPosition.fretted(2, 2),
            StringPosition.fretted(2, 3),
            StringPosition.fretted(2, 4),
            _o,
            _o,
          ],
        ),
      ],
    ),
    'G|sus4': const ChordEntry(
      rootNote: 'G',
      quality: ChordQuality.sus4,
      intervalsLabel: 'G • C • D (Tónica • 4ta J • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            StringPosition.fretted(3, 3),
            StringPosition.fretted(3, 4),
            _o,
            _o,
            StringPosition.fretted(1, 1),
            StringPosition.fretted(3, 2),
          ],
        ),
      ],
    ),
    'C|sus4': const ChordEntry(
      rootNote: 'C',
      quality: ChordQuality.sus4,
      intervalsLabel: 'C • F • G (Tónica • 4ta J • 5ta J)',
      variations: [
        ChordVariation(
          label: 'Posición abierta',
          strings: [
            _s,
            StringPosition.fretted(3, 3),
            StringPosition.fretted(3, 4),
            _o,
            StringPosition.fretted(1, 1),
            StringPosition.fretted(1, 1),
          ],
        ),
      ],
    ),
  };

  static ChordEntry? lookup(String rootNote, ChordQuality quality) {
    return _entries['$rootNote|${quality.name}'];
  }

  static List<ChordEntry> get all => _entries.values.toList(growable: false);

  /// Busca por símbolo o nombre en español (ej. "Am", "Do menor").
  static List<ChordEntry> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return all.where((entry) {
      return entry.symbol.toLowerCase().contains(q) ||
          entry.spanishName.toLowerCase().contains(q);
    }).toList();
  }
}
