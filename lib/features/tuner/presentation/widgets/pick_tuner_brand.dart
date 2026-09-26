import 'package:flutter/material.dart';

import '../providers/theme_provider.dart';

/// Isotipo vectorial de PickTuner.
///
/// La geometría está basada en el SVG de 137.08 x 144 px proporcionado para
/// la marca. Se dibuja directamente con Canvas para no depender de un PNG.
/// La silueta exterior se ensanchó ligeramente y se simplificó a pocas curvas
/// suaves; las cinco barras interiores conservan su proporción independiente.
class PickTunerLogo extends StatelessWidget {
  const PickTunerLogo({super.key, this.size = 120});

  final double size;

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
    final w = size.width;
    final h = size.height;

    // Silueta de púa basada en el SVG 137.08 x 144.
    // Se mantiene deliberadamente más ancha que la versión anterior,
    // sin modificar la escala relativa de las barras interiores.
    final pickPath = Path()
      ..moveTo(w * 0.50, h * 0.012)
      ..cubicTo(w * 0.76, h * 0.012, w * 0.96, h * 0.085, w * 0.985, h * 0.245)
      ..cubicTo(w * 1.01, h * 0.435, w * 0.91, h * 0.68, w * 0.72, h * 0.865)
      ..cubicTo(w * 0.63, h * 0.95, w * 0.55, h * 0.99, w * 0.50, h * 0.998)
      ..cubicTo(w * 0.45, h * 0.99, w * 0.37, h * 0.95, w * 0.28, h * 0.865)
      ..cubicTo(w * 0.09, h * 0.68, w * -0.01, h * 0.435, w * 0.015, h * 0.245)
      ..cubicTo(w * 0.04, h * 0.085, w * 0.24, h * 0.012, w * 0.50, h * 0.012)
      ..close();

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.darkPrimary, AppColors.darkSecondary],
      ).createShader(rect);

    canvas.drawPath(pickPath, outline);

    // Cinco barras, manteniendo su propia proporción y sin ensancharlas con
    // la silueta exterior.
    final bars = <double>[0.31, 0.405, 0.50, 0.595, 0.69];
    final halfHeights = <double>[0.085, 0.165, 0.255, 0.165, 0.085];
    final centerY = h * 0.490;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.darkPrimary, AppColors.darkSecondary],
      ).createShader(rect);

    for (var i = 0; i < bars.length; i++) {
      final x = w * bars[i];
      final half = h * halfHeights[i];
      canvas.drawLine(
        Offset(x, centerY - half),
        Offset(x, centerY + half),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
