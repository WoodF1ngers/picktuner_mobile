import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../providers/theme_provider.dart';
import '../widgets/pick_tuner_brand.dart';
import 'main_shell_screen.dart';

/// Pantalla de arranque de PickTuner.
///
/// Presenta una splash breve seguida de un loader visual relacionado con
/// frecuencia/ondas. No depende de una carga artificial de datos: el tiempo
/// es deliberadamente corto para dar identidad visual al arranque sin hacer
/// que la app se sienta lenta.
class AppStartupScreen extends StatefulWidget {
  const AppStartupScreen({super.key});

  @override
  State<AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends State<AppStartupScreen>
    with TickerProviderStateMixin {
  static const Duration _splashDuration = Duration(seconds: 2);
  static const Duration _loaderDuration = Duration(seconds: 5);

  late final AnimationController _introController;
  late final AnimationController _loaderController;
  bool _showLoader = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future<void>.delayed(_splashDuration);
    if (!mounted) return;

    setState(() => _showLoader = true);

    await Future<void>.delayed(_loaderDuration);
    if (!mounted || _finished) return;

    _finished = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const MainShellScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // La identidad de las pantallas de arranque usa siempre la paleta oscura
    // oficial para que splash y loader se sientan como una misma pieza de marca.
    return Scaffold(
      backgroundColor: AppColors.darkNeutralBackground,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _showLoader ? _buildLoader() : _buildSplash(),
      ),
    );
  }

  Widget _buildSplash() {
    return FadeTransition(
      key: const ValueKey('splash'),
      opacity: CurvedAnimation(parent: _introController, curve: Curves.easeOut),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: _BrandBackground()),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PickTunerLogo(size: 142),
                  const SizedBox(height: 26),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 39,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.2,
                      ),
                      children: [
                        TextSpan(
                          text: 'Pick',
                          style: TextStyle(color: AppColors.darkTextPrimary),
                        ),
                        TextSpan(
                          text: 'Tuner',
                          style: TextStyle(color: AppColors.darkSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AFINA TU PASIÓN',
                    style: TextStyle(
                      color: AppColors.darkTextPrimary.withValues(alpha: .88),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 38,
            child: Text(
              'Afinación precisa, mejor sonido.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 13,
                letterSpacing: .4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return AnimatedBuilder(
      key: const ValueKey('loader'),
      animation: _loaderController,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(child: _BrandBackground()),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PickTunerLogo(size: 92),
                    const SizedBox(height: 16),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.8,
                        ),
                        children: [
                          TextSpan(
                            text: 'Pick',
                            style: TextStyle(color: AppColors.darkTextPrimary),
                          ),
                          TextSpan(
                            text: 'Tuner',
                            style: TextStyle(color: AppColors.darkSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Afinación precisa, mejor sonido.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.darkTextPrimary.withValues(alpha: .82),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 42),
                    SizedBox(
                      width: 310,
                      height: 155,
                      child: CustomPaint(
                        painter: FrequencyLoaderPainter(
                          progress: _loaderController.value,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Preparando el afinador…',
                      style: TextStyle(
                        color: AppColors.darkTextSecondary,
                        fontSize: 13,
                        letterSpacing: .5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 38,
              child: Text(
                'Escucha · Detecta · Afina',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BrandBackground extends StatelessWidget {
  const _BrandBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: BrandBackgroundPainter());
  }
}

class BrandBackgroundPainter extends CustomPainter {
  const BrandBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0E1110),
          AppColors.darkNeutralBackground,
          Color(0xFF101514),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    final glow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.darkPrimary.withValues(alpha: .15),
              AppColors.darkPrimary.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .5, size.height * .34),
              radius: size.width * .62,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * .5, size.height * .34),
      size.width * .62,
      glow,
    );

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = AppColors.darkSecondary.withValues(alpha: .09);

    for (int i = 0; i < 6; i++) {
      final path = Path();
      final baseY = size.height * (.74 + i * .035);
      for (double x = -20; x <= size.width + 20; x += 8) {
        final y =
            baseY +
            math.sin(x / 58 + i * .55) * (7 + i * 1.5) +
            (x / size.width) * 8;
        if (x == -20) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FrequencyLoaderPainter extends CustomPainter {
  final double progress;

  const FrequencyLoaderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = math.min(size.width, size.height) * .30;

    final glowPaint = Paint()
      ..color = AppColors.darkPrimary.withValues(alpha: .15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, ringRadius + 2, glowPaint);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = AppColors.darkSurfaceVariant;
    canvas.drawCircle(center, ringRadius, trackPaint);

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5
      ..shader = const SweepGradient(
        colors: [
          AppColors.darkPrimary,
          AppColors.darkSecondary,
          AppColors.darkPrimary,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: ringRadius));

    final startAngle = -math.pi / 2 + progress * math.pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: ringRadius),
      startAngle,
      math.pi * 1.35,
      false,
      activePaint,
    );

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = AppColors.darkSecondary.withValues(alpha: .78);

    final secondWavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.darkPrimary.withValues(alpha: .48);

    for (int wave = 0; wave < 2; wave++) {
      final path = Path();
      final amplitude = wave == 0 ? 17.0 : 10.0;
      final frequency = wave == 0 ? 0.078 : 0.11;
      final phase = progress * math.pi * 2.0 * (wave == 0 ? 1.0 : -1.0);
      final paint = wave == 0 ? wavePaint : secondWavePaint;

      for (double x = 0; x <= size.width; x += 3) {
        final y = center.dy + math.sin(x * frequency + phase) * amplitude;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }

    final bars = [18.0, 32.0, 45.0, 28.0, 18.0];
    final barPaint = Paint()
      ..color = AppColors.darkTextPrimary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const gap = 8.0;
    final totalWidth = gap * (bars.length - 1) + 4;
    final left = center.dx - totalWidth / 2;

    for (int i = 0; i < bars.length; i++) {
      final x = left + i * gap;
      final half = bars[i] / 2;
      canvas.drawLine(
        Offset(x, center.dy - half),
        Offset(x, center.dy + half),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FrequencyLoaderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
