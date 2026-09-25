import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';

class PhotoHeadstockWidget extends StatelessWidget {
  final int? activeStringNumber; // 1 a 6
  final List<String>? stringLabels;
  final Set<int> tunedStrings; // Cuerdas afiandas
  final double tuningProgress; // Llenado (0.0 a 1.0)
  final ValueChanged<int>? onSelectString;

  const PhotoHeadstockWidget({
    super.key,
    this.activeStringNumber,
    this.stringLabels,
    this.tunedStrings = const {},
    this.tuningProgress = 0.0,
    this.onSelectString,
  });

  static const double _canvasWidth = 1080.0;
  static const double _canvasHeight = 1920.0;

  static const Map<int, String> _stringSvgPaths = {
    1: 'M749.5,1091.8c-19.2,0-34.9,15.6-34.9,34.9c0,5.1,1.1,10.1,3.2,14.7l3.2,424.6l0.8,46.9l3.2,305l5,0l-7.2-768.5c6.5,7.7,16.1,12.2,26.5,12.2c19.2,0,34.9-15.6,34.9-34.9S768.8,1091.8,749.5,1091.8z M749.5,1156.5c-11.5,0-21.7-6.4-26.8-16.7l-0.1-0.1c-2-4.1-3-8.5-3-13c0-16.5,13.4-29.9,29.9-29.9s29.9,13.4,29.9,29.9S766,1156.5,749.5,1156.5z',
    2: 'M749.5,741.8c-19.1,0-34.6,15.5-34.6,34.6c0,5.4,1.3,10.6,3.5,15.1L646.2,1577l0,0.1l1.8,341.1l6,0l-1.8-340.8l71.6-778c6.3,7.1,15.5,11.5,25.8,11.5c19.1,0,34.6-15.5,34.6-34.6S768.6,741.8,749.5,741.8z M749.5,804.9c-15.7,0-28.6-12.8-28.6-28.6c0-15.7,12.8-28.6,28.6-28.6s28.6,12.8,28.6,28.6C778.1,792.1,765.3,804.9,749.5,804.9z',
    3: 'M766.1,388.6c-19.5,0-35.5,15.9-35.5,35.5c0,3.2,0.4,6.3,1.2,9.2L572.1,1577.6l0,0.2l0.4,340.8l7,0l-0.4-340.3L737.4,444.7c6.4,8.9,16.9,14.8,28.8,14.8c19.5,0,35.5-15.9,35.5-35.5S785.7,388.6,766.1,388.6z M766.1,452.5c-15.7,0-28.5-12.8-28.5-28.5s12.8-28.5,28.5-28.5s28.5,12.8,28.5,28.5S781.8,452.5,766.1,452.5z',
    4: 'M347.4,440.5c2.7-5.4,4.3-11.5,4.3-17.9c0-21.8-17.8-39.6-39.6-39.6s-39.6,17.8-39.6,39.6s17.8,39.6,39.6,39.6c10.8,0,20.5-4.3,27.7-11.3l158.5,1130.8v337h9V1581L347.4,440.5z M312.1,454.2c-17.4,0-31.6-14.2-31.6-31.6s14.2-31.6,31.6-31.6s31.6,14.2,31.6,31.6S329.6,454.2,312.1,454.2z',
    5: 'M365.8,786c1.1-3.7,1.7-7.6,1.7-11.7c0-22.4-18.2-40.6-40.6-40.6c-22.4,0-40.6,18.2-40.6,40.6c0,22.4,18.2,40.6,40.6,40.6c12,0,22.7-5.2,30.1-13.4l66.1,775.2v342h10v-342.4L365.8,786z M326.9,804.9c-16.9,0-30.6-13.7-30.6-30.6c0-16.9,13.7-30.6,30.6-30.6c16.9,0,30.6,13.7,30.6,30.6C357.5,791.2,343.8,804.9,326.9,804.9z',
    6: 'M368.6,1122.4c-1.9-21-19.5-37.4-40.9-37.4c-22.7,0-41.1,18.4-41.1,41.1s18.4,41.1,41.1,41.1c12.7,0,24.1-5.8,31.7-14.9l-9.5,412.1l-3,354.5c0,3,2.4,5.5,5.5,5.5c0,0,0,0,0,0c3,0,5.5-2.4,5.5-5.5l3-354.5L371,1127C371,1125.1,370.1,1123.4,368.6,1122.4z M327.7,1156.1c-16.6,0-30.1-13.5-30.1-30.1s13.5-30.1,30.1-30.1s30.1,13.5,30.1,30.1S344.3,1156.1,327.7,1156.1z',
  };

