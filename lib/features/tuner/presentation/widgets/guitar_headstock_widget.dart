import 'package:flutter/material.dart';

import '../providers/tuner_settings_provider.dart';
import 'photo_headstock_widget.dart';

class GuitarHeadstockWidget extends StatelessWidget {
  final int activeStringNumber; // 1 (E agudo) a 6 (E grave)
  final Function(int) onSelectString;
  final List<String>? stringLabels;
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
    if (layout == HeadstockLayout.threeAndThree) {
      return PhotoHeadstockWidget(
        activeStringNumber: activeStringNumber,
        stringLabels: stringLabels,
        onSelectString: onSelectString,
      );
    }

    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: 350,
        height: 470,
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
            _buildNoteButton(
              label: _labelFor(1, 'E'),
              stringNum: 1,
              left: 12,
              top: 48,
            ),
            _buildNoteButton(
              label: _labelFor(2, 'B'),
              stringNum: 2,
              left: 12,
              top: 88,
            ),
            _buildNoteButton(
              label: _labelFor(3, 'G'),
              stringNum: 3,
              left: 12,
              top: 128,
            ),
            _buildNoteButton(
              label: _labelFor(4, 'D'),
              stringNum: 4,
              left: 12,
              top: 168,
            ),
            _buildNoteButton(
              label: _labelFor(5, 'A'),
              stringNum: 5,
              left: 12,
              top: 208,
            ),
            _buildNoteButton(
              label: _labelFor(6, 'E'),
              stringNum: 6,
              left: 12,
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
        behavior: HitTestBehavior.opaque,
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

  static const List<double> _nutXPositions = [131, 149, 166, 184, 201, 219];
  static const double _postX = 95;
  static const List<double> _postYByStringIndex = [70, 110, 150, 190, 230, 270];

  @override
  void paint(Canvas canvas, Size size) {
    // 1. MÁSTIL Y TRASTES
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
    final Rect fadeRect = const Rect.fromLTWH(115, 400, 120, 70);
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

    // 3. SILUETA STRATOCASTER
    final Path headstockPath = Path()
      ..moveTo(122, 299)
      ..cubicTo(97, 262, 80, 220, 78, 178)
      ..cubicTo(76, 138, 80, 100, 96, 74)
      ..cubicTo(104, 60, 114, 48, 128, 40)
      ..cubicTo(140, 33, 152, 33, 160, 42)
      ..cubicTo(172, 55, 180, 62, 198, 70)
      ..cubicTo(228, 84, 258, 98, 270, 130)
      ..cubicTo(282, 162, 278, 198, 258, 228)
      ..cubicTo(244, 250, 236, 268, 228, 299)
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

    final Paint logoPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(195, 180);
    canvas.rotate(-0.55);
    canvas.drawLine(const Offset(-30, 0), const Offset(30, 0), logoPaint);
    canvas.restore();

    // 4. CEJUELA
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

    // 5. CLAVIJAS
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
      ).createShader(const Rect.fromLTWH(0, 0, 350, 470));

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

      final Rect shaftRect = Rect.fromLTWH(x - 26, y - 2.75, 15, 5.5);
      final RRect shaftRRect = RRect.fromRectAndRadius(
        shaftRect,
        const Radius.circular(1.5),
      );
      canvas.drawRRect(shaftRRect, shaftPaint);
      canvas.drawRRect(shaftRRect, shaftBorderPaint);

      canvas.save();
      canvas.translate(0, 3);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 23, height: 26),
        shadowPaint,
      );
      canvas.restore();

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
    const List<double> widths = [1.1, 1.4, 1.7, 1.9, 2.3, 2.6];

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
