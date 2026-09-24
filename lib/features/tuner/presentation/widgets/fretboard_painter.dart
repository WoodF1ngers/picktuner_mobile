import 'package:flutter/material.dart';

import '../../domain/models/chord_models.dart';

/// Dibuja el diagrama de diapasón de una [ChordVariation], replicando la
/// composición del diseño original (viewBox lógico 240x200): clavijero
/// arriba, 6 cuerdas con grosor graduado, 4 trastes visibles y puntos de
/// digitación numerados. Si dos o más dedos comparten el mismo traste con
/// el mismo número de dedo, se dibuja una barra de cejilla detrás.
class FretboardPainter extends CustomPainter {
  final ChordVariation variation;
  final bool isDark;

  FretboardPainter(this.variation, {this.isDark = false});

  // Coordenadas lógicas (espacio 240x200), igual que el SVG de referencia.
  static const double _nutY = 10;
  static const double _nutHeight = 6;
  static const List<double> _fretLineYs = [55, 100, 145, 190];
  static const List<double> _rowCenterYs = [32.5, 77.5, 122.5, 167.5];
  static const double _stringTopY = 14;
  static const double _stringBottomY = 190;
  static const List<double> _stringXs = [30, 66, 102, 138, 174, 210];
  static const List<double> _stringWidths = [3.2, 2.6, 2.1, 1.6, 1.2, 0.9];

  Offset _mapLogical(double x, double y, Size size) {
    return Offset(x / 240 * size.width, y / 200 * size.height);
  }

  double _scaleX(double v, Size size) => v / 240 * size.width;
  double _scaleY(double v, Size size) => v / 200 * size.height;

  @override
  void paint(Canvas canvas, Size size) {
    final bool isOpenPosition = variation.startFret == 1;

    // Diapasón de fondo
    final backingRect = Rect.fromPoints(
      _mapLogical(30, _nutY, size),
      _mapLogical(210, _nutY + 180, size),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(backingRect, Radius.circular(_scaleX(4, size))),
      Paint()
        ..color = isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF4FAFD).withValues(alpha: 0.6),
    );

    // Traste (nut) o etiqueta de traste inicial si es cejilla
    if (isOpenPosition) {
      final nutRect = Rect.fromPoints(
        _mapLogical(28, _nutY, size),
        _mapLogical(212, _nutY + _nutHeight, size),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(nutRect, Radius.circular(_scaleX(2, size))),
        Paint()
          ..color = isDark ? Colors.white70 : const Color(0xFF2B3234),
      );
    }

    // Líneas de trastes horizontales
    final fretPaint = Paint()
      ..color = isDark ? Colors.white30 : const Color(0xFFC8C4D7)
      ..strokeWidth = _scaleY(2, size)
      ..strokeCap = StrokeCap.round;
    for (final y in _fretLineYs) {
      canvas.drawLine(
        _mapLogical(30, y, size),
        _mapLogical(210, y, size),
        fretPaint,
      );
    }

    // Etiquetas de traste (Fr N) a la izquierda
    for (int i = 0; i < _rowCenterYs.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Fr ${variation.startFret + i}',
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF787586),
            fontSize: _scaleX(11, size),
            fontWeight: FontWeight.w600,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      final center = _mapLogical(10, _rowCenterYs[i] + 4, size);
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
      );
    }

    // Cuerdas verticales con grosor graduado
    for (int i = 0; i < _stringXs.length; i++) {
      final paint = Paint()
        ..color = isDark ? Colors.white60 : const Color(0xFF787586)
        ..strokeWidth = _scaleX(_stringWidths[i], size);
      canvas.drawLine(
        _mapLogical(_stringXs[i], _stringTopY, size),
        _mapLogical(_stringXs[i], _stringBottomY, size),
        paint,
      );
    }

    // Incrustación decorativa (punto) en el traste 3 relativo de la ventana
    if (variation.startFret <= 3 && variation.startFret + 3 >= 3) {
      final inlayRowIndex = 3 - variation.startFret;
      if (inlayRowIndex >= 0 && inlayRowIndex < _rowCenterYs.length) {
        canvas.drawCircle(
          _mapLogical(120, _rowCenterYs[inlayRowIndex], size),
          _scaleX(3.5, size),
          Paint()..color = const Color(0xFFDDE4E6),
        );
      }
    }

    // Barras de cejilla: agrupamos dedos repetidos en el mismo traste
    final Map<int, List<int>> fingerGroups = {}; // finger -> string indices
    for (int i = 0; i < variation.strings.length; i++) {
      final pos = variation.strings[i];
      if (pos.status == StringStatus.fretted && pos.finger > 0) {
        fingerGroups.putIfAbsent(pos.finger, () => []).add(i);
      }
    }
    for (final entry in fingerGroups.entries) {
      final indices = entry.value;
      if (indices.length < 2) continue;
      // Deben compartir el mismo traste para dibujar una barra
      final frets = indices.map((i) => variation.strings[i].fret).toSet();
      if (frets.length != 1) continue;
      final fret = frets.first;
      final rowIndex = fret - variation.startFret;
      if (rowIndex < 0 || rowIndex >= _rowCenterYs.length) continue;

      indices.sort();
      final startX = _stringXs[indices.first];
      final endX = _stringXs[indices.last];
      final barRect = Rect.fromPoints(
        _mapLogical(startX, _rowCenterYs[rowIndex] - 11, size),
        _mapLogical(endX, _rowCenterYs[rowIndex] + 11, size),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, Radius.circular(_scaleX(11, size))),
        Paint()..color = const Color(0xFF6C5CE7).withValues(alpha: 0.85),
      );
    }

    // Puntos de digitación + marcadores de abierta/muteada
    for (int i = 0; i < variation.strings.length; i++) {
      final pos = variation.strings[i];
      final x = _stringXs[i];

      if (pos.status == StringStatus.fretted) {
        final rowIndex = pos.fret - variation.startFret;
        if (rowIndex < 0 || rowIndex >= _rowCenterYs.length) continue;
        final center = _mapLogical(x, _rowCenterYs[rowIndex], size);
        canvas.drawCircle(center, _scaleX(11, size), Paint()..color = const Color(0xFF6C5CE7));
        final tp = TextPainter(
          text: TextSpan(
            text: '${pos.finger}',
            style: TextStyle(
              color: Colors.white,
              fontSize: _scaleX(12, size),
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
      } else {
        // X (muteada) / O (abierta) arriba del diapasón
        final markerCenter = _mapLogical(x, _nutY - 6, size);
        final tp = TextPainter(
          text: TextSpan(
            text: pos.status == StringStatus.muted ? 'X' : 'O',
            style: TextStyle(
              color: pos.status == StringStatus.muted
                  ? const Color(0xFFBA1A1A)
                  : const Color(0xFF006B55),
              fontSize: _scaleX(13, size),
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(markerCenter.dx - tp.width / 2, markerCenter.dy - tp.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant FretboardPainter oldDelegate) =>
      oldDelegate.variation != variation;
}
