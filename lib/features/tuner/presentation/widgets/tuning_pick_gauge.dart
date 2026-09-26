import 'package:flutter/material.dart';

class TuningPickGauge extends StatelessWidget {
  final double cents;
  final bool isTuned;
  final bool hasSignal;

  const TuningPickGauge({
    super.key,
    required this.cents,
    this.isTuned = false,
    this.hasSignal = false,
  });

  @override
  Widget build(BuildContext context) {
    const double inTuneCents = 4.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 76,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double center = width / 2;
              final double maxOffset = (width / 2) - 24;
              final double normalizedCents = cents.clamp(-50.0, 50.0) / 50.0;
              final double xPos = center + (normalizedCents * maxOffset);
              final bool showDirection =
                  hasSignal && !isTuned && cents.abs() > inTuneCents;
              final bool showInTune = hasSignal && isTuned;
              final bool needsTension = cents < -inTuneCents;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: center - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: isTuned
                          ? const Color(0xFF00B894)
                          : const Color(0x6000B894),
                    ),
                  ),

                  if (showDirection)
                    Positioned(
                      left: needsTension
                          ? (xPos - 18 - 58).clamp(0.0, width - 66)
                          : (xPos + 18).clamp(0.0, width - 66),
                      top: 34,
                      child: Text(
                        needsTension ? 'TENSAR' : 'DESTENSAR',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),

                  // La etiqueta AFINADO se coloca sobre la púa, centrada en
                  // el mismo eje que ella, para que nunca quede detrás.
                  if (showInTune)
                    Positioned(
                      left: (xPos - 48).clamp(0.0, width - 96),
                      top: 0,
                      child: Container(
                        width: 96,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F9F0),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF00B894),
                            width: 1.0,
                          ),
                        ),
                        child: const Text(
                          'AFINADO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                            color: Color(0xFF00B894),
                          ),
                        ),
                      ),
                    ),

                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 70),
                    curve: Curves.easeOutCubic,
                    left: (hasSignal ? xPos : center) - 18,
                    top: 27,
                    child: CustomPaint(
                      size: const Size(36, 42),
                      painter: GuitarPickPainter(
                        color: isTuned
                            ? const Color(0xFF00B894)
                            : const Color(0xFF6C5CE7),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 6),

        SizedBox(
          height: 16,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(13, (index) {
              final bool isCenter = index == 6;
              final bool isMajor = index % 3 == 0;

              return Container(
                width: isCenter ? 3.0 : (isMajor ? 2.0 : 1.2),
                height: isCenter ? 14 : (isMajor ? 10 : 6),
                decoration: BoxDecoration(
                  color: isCenter
                      ? const Color(0xFF00B894)
                      : (isMajor
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// Púa del indicador basada en el mismo lenguaje geométrico del isotipo
/// oficial: silueta más ancha, hombros suaves y cinco líneas verticales.
class GuitarPickPainter extends CustomPainter {
  final Color color;

  GuitarPickPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final rect = Offset.zero & size;

    final Path pickPath = Path()
      ..moveTo(w * 0.50, h * 0.012)
      ..cubicTo(w * 0.76, h * 0.012, w * 0.96, h * 0.085, w * 0.985, h * 0.245)
      ..cubicTo(w * 1.01, h * 0.435, w * 0.91, h * 0.68, w * 0.72, h * 0.865)
      ..cubicTo(w * 0.63, h * 0.95, w * 0.55, h * 0.99, w * 0.50, h * 0.998)
      ..cubicTo(w * 0.45, h * 0.99, w * 0.37, h * 0.95, w * 0.28, h * 0.865)
      ..cubicTo(w * 0.09, h * 0.68, w * -0.01, h * 0.435, w * 0.015, h * 0.245)
      ..cubicTo(w * 0.04, h * 0.085, w * 0.24, h * 0.012, w * 0.50, h * 0.012)
      ..close();

    // Sombra/glow muy sutil para conservar la presencia de la púa sin hacerla
    // pesada sobre el afinador.
    canvas.drawPath(
      pickPath,
      Paint()
        ..color = color.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(Colors.white.withValues(alpha: 0.18), color),
          color,
          Color.alphaBlend(Colors.black.withValues(alpha: 0.22), color),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawPath(pickPath, bodyPaint);

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = Colors.white.withValues(alpha: 0.28);

    canvas.drawPath(pickPath, borderPaint);

    // Las cinco líneas del isotipo, ahora también en la púa del indicador.
    final bars = <double>[0.25, 0.37, 0.50, 0.63, 0.75];
    final halfHeights = <double>[0.065, 0.140, 0.230, 0.140, 0.060];
    final centerY = h * 0.480;

    final Paint barPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.040
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.96),
          Colors.white.withValues(alpha: 0.72),
        ],
      ).createShader(rect);

    for (var i = 0; i < bars.length; i++) {
      final x = w * bars[i];
      final half = h * halfHeights[i];
      canvas.drawLine(
        Offset(x, centerY - half),
        Offset(x, centerY + half),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GuitarPickPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
