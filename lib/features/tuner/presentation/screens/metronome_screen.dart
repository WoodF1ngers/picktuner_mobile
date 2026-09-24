import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/metronome_provider.dart';
import '../providers/theme_provider.dart';

class MetronomeScreen extends ConsumerWidget {
  const MetronomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(metronomeProvider);
    final notifier = ref.read(metronomeProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF161D1F);
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF464554);
    final primaryColor = isDark ? AppColors.darkPrimary : const Color(0xFF6C5CE7);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkNeutralBackground : const Color(0xFFF4FAFD),
      body: SafeArea(
        // Reemplazamos SingleChildScrollView + Column por ListView
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 12.0,
            bottom: 100.0,
          ),
          children: [
            // Sub-header context strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSecondary : const Color(0xFF006B55),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ACOUSTIC ENGINE V2.4',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFE8EFF1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.graphic_eq,
                        size: 16,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Clásico / Beep',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Dial Visualizer Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 230,
                    height: 230,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(230, 230),
                          painter: MetronomeArcPainter(bpm: state.bpm, isDark: isDark),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${state.bpm}',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                                letterSpacing: -2,
                              ),
                            ),
                            Text(
                              'BPM',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                state.tempoMarking,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepButton('-5', () => notifier.adjustBpm(-5)),
                      const SizedBox(width: 8),
                      _buildStepButton('-1', () => notifier.adjustBpm(-1)),
                      const SizedBox(width: 12),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC7C4D7),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStepButton('+1', () => notifier.adjustBpm(1)),
                      const SizedBox(width: 8),
                      _buildStepButton('+5', () => notifier.adjustBpm(5)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botón central Play / Pause
            Center(
              child: GestureDetector(
                onTap: () => notifier.togglePlay(),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: state.isPlaying
                        ? const Color(0xFFBC4446)
                        : const Color(0xFF6757E2),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(108, 92, 231, 0.38),
                        blurRadius: 28,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    state.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card Métrica y Pulsos
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'COMPÁS / MÉTRICA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF464554),
                        ),
                      ),
                      Text(
                        'Cuarto (1/4)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4E3BC8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [2, 3, 4, 6].map((sig) {
                      final isSelected = state.timeSignature == sig;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? const Color(0xFF6757E2)
                                  : const Color(0xFFEEF5F7),
                              foregroundColor: isSelected
                                  ? Colors.white
                                  : const Color(0xFF464554),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => notifier.setTimeSignature(sig),
                            child: Text('$sig/4'),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PULSO EN VIVO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF464554),
                        ),
                      ),
                      Text(
                        '${state.currentBeat + 1} / ${state.timeSignature}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B55),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // LEDs de pulso
                  Row(
                    children: List.generate(state.timeSignature, (index) {
                      final isActive =
                          state.isPlaying && state.currentBeat == index;
                      final isAccent = index == 0;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 40,
                          decoration: BoxDecoration(
                            color: isActive
                                ? (isAccent
                                      ? const Color(0xFF6757E2)
                                      : const Color(0xFF6DFAD2))
                                : const Color(0xFFEEF5F7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? (isAccent
                                          ? Colors.white
                                          : const Color(0xFF005140))
                                    : const Color(0xFF464554),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Botones de Tap Tempo y Audio
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8EFF1),
                            foregroundColor: const Color(0xFF161D1F),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => notifier.registerTap(),
                          icon: const Icon(
                            Icons.touch_app,
                            size: 20,
                            color: Color(0xFF4E3BC8),
                          ),
                          label: const Text(
                            'TAP TEMPO',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8EFF1),
                            foregroundColor: const Color(0xFF161D1F),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => notifier.toggleMute(),
                          icon: Icon(
                            state.isMuted ? Icons.volume_off : Icons.volume_up,
                            size: 20,
                            color: state.isMuted
                                ? const Color(0xFFBA1A1A)
                                : const Color(0xFF464554),
                          ),
                          label: Text(
                            state.isMuted ? 'Mute' : 'Audio',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Advice Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF6DFAD2).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Color(0xFF006B55)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consejo de groove',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005140),
                          ),
                        ),
                        Text(
                          'Comienza a 60 BPM para dominar el cambio limpio de acordes.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF005140),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Si agregas nuevos widgets aquí más adelante, no necesitas agregar
            // ningún SizedBox extra al final; el padding inferior del ListView lo gestiona solo.
          ],
        ),
      ),
    );
  }

  Widget _buildStepButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 48,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEEF5F7),
          foregroundColor: const Color(0xFF161D1F),
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}

class MetronomeArcPainter extends CustomPainter {
  final int bpm;
  final bool isDark;

  MetronomeArcPainter({required this.bpm, this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    final primaryColor = isDark ? AppColors.darkPrimary : const Color(0xFF6757E2);
    final secondaryColor = isDark ? AppColors.darkSecondary : const Color(0xFF4029BA);
    final trackColor = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFE8EFF1);

    // Background track
    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress Arc
    final progressFraction = (bpm - 40) / (240 - 40);
    final sweepAngle = 2 * math.pi * progressFraction;

    final arcPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    // Knob dot
    final knobAngle = -math.pi / 2 + sweepAngle;
    final knobOffset = Offset(
      center.dx + radius * math.cos(knobAngle),
      center.dy + radius * math.sin(knobAngle),
    );

    final knobOuter = Paint()..color = secondaryColor;
    final knobInner = Paint()..color = isDark ? AppColors.darkTextPrimary : Colors.white;

    canvas.drawCircle(knobOffset, 7, knobOuter);
    canvas.drawCircle(knobOffset, 4, knobInner);
  }

  @override
  bool shouldRepaint(covariant MetronomeArcPainter oldDelegate) {
    return oldDelegate.bpm != bpm || oldDelegate.isDark != isDark;
  }
}