  static const Map<int, String> _pegSvgPaths = {
    1: 'M882.8,1101.6l2.2,45l28.9-0.5l1.6-0.8l1.3-1.3l1.9-0.5l1.6,0.3v1.6h1.6l3-0.3h2.4h2.2l1.1,0.3l0.8,1.3l1.3,1.9l2.7,1.6l2.4,1.6l3.8,2.7c0,0,9.4,8.6,13.2,23.7l3.8,11.6l4,12.1l4,9.2c0,0,3,5.1,6.2,7.6c3.2,2.4,8.4,5.7,18.9,6.2c0,0,19.7-1.9,27.8-4c8.1-2.2,17.8-7,24-15.1c0,0,17.5-24.3,21.3-48.3c0,0,5.9-22.4,1.9-49.3c-4-27-12.1-46.4-20.5-59.6c-8.4-13.2-22.9-17.8-22.9-17.8s-10.5-4.3-24.8-5.1c0,0-16.2-1.9-22.4,3.2c-6.2,5.1-8.1,8.4-9.4,11.6c-1.3,3.2-7.3,19.1-7.8,21.8c-0.5,2.7-5.1,17.5-7,21s-6.5,9.4-10.2,11.9c0,0-7.6,2.7-8.9,5.7l-1.6,2.7l-1.3,1.3h-7.6l-1.3,1.1l-3-1.1l-1.3-0.3l-1.1-1.9l-2.4-1.1H882.8z',
    2: 'M882.8,750.5l-1.2,45.6l32.2-0.3l1.6-0.8l1.3-1.3l1.9-0.5l1.6,0.3v0.8c0,0.4,0.4,0.8,0.8,0.8h0.8l3-0.3h2.4h2.2l1.1,0.3l0.8,0.5l1.3,1.9l2.7,1.6l2.4,1.6l3.8,2.7c0,0,9.4,8.6,13.2,23.7l3.8,11.6l4,12.1l4,9.2c0,0,3,5.1,6.2,7.6c3.2,2.4,8.4,5.7,18.9,6.2c0,0,19.7-1.9,27.8-4c8.1-2.2,17.8-7,24-15.1c0,0,17.5-24.3,21.3-48.3c0,0,5.9-22.4,1.9-49.3c-4-27-12.1-46.4-20.5-59.6c-8.4-13.2-22.9-17.8-22.9-17.8s-10.5-4.3-24.8-5.1c0,0-16.2-1.9-22.4,3.2c-6.2,5.1-8.1,8.4-9.4,11.6s-7.3,19.1-7.8,21.8c-0.5,2.7-5.1,17.5-7,21s-6.5,9.4-10.2,11.9c0,0-7.6,2.7-8.9,5.7l-1.6,2.7l-1.3,1.3h-7.6l-1.3,1.1l-3-1.1l-1.3-0.3l-1.1-1.9l-2.4-1.1H882.8z',
    3: 'M906.9,399.4l-4,46l19,0l2.2-0.8l1.1-1.5l1.9-0.5h1.2l0.4,0.6l1.4,0.1l2.8-0.5h2.4h2.2l1.1,0.3l0.8,1.3l1.3,1.9l2.7,1.6l2.4,1.6l3.8,2.7c0,0,9.4,8.6,13.2,23.7l3.8,11.6l4,12.1l4,9.2c0,0,3,5.1,6.2,7.6c3.2,2.4,8.4,5.7,18.9,6.2c0,0,19.7-1.9,27.8-4c8.1-2.2,17.8-7,24-15.1c0,0,17.5-24.3,21.3-48.3c0,0,5.9-22.4,1.9-49.3c-4-27-12.1-46.4-20.5-59.6c-8.4-13.2-22.9-17.8-22.9-17.8s-10.5-4.3-24.8-5.1c0,0-16.2-1.9-22.4,3.2c-6.2,5.1-8.1,8.4-9.4,11.6c-1.3,3.2-7.3,19.1-7.8,21.8s-5.1,17.5-7,21s-6.5,9.4-10.2,11.9c0,0-7.6,2.7-8.9,5.7l-1.6,2.7l-1.3,1.3h-7.6l-1.3,1.1l-3-1.1l-1.3-0.3l-1.1-1.9l-2.4-1.1H906.9z',
    4: 'M171.3,399.4l4.5,45.6l-19.3,0l-1.6-0.8l-1.3-1.3l-1.9-0.5l-1.6,0.3l-0.5,0.5h-1.6l-2.4-0.3H143h-2.2l-1.1,0.3l-0.8,1.3l-1.3,1.9l-2.7,1.6l-2.4,1.6l-3.8,2.7c0,0-9.4,8.6-13.2,23.7l-3.8,11.6l-4,12.1l-4,9.2c0,0-3,5.1-6.2,7.6c-3.2,2.4-8.4,5.7-18.9,6.2c0,0-19.7-1.9-27.8-4c-8.1-2.2-17.8-7-24-15.1c0,0-17.5-24.3-21.3-48.3c0,0-5.9-22.4-1.9-49.3c4-27,12.1-46.4,20.5-59.6C32.5,333,47,328.5,47,328.5s10.5-4.3,24.8-5.1c0,0,16.2-1.9,22.4,3.2s8.1,8.4,9.4,11.6c1.3,3.2,7.3,19.1,7.8,21.8c0.5,2.7,5.1,17.5,7,21s6.5,9.4,10.2,11.9c0,0,7.6,2.7,8.9,5.7l1.6,2.7l1.3,1.3h7.6l1.3,1.1l3-1.1l1.3-0.3l1.1-1.9l2.4-1.1H171.3z',
    5: 'M196.2,751.3l1,44.7l-32-0.2l-1.6-0.8l-1.3-1.3l-1.9-0.5l-1.6,0.3v1.6h-1.6l-3-0.3h-2.4h-2.2l-1.1,0.3l-0.8,1.3l-1.3,1.9l-2.7,1.6l-2.4,1.6l-3.8,2.7c0,0-9.4,8.6-13.2,23.7l-3.8,11.6l-4,12.1l-4,9.2c0,0-3,5.1-6.2,7.6c-3.2,2.4-8.4,5.7-18.9,6.2c0,0-19.7-1.9-27.8-4s-17.8-7-24-15.1c0,0-17.5-24.3-21.3-48.3c0,0-5.9-22.4-1.9-49.3s12.1-46.4,20.5-59.6c8.4-13.2,22.9-17.8,22.9-17.8s10.5-4.3,24.8-5.1c0,0,16.2-1.9,22.4,3.2s8.1,8.4,9.4,11.6c1.3,3.2,7.3,19.1,7.8,21.8c0.5,2.7,5.1,17.5,7,21c1.9,3.5,6.5,9.4,10.2,11.9c0,0,7.6,2.7,8.9,5.7l1.6,2.7l1.3,1.3h7.6l1.3,1.1l3-1.1l1.3-0.3l1.1-1.9l2.4-1.1H196.2z',
    6: 'M195.1,1101.9l-2.2,45l-27.9-0.5l-1.6-0.8l-1.3-1.3l-1.9-0.5l-1.6,0.3v1.6H157l-3-0.3h-2.4h-2.2l-1.1,0.3l-0.8,1.3l-1.3,1.9l-2.7,1.6l-2.4,1.6l-3.8,2.7c0,0-9.4,8.6-13.2,23.7l-3.8,11.6l-4,12.1l-4,9.2c0,0-3,5.1-6.2,7.6c-3.2,2.4-8.4,5.7-18.9,6.2c0,0-19.7-1.9-27.8-4c-8.1-2.2-17.8-7-24-15.1c0,0-17.5-24.3-21.3-48.3c0,0-5.9-22.4-1.9-49.3s12.1-46.4,20.5-59.6s22.9-17.8,22.9-17.8s10.5-4.3,24.8-5.1c0,0,16.2-1.9,22.4,3.2c6.2,5.1,8.1,8.4,9.4,11.6s7.3,19.1,7.8,21.8c0.5,2.7,5.1,17.5,7,21s6.5,9.4,10.2,11.9c0,0,7.6,2.7,8.9,5.7l1.6,2.7l1.3,1.3h7.6l1.3,1.1l3-1.1l1.3-0.3l1.1-1.9l2.4-1.1H195.1z',
  };

