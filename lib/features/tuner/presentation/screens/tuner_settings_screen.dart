import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/instrument_tuning.dart';
import '../../domain/tuning_database.dart';
import '../providers/tuner_settings_provider.dart';

class TunerSettingsScreen extends ConsumerStatefulWidget {
  const TunerSettingsScreen({super.key});

  @override
  ConsumerState<TunerSettingsScreen> createState() => _TunerSettingsScreenState();
}

class _TunerSettingsScreenState extends ConsumerState<TunerSettingsScreen> {
  late InstrumentTuning _pendingTuning;
  late HeadstockLayout _headstockLayout;
  final Set<String> _expandedGroupIds = {'guitar6'};
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(tunerSettingsProvider);
    _pendingTuning = settings.appliedTuning;
    _headstockLayout = settings.headstockLayout;
  }

  void _showComingSoonSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Este instrumento estará disponible próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _applyTuning() async {
    setState(() => _isApplying = true);
    ref.read(tunerSettingsProvider.notifier).applyTuning(_pendingTuning);
    ref.read(tunerSettingsProvider.notifier).setHeadstockLayout(_headstockLayout);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFD),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                children: [
                  _HeadstockToggle(
                    layout: _headstockLayout,
                    onChanged: (layout) => setState(() => _headstockLayout = layout),
                  ),
                  const SizedBox(height: 12),
                  _ActivePreviewPill(layout: _headstockLayout),
                  const SizedBox(height: 20),
                  _SectionLabel(
                    label: 'Recientes',
                    trailingIcon: Icons.history,
                    trailingLabel: 'Historial',
                  ),
                  const SizedBox(height: 8),
                  _RecentTuningCard(
                    tuning: ref.watch(tunerSettingsProvider).appliedTuning,
                    isSelected: _pendingTuning.id == ref.watch(tunerSettingsProvider).appliedTuning.id,
                    onTap: () => setState(
                      () => _pendingTuning = ref.read(tunerSettingsProvider).appliedTuning,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel(label: 'Todas las afinaciones'),
                  const SizedBox(height: 8),
                  ...TuningDatabase.all.map((group) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _InstrumentAccordion(
                        group: group,
                        isExpanded: _expandedGroupIds.contains(group.id),
                        pendingTuningId: _pendingTuning.id,
                        onToggleExpand: () => setState(() {
                          if (_expandedGroupIds.contains(group.id)) {
                            _expandedGroupIds.remove(group.id);
                          } else {
                            _expandedGroupIds.add(group.id);
                          }
                        }),
                        onSelectTuning: (tuning) {
                          if (!group.isFunctional) {
                            _showComingSoonSnack();
                            return;
                          }
                          setState(() => _pendingTuning = tuning);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            _ApplyBar(
              pendingTuning: _pendingTuning,
              isApplying: _isApplying,
              onApply: _applyTuning,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          const Expanded(
            child: Text(
              'Configuración Acústica',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF161D1F),
                letterSpacing: -0.2,
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(color: Color(0xFF4E3BC8), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

class _HeadstockToggle extends StatelessWidget {
  final HeadstockLayout layout;
  final ValueChanged<HeadstockLayout> onChanged;

  const _HeadstockToggle({required this.layout, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E9EC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              icon: Icons.tune,
              label: '3+3 Clavijero',
              isActive: layout == HeadstockLayout.threeAndThree,
              onTap: () => onChanged(HeadstockLayout.threeAndThree),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              icon: Icons.list,
              label: '6 En Línea',
              isActive: layout == HeadstockLayout.inline,
              onTap: () => onChanged(HeadstockLayout.inline),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isActive ? const Color(0xFF4E3BC8) : const Color(0xFF464554)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF161D1F) : const Color(0xFF464554),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivePreviewPill extends StatelessWidget {
  final HeadstockLayout layout;

  const _ActivePreviewPill({required this.layout});

  @override
  Widget build(BuildContext context) {
    final description = layout == HeadstockLayout.threeAndThree
        ? 'Distribución balanceada L-R (Gibson style)'
        : 'Alineación superior 6 en línea (Fender style)';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFFE4DFFF), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.music_note, color: Color(0xFF4E3BC8), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Paso Clave Activo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF464554))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFF6DFAD2), borderRadius: BorderRadius.circular(20)),
            child: const Text(
              'A=440Hz',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF005140)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData? trailingIcon;
  final String? trailingLabel;

  const _SectionLabel({required this.label, this.trailingIcon, this.trailingLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF767586), letterSpacing: 0.6),
          ),
          if (trailingLabel != null)
            Row(
              children: [
                if (trailingIcon != null) Icon(trailingIcon, size: 13, color: const Color(0xFF4E3BC8)),
                const SizedBox(width: 3),
                Text(trailingLabel!, style: const TextStyle(fontSize: 12, color: Color(0xFF4E3BC8))),
              ],
            ),
        ],
      ),
    );
  }
}

class _RecentTuningCard extends StatelessWidget {
  final InstrumentTuning tuning;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecentTuningCard({required this.tuning, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: Color(0xFF6DFAD2), shape: BoxShape.circle),
              child: const Icon(Icons.graphic_eq, color: Color(0xFF006B55), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Guitarra 6 Cuerdas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    tuning.displayLabel,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF464554)),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(color: Color(0xFF006B55), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class _InstrumentAccordion extends StatelessWidget {
  final InstrumentGroup group;
  final bool isExpanded;
  final String pendingTuningId;
  final VoidCallback onToggleExpand;
  final ValueChanged<InstrumentTuning> onSelectTuning;

  const _InstrumentAccordion({
    required this.group,
    required this.isExpanded,
    required this.pendingTuningId,
    required this.onToggleExpand,
    required this.onSelectTuning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpand,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: group.isFunctional ? const Color(0xFFE4DFFF) : const Color(0xFFE2E9EC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      group.isFunctional ? Icons.graphic_eq : Icons.speaker,
                      size: 18,
                      color: group.isFunctional ? const Color(0xFF4E3BC8) : const Color(0xFF464554),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(group.subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF767586))),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.expand_more, color: Color(0xFF767586)),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Column(
              children: group.tunings.map((tuning) {
                final isSelected = group.isFunctional && tuning.id == pendingTuningId;
                return InkWell(
                  onTap: () => onSelectTuning(tuning),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    color: isSelected ? const Color(0xFFE4DFFF).withValues(alpha: 0.4) : Colors.transparent,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF006B55) : const Color(0xFFC7C4D7),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tuning.displayLabel,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: const Color(0xFF161D1F),
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check, size: 18, color: Color(0xFF006B55)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _ApplyBar extends StatelessWidget {
  final InstrumentTuning pendingTuning;
  final bool isApplying;
  final VoidCallback onApply;

  const _ApplyBar({required this.pendingTuning, required this.isApplying, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: isApplying ? null : onApply,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF4E3BC8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isApplying)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  else
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isApplying ? 'Configurando afinador...' : 'Aplicar Afinación',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified, size: 14, color: Color(0xFF006B55)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Seleccionada: ${pendingTuning.displayLabel}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF464554)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
