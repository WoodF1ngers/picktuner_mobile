import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';

class AppPreferencesScreen extends ConsumerWidget {
  const AppPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? AppColors.darkNeutralBackground
        : AppColors.lightNeutralBackground;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Preferencias',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // =================================================================
            // SECCIÓN: APARIENCIA (THEME SELECTOR)
            // =================================================================
            _SectionHeader(
              title: 'APARIENCIA',
              icon: Icons.palette_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tema de la aplicación',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Elige el estilo visual según tus preferencias o sincroniza con tu sistema.',
                    style: TextStyle(fontSize: 12, color: subtitleColor),
                  ),
                  const SizedBox(height: 16),

                  // Opciones de Tema (Sistema, Dark Mode, Light Mode)
                  Row(
                    children: [
                      Expanded(
                        child: _ThemeCardTile(
                          title: 'Sistema',
                          icon: Icons.brightness_auto_rounded,
                          isSelected: prefs.themeOption == AppThemeOption.system,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.setThemeOption(AppThemeOption.system);
                          },
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ThemeCardTile(
                          title: 'Oscuro',
                          subtitle: 'Precision',
                          icon: Icons.dark_mode_rounded,
                          isSelected: prefs.themeOption == AppThemeOption.dark,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.setThemeOption(AppThemeOption.dark);
                          },
                          isDark: isDark,
                          accentColor: AppColors.darkPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ThemeCardTile(
                          title: 'Claro',
                          icon: Icons.light_mode_rounded,
                          isSelected: prefs.themeOption == AppThemeOption.light,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.setThemeOption(AppThemeOption.light);
                          },
                          isDark: isDark,
                          accentColor: AppColors.lightPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Muestra de la paleta "Precision Audio Dark"
                  Row(
                    children: [
                      Icon(Icons.color_lens_outlined, size: 16, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Paleta "Precision Audio":',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                      const Spacer(),
                      _ColorDot(color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary, tooltip: 'Primary (#585AE8)'),
                      const SizedBox(width: 6),
                      _ColorDot(color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary, tooltip: 'Secondary (#07B097)'),
                      const SizedBox(width: 6),
                      _ColorDot(color: AppColors.darkTertiary, tooltip: 'Tertiary (#FF7675)'),
                      const SizedBox(width: 6),
                      _ColorDot(color: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0), tooltip: 'Neutral (#232827)'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =================================================================
            // SECCIÓN: CALIBRACIÓN Y NOTACIÓN
            // =================================================================
            _SectionHeader(
              title: 'AFINACIÓN Y AUDIO',
              icon: Icons.graphic_eq_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Calibración A4 (Hz)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Referencia A4',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${prefs.referenceA4.toStringAsFixed(1)} Hz',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ajusta la frecuencia de afinación estándar (A4 = 440 Hz por defecto).',
                          style: TextStyle(fontSize: 12, color: subtitleColor),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton(
                              onPressed: prefs.referenceA4 > 430.0
                                  ? () => notifier.setReferenceA4(prefs.referenceA4 - 0.5)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              color: primaryColor,
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: primaryColor,
                                  inactiveTrackColor: primaryColor.withValues(alpha: 0.2),
                                  thumbColor: primaryColor,
                                ),
                                child: Slider(
                                  value: prefs.referenceA4,
                                  min: 430.0,
                                  max: 450.0,
                                  divisions: 40,
                                  onChanged: (val) => notifier.setReferenceA4(val),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: prefs.referenceA4 < 450.0
                                  ? () => notifier.setReferenceA4(prefs.referenceA4 + 0.5)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Sistema de Notación
                  _PreferenceTile(
                    title: 'Sistema de Notación',
                    subtitle: prefs.notationSystem,
                    icon: Icons.music_note_rounded,
                    isDark: isDark,
                    onTap: () {
                      final next = prefs.notationSystem.startsWith('Solfeo')
                          ? 'Científica (C, D, E)'
                          : 'Solfeo (Do, Re, Mi)';
                      notifier.setNotationSystem(next);
                    },
                  ),

                  const Divider(height: 1),

                  // Mostrar Hz
                  _SwitchPreferenceTile(
                    title: 'Mostrar Frecuencia (Hz)',
                    subtitle: 'Exhibe los hercios exactos bajo la nota detectada.',
                    icon: Icons.speed_rounded,
                    value: prefs.showFrequencyHz,
                    onChanged: (val) => notifier.toggleShowFrequencyHz(val),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =================================================================
            // SECCIÓN: ALGORITMO Y SENSIBILIDAD
            // =================================================================
            _SectionHeader(
              title: 'DETECCIÓN Y ALGORITMO',
              icon: Icons.tune_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _PreferenceTile(
                    title: 'Sensibilidad del Micrófono',
                    subtitle: prefs.sensitivity,
                    icon: Icons.mic_rounded,
                    isDark: isDark,
                    onTap: () {
                      final levels = ['Baja', 'Media', 'Alta'];
                      final nextIndex = (levels.indexOf(prefs.sensitivity) + 1) % levels.length;
                      notifier.setSensitivity(levels[nextIndex]);
                    },
                  ),
                  const Divider(height: 1),
                  _PreferenceTile(
                    title: 'Tolerancia de Afinación',
                    subtitle: prefs.tolerance,
                    icon: Icons.architecture_rounded,
                    isDark: isDark,
                    onTap: () {
                      final options = [
                        'Relajado (±8c)',
                        'Estándar (±4c)',
                        'Estricto (±2c)',
                      ];
                      final nextIndex = (options.indexOf(prefs.tolerance) + 1) % options.length;
                      notifier.setTolerance(options[nextIndex]);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =================================================================
            // SECCIÓN: RETROALIMENTACIÓN Y DISPOSITIVO
            // =================================================================
            _SectionHeader(
              title: 'DISPOSITIVO Y FEEDBACK',
              icon: Icons.vibration_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _SwitchPreferenceTile(
                    title: 'Mantener Pantalla Encendida',
                    subtitle: 'Evita que el dispositivo suspenda la pantalla mientras afinas.',
                    icon: Icons.wb_sunny_outlined,
                    value: prefs.keepScreenAwake,
                    onChanged: (val) => notifier.toggleKeepScreenAwake(val),
                    isDark: isDark,
                  ),
                  const Divider(height: 1),
                  _SwitchPreferenceTile(
                    title: 'Respuesta Háptica (Vibración)',
                    subtitle: 'Vibra al afinar cuerdas y al realizar reseteo de badges.',
                    icon: Icons.vibration_rounded,
                    value: prefs.hapticFeedback,
                    onChanged: (val) => notifier.toggleHapticFeedback(val),
                    isDark: isDark,
                  ),
                  const Divider(height: 1),
                  _SwitchPreferenceTile(
                    title: 'Sonido al Afinar',
                    subtitle: 'Toca un tono auditivo breve cuando la cuerda esté afinada.',
                    icon: Icons.volume_up_outlined,
                    value: prefs.playSoundOnTune,
                    onChanged: (val) => notifier.togglePlaySoundOnTune(val),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =================================================================
            // SECCIÓN: ACERCA DE
            // =================================================================
            _SectionHeader(
              title: 'INFORMACIÓN',
              icon: Icons.info_outline_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.music_note_rounded, color: primaryColor),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PickTuner',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Versión 1.0.0 • Precision Audio Edition',
                        style: TextStyle(fontSize: 12, color: subtitleColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGETS AUXILIARES
// -----------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _ThemeCardTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color? accentColor;

  const _ThemeCardTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = accentColor ?? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary);
    final borderColor = isSelected
        ? activeColor
        : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0));
    final containerBg = isSelected
        ? activeColor.withValues(alpha: isDark ? 0.2 : 0.08)
        : (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? activeColor
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              size: 22,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? activeColor
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? activeColor : AppColors.darkSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _PreferenceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: primaryColor, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: subtitleColor),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: subtitleColor,
      ),
    );
  }
}

class _SwitchPreferenceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _SwitchPreferenceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: primaryColor, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: subtitleColor),
      ),
      activeTrackColor: primaryColor,
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final String tooltip;

  const _ColorDot({required this.color, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
      ),
    );
  }
}
