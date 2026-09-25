import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../providers/theme_provider.dart';

/// Logo vectorial de PickTuner. Se dibuja en Flutter para que conserve nitidez
/// en cualquier densidad de pantalla y no dependa de una imagen rasterizada.
class PickTunerLogo extends StatelessWidget {
  final double size;

  const PickTunerLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PickTunerLogoPainter()),
    );
  }
}

class _PickTunerLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 120;

    final pickPath = Path();
    pickPath.moveTo(60 * scale, 9 * scale);
    pickPath.cubicTo(
      84 * scale,
      9 * scale,
      105 * scale,
      20 * scale,
      108 * scale,
      43 * scale,
    );
    pickPath.cubicTo(
      111 * scale,
      67 * scale,
      96 * scale,
      94 * scale,
      60 * scale,
      111 * scale,
    );
    pickPath.cubicTo(
      24 * scale,
      94 * scale,
      9 * scale,
      67 * scale,
      12 * scale,
      43 * scale,
    );
    pickPath.cubicTo(
      15 * scale,
      20 * scale,
      36 * scale,
      9 * scale,
      60 * scale,
      9 * scale,
    );
    pickPath.close();

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.darkPrimary, AppColors.darkSecondary],
      ).createShader(rect);
    canvas.drawPath(pickPath, outline);

    final glow = Paint()
      ..color = AppColors.darkSecondary.withValues(alpha: .18)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 * scale);
    canvas.drawPath(pickPath, glow);

    final barHeights = [20.0, 34.0, 49.0, 37.0, 24.0];
    final barPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5 * scale
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.darkSecondary, AppColors.darkPrimary],
      ).createShader(rect);

    const gap = 10.0;
    final total = (barHeights.length - 1) * gap;
    final startX = 60 - total / 2;
    for (int i = 0; i < barHeights.length; i++) {
      final x = (startX + i * gap) * scale;
      final half = barHeights[i] * scale / 2;
      canvas.drawLine(
        Offset(x, center.dy - half),
        Offset(x, center.dy + half),
        barPaint,
      );
    }

    // Pequeños puntos de frecuencia que refuerzan el concepto de señal.
    final dotPaint = Paint()
      ..color = AppColors.darkSecondary.withValues(alpha: .7);
    for (int i = 0; i < 3; i++) {
      final angle = -math.pi / 2 + (i - 1) * .45;
      final p =
          center + Offset(math.cos(angle), math.sin(angle)) * (43 * scale);
      canvas.drawCircle(p, 1.8 * scale, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
