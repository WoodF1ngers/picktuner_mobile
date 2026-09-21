import 'package:flutter/material.dart';
import 'package:picktuner_mobile/app/theme/app_colors.dart';
import 'package:picktuner_mobile/features/tuner/domain/models/tuning_status.dart';

// ...
// Para el warning de deprecación en la línea 89:
// Cambia: .withOpacity(0.5)
// Por:    .withValues(alpha: 0.5)

class TuningGauge extends StatelessWidget {
  final double centsOffset; // Valor de -50.0 a +50.0
  final TuningStatus status;

  const TuningGauge({
    super.key,
    required this.centsOffset,
    required this.status,
  });

  Color _getStatusColor() {
    switch (status) {
      case TuningStatus.inTune:
        return AppColors.inTune;
      case TuningStatus.sharp:
        return AppColors.sharp;
      case TuningStatus.flat:
        return AppColors.flat;
      case TuningStatus.undefined:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Normalizar centsOffset de [-50, 50] a una posición de [-1.0, 1.0]
    final double normalizedPosition = (centsOffset.clamp(-50.0, 50.0)) / 50.0;
    final Color currentColor = _getStatusColor();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Indicador numérico de cents
        Text(
          '${centsOffset > 0 ? "+" : ""}${centsOffset.toStringAsFixed(1)} cents',
          style: TextStyle(
            color: currentColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Barra/Dial de afinación
        Container(
          width: 300,
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: status == TuningStatus.inTune
                  ? AppColors.inTune.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Línea central (Afinado - 0 cents)
              Container(
                width: 4,
                height: 80,
                color: status == TuningStatus.inTune
                    ? AppColors.inTune
                    : AppColors.textMuted.withValues(alpha: 0.3),
              ),

              // Aguja / Indicador móvil
              AnimatedAlign(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                alignment: Alignment(normalizedPosition, 0),
                child: Container(
                  width: 6,
                  height: 90,
                  decoration: BoxDecoration(
                    color: currentColor,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: currentColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
