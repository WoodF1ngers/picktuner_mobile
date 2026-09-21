enum TuningStatus {
  inTune, // Afinado (dentro del rango aceptable, ej. +/- 5 cents)
  flat, // Grave / Desafinado por debajo
  sharp, // Agudo / Desafinado por encima
  undefined, // Sin señal o nota no detectada
}
