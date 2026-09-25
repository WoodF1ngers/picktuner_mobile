import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';

import 'photo_headstock_widget.dart';

/// Pala fotográfica para guitarras con las seis clavijas en línea.
///
/// El PNG y los paths SVG comparten el canvas original de Illustrator
/// (1080 x 1920), por lo que los paths se dibujan directamente sobre ese
/// mismo sistema de coordenadas.
class PhotoHeadstockInlineWidget extends StatelessWidget {
  final int activeStringNumber;
  final List<String>? stringLabels;
  final Set<int> tunedStrings;
  final double tuningProgress;
  final ValueChanged<int>? onSelectString;

  const PhotoHeadstockInlineWidget({
    super.key,
    required this.activeStringNumber,
    this.stringLabels,
    this.tunedStrings = const {},
    this.tuningProgress = 0.0,
    this.onSelectString,
  });

  static const double _canvasWidth = 1080.0;
  static const double _canvasHeight = 1920.0;

  static const String _assetPath = 'assets/images/headstock_6_inline.png';

  // Los paths proceden de Illustrator y están en las coordenadas originales
  // del canvas 1080 x 1920. No aplicamos el translate del <g> del SVG porque
  // ese translate corresponde al recorte del viewBox exportado, no al canvas
  // de la imagen que usamos como fondo.
  static const Map<int, String> _stringSvgPaths = {
    1: 'M664,1595l2-498-5-308-8-455v0a30.49,30.49,0,0,0,.5-5.44,30,30,0,1,0-4.32,15.5L657,789l5,308-2,498,5,324a2,2,0,0,0,2,2h0a2,2,0,0,0,2-2ZM623.5,354.5a26,26,0,1,1,26-26A26,26,0,0,1,623.5,354.5Z',
    2: 'M609,1594.48l-5-514-7-566h0a30.55,30.55,0,1,0-4.8,16.42l6.8,549.63,5,514,4,323,5-.06ZM566.5,540A25.5,25.5,0,1,1,592,514.5,25.53,25.53,0,0,1,566.5,540Z',
    3: 'M553,1594,540.58,710a2.88,2.88,0,0,0-.18-1,30.09,30.09,0,1,0-5.66,12.32L547,1594l3,324a3,3,0,0,0,3,3h0a3,3,0,0,0,3-3ZM511,727a24,24,0,1,1,24-24A24,24,0,0,1,511,727Z',
    4: 'M496,1592.44l-12-692a32.22,32.22,0,0,0,2-11.19c0-18.06-14.92-32.75-33.26-32.75s-33.25,14.69-33.25,32.75S434.42,922,452.75,922a33.43,33.43,0,0,0,24.45-10.57L489,1592.52l2,325,7,0ZM452.75,915c-14.47,0-26.25-11.55-26.25-25.75s11.78-25.75,26.25-25.75S479,875.05,479,889.25,467.23,915,452.75,915Z',
    5: 'M437,1590.92l-9.89-509.62a4.1,4.1,0,0,0-.25-1.27,33.75,33.75,0,0,0,.68-6.78c0-18.89-15.6-34.25-34.77-34.25S358,1054.36,358,1073.25s15.6,34.25,34.77,34.25a34.9,34.9,0,0,0,26.61-12.24L429,1591l1,324a4,4,0,0,0,4,4h0a4,4,0,0,0,4-4ZM392.77,1099.5c-14.76,0-26.77-11.78-26.77-26.25S378,1047,392.77,1047s26.77,11.78,26.77,26.25S407.53,1099.5,392.77,1099.5Z',
    6: 'M371.93,1278.13a36.18,36.18,0,0,0,4.18-16.88c0-20.26-16.73-36.75-37.3-36.75S301.5,1241,301.5,1261.25,318.24,1298,338.81,1298a37.47,37.47,0,0,0,24.36-9L370,1594.54l-1,323,9,0,1-323ZM338.81,1289c-15.61,0-28.31-12.45-28.31-27.75s12.7-27.75,28.31-27.75,28.3,12.45,28.3,27.75S354.41,1289,338.81,1289Z',
  };

  static const Map<int, String> _pegSvgPaths = {
    1: 'M551,236a399.38,399.38,0,0,0-17,49l-5-2-4-2-1-2-2-1-3-1-4-1s-2-4-5,0-11,14-11,14l-5,8-9,14-3,4s-2,4-17,0-47-15-47-15-8-4-9-24-5-38,9-68c13.05-28,41-51,41-51s2-3,15,1,46,14,46,14,7,2,6,14-2,41-2,41l1,2,2,1,5,2,1,2,1,1h4l2-2h4l6,2Z',
    2: 'M492,420s-10,31-16,51l-6-3-3-1.21a3.17,3.17,0,0,1-2-2.93V463l-2-1-3-1-4-1s-2-4-5,0-11,14-11,14l-5,8-9,14-3,4s-2,4-17,0-47-15-47-15-8-4-9-24-5-38,9-68c13.05-28,41-51,41-51s2-3,15,1,46,14,46,14,7,2,6,14-2,41-2,41l1,2,2,1,5,2,1,2h3l2-1,2-1h9Z',
    3: 'M434,606s-10,28-18,53l-5-2-4-4-1-2-2-1-3-1-4-1s-2-4-5,0-11,14-11,14l-5,8-9,14-3,4s-2,4-17,0-47-15-47-15-8-4-9-24-5-38,9-68c13.05-28,41-51,41-51s2-3,15,1,46,14,46,14,7,2,6,14-2,41-2,41l1,2,2,1,5,2,1,2h3l2-1,2-1h9Z',
    4: 'M375,791s-9,27-17,52l-5-3-5-3-1-1-2-3h-3l-3-1s-3-3-6,1-11,14-11,14l-5,8-9,14-3,4s0,6-15,2-47-15-47-15-10-6-11-26-5-38,9-68c13.05-28,41-51,41-51s2-3,15,1,46,14,46,14,7,2,6,14-2,41-2,41l1,2,2,1,5,2,1,2h3l2-1,2-1h9Z',
    5: 'M318,977s-9,28-17,53l-6-2-4-4-1-2-2-1-3-1-4-1s-2-4-5,0-11,14-11,14l-5,8-9,14-3,4s-2,4-17,0-47-15-47-15-8-4-9-24-5-38,9-68c13.05-28,41-51,41-51s2-3,15,1,46,14,46,14,7,2,6,14-2,41-2,41l1,2,2,1,5,2,1,2h3l2-1,2-1h9Z',
    6: 'M260,1163s-8,28-16,53l-6-3-5-2h-3l-3-1-3-2-1-2s-2-4-5,0-11,14-11,14l-5,8-9,14-3,4s-2,4-17,0-47-15-47-15-6-5-7-25-7-37,7-67c13.05-28,41-51,41-51s2-3,15,1,46,14,46,14,7,2,6,14-2,41-2,41l1,2,3,2h5l1,2,1,1h1l2-1,2-1,3-1h5Z',
  };

