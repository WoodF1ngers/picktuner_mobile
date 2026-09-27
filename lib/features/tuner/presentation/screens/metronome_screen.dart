import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/metronome_provider.dart';
import '../providers/metronome_sound_presets.dart';
import '../providers/theme_provider.dart';

class MetronomeScreen extends ConsumerWidget {
  const MetronomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(metronomeProvider);
    final notifier = ref.read(metronomeProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : const Color(0xFF161D1F);
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : const Color(0xFF464554);
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : const Color(0xFF6C5CE7);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkNeutralBackground
          : const Color(0xFFF4FAFD),
      body: SafeArea(
        // Reemplazamos SingleChildScrollView + Column por ListView
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 12.0,
            bottom: 100.0,
          ),
          children: [
            // Sub-header context strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSecondary
                            : const Color(0xFF006B55),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ACOUSTIC ENGINE V2.4',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showSoundSelector(
                    context,
                    ref,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    primaryColor: primaryColor,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : const Color(0xFFE8EFF1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.graphic_eq, size: 16, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          state.soundPresetName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Dial Visualizer Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _BpmDial(
                    bpm: state.bpm,
                    tempoMarking: state.tempoMarking,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    primaryColor: primaryColor,
                    onBpmChanged: notifier.adjustBpm,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepButton('-5', () => notifier.adjustBpm(-5)),
                      const SizedBox(width: 8),
                      _buildStepButton('-1', () => notifier.adjustBpm(-1)),
                      const SizedBox(width: 12),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC7C4D7),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStepButton('+1', () => notifier.adjustBpm(1)),
                      const SizedBox(width: 8),
                      _buildStepButton('+5', () => notifier.adjustBpm(5)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botón central Play / Pause
            Center(
              child: GestureDetector(
                onTap: () => notifier.togglePlay(),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: state.isPlaying
                        ? const Color(0xFFBC4446)
                        : const Color(0xFF6757E2),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(108, 92, 231, 0.38),
                        blurRadius: 28,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    state.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card Métrica y Pulsos
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'COMPÁS / MÉTRICA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textSecondary,
                        ),
                      ),
                      Text(
                        'Cuarto (1/4)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [2, 3, 4, 6].map((sig) {
                      final isSelected = state.timeSignature == sig;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? primaryColor
                                  : (isDark
                                        ? AppColors.darkSurfaceVariant
                                        : const Color(0xFFEEF5F7)),
                              foregroundColor: isSelected
                                  ? Colors.white
                                  : textSecondary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => notifier.setTimeSignature(sig),
                            child: Text('$sig/4'),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PULSO EN VIVO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textSecondary,
                        ),
                      ),
                      Text(
                        '${state.currentBeat + 1} / ${state.timeSignature}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkSecondary
                              : const Color(0xFF006B55),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // LEDs de pulso
                  Row(
                    children: List.generate(state.timeSignature, (index) {
                      final isActive =
                          state.isPlaying && state.currentBeat == index;
                      final isAccent = index == 0;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 40,
                          decoration: BoxDecoration(
                            color: isActive
                                ? (isAccent
                                      ? const Color(0xFF6757E2)
                                      : const Color(0xFF6DFAD2))
                                : (isDark
                                      ? AppColors.darkSurfaceVariant
                                      : const Color(0xFFEEF5F7)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? (isAccent
                                          ? Colors.white
                                          : (isDark
                                                ? AppColors.darkSecondary
                                                : const Color(0xFF005140)))
                                    : textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Botones de Tap Tempo y Audio
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceVariant
                                : const Color(0xFFE8EFF1),
                            foregroundColor: textPrimary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => notifier.registerTap(),
                          icon: const Icon(
                            Icons.touch_app,
                            size: 20,
                            color: Color(0xFF4E3BC8),
                          ),
                          label: const Text(
                            'TAP TEMPO',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceVariant
                                : const Color(0xFFE8EFF1),
                            foregroundColor: textPrimary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => notifier.toggleMute(),
                          icon: Icon(
                            state.isMuted ? Icons.volume_off : Icons.volume_up,
                            size: 20,
                            color: state.isMuted
                                ? const Color(0xFFBA1A1A)
                                : textSecondary,
                          ),
                          label: Text(
                            state.isMuted ? 'Mute' : 'Audio',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Advice Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSecondary.withValues(alpha: 0.16)
                    : const Color(0xFF6DFAD2).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: isDark
                        ? AppColors.darkSecondary
                        : const Color(0xFF006B55),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consejo de groove',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkSecondary
                                : const Color(0xFF005140),
                          ),
                        ),
                        Text(
                          'Comienza a 60 BPM para dominar el cambio limpio de acordes.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : const Color(0xFF005140),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Si agregas nuevos widgets aquí más adelante, no necesitas agregar
            // ningún SizedBox extra al final; el padding inferior del ListView lo gestiona solo.
          ],
        ),
      ),
    );
  }

  Future<void> _showSoundSelector(
    BuildContext context,
    WidgetRef ref, {
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
  }) async {
    final notifier = ref.read(metronomeProvider.notifier);
    final selectedId = ref.read(metronomeProvider).soundPresetId;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 620),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.45)
                        : const Color(0xFFD6DDE0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.graphic_eq, color: primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sonido del metrónomo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Elige el tick normal y el acentuado.',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: metronomeSoundPresets.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final preset = metronomeSoundPresets[index];
                      final selected = preset.id == selectedId;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            await notifier.selectSoundPreset(preset.id);
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? primaryColor.withValues(alpha: 0.10)
                                  : (isDark
                                        ? AppColors.darkSurfaceVariant
                                        : const Color(0xFFF4F7F8)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? primaryColor.withValues(alpha: 0.45)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.multitrack_audio,
                                  size: 20,
                                  color: selected
                                      ? primaryColor
                                      : textSecondary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    preset.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  Icon(
                                    Icons.check_circle,
                                    color: primaryColor,
                                    size: 21,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 48,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEEF5F7),
          foregroundColor: const Color(0xFF161D1F),
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}

class _BpmDial extends StatefulWidget {
  final int bpm;
  final String tempoMarking;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color primaryColor;
  final ValueChanged<int> onBpmChanged;

  const _BpmDial({
    required this.bpm,
    required this.tempoMarking,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.primaryColor,
    required this.onBpmChanged,
  });

  @override
  State<_BpmDial> createState() => _BpmDialState();
}

class _BpmDialState extends State<_BpmDial> {
  // Sensibilidad: 12 grados de giro físico equivalen a 1 BPM.
  static const double _degreesPerBpm = 3.0;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: <Type, GestureRecognizerFactory>{
        _BpmDialGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_BpmDialGestureRecognizer>(
              () => _BpmDialGestureRecognizer(
                onBpmChanged: widget.onBpmChanged,
                degreesPerBpm: _degreesPerBpm,
              ),
              (instance) {
                instance.onBpmChanged = widget.onBpmChanged;
                instance.degreesPerBpm = _degreesPerBpm;
              },
            ),
      },
      child: SizedBox(
        width: 280,
        height: 280,
        child: Center(
          child: SizedBox(
            width: 230,
            height: 230,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(230, 230),
                  painter: MetronomeArcPainter(
                    bpm: widget.bpm,
                    isDark: widget.isDark,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.bpm}',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: widget.textPrimary,
                        letterSpacing: -2,
                      ),
                    ),
                    Text(
                      'BPM',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.tempoMarking,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Captura el gesto desde el primer contacto dentro de los 280x280 px.
///
/// Esto es intencional: al aceptar el gesto inmediatamente, el ListView padre
/// no puede apropiarse de un movimiento vertical iniciado sobre el dial.
/// Así el dedo puede entrar por cualquier lado del área táctil y girar
/// físicamente alrededor del centro, sin importar la dirección inicial.
class _BpmDialGestureRecognizer extends OneSequenceGestureRecognizer {
  _BpmDialGestureRecognizer({this.onBpmChanged, required this.degreesPerBpm});

  ValueChanged<int>? onBpmChanged;
  double degreesPerBpm;

  double? _previousAngle;
  double _accumulatedDegrees = 0;
  bool _ended = false;

  double _normalizeAngle(double angle) {
    if (angle > math.pi) {
      return angle - (2 * math.pi);
    }
    if (angle < -math.pi) {
      return angle + (2 * math.pi);
    }
    return angle;
  }

  void _reset() {
    _previousAngle = null;
    _accumulatedDegrees = 0;
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);

    const center = Offset(140, 140);
    final vector = event.localPosition - center;

    _ended = false;
    _reset();

    if (vector.distance >= 16) {
      _previousAngle = math.atan2(vector.dy, vector.dx);
    }

    // El dial gana deliberadamente el gesto frente al ListView padre.
    resolve(GestureDisposition.accepted);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      const center = Offset(140, 140);
      final vector = event.localPosition - center;

      if (vector.distance < 16) {
        return;
      }

      final angle = math.atan2(vector.dy, vector.dx);

      if (_previousAngle == null) {
        _previousAngle = angle;
        return;
      }

      final deltaRadians = _normalizeAngle(angle - _previousAngle!);
      _previousAngle = angle;

      // Giro horario -> aumenta BPM.
      // Giro antihorario -> disminuye BPM.
      final deltaDegrees = deltaRadians * 180 / math.pi;
      _accumulatedDegrees += deltaDegrees;

      final bpmDelta = (_accumulatedDegrees / degreesPerBpm).truncate();

      if (bpmDelta != 0) {
        onBpmChanged?.call(bpmDelta);
        _accumulatedDegrees -= bpmDelta * degreesPerBpm;
      }
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    if (!_ended) {
      _ended = true;
      _reset();
    }
  }

  @override
  String get debugDescription => 'bpm dial circular gesture';

  @override
  void dispose() {
    _reset();
    super.dispose();
  }
}

class MetronomeArcPainter extends CustomPainter {
  final int bpm;
  final bool isDark;

  MetronomeArcPainter({required this.bpm, this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    final primaryColor = isDark
        ? AppColors.darkPrimary
        : const Color(0xFF6757E2);
    final secondaryColor = isDark
        ? AppColors.darkSecondary
        : const Color(0xFF4029BA);
    final trackColor = isDark
        ? AppColors.darkSurfaceVariant
        : const Color(0xFFE8EFF1);

    // Profundidad 2.5D muy sutil para que el control se lea como un dial.
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.22 : 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center.translate(0, 4), radius - 28, shadowPaint);

    final innerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          isDark
              ? AppColors.darkTextPrimary.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.95),
          isDark
              ? AppColors.darkSurfaceVariant.withValues(alpha: 0.55)
              : const Color(0xFFF0F4F5),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 26));
    canvas.drawCircle(center, radius - 27, innerPaint);

    final innerRing = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.10 : 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 27, innerRing);

    // Marcas sutiles para reforzar la lectura de una perilla física.
    final tickPaint = Paint()
      ..color = isDark
          ? AppColors.darkTextSecondary.withValues(alpha: 0.30)
          : const Color(0xFF8D989D).withValues(alpha: 0.28)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 24; i++) {
      final tickAngle = -math.pi / 2 + (2 * math.pi * i / 24);
      final tickOuter = Offset(
        center.dx + (radius + 8) * math.cos(tickAngle),
        center.dy + (radius + 8) * math.sin(tickAngle),
      );
      final tickInner = Offset(
        center.dx + (radius + 3) * math.cos(tickAngle),
        center.dy + (radius + 3) * math.sin(tickAngle),
      );
      canvas.drawLine(tickInner, tickOuter, tickPaint);
    }

    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final progressFraction = ((bpm - 40) / (240 - 40)).clamp(0.0, 1.0);
    final sweepAngle = 2 * math.pi * progressFraction;

    final arcPaint = Paint()
      ..shader = LinearGradient(colors: [primaryColor, secondaryColor])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    // Rayita del potenciómetro: indica con precisión la posición actual.
    final knobAngle = -math.pi / 2 + sweepAngle;
    final outerPoint = Offset(
      center.dx + (radius + 1) * math.cos(knobAngle),
      center.dy + (radius + 1) * math.sin(knobAngle),
    );
    final innerPoint = Offset(
      center.dx + (radius - 13) * math.cos(knobAngle),
      center.dy + (radius - 13) * math.sin(knobAngle),
    );

    final knobShadow = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.30 : 0.12)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      innerPoint.translate(0, 2),
      outerPoint.translate(0, 2),
      knobShadow,
    );

    final knobLine = Paint()
      ..shader = LinearGradient(colors: [primaryColor, secondaryColor])
          .createShader(Rect.fromPoints(innerPoint, outerPoint))
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(innerPoint, outerPoint, knobLine);

    final knobCap = Paint()
      ..color = isDark ? AppColors.darkTextPrimary : Colors.white;
    canvas.drawCircle(outerPoint, 3.5, knobCap);
  }

  @override
  bool shouldRepaint(covariant MetronomeArcPainter oldDelegate) {
    return oldDelegate.bpm != bpm || oldDelegate.isDark != isDark;
  }
}
