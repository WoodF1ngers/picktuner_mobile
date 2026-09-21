import 'package:flutter/material.dart';

class AppColors {
  // Fondos y Superficies
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF2C2C2C);

  // Colores Principales
  static const Color primary = Color(0xFFBB86FC);
  static const Color accent = Color(0xFF03DAC6);

  // Estados del Afinador
  static const Color inTune = Color(0xFF00E676); // Verde: Afinado
  static const Color sharp = Color(0xFFFF5252); // Rojo: Demasiado agudo / alto
  static const Color flat = Color(
    0xFFFFAB40,
  ); // Naranja/Amarillo: Demasiado grave / bajo

  // Texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textMuted = Color(0x66FFFFFF);
}
