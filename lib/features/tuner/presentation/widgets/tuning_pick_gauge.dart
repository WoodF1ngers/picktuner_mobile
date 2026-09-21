import 'package:flutter/material.dart';

class TuningPickGauge extends StatelessWidget {
  final double cents; // Desviación en cents (-50.0 a +50.0)
  final bool isTuned;

  const TuningPickGauge({super.key, required this.cents, this.isTuned = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- ÁREA DE LA PÚA MÓVIL ---
        SizedBox(
          height: 48,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double center = width / 2;

              // Convertimos el rango de cents (-50 a +50) a rango horizontal en pixeles
              final double maxOffset = (width / 2) - 24;
              final double normalizedCents = (cents.clamp(-50.0, 50.0)) / 50.0;
              final double xPos = center + (normalizedCents * maxOffset);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Marcador de centro vertical
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

                  // Púa animada según el valor de 'cents'
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 70),
                    curve: Curves.easeOutCubic,
                    left: xPos - 18, // Centrar púa de ancho 36px
                    top: 2,
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

        // --- REGLA HORIZONTAL DE GRADUACIÓN ---
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

/// Vector estilizado para renderizar una púa de guitarra realista
class GuitarPickPainter extends CustomPainter {
  final Color color;

  GuitarPickPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. PATH DE PÚA ANATÓMICAMENTE REALISTA (Estilo Fender 351)
    final Path pickPath = Path()
      ..moveTo(w * 0.25, 0)
      // Borde superior suavemente curvado
      ..cubicTo(w * 0.45, h * 0.02, w * 0.55, h * 0.02, w * 0.75, 0)
      // Hombro derecho amplio
      ..cubicTo(w * 0.95, h * 0.02, w, h * 0.22, w, h * 0.38)
      // Curva descendente hacia la punta
      ..cubicTo(w * 1.0, h * 0.62, w * 0.68, h * 0.91, w * 0.54, h * 0.98)
      // Punta redondeada (evita el ángulo en 'V' recto)
      ..cubicTo(w * 0.52, h * 0.995, w * 0.48, h * 0.995, w * 0.46, h * 0.98)
      // Curva ascendente por el lado izquierdo
      ..cubicTo(w * 0.32, h * 0.91, 0, h * 0.62, 0, h * 0.38)
      // Hombro izquierdo amplio
      ..cubicTo(0, h * 0.22, w * 0.05, h * 0.02, w * 0.25, 0)
      ..close();

    // 2. RESPLANDOR Y SOMBRA PROYECTADA (Drop Shadow)
    canvas.drawPath(
      pickPath,
      Paint()
        ..color = color.withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // 3. GRADIENTE DE VOLUMEN 3D (Efecto biselado/curvo)
    final Paint bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.4), // Punto de luz descentrado
        radius: 0.85,
        colors: [
          // Iluminación central levemente más clara
          Color.alphaBlend(Colors.white.withValues(alpha: 0.25), color),
          color,
          // Sombra de borde levemente más oscura
          Color.alphaBlend(Colors.black.withValues(alpha: 0.35), color),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(pickPath, bodyPaint);

    // 4. BISLE DE BORDE PULIDO (Stroke sutil)
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.25);

    canvas.drawPath(pickPath, borderPaint);

    // 5. REFLEJO ESPECULAR / BRILLO EN EL HOMBRO IZQUIERDO
    final Path highlightPath = Path()
      ..moveTo(w * 0.15, h * 0.08)
      ..cubicTo(w * 0.35, h * 0.05, w * 0.55, h * 0.05, w * 0.70, h * 0.08)
      ..cubicTo(w * 0.45, h * 0.14, w * 0.25, h * 0.16, w * 0.15, h * 0.08)
      ..close();

    canvas.drawPath(
      highlightPath,
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );

    // 6. TEXTO / LOGO EN EL CENTRO
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.5,
      shadows: [
        Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2),
      ],
    );

    final textSpan = const TextSpan(text: 'PT', style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    // Posicionamiento centrado en la zona superior
    textPainter.paint(
      canvas,
      Offset((w - textPainter.width) / 2, (h - textPainter.height) / 2.7),
    );
  }

  @override
  bool shouldRepaint(covariant GuitarPickPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
