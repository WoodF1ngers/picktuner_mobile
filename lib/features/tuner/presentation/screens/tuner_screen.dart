import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/tuning_status.dart';
import '../providers/tuner_provider.dart';
import '../widgets/photo_headstock_widget.dart';
import '../widgets/tuning_pick_gauge.dart';
import '../widgets/photo_headstock_inline_widget.dart';
import '../providers/tuner_settings_provider.dart';
import '../providers/theme_provider.dart';
import 'tuner_settings_screen.dart';
import 'app_preferences_screen.dart';

class TunerScreen extends ConsumerStatefulWidget {
  const TunerScreen({super.key});

  @override
  ConsumerState<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends ConsumerState<TunerScreen> {
  double _dragAmount = 0.0;
  bool _hasTriggeredReset = false;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tunerProvider.notifier).startListening();
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;

    if (delta > 0) {
      setState(() {
        _dragAmount = (_dragAmount + delta).clamp(0.0, 90.0);
      });
    } else if (delta < 0 && _dragAmount > 0) {
      setState(() {
        _dragAmount = (_dragAmount + delta).clamp(0.0, 90.0);
      });
    }

    if (_dragAmount >= 70.0 && !_hasTriggeredReset) {
      _hasTriggeredReset = true;
      _isResetting = true;
      HapticFeedback.mediumImpact();
      ref.read(tunerProvider.notifier).resetAllBadges();

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _dragAmount = 0.0;
            _hasTriggeredReset = false;
            _isResetting = false;
          });
        }
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!_isResetting) {
      setState(() {
        _dragAmount = 0.0;
        _hasTriggeredReset = false;
      });
    }
  }

  String _getNoteInSpanish(String? noteName) {
    if (noteName == null) return '--';
    switch (noteName) {
      case 'C':
        return 'Do';
      case 'C#':
        return 'Do#';
      case 'D':
        return 'Re';
      case 'D#':
        return 'Re#';
      case 'E':
        return 'Mi';
      case 'F':
        return 'Fa';
      case 'F#':
        return 'Fa#';
      case 'G':
        return 'Sol';
      case 'G#':
        return 'Sol#';
      case 'A':
        return 'La';
      case 'A#':
        return 'La#';
      case 'B':
        return 'Si';
      default:
        return noteName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tunerState = ref.watch(tunerProvider);
    final currentNoteModel = tunerState.currentNote;
    final tunerSettings = ref.watch(tunerSettingsProvider);
    final appliedTuning = tunerSettings.appliedTuning;
    final appliedTuningShortLabel = appliedTuning.displayLabel
        .split(' (')
        .first;
    final List<String> stringLabels = List.generate(6, (i) {
      final number = i + 1;
      final tunedString = appliedTuning.strings.firstWhere(
        (s) => s.number == number,
        orElse: () => appliedTuning.strings.first,
      );
      return tunedString.displayName;
    });

    final String displayNote = _getNoteInSpanish(currentNoteModel?.name);
    final String octaveNotation = currentNoteModel != null
        ? '${currentNoteModel.name}${currentNoteModel.octave}'
        : '--';
    final double? currentFrequency = currentNoteModel?.currentFrequency;
    final double cents = currentNoteModel?.centsOffset ?? 0.0;
    final bool isTuned = currentNoteModel?.status == TuningStatus.inTune;

    final double pullProgress = (_dragAmount / 70.0).clamp(0.0, 1.0);
    final double screenShiftY = math.pow(pullProgress, 0.8) * 22.0;

    // Paleta de colores según tema
    final bgGradient = isDark
        ? const [Color(0xFF1B1E1D), Color(0xFF141716), Color(0xFF0F1211)]
        : const [Color(0xFFFFFFFF), Color(0xFFF4F7FC), Color(0xFFE8EEF7)];
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final chipBgColor = isDark
        ? AppColors.darkSurface
        : const Color(0xFFF1F5F9);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgGradient,
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // --- ESTRUCTURA PRINCIPAL ---
              GestureDetector(
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                behavior: HitTestBehavior.translucent,
                child: AnimatedContainer(
                  duration: _dragAmount == 0
                      ? const Duration(milliseconds: 300)
                      : Duration.zero,
                  curve: Curves.easeOutBack,
                  transform: Matrix4.translationValues(0, screenShiftY, 0),
                  child: Column(
                    children: [
                      // --- ENCABEZADO ---
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: accentColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'PT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    RichText(
                                      text: TextSpan(
                                        text: 'Pick',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: textPrimary,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Tuner',
                                            style: TextStyle(
                                              color: accentColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TunerSettingsScreen(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'Guitarra 6 cuerdas',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        size: 16,
                                        color: textSecondary,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: accentColor.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          appliedTuningShortLabel,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: accentColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                // Contenedor estilizado del MODO AUTOMÁTICO
                                Container(
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                    right: 2,
                                    top: 2,
                                    bottom: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: chipBgColor.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.end,
                                        text: TextSpan(
                                          text: 'MODO\n',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w800,
                                            color: textSecondary,
                                            height: 1.1,
                                            letterSpacing: 0.5,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'AUTOM.',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: accentColor,
                                                height: 1.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Transform.scale(
                                        scale: 0.8,
                                        child: Switch.adaptive(
                                          value: tunerState.isAutoMode,
                                          activeThumbColor: Colors.white,
                                          activeTrackColor: accentColor,
                                          inactiveThumbColor: Colors.white,
                                          inactiveTrackColor: isDark
                                              ? const Color(0xFF4A5568)
                                              : const Color(0xFFCBD5E1),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          onChanged: (val) {
                                            ref
                                                .read(tunerProvider.notifier)
                                                .toggleAutoMode(val);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: Icon(
                                    Icons.settings_outlined,
                                    color: accentColor,
                                    size: 22,
                                  ),
                                  tooltip: 'Preferencias',
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AppPreferencesScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // --- ZONA DEL AFINADOR CON TRAMA DE PUNTOS ---
                      CustomPaint(
                        painter: TunerGridBackgroundPainter(isDark: isDark),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            // DETECCIÓN DE NOTA
                            Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      displayNote,
                                      style: TextStyle(
                                        fontSize: 72,
                                        fontWeight: FontWeight.w900,
                                        color: textPrimary,
                                        height: 1.0,
                                        letterSpacing: -1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      currentFrequency != null
                                          ? '$octaveNotation  •  ${currentFrequency.toStringAsFixed(2)} Hz'
                                          : '--',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (tunerState.activeStringNumber != null)
                                  Positioned(
                                    right: -80,
                                    top: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: chipBgColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${tunerState.activeStringNumber}ª cuerda',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : const Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // MEDIDOR DE PÚA
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: TuningPickGauge(
                                cents: cents,
                                isTuned: isTuned,
                                hasSignal: currentNoteModel != null,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- PALA DE LA GUITARRA EN TUNERSCREEN ---
                      Expanded(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            if (tunerSettings.headstockLayout ==
                                HeadstockLayout.inline)
                              PhotoHeadstockInlineWidget(
                                activeStringNumber:
                                    tunerState.activeStringNumber,
                                stringLabels: stringLabels,
                                tunedStrings: tunerState.tunedStrings,
                                tuningProgress: tunerState.tuningProgress,
                                onSelectString: (stringNum) {
                                  ref
                                      .read(tunerProvider.notifier)
                                      .selectString(stringNum);
                                },
                              )
                            else
                              PhotoHeadstockWidget(
                                activeStringNumber:
                                    tunerState.activeStringNumber,
                                stringLabels: stringLabels,
                                tunedStrings: tunerState.tunedStrings,
                                tuningProgress: tunerState.tuningProgress,
                                onSelectString: (stringNum) {
                                  ref
                                      .read(tunerProvider.notifier)
                                      .selectString(stringNum);
                                },
                              ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 80,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      bgGradient[0].withValues(alpha: 0.0),
                                      bgGradient.last.withValues(
                                        alpha: isDark ? 0.95 : 0.8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 55),
                    ],
                  ),
                ),
              ),

              // --- INDICADOR FLOTANTE SPINNER ---
              if (pullProgress > 0 || _isResetting)
                Positioned(
                  top: 8 + screenShiftY,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Transform.scale(
                      scale: 0.6 + (pullProgress * 0.4),
                      child: Opacity(
                        opacity: pullProgress.clamp(0.2, 1.0),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _isResetting
                              ? Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      accentColor,
                                    ),
                                  ),
                                )
                              : Transform.rotate(
                                  angle: pullProgress * math.pi * 2,
                                  child: Icon(
                                    Icons.refresh_rounded,
                                    color: accentColor,
                                    size: 24,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PAINTER DEL FONDO DE PUNTOS
// -----------------------------------------------------------------------------
class TunerGridBackgroundPainter extends CustomPainter {
  final bool isDark;

  TunerGridBackgroundPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
    final dotPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.22 : 0.12)
      ..style = PaintingStyle.fill;

    const double stepX = 28.0;
    const double stepY = 24.0;

    for (double x = stepX / 2; x < size.width; x += stepX) {
      for (double y = stepY / 2; y < size.height; y += stepY) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TunerGridBackgroundPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
