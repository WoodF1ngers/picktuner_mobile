import 'package:flutter/material.dart';

class GuitarHeadstockWidget extends StatelessWidget {
  final int activeStringNumber; // 1 (E agudo) a 6 (E grave)
  final Function(int) onSelectString;

  const GuitarHeadstockWidget({
    super.key,
    required this.activeStringNumber,
    required this.onSelectString,
  });

  @override
  Widget build(BuildContext context) {
    // Proporciones fijas del ViewBox SVG 350x470
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 350,
        height: 450,
        child: Stack(
          children: [
            // --- VECTOR GRAPHIC (PALA + CLAVIJAS + MÁSTIL) ---
            Positioned.fill(
              child: CustomPaint(
                painter: AcousticHeadstockPainter(
                  activeStringNumber: activeStringNumber,
                ),
              ),
            ),

            // --- INDICADORES DE NOTA (IZQUIERDA) ---
            // D (4ª Cuerda) -> Alineado a clavija superior (y = 108)
            _buildNoteButton(label: 'D', stringNum: 4, left: 12, top: 86),
            // A (5ª Cuerda) -> Alineado a clavija media (y = 174)
            _buildNoteButton(label: 'A', stringNum: 5, left: 12, top: 152),
            // E (6ª Cuerda) -> Alineado a clavija inferior (y = 240)
            _buildNoteButton(label: 'E', stringNum: 6, left: 12, top: 218),

            // --- INDICADORES DE NOTA (DERECHA) ---
            // G (3ª Cuerda) -> Alineado a clavija superior (y = 108)
            _buildNoteButton(label: 'G', stringNum: 3, right: 12, top: 86),
            // B (2ª Cuerda) -> Alineado a clavija media (y = 174)
            _buildNoteButton(label: 'B', stringNum: 2, right: 12, top: 152),
            // E (1ª Cuerda) -> Alineado a clavija inferior (y = 240)
            _buildNoteButton(label: 'E', stringNum: 1, right: 12, top: 218),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteButton({
    required String label,
    required int stringNum,
    double? left,
    double? right,
    required double top,
  }) {
    final bool isActive = stringNum == activeStringNumber;

    return Positioned(
      left: left,
      right: right,
      top: top,
      child: GestureDetector(
        onTap: () => onSelectString(stringNum),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF6C5CE7) : Colors.white,
            border: Border.all(
              color: isActive ? Colors.white : const Color(0xFFE2E8F0),
              width: isActive ? 2.5 : 1.0,
            ),
            boxShadow: [
              if (isActive) ...[
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.45),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ] else ...[
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isActive ? Colors.white : const Color(0xFF334155),
                ),
              ),
              if (isActive)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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

class AcousticHeadstockPainter extends CustomPainter {
  final int activeStringNumber;

  AcousticHeadstockPainter({required this.activeStringNumber});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. DIBUJO DE MÁSTIL Y TRASTES (FRETBOARD)
    final Rect fretboardRect = const Rect.fromLTWH(122, 308.5, 106, 161.5);
    final Paint fretboardPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2B170E), Color(0xFF201009), Color(0xFF160B06)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(fretboardRect);

    canvas.drawRect(fretboardRect, fretboardPaint);

    // Trastes horizontales
    final Paint fretLinePaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.9)
      ..strokeWidth = 2.2;

    canvas.drawLine(
      const Offset(122, 345),
      const Offset(228, 345),
      fretLinePaint,
    );
    canvas.drawLine(
      const Offset(122, 387),
      const Offset(228, 387),
      fretLinePaint,
    );
    canvas.drawLine(
      const Offset(122, 429),
      const Offset(228, 429),
      fretLinePaint,
    );

    // Inlay perlado en traste 3
    final Paint inlayPaint = Paint()
      ..color = const Color(0xFFF1F5F9).withValues(alpha: 0.95);
    final Paint inlayBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(const Offset(175, 408), 3.5, inlayPaint);
    canvas.drawCircle(const Offset(175, 408), 3.5, inlayBorder);

    // 2. DESVANECIMIENTO (FADE OUT) EN LA BASE DEL MÁSTIL
    final Rect fadeRect = const Rect.fromLTWH(115, 400, 120, 110);
    final Paint fadePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFF8FAFD).withValues(alpha: 0.0),
          const Color(0xFFF8FAFD).withValues(alpha: 0.85),
          const Color(0xFFF8FAFD),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(fadeRect);
    canvas.drawRect(fadeRect, fadePaint);

    // 3. PALOMILLAS Y CLAVIJAS CROMADAS (MACHINE HEADS)
    _drawMachineHeads(canvas);

    // 4. SILUETA Y MADERA DE LA PALA
    // Sombra proyectada
    final Path headstockPath = Path()
      ..moveTo(128, 56)
      ..cubicTo(141, 47, 159, 58, 175, 51)
      ..cubicTo(191, 58, 209, 47, 222, 56)
      ..cubicTo(243, 67, 247, 142, 243, 239)
      ..lineTo(228, 299)
      ..lineTo(122, 299)
      ..lineTo(107, 239)
      ..cubicTo(103, 142, 107, 67, 128, 56)
      ..close();

    canvas.save();
    canvas.translate(0, 5);
    canvas.drawPath(
      headstockPath,
      Paint()..color = Colors.black.withValues(alpha: 0.08),
    );
    canvas.restore();

    // Borde blanco marfil exterior
    canvas.drawPath(
      headstockPath,
      Paint()
        ..color = const Color(0xFFF8FAFC)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      headstockPath,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );

    // Madera interior
    final Path innerWoodPath = Path()
      ..moveTo(130, 59)
      ..cubicTo(143, 51, 159, 60, 175, 54)
      ..cubicTo(191, 60, 207, 51, 220, 59)
      ..cubicTo(239, 69, 243, 142, 239, 237)
      ..lineTo(225, 296)
      ..lineTo(125, 296)
      ..lineTo(111, 237)
      ..cubicTo(107, 142, 111, 69, 130, 59)
      ..close();

    final Rect hsRect = const Rect.fromLTWH(110, 50, 130, 250);
    final Paint woodPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF8A4822),
          Color(0xFF703314),
          Color(0xFF53220A),
          Color(0xFF381506),
        ],
        stops: [0.0, 0.25, 0.65, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(hsRect);

    canvas.drawPath(innerWoodPath, woodPaint);

    // Cover del Alma (Truss Rod Cover)
    final Path trussPath = Path()
      ..moveTo(171, 202)
      ..cubicTo(168, 181, 165, 168, 175, 163)
      ..cubicTo(185, 168, 182, 181, 179, 202)
      ..cubicTo(178, 226, 176, 235, 175, 239)
      ..cubicTo(174, 235, 172, 226, 171, 202)
      ..close();

    canvas.drawPath(trussPath, Paint()..color = const Color(0xFF1E1E24));
    canvas.drawPath(
      trussPath,
      Paint()
        ..color = const Color(0xFF2B2B36)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    canvas.drawCircle(
      const Offset(175, 235),
      1.6,
      Paint()..color = const Color(0xFFA1A1AA),
    );

    // Cejuela de Hueso (Nut)
    final RRect nutRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(122, 299, 106, 9.5),
      const Radius.circular(2),
    );
    canvas.drawRRect(nutRRect, Paint()..color = const Color(0xFFFBFBF9));
    canvas.drawRRect(
      nutRRect,
      Paint()
        ..color = const Color(0xFFD1D5DB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Ranuras de la Cejuela
    final Paint nutSlotPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeCap = StrokeCap.round;

    final List<double> nutXPositions = [131, 149, 166, 184, 201, 219];
    final List<double> nutSlotWidths = [2.3, 2.0, 1.8, 1.6, 1.4, 1.2];

    for (int i = 0; i < 6; i++) {
      nutSlotPaint.strokeWidth = nutSlotWidths[i];
      canvas.drawLine(
        Offset(nutXPositions[i], 299),
        Offset(nutXPositions[i], 308.5),
        nutSlotPaint,
      );
    }

    // 5. POSTES METÁLICOS SOBRE LA PALA
    _drawPosts(canvas);

    // 6. DIBUJO DE CUERDAS Y SUS RESPLANDORES
    _drawStrings(canvas);
  }

  void _drawMachineHeads(Canvas canvas) {
    final List<double> yPositions = [108.0, 174.0, 240.0];

    // --- GRADIENTES CROMADOS FOTORREALISTAS ---

    // 1. Gradiente metálico horizontal para el eje tubular
    final Paint shaftPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF64748B), // Sombra superior
          Color(0xFFCBD5E1),
          Color(0xFFFFFFFF), // Brillo central
          Color(0xFF94A3B8),
          Color(0xFF334155), // Sombra inferior
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(0, 0, 350, 450));

    // Borde biselado para los ejes
    final Paint shaftBorderPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    // 2. Gradiente diagonal con alto contraste para las palomillas (Peg Ears)
    final Paint pegEarPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFFFFFF), // Reflejo de luz alta
          Color(0xFFE2E8F0),
          Color(0xFF94A3B8), // Tono medio metálico
          Color(0xFF64748B),
          Color(0xFF1E293B), // Sombra de contraste
        ],
        stops: [0.0, 0.25, 0.55, 0.8, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(0, 0, 350, 450));

    final Paint pegBorderPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Brillo/Especular blanco interior
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75);

    // Dynamic Sombra proyectada por la palomilla
    final Paint shadowPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // --- DIBUJO DE CLAVIJAS IZQUIERDAS (D, A, E) ---
    for (double y in yPositions) {
      // Eje cilíndrico cromado
      final Rect shaftRect = Rect.fromLTWH(92, y - 2.75, 15, 5.5);
      final RRect shaftRRect = RRect.fromRectAndRadius(
        shaftRect,
        const Radius.circular(1.5),
      );
      canvas.drawRRect(shaftRRect, shaftPaint);
      canvas.drawRRect(shaftRRect, shaftBorderPaint);

      // Sombra de la palomilla
      canvas.save();
      canvas.translate(0, 3);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(82, y), width: 23, height: 26),
        shadowPaint,
      );
      canvas.restore();

      // Palomilla cromada (Cuerpo principal)
      final Rect pegRect = Rect.fromCenter(
        center: Offset(82, y),
        width: 23,
        height: 26,
      );
      final Path pegPath = Path()..addOval(pegRect);

      canvas.drawPath(pegPath, pegEarPaint);
      canvas.drawPath(pegPath, pegBorderPaint);

      // Reflejo especular ovalado en la esquina superior izquierda
      canvas.drawOval(
        Rect.fromCenter(center: Offset(80, y - 5), width: 8, height: 4.5),
        highlightPaint,
      );
    }

    // --- DIBUJO DE CLAVIJAS DERECHAS (G, B, E) ---
    for (double y in yPositions) {
      // Eje cilíndrico cromado
      final Rect shaftRect = Rect.fromLTWH(243, y - 2.75, 15, 5.5);
      final RRect shaftRRect = RRect.fromRectAndRadius(
        shaftRect,
        const Radius.circular(1.5),
      );
      canvas.drawRRect(shaftRRect, shaftPaint);
      canvas.drawRRect(shaftRRect, shaftBorderPaint);

      // Sombra de la palomilla
      canvas.save();
      canvas.translate(0, 3);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(268, y), width: 23, height: 26),
        shadowPaint,
      );
      canvas.restore();

      // Palomilla cromada (Cuerpo principal)
      final Rect pegRect = Rect.fromCenter(
        center: Offset(268, y),
        width: 23,
        height: 26,
      );
      final Path pegPath = Path()..addOval(pegRect);

      canvas.drawPath(pegPath, pegEarPaint);
      canvas.drawPath(pegPath, pegBorderPaint);

      // Reflejo especular ovalado en la esquina superior izquierda
      canvas.drawOval(
        Rect.fromCenter(center: Offset(270, y - 5), width: 8, height: 4.5),
        highlightPaint,
      );
    }
  }

  void _drawPosts(Canvas canvas) {
    final List<Offset> posts = [
      const Offset(132, 110), // D (4ª)
      const Offset(133, 174), // A (5ª)
      const Offset(135, 238), // E (6ª)
      const Offset(218, 110), // G (3ª)
      const Offset(217, 174), // B (2ª)
      const Offset(215, 238), // E (1ª)
    ];

    final Map<int, Offset> stringToPost = {
      4: posts[0],
      5: posts[1],
      6: posts[2],
      3: posts[3],
      2: posts[4],
      1: posts[5],
    };

    for (int str = 1; str <= 6; str++) {
      final Offset pos = stringToPost[str]!;
      final bool isActive = str == activeStringNumber;

      if (isActive) {
        canvas.drawCircle(
          pos,
          11,
          Paint()..color = const Color(0xFF6C5CE7).withValues(alpha: 0.3),
        );
      }

      canvas.drawCircle(
        pos,
        8.5,
        Paint()
          ..color = isActive
              ? const Color(0xFF6C5CE7)
              : const Color(0xFF475569),
      );
      canvas.drawCircle(pos, 6.0, Paint()..color = const Color(0xFFE2E8F0));
      canvas.drawCircle(
        pos,
        2.8,
        Paint()
          ..color = isActive
              ? const Color(0xFF6C5CE7)
              : const Color(0xFF0F172A),
      );
    }
  }

  void _drawStrings(Canvas canvas) {
    // Mapeo exacto entre cuerda -> poste (pala) -> ranura nut -> final diapasón
    final Map<int, _StringPathData> stringData = {
      6: _StringPathData(
        post: const Offset(135, 238),
        nut: const Offset(131, 299),
        end: const Offset(131, 470),
        width: 2.6,
      ),
      5: _StringPathData(
        post: const Offset(133, 174),
        nut: const Offset(149, 299),
        end: const Offset(149, 470),
        width: 2.3,
      ),
      4: _StringPathData(
        post: const Offset(132, 110),
        nut: const Offset(166, 299),
        end: const Offset(166, 470),
        width: 1.9,
      ),
      3: _StringPathData(
        post: const Offset(218, 110),
        nut: const Offset(184, 299),
        end: const Offset(184, 470),
        width: 1.7,
      ),
      2: _StringPathData(
        post: const Offset(217, 174),
        nut: const Offset(201, 299),
        end: const Offset(201, 470),
        width: 1.4,
      ),
      1: _StringPathData(
        post: const Offset(215, 238),
        nut: const Offset(219, 299),
        end: const Offset(219, 470),
        width: 1.1,
      ),
    };

    for (int str = 1; str <= 6; str++) {
      final data = stringData[str]!;
      final bool isActive = str == activeStringNumber;

      if (isActive) {
        // Resplandor Neón
        final Paint glowPaint = Paint()
          ..color = const Color(0xFF6C5CE7).withValues(alpha: 0.8)
          ..strokeWidth = data.width + 5
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawLine(data.post, data.nut, glowPaint);
        canvas.drawLine(data.nut, data.end, glowPaint);

        // Cuerda Violeta Activa
        final Paint activePaint = Paint()
          ..color = const Color(0xFF6C5CE7)
          ..strokeWidth = data.width + 0.8
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(data.post, data.nut, activePaint);
        canvas.drawLine(data.nut, data.end, activePaint);

        // Núcleo Blanco Brillante
        final Paint corePaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(data.post, data.nut, corePaint);
        canvas.drawLine(data.nut, data.end, corePaint);
      } else {
        // Cuerda plateada inactiva
        final Paint inactivePaint = Paint()
          ..color = const Color(0xFFB5C2CE)
          ..strokeWidth = data.width
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(data.post, data.nut, inactivePaint);
        canvas.drawLine(data.nut, data.end, inactivePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AcousticHeadstockPainter oldDelegate) {
    return oldDelegate.activeStringNumber != activeStringNumber;
  }
}

class _StringPathData {
  final Offset post;
  final Offset nut;
  final Offset end;
  final double width;

  _StringPathData({
    required this.post,
    required this.nut,
    required this.end,
    required this.width,
  });
}
