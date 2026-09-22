import 'instrument_tuning.dart';

/// Construye la lista de 6 cuerdas para guitarra a partir de las notas
/// (de la más grave a la más aguda), asignando el lado del clavijero
/// (izquierda = cuerdas 4,5,6 / derecha = 1,2,3) igual que el diagrama
/// 3+3 ya existente en la app.
List<TunedString> _guitar6(List<(String, int)> lowToHigh) {
  // lowToHigh[0] = 6ta cuerda (más grave) ... lowToHigh[5] = 1ra (más aguda)
  return List.generate(6, (i) {
    final stringNumber = 6 - i; // i=0 -> cuerda 6, i=5 -> cuerda 1
    final (note, octave) = lowToHigh[i];
    return TunedString(
      number: stringNumber,
      noteName: note,
      octave: octave,
      isLeft: stringNumber >= 4,
    );
  });
}

class TuningDatabase {
  TuningDatabase._();

  static final InstrumentGroup guitar6 = InstrumentGroup(
    id: 'guitar6',
    name: 'Guitarra (6 Cuerdas)',
    subtitle: '5 afinaciones disponibles',
    isFunctional: true,
    tunings: [
      InstrumentTuning(
        id: 'guitar6_standard',
        displayLabel: 'Estándar (E A D G B E)',
        strings: _guitar6([
          ('E', 2),
          ('A', 2),
          ('D', 3),
          ('G', 3),
          ('B', 3),
          ('E', 4),
        ]),
      ),
      InstrumentTuning(
        id: 'guitar6_drop_d',
        displayLabel: 'Drop D (D A D G B E)',
        strings: _guitar6([
          ('D', 2),
          ('A', 2),
          ('D', 3),
          ('G', 3),
          ('B', 3),
          ('E', 4),
        ]),
      ),
      InstrumentTuning(
        id: 'guitar6_open_g',
        displayLabel: 'Open G (D G D G B D)',
        strings: _guitar6([
          ('D', 2),
          ('G', 2),
          ('D', 3),
          ('G', 3),
          ('B', 3),
          ('D', 4),
        ]),
      ),
      InstrumentTuning(
        id: 'guitar6_dadgad',
        displayLabel: 'DADGAD',
        strings: _guitar6([
          ('D', 2),
          ('A', 2),
          ('D', 3),
          ('G', 3),
          ('A', 3),
          ('D', 4),
        ]),
      ),
      InstrumentTuning(
        id: 'guitar6_half_step_down',
        displayLabel: 'Medio tono abajo (Eb Ab Db Gb Bb Eb)',
        strings: _guitar6([
          ('D#', 2), // Eb2
          ('G#', 2), // Ab2
          ('C#', 3), // Db3
          ('F#', 3), // Gb3
          ('A#', 3), // Bb3
          ('D#', 4), // Eb4
        ]),
      ),
    ],
  );

  // ---------------------------------------------------------------------
  // Los siguientes grupos se muestran en la UI (igual que en el diseño)
  // pero no son funcionales todavía: no hay digitaciones ni lógica de
  // detección para bajo, ukelele u otros instrumentos aún. Se agregan
  // como placeholders explícitos para completar en una siguiente etapa,
  // en vez de ocultarlos u omitirlos del diseño.
  // ---------------------------------------------------------------------

  static const InstrumentGroup bass = InstrumentGroup(
    id: 'bass',
    name: 'Bajo (4 & 5 Cuerdas)',
    subtitle: 'Estándar EADG, 5-String B-E-A-D-G',
    isFunctional: false,
    tunings: [
      InstrumentTuning(id: 'bass_4_standard', displayLabel: 'Estándar 4 Cuerdas (E A D G)', strings: []),
      InstrumentTuning(id: 'bass_5_standard', displayLabel: '5 Cuerdas Grave (B E A D G)', strings: []),
    ],
  );

  static const InstrumentGroup ukelele = InstrumentGroup(
    id: 'ukelele',
    name: 'Ukelele',
    subtitle: 'Soprano, Concierto (G C E A)',
    isFunctional: false,
    tunings: [
      InstrumentTuning(id: 'uke_standard', displayLabel: 'Estándar C (G4 C4 E4 A4)', strings: []),
      InstrumentTuning(id: 'uke_d_tuning', displayLabel: 'D-Tuning (A4 D4 F#4 B4)', strings: []),
    ],
  );

  static const InstrumentGroup others = InstrumentGroup(
    id: 'others',
    name: 'Otros Instrumentos',
    subtitle: 'Violín, Mandolina, Banjo',
    isFunctional: false,
    tunings: [
      InstrumentTuning(id: 'violin_standard', displayLabel: 'Violín (G D A E)', strings: []),
      InstrumentTuning(id: 'banjo5_open_g', displayLabel: 'Banjo 5C (g D G B D)', strings: []),
    ],
  );

  static List<InstrumentGroup> get all => [guitar6, bass, ukelele, others];

  static InstrumentTuning get defaultTuning => guitar6.tunings.first;
}