  // Centros calculados sobre los seis paths de clavijas. Se usan como área
  // táctil/indicador, manteniendo el badge alineado con cada peg del PNG.
  // Los badges permanecen fuera de la pala, en la columna izquierda, igual
  // que en la referencia visual del afinador. Solo cambia su posición; el
  // estado, animación, selección, progreso y reset siguen siendo los mismos.
  // Los valores Y coinciden con el centro visual de cada clavija.
  static const Map<int, Offset> _badgeCenters = {
    1: Offset(-145.0, 237.0), // E
    2: Offset(-145.0, 421.0), // B
    3: Offset(-145.0, 609.0), // G
    4: Offset(-145.0, 795.0), // D
    5: Offset(-145.0, 980.0), // A
    6: Offset(-145.0, 1167.0), // E
  };

  String _getLabel(int stringNumber) {
    const defaultLabels = {1: 'E', 2: 'B', 3: 'G', 4: 'D', 5: 'A', 6: 'E'};
    if (stringLabels != null && stringLabels!.length >= 6) {
      return stringLabels![stringNumber - 1];
    }
    return defaultLabels[stringNumber]!;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double containerW = constraints.maxWidth;
          final double containerH = constraints.maxHeight;
          final double canvasAspect = _canvasWidth / _canvasHeight;
          final double containerAspect = containerW / containerH;

          double renderW;
          double renderH;
          if (containerAspect > canvasAspect) {
            renderH = containerH;
            renderW = containerH * canvasAspect;
          } else {
            renderW = containerW;
            renderH = containerW / canvasAspect;
          }

          final double offsetX = (containerW - renderW) / 2;
          final double offsetY = (containerH - renderH) / 2;
          final double scale = renderW / _canvasWidth;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: offsetX,
                top: offsetY,
                width: renderW,
                height: renderH,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _canvasWidth,
                    height: _canvasHeight,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(_assetPath, fit: BoxFit.contain),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _InlineSvgElementsPainter(
                                activeStringNumber: activeStringNumber,
                                stringSvgPaths: _stringSvgPaths,
                                pegSvgPaths: _pegSvgPaths,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              for (int i = 1; i <= 6; i++)
                HeadstockBadgeWidget(
                  key: ValueKey('inline_badge_$i'),
                  stringNumber: i,
                  label: _getLabel(i),
                  centerInCanvas: _badgeCenters[i]!,
                  offsetX: offsetX,
                  offsetY: offsetY,
                  scale: scale,
                  baseSize: 192.0,
                  isActive: i == activeStringNumber,
                  isTuned: tunedStrings.contains(i),
                  progress: i == activeStringNumber ? tuningProgress : 0.0,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelectString?.call(i);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _InlineSvgElementsPainter extends CustomPainter {
  final int activeStringNumber;
  final Map<int, String> stringSvgPaths;
  final Map<int, String> pegSvgPaths;

  _InlineSvgElementsPainter({
    required this.activeStringNumber,
    required this.stringSvgPaths,
    required this.pegSvgPaths,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final String? stringData = stringSvgPaths[activeStringNumber];
    if (stringData == null) return;

    final Path stringPath = parseSvgPathData(stringData);
    const Color glowColor = Color(0xFF7C5CFF);

    final Paint wideGlowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawPath(stringPath, wideGlowPaint);

    final Paint mediumGlowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(stringPath, mediumGlowPaint);

    final Paint corePaint = Paint()
      ..color = const Color(0xFFEFE8FF)
      ..style = PaintingStyle.fill;
    canvas.drawPath(stringPath, corePaint);

    final String? pegData = pegSvgPaths[activeStringNumber];
    if (pegData != null) {
      final Path pegPath = parseSvgPathData(pegData);
      final Paint pegHighlight = Paint()
        ..color = glowColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(pegPath, pegHighlight);

      final Paint pegCore = Paint()
        ..color = glowColor.withValues(alpha: 0.28)
        ..style = PaintingStyle.fill;
      canvas.drawPath(pegPath, pegCore);
    }
  }

  @override
  bool shouldRepaint(covariant _InlineSvgElementsPainter oldDelegate) {
    return oldDelegate.activeStringNumber != activeStringNumber;
  }
}
