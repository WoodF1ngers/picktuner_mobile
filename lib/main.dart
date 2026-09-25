import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/tuner/presentation/screens/app_startup_screen.dart';
import 'features/tuner/presentation/providers/theme_provider.dart';

//import 'features/tuner/presentation/screens/main_shell_screen.dart';

void main() {
  runApp(const ProviderScope(child: PickTunerApp()));
}

class PickTunerApp extends ConsumerWidget {
  const PickTunerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);

    return MaterialApp(
      title: 'PickTuner',
      debugShowCheckedModeBanner: false,
      themeMode: prefs.themeMode,

      // Tema Claro (Estándar por defecto)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.lightNeutralBackground,
        colorScheme: const ColorScheme.light(
          primary: AppColors.lightPrimary,
          secondary: AppColors.lightSecondary,
          tertiary: AppColors.lightTertiary,
          surface: AppColors.lightSurface,
          surfaceContainerHigh: AppColors.lightSurfaceVariant,
          onSurface: AppColors.lightTextPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
        ),
      ),

      // Tema Oscuro ("Precision Audio Dark" según la paleta del diseño)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.darkNeutralBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkPrimary,
          secondary: AppColors.darkSecondary,
          tertiary: AppColors.darkTertiary,
          surface: AppColors.darkSurface,
          surfaceContainerHigh: AppColors.darkSurfaceVariant,
          onSurface: AppColors.darkTextPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
        ),
      ),

      home: const AppStartupScreen(),
    );
  }
}
