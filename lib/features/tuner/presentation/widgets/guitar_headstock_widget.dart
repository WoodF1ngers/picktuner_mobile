import 'package:flutter/material.dart';

import '../providers/tuner_settings_provider.dart';
import 'photo_headstock_widget.dart';

class GuitarHeadstockWidget extends StatelessWidget {
  final int activeStringNumber; // 1 (E agudo) a 6 (E grave)
  final Function(int) onSelectString;

  /// Etiquetas de las 6 cuerdas indexadas por (número de cuerda - 1), ej.
  /// stringLabels[0] = nombre de la 1ra cuerda. Si no se provee, usa la
  /// afinación estándar E A D G B E.
  final List<String>? stringLabels;

  /// Estilo de clavijero a dibujar: 3+3 (Gibson) o 6 en línea (Fender).
  final HeadstockLayout layout;

  const GuitarHeadstockWidget({
    super.key,
    required this.activeStringNumber,
    required this.onSelectString,
    this.stringLabels,
    this.layout = HeadstockLayout.threeAndThree,
  });

  String _labelFor(int stringNumber, String fallback) {
    final labels = stringLabels;
    if (labels == null || labels.length < 6) return fallback;
    return labels[stringNumber - 1];
  }

  @override
  Widget build(BuildContext context) {
    // El 3+3 ahora se renderiza sobre la FOTO real (photo_headstock_widget)
    // con el efecto de luz medido a mano — reemplaza el dibujo vectorial
    // anterior. El "6 en línea" sigue siendo vectorial hasta que tengamos
    // una foto equivalente para ese estilo.
    if (layout == HeadstockLayout.threeAndThree) {
      return PhotoHeadstockWidget(
        activeStringNumber: activeStringNumber,
        stringLabels: stringLabels,
        onSelectString: onSelectString,
      );
    }

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
                painter: InlineHeadstockPainter(
                  activeStringNumber: activeStringNumber,
                ),
              ),
            ),

            // --- INDICADORES DE NOTA EN COLUMNA (6 EN LÍNEA) ---
            // Alineados con los postes verticales del
            // InlineHeadstockPainter (_postX = 95,
            // _postYByStringIndex = [70, 110, 150, 190, 230, 270]).
            _buildNoteButton(
              label: _labelFor(1, 'E'),
              stringNum: 1,
              left: 8,
              top: 48,
            ),
            _buildNoteButton(
              label: _labelFor(2, 'B'),
              stringNum: 2,
              left: 8,
              top: 88,
            ),
            _buildNoteButton(
              label: _labelFor(3, 'G'),
              stringNum: 3,
              left: 8,
              top: 128,
            ),
            _buildNoteButton(
              label: _labelFor(4, 'D'),
              stringNum: 4,
              left: 8,
              top: 168,
            ),
            _buildNoteButton(
              label: _labelFor(5, 'A'),
              stringNum: 5,
              left: 8,
              top: 208,
            ),
            _buildNoteButton(
              label: _labelFor(6, 'E'),
              stringNum: 6,
              left: 8,
              top: 248,
            ),
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

class InlineHeadstockPainter extends CustomPainter {
  final int activeStringNumber;

  InlineHeadstockPainter({required this.activeStringNumber});

  // Mismas posiciones de cejuela/nut y diapasón que el clavijero 3+3, para
  // que el mástil no "salte" visualmente al cambiar de estilo.
  static const List<double> _nutXPositions = [131, 149, 166, 184, 201, 219];

  // Las 6 clavijas van en una sola COLUMNA vertical sobre el borde
  // izquierdo de la pala (estilo Stratocaster real), no en fila. De
  // arriba a abajo: cuerda 1 (aguda) a cuerda 6 (grave) — igual que en
  // una Fender de verdad, donde el mi agudo está más cerca de la punta.
  static const double _postX = 95;
  static const List<double> _postYByStringIndex = [
    70,
    110,
    150,
    190,
    230,
    270,
  ]; // string 1..6

  @override
  void paint(Canvas canvas, Size size) {
    // 1. MÁSTIL Y TRASTES (idéntico al estilo 3+3)
    final Rect fretboardRect = const Rect.fromLTWH(122, 308.5, 106, 161.5);
    final Paint fretboardPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2B170E), Color(0xFF201009), Color(0xFF160B06)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(fretboardRect);
    canvas.drawRect(fretboardRect, fretboardPaint);

