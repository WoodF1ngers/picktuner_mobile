import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/tuning_status.dart';
import '../providers/tuner_provider.dart';
import '../widgets/photo_headstock_widget.dart';
import '../widgets/tuning_pick_gauge.dart';
import '../providers/tuner_settings_provider.dart';
import 'tuner_settings_screen.dart';

class TunerScreen extends ConsumerStatefulWidget {
  const TunerScreen({super.key});

  @override
  ConsumerState<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends ConsumerState<TunerScreen> {
  late final ScrollController _scrollController;
  bool _hasTriggeredReset = false; // Evita disparar el reset múltiples veces en un mismo gesto

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tunerProvider.notifier).startListening();
    });
  }

  void _onScroll() {
    // Detecta overscroll hacia arriba (el usuario arrastra más allá del límite superior)
    if (_scrollController.hasClients &&
        _scrollController.offset < -60.0 &&
        !_hasTriggeredReset) {
      _hasTriggeredReset = true;
      HapticFeedback.mediumImpact();
      ref.read(tunerProvider.notifier).resetAllBadges();
    }
    // Reset el flag cuando el scroll vuelve a posición normal
    if (_scrollController.offset >= -20.0) {
      _hasTriggeredReset = false;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  String _getNoteInSpanish(String? noteName) {
    if (noteName == null) return '--';
    switch (noteName) {
      case 'C':
        return 'Do';
      case 'C#':
        return 'Do#';
      case 'D':
        return 'Re';
      case 'D#':
        return 'Re#';
      case 'E':
        return 'Mi';
      case 'F':
        return 'Fa';
      case 'F#':
        return 'Fa#';
      case 'G':
        return 'Sol';
      case 'G#':
        return 'Sol#';
      case 'A':
        return 'La';
      case 'A#':
        return 'La#';
      case 'B':
        return 'Si';
      default:
        return noteName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tunerState = ref.watch(tunerProvider);
    final currentNoteModel = tunerState.currentNote;
    final appliedTuning = ref.watch(tunerSettingsProvider).appliedTuning;
    final appliedTuningShortLabel = appliedTuning.displayLabel
        .split(' (')
        .first;
    final List<String> stringLabels = List.generate(6, (i) {
      final number = i + 1;
      final tunedString = appliedTuning.strings.firstWhere(
        (s) => s.number == number,
        orElse: () => appliedTuning.strings.first,
      );
      return tunedString.displayName;
    });

    final String displayNote = _getNoteInSpanish(currentNoteModel?.name);
    final String octaveNotation = currentNoteModel != null
        ? '${currentNoteModel.name}${currentNoteModel.octave}'
        : 'A₂';
    final double currentFrequency = currentNoteModel?.currentFrequency ?? 110.0;
    final double cents = currentNoteModel?.centsOffset ?? 0.0;
    final bool isTuned = currentNoteModel?.status == TuningStatus.inTune;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF4F7FC), Color(0xFFE8EEF7)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: NotificationListener<OverscrollNotification>(
            onNotification: (notification) {
              // OverscrollNotification complementa el ScrollController
              // para físicas que no actualicen el offset (e.g. BouncingScrollPhysics)
              if (notification.overscroll < -1 && !_hasTriggeredReset) {
                _hasTriggeredReset = true;
                HapticFeedback.mediumImpact();
                ref.read(tunerProvider.notifier).resetAllBadges();
              }
              return false;
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // --- INDICADOR DE PULL-TO-RESET ---
                      _PullToResetIndicator(
                        scrollController: _scrollController,
                      ),
                      // --- ENCABEZADO ---
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6C5CE7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'PT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    RichText(
                                      text: const TextSpan(
                                        text: 'Pick',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0F172A),
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Tuner',
                                            style: TextStyle(color: Color(0xFF6C5CE7)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const TunerSettingsScreen(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Guitarra 6 cuerdas',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        size: 16,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4F2FF),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          appliedTuningShortLabel,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF5A48D9),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Contenedor estilizado del MODO AUTOMÁTICO
                            Container(
                              padding: const EdgeInsets.only(
                                left: 14,
                                right: 4,
                                top: 4,
                                bottom: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF1F5F9,
                                ).withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RichText(
                                    textAlign: TextAlign.end,
                                    text: const TextSpan(
                                      text: 'MODO\n',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF94A3B8),
                                        height: 1.1,
                                        letterSpacing: 0.5,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'AUTOM.',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF6C5CE7),
                                            height: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Switch.adaptive(
                                      value: tunerState.isAutoMode,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: const Color(0xFF6C5CE7),
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: const Color(0xFFCBD5E1),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      onChanged: (val) {
                                        ref
                                            .read(tunerProvider.notifier)
                                            .toggleAutoMode(val);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- ZONA DEL AFINADOR CON TRAMA DE PUNTOS ---
                      CustomPaint(
                        painter: TunerGridBackgroundPainter(),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            // DETECCIÓN DE NOTA
                            Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      displayNote,
                                      style: const TextStyle(
                                        fontSize: 72,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F172A),
                                        height: 1.0,
                                        letterSpacing: -1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '$octaveNotation  •  ${currentFrequency.toStringAsFixed(2)} Hz',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  right: -80,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${tunerState.activeStringNumber}ª cuerda',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ESTADO TENSAR / DESTENSAR Y BADGE DE AFINACIÓN
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '« TENSAR',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF94A3B8),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isTuned
                                          ? const Color(0xFFE6F9F0)
                                          : const Color(0xFFFFF0F0),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isTuned
                                            ? const Color(0xFF00B894)
                                            : const Color(0xFFFF7675),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      isTuned ? 'AFINADO' : 'DESAFINADO',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: isTuned
                                            ? const Color(0xFF00B894)
                                            : const Color(0xFFFF7675),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'DESTENSAR »',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF94A3B8),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // MEDIDOR DE PÚA
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: TuningPickGauge(cents: cents, isTuned: isTuned),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // --- PALA DE LA GUITARRA EN TUNERSCREEN ---
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PhotoHeadstockWidget(
                          activeStringNumber: tunerState.activeStringNumber,
                          stringLabels: stringLabels,
                          tunedStrings: tunerState.tunedStrings,
                          tuningProgress: tunerState.tuningProgress,
                          onSelectString: (stringNum) {
                            ref
                                .read(tunerProvider.notifier)
                                .selectString(stringNum);
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 80,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.0),
                                  const Color(0xFFE8EEF7).withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 55),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// INDICADOR VISUAL DE PULL-TO-RESET
// -----------------------------------------------------------------------------
class _PullToResetIndicator extends StatefulWidget {
  final ScrollController scrollController;
  const _PullToResetIndicator({required this.scrollController});

  @override
  State<_PullToResetIndicator> createState() => _PullToResetIndicatorState();
}

class _PullToResetIndicatorState extends State<_PullToResetIndicator> {
  double _pullProgress = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    final offset = widget.scrollController.offset;
    // offset negativo = pull hacia arriba. Mapea -0 a -80 => 0.0 a 1.0
    final progress = ((-offset) / 80.0).clamp(0.0, 1.0);
    if (progress != _pullProgress) {
      setState(() => _pullProgress = progress);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pullProgress <= 0.0) return const SizedBox.shrink();

    final bool willTrigger = _pullProgress >= 0.75;

    return Opacity(
      opacity: _pullProgress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedRotation(
              turns: _pullProgress * 0.5,
              duration: Duration.zero,
              child: Icon(
                willTrigger ? Icons.refresh_rounded : Icons.arrow_upward_rounded,
                size: 14,
                color: willTrigger
                    ? const Color(0xFF6C5CE7)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              willTrigger ? 'Suelta para resetear' : 'Sube para resetear badges',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: willTrigger
                    ? const Color(0xFF6C5CE7)
                    : const Color(0xFF94A3B8),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PAINTER DEL FONDO DE PUNTOS
// Definido en el nivel superior (top-level) fuera de las clases del widget
// -----------------------------------------------------------------------------
class TunerGridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0xFF6C5CE7).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    const double stepX = 28.0;
    const double stepY = 24.0;

    for (double x = stepX / 2; x < size.width; x += stepX) {
      for (double y = stepY / 2; y < size.height; y += stepY) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