  static const Map<int, Offset> _noteBadgeCenters = {
    1: Offset(1225.0, 1125.0),
    2: Offset(1225.0, 775.0),
    3: Offset(1225.0, 424.0),
    4: Offset(-145.0, 422.0),
    5: Offset(-145.0, 774.0),
    6: Offset(-145.0, 1126.0),
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
      padding: const EdgeInsets.only(top: 30.0, bottom: 0.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double containerW = constraints.maxWidth;
          final double containerH = constraints.maxHeight;

          final double canvasAspect = _canvasWidth / _canvasHeight;
          final double containerAspect = containerW / containerH;

          double renderW, renderH;
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
                          child: Image.asset(
                            'assets/images/headstock_3_3.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _SvgElementsPainter(
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
                  key: ValueKey('badge_$i'),
                  stringNumber: i,
                  label: _getLabel(i),
                  centerInCanvas: _noteBadgeCenters[i]!,
                  offsetX: offsetX,
                  offsetY: offsetY,
                  scale: scale,
                  isActive: i == activeStringNumber,
                  isTuned: tunedStrings.contains(i),
                  progress: i == activeStringNumber ? tuningProgress : 0.0,
                  onTap: () {
                    HapticFeedback.selectionClick(); // Feedback háptico al tocar manualmente
                    if (onSelectString != null) {
                      onSelectString!(i);
                    }
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class HeadstockBadgeWidget extends StatefulWidget {
  final int stringNumber;
  final String label;
  final Offset centerInCanvas;
  final double offsetX;
  final double offsetY;
  final double scale;
  final bool isActive;
  final bool isTuned;
  final double progress;
  final VoidCallback onTap;
  final double baseSize;

  const HeadstockBadgeWidget({
    super.key,
    required this.stringNumber,
    required this.label,
    required this.centerInCanvas,
    required this.offsetX,
    required this.offsetY,
    required this.scale,
    required this.isActive,
    required this.isTuned,
    required this.progress,
    required this.onTap,
    this.baseSize = 192.0,
  });

  @override
  State<HeadstockBadgeWidget> createState() => _HeadstockBadgeWidgetState();
}

class _HeadstockBadgeWidgetState extends State<HeadstockBadgeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  // =========================================================================
  // AJUSTES DE CALIBRACIÓN UX / FEEDBACK
  // =========================================================================
  /// Cambia esta duración para probar qué tan rápido/lento quieres el pop (250ms a 400ms suele ser ideal)
  static const Duration kPopDuration = Duration(milliseconds: 320);

  /// Curva del rebote al afinar (Prueba: Curves.elasticOut, Curves.bounceOut, Curves.easeOutBack)
  static const Curve kPopCurve = Curves.bounceOut;

  // Colores principales
  static const Color activeColor = Color(0xFF6C5CE7);
  static const Color flashYellowColor = Color(0xFFFFB400);
  static const Color tunedGreenColor = Color(0xFF00E676);
  static const Color softFillGreen = Color(0x9900E676);
  // =========================================================================

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: kPopDuration, vsync: this);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.25,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.25,
          end: 1.0,
        ).chain(CurveTween(curve: kPopCurve)),
        weight: 60,
      ),
    ]).animate(_controller);

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: activeColor, end: flashYellowColor),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: flashYellowColor, end: tunedGreenColor),
        weight: 70,
      ),
    ]).animate(_controller);

    if (widget.isTuned) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant HeadstockBadgeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isTuned && widget.isTuned) {
      // Vibra fuerte al detectar la cuerda en tono perfecto
      HapticFeedback.heavyImpact();
      _controller.forward(from: 0.0);
    } else if (oldWidget.isTuned && !widget.isTuned) {
      _controller.reverse(from: 1.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double baseSize = widget.baseSize;
    final double realSize = baseSize * widget.scale;

    final double screenCenterX =
        widget.offsetX + (widget.centerInCanvas.dx * widget.scale);
    final double screenCenterY =
        widget.offsetY + (widget.centerInCanvas.dy * widget.scale);

    return Positioned(
      left: screenCenterX - (realSize / 2),
      top: screenCenterY - (realSize / 2),
      width: realSize,
      height: realSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double currentScale = _scaleAnimation.value;

          Color bgColor;
          Color borderColor;
          Color textColor;

          if (widget.isTuned) {
            bgColor = _colorAnimation.value ?? tunedGreenColor;
            borderColor = Colors.white;
            textColor = Colors.white;
          } else if (widget.isActive) {
            bgColor = activeColor;
            borderColor = Colors.white;
            textColor = Colors.white;
          } else {
            bgColor = Colors.white;
            borderColor = const Color(0xFFD0D7DE);
            textColor = const Color(0xFF24292F);
          }

          final bool isHighlighted = widget.isActive || widget.isTuned;

          return Transform.scale(
            scale: currentScale,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor,
                      width: (isHighlighted ? 8 : 4) * widget.scale,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isTuned ? tunedGreenColor : activeColor)
                            .withValues(alpha: isHighlighted ? 0.6 : 0.15),
                        blurRadius: (isHighlighted ? 26 : 10) * widget.scale,
                        spreadRadius: (isHighlighted ? 4 : 0) * widget.scale,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (widget.isActive &&
                          !widget.isTuned &&
                          widget.progress > 0.0)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _BadgeFillPainter(
                              progress: widget.progress,
                              fillColor: softFillGreen,
                            ),
                          ),
                        ),
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 76 * widget.scale,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BadgeFillPainter extends CustomPainter {
  final double progress;
  final Color fillColor;

  _BadgeFillPainter({required this.progress, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final double fillHeight = size.height * progress;
    final double topOffset = size.height - fillHeight;

    final Rect fillRect = Rect.fromLTRB(0, topOffset, size.width, size.height);
    final Paint fillPaint = Paint()..color = fillColor;

    canvas.clipPath(
      Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    canvas.drawRect(fillRect, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _BadgeFillPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.fillColor != fillColor;
  }
}

class _SvgElementsPainter extends CustomPainter {
  final int? activeStringNumber;
  final Map<int, String> stringSvgPaths;
  final Map<int, String> pegSvgPaths;

  _SvgElementsPainter({
    this.activeStringNumber,
    required this.stringSvgPaths,
    required this.pegSvgPaths,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final String? activeStringData = activeStringNumber == null
        ? null
        : stringSvgPaths[activeStringNumber];
    final String? activePegData = activeStringNumber == null
        ? null
        : pegSvgPaths[activeStringNumber];

    if (activeStringData == null) return;

    final Path stringPath = parseSvgPathData(activeStringData);
    const Color glowColor = Color(0xFF7C5CFF);

    final Paint wideGlowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.6)
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

    if (activePegData != null) {
      final Path pegPath = parseSvgPathData(activePegData);
      final Paint pegHighlight = Paint()
        ..color = glowColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawPath(pegPath, pegHighlight);
    }
  }

  @override
  bool shouldRepaint(covariant _SvgElementsPainter oldDelegate) {
    return oldDelegate.activeStringNumber != activeStringNumber;
  }
}