    final Paint fretLinePaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.9)
      ..strokeWidth = 2.2;
    for (final y in [345.0, 387.0, 429.0]) {
      canvas.drawLine(Offset(122, y), Offset(228, y), fretLinePaint);
    }

    canvas.drawCircle(
      const Offset(175, 408),
      3.5,
      Paint()..color = const Color(0xFFF1F5F9).withValues(alpha: 0.95),
    );
    canvas.drawCircle(
      const Offset(175, 408),
      3.5,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // 2. DESVANECIMIENTO EN LA BASE DEL MÁSTIL
    final Rect fadeRect = const Rect.fromLTWH(115, 400, 120, 110);
    canvas.drawRect(
      fadeRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFF8FAFD).withValues(alpha: 0.0),
            const Color(0xFFF8FAFD).withValues(alpha: 0.85),
            const Color(0xFFF8FAFD),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(fadeRect),
    );

    // 3. SILUETA REAL DE STRATOCASTER: asimétrica, angosta junto a las
    // clavijas (izquierda), con el característico "cuerno" curvo que se
    // abre hacia la derecha y remata en una punta redondeada arriba.
    final Path headstockPath = Path()
      ..moveTo(122, 299) // cejuela izquierda (base del mástil)
      ..cubicTo(97, 262, 80, 220, 78, 178)
      ..cubicTo(76, 138, 80, 100, 96, 74)
      ..cubicTo(104, 60, 114, 48, 128, 40) // sube hacia la puntita superior
      ..cubicTo(140, 33, 152, 33, 160, 42) // pequeña "nariz" redondeada
      ..cubicTo(172, 55, 180, 62, 198, 70) // comienza la curva del cuerno
      ..cubicTo(228, 84, 258, 98, 270, 130) // el cuerno se abre hacia afuera
      ..cubicTo(282, 162, 278, 198, 258, 228) // la panza más ancha del cuerno
      ..cubicTo(244, 250, 236, 268, 228, 299) // vuelve a la cejuela derecha
      ..close();

    canvas.save();
    canvas.translate(0, 5);
    canvas.drawPath(
      headstockPath,
      Paint()..color = Colors.black.withValues(alpha: 0.08),
    );
    canvas.restore();

    canvas.drawPath(headstockPath, Paint()..color = const Color(0xFFF8FAFC));
    canvas.drawPath(
      headstockPath,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );

    // Madera interior (mismo path, ligeramente escalado hacia el centro)
    final Rect bounds = headstockPath.getBounds();
    final Offset center = bounds.center;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(0.94);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(
      headstockPath,
      Paint()
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
        ).createShader(bounds),
    );
    canvas.restore();

    // Logo decorativo simple (línea diagonal, evoca el logo impreso real)
    final Paint logoPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(195, 180);
    canvas.rotate(-0.55);
    canvas.drawLine(const Offset(-30, 0), const Offset(30, 0), logoPaint);
    canvas.restore();

    // 4. CEJUELA (NUT)
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

    final Paint nutSlotPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeCap = StrokeCap.round;
    const List<double> nutSlotWidths = [2.3, 2.0, 1.8, 1.6, 1.4, 1.2];
    for (int i = 0; i < 6; i++) {
      nutSlotPaint.strokeWidth = nutSlotWidths[i];
      canvas.drawLine(
        Offset(_nutXPositions[i], 299),
        Offset(_nutXPositions[i], 308.5),
        nutSlotPaint,
      );
    }

    // 5. CLAVIJAS EN COLUMNA (todas sobre el mismo borde, estilo Fender)
    _drawInlinePegs(canvas);

    // 6. CUERDAS
    _drawInlineStrings(canvas);
  }

  void _drawInlinePegs(Canvas canvas) {
    final Paint shaftPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF64748B),
          Color(0xFFCBD5E1),
          Color(0xFFFFFFFF),
          Color(0xFF94A3B8),
          Color(0xFF334155),
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(const Rect.fromLTWH(0, 0, 350, 450));

    final Paint shaftBorderPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final Paint highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75);

    final Paint shadowPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (int str = 1; str <= 6; str++) {
      final double y = _postYByStringIndex[str - 1];
      const double x = _postX;
      final bool isActive = str == activeStringNumber;

      // Eje cilíndrico sobresaliendo hacia la IZQUIERDA (todas las clavijas
      // de una Fender inline apuntan hacia el mismo borde de la pala).
      final Rect shaftRect = Rect.fromLTWH(x - 26, y - 2.75, 15, 5.5);
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
        Rect.fromCenter(center: Offset(x, y), width: 23, height: 26),
        shadowPaint,
      );
      canvas.restore();

      // Palomilla cromada (o violeta si es la cuerda activa)
      final Paint pegEarPaint = Paint()
        ..shader =
            LinearGradient(
              colors: isActive
                  ? const [
                      Color(0xFFE4DFFF),
                      Color(0xFFB3A6FF),
                      Color(0xFF6C5CE7),
                      Color(0xFF4E3BC8),
                      Color(0xFF2A1F7A),
                    ]
                  : const [
                      Color(0xFFFFFFFF),
                      Color(0xFFE2E8F0),
                      Color(0xFF94A3B8),
                      Color(0xFF64748B),
                      Color(0xFF1E293B),
                    ],
              stops: const [0.0, 0.25, 0.55, 0.8, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(
              Rect.fromCenter(center: Offset(x, y), width: 23, height: 26),
            );

      final Path pegPath = Path()
        ..addOval(Rect.fromCenter(center: Offset(x, y), width: 23, height: 26));
      canvas.drawPath(pegPath, pegEarPaint);
      canvas.drawPath(
        pegPath,
        Paint()
          ..color = const Color(0xFF64748B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );

      canvas.drawOval(
        Rect.fromCenter(center: Offset(x - 2, y - 5), width: 8, height: 4.5),
        highlightPaint,
      );

      if (isActive) {
        canvas.drawCircle(
          Offset(x, y),
          14,
          Paint()..color = const Color(0xFF6C5CE7).withValues(alpha: 0.25),
        );
      }
    }
  }

  void _drawInlineStrings(Canvas canvas) {
    const List<double> widths = [
      1.1,
      1.4,
      1.7,
      1.9,
      2.3,
      2.6,
    ]; // por cuerda 1..6

    for (int str = 1; str <= 6; str++) {
      final Offset post = Offset(_postX, _postYByStringIndex[str - 1]);
      final Offset nut = Offset(_nutXPositions[str - 1], 299);
      final Offset end = Offset(_nutXPositions[str - 1], 470);
      final double width = widths[str - 1];
      final bool isActive = str == activeStringNumber;

      if (isActive) {
        final Paint glowPaint = Paint()
          ..color = const Color(0xFF6C5CE7).withValues(alpha: 0.8)
          ..strokeWidth = width + 5
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawLine(post, nut, glowPaint);
        canvas.drawLine(nut, end, glowPaint);

        final Paint activePaint = Paint()
          ..color = const Color(0xFF6C5CE7)
          ..strokeWidth = width + 0.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(post, nut, activePaint);
        canvas.drawLine(nut, end, activePaint);

        final Paint corePaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(post, nut, corePaint);
        canvas.drawLine(nut, end, corePaint);
      } else {
        final Paint inactivePaint = Paint()
          ..color = const Color(0xFFB5C2CE)
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(post, nut, inactivePaint);
        canvas.drawLine(nut, end, inactivePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant InlineHeadstockPainter oldDelegate) {
    return oldDelegate.activeStringNumber != activeStringNumber;
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

    // 4. SILUETA Y MADERA DE LA PALA (forma de "corona" simétrica, igual a
    // las cabezas acústicas clásicas tipo Paramount/Gretsch — NO la
    // silueta "libro abierto" tipo Gibson que tenía antes).
    final Path headstockPath = Path()
      ..moveTo(122, 299) // cejuela izquierda
      ..cubicTo(95, 260, 78, 210, 76, 160)
      ..cubicTo(75, 120, 85, 85, 112, 63)
      ..cubicTo(128, 50, 148, 58, 160, 47) // punta izquierda de la corona
      ..cubicTo(166, 41, 172, 49, 175, 54) // hendidura central
      ..cubicTo(178, 49, 184, 41, 190, 47) // punta derecha de la corona
      ..cubicTo(202, 58, 222, 50, 238, 63)
      ..cubicTo(265, 85, 275, 120, 274, 160)
      ..cubicTo(272, 210, 255, 260, 228, 299) // cejuela derecha
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

    // Madera interior: mismo path, ligeramente escalado hacia el centro
    // (deja ver el borde marfil alrededor), igual color de madera clara
    // que ya usaba la app.
    final Rect hsRect = headstockPath.getBounds();
    final Offset hsCenter = hsRect.center;
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

    canvas.save();
    canvas.translate(hsCenter.dx, hsCenter.dy);
    canvas.scale(0.95);
    canvas.translate(-hsCenter.dx, -hsCenter.dy);
    canvas.drawPath(headstockPath, woodPaint);
    canvas.restore();

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
