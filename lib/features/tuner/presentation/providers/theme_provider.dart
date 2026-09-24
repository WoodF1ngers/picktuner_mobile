import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeOption {
  system,
  dark,
  light,
}

class AppPreferencesState {
  final AppThemeOption themeOption;
  final double referenceA4;
  final bool keepScreenAwake;
  final bool hapticFeedback;
  final bool playSoundOnTune;
  final String notationSystem; // 'Solfeo (Do, Re, Mi)' | 'Científica (C, D, E)'
  final String sensitivity; // 'Baja', 'Media', 'Alta'
  final String tolerance; // 'Relajado (±8c)', 'Estándar (±4c)', 'Estricto (±2c)'
  final bool showFrequencyHz;

  const AppPreferencesState({
    this.themeOption = AppThemeOption.system,
    this.referenceA4 = 440.0,
    this.keepScreenAwake = true,
    this.hapticFeedback = true,
    this.playSoundOnTune = false,
    this.notationSystem = 'Solfeo (Do, Re, Mi)',
    this.sensitivity = 'Media',
    this.tolerance = 'Estándar (±4c)',
    this.showFrequencyHz = true,
  });

  ThemeMode get themeMode {
    switch (themeOption) {
      case AppThemeOption.dark:
        return ThemeMode.dark;
      case AppThemeOption.light:
        return ThemeMode.light;
      case AppThemeOption.system:
        return ThemeMode.system;
    }
  }

  AppPreferencesState copyWith({
    AppThemeOption? themeOption,
    double? referenceA4,
    bool? keepScreenAwake,
    bool? hapticFeedback,
    bool? playSoundOnTune,
    String? notationSystem,
    String? sensitivity,
    String? tolerance,
    bool? showFrequencyHz,
  }) {
    return AppPreferencesState(
      themeOption: themeOption ?? this.themeOption,
      referenceA4: referenceA4 ?? this.referenceA4,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      playSoundOnTune: playSoundOnTune ?? this.playSoundOnTune,
      notationSystem: notationSystem ?? this.notationSystem,
      sensitivity: sensitivity ?? this.sensitivity,
      tolerance: tolerance ?? this.tolerance,
      showFrequencyHz: showFrequencyHz ?? this.showFrequencyHz,
    );
  }
}

class AppPreferencesNotifier extends StateNotifier<AppPreferencesState> {
  AppPreferencesNotifier() : super(const AppPreferencesState());

  void setThemeOption(AppThemeOption option) {
    state = state.copyWith(themeOption: option);
  }

  void setReferenceA4(double hz) {
    state = state.copyWith(referenceA4: hz);
  }

  void toggleKeepScreenAwake(bool value) {
    state = state.copyWith(keepScreenAwake: value);
  }

  void toggleHapticFeedback(bool value) {
    state = state.copyWith(hapticFeedback: value);
  }

  void togglePlaySoundOnTune(bool value) {
    state = state.copyWith(playSoundOnTune: value);
  }

  void setNotationSystem(String notation) {
    state = state.copyWith(notationSystem: notation);
  }

  void setSensitivity(String level) {
    state = state.copyWith(sensitivity: level);
  }

  void setTolerance(String level) {
    state = state.copyWith(tolerance: level);
  }

  void toggleShowFrequencyHz(bool value) {
    state = state.copyWith(showFrequencyHz: value);
  }
}

final preferencesProvider =
    StateNotifierProvider<AppPreferencesNotifier, AppPreferencesState>((ref) {
  return AppPreferencesNotifier();
});

/// Definición de paletas de color según "Precision Audio Dark"
class AppColors {
  AppColors._();

  // Precision Audio Dark Palette
  static const Color darkPrimary = Color(0xFF585AE8);
  static const Color darkSecondary = Color(0xFF07B097);
  static const Color darkTertiary = Color(0xFFFF7675);
  static const Color darkNeutralBackground = Color(0xFF141716);
  static const Color darkBackground = Color(0xFF141716);
  static const Color darkSurface = Color(0xFF232827);
  static const Color darkSurfaceVariant = Color(0xFF2D3332);
  static const Color darkTextPrimary = Color(0xFFE8ECEB);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Precision Audio Light Palette
  static const Color lightPrimary = Color(0xFF6C5CE7);
  static const Color lightSecondary = Color(0xFF00B894);
  static const Color lightTertiary = Color(0xFFFF7675);
  static const Color lightNeutralBackground = Color(0xFFF4F7FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
}
