import 'package:flutter/material.dart';

/// Clavijero 3+3 renderizado a partir de una foto real (PNG con fondo
/// transparente), con el efecto de "cuerda/clavija activa" dibujado como
/// una capa independiente ENCIMA de la imagen — la foto nunca se modifica.
///
/// Las coordenadas de cada clavija y de cada cuerda se extrajeron
/// directamente del archivo vectorial (Illustrator) que acompaña a la
/// foto, con cada cuerda y cada clavija ya identificada por nombre
/// (string_1..6, peg_1..6) — no son coordenadas estimadas a ojo.
/// El "punto de clavija" usado es el extremo superior de cada trazo de
/// cuerda (coincide con el centro visual de la perilla mucho mejor que
/// el bounding box de la pieza completa de la clavija, que incluye
/// también la palanca metálica lateral).
///
/// Todo el widget vive en un lienzo lógico de 1080x1920 (el tamaño real
/// de la foto/vector), escalado como una sola unidad mediante FittedBox,
/// así que las coordenadas medidas siempre caen en el lugar correcto sin
/// importar el tamaño real de pantalla.
class PhotoHeadstockWidget extends StatelessWidget {
  final int activeStringNumber; // 1 (E aguda) a 6 (E grave)
  final List<String>? stringLabels;
  final ValueChanged<int>? onSelectString;

  const PhotoHeadstockWidget({
    super.key,
    required this.activeStringNumber,
    this.stringLabels,
    this.onSelectString,
  });

  static const double _canvasWidth = 1080;
  static const double _canvasHeight = 1920;

  // Punto de "clavija" (extremo superior del trazo de cada cuerda, medido
  // sobre string_pegs.svg / headStroke2.png).
  static const Map<int, Offset> _pegPoints = {
    1: Offset(749.5, 1091.8),
    2: Offset(749.5, 741.8),
    3: Offset(766.1, 388.6),
    4: Offset(333.9, 383.0),
    5: Offset(349.3, 733.7),
    6: Offset(349.1, 1085.0),
  };

  // Punto donde cada cuerda cruza la cejuela (nut), interpolado sobre el
  // trazado real para que las 6 queden alineadas en la misma banda.
  static const Map<int, Offset> _nutPoints = {
    1: Offset(721.5, 1595),
    2: Offset(652.0, 1595),
    3: Offset(578.8, 1595),
    4: Offset(498.3, 1581.7),
    5: Offset(423.1, 1576.7),
    6: Offset(359.7, 1595),
  };

  String _labelFor(int stringNumber, String fallback) {
    final labels = stringLabels;
    if (labels == null || labels.length < 6) return fallback;
    return labels[stringNumber - 1];
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: _canvasWidth,
        height: _canvasHeight,
        child: Stack(
          children: [
            // 1. FOTO DE FONDO (sin modificar)
            Positioned.fill(
              child: Image.asset(
                'assets/images/headstock_3_3.png',
                fit: BoxFit.fill,
              ),
            ),

            // 2. EFECTO DE LUZ (cuerda + clavija activa), capa independiente
            Positioned.fill(
              child: CustomPaint(
                painter: _StringGlowPainter(
                  activeStringNumber: activeStringNumber,
                  pegPoints: _pegPoints,
                  nutPoints: _nutPoints,
                ),
              ),
            ),

            // 3. ZONAS TÁCTILES + ETIQUETAS DE NOTA SOBRE CADA CLAVIJA
            for (final entry in _pegPoints.entries)
              _buildPegHotspot(entry.key, entry.value),
          ],
        ),
      ),
    );
  }

  Widget _buildPegHotspot(int stringNumber, Offset center) {
    const double hotspotSize = 70;
    final bool isActive = stringNumber == activeStringNumber;
    final bool isLeftSide = center.dx < _canvasWidth / 2;

    const fallbacks = {1: 'E', 2: 'B', 3: 'G', 4: 'D', 5: 'A', 6: 'E'};
    final label = _labelFor(stringNumber, fallbacks[stringNumber]!);

    return Positioned(
      left: center.dx - hotspotSize / 2,
      top: center.dy - hotspotSize / 2,
      width: hotspotSize,
      height: hotspotSize,
      child: GestureDetector(
        onTap: onSelectString == null ? null : () => onSelectString!(stringNumber),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            const SizedBox.expand(), // zona táctil transparente sobre la clavija real
            Positioned(
              left: isLeftSide ? -46 : null,
              right: isLeftSide ? null : -46,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF6C5CE7) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? const Color(0xFF6C5CE7) : const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6),
                  ],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : const Color(0xFF334155),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StringGlowPainter extends CustomPainter {
  final int activeStringNumber;
  final Map<int, Offset> pegPoints;
  final Map<int, Offset> nutPoints;

  _StringGlowPainter({
    required this.activeStringNumber,
    required this.pegPoints,
    required this.nutPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset? peg = pegPoints[activeStringNumber];
    final Offset? nut = nutPoints[activeStringNumber];
    if (peg == null || nut == null) return;

    // Resplandor ancho y difuminado detrás de la cuerda activa
    final Paint outerGlow = Paint()
      ..color = const Color(0xFF6C5CE7).withValues(alpha: 0.55)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawLine(peg, nut, outerGlow);

    // Núcleo violeta sólido, sigue la cuerda real
    final Paint core = Paint()
      ..color = const Color(0xFF6C5CE7)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(peg, nut, core);

    // Brillo blanco central (simula la cuerda "vibrando")
    final Paint innerHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(peg, nut, innerHighlight);

    // Resplandor sobre la clavija activa
    final Paint pegGlow = Paint()
      ..color = const Color(0xFF6C5CE7).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(peg, 48, pegGlow);

    final Paint pegRing = Paint()
      ..color = const Color(0xFF6C5CE7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(peg, 32, pegRing);
  }

  @override
  bool shouldRepaint(covariant _StringGlowPainter oldDelegate) {
    return oldDelegate.activeStringNumber != activeStringNumber;
  }
}
