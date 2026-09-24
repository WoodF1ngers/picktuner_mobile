import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_preferences_screen.dart';
import '../../domain/chord_audio_synth.dart';
import '../../domain/chord_database.dart';
import '../../domain/models/chord_models.dart';
import '../../domain/related_chords.dart';
import '../providers/chord_bank_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/fretboard_painter.dart';

const List<String> _kRootPills = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];

class ChordBankScreen extends ConsumerStatefulWidget {
  const ChordBankScreen({super.key});

  @override
  ConsumerState<ChordBankScreen> createState() => _ChordBankScreenState();
}

class _ChordBankScreenState extends ConsumerState<ChordBankScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chordState = ref.watch(chordBankProvider);
    final notifier = ref.read(chordBankProvider.notifier);
    final entry = chordState.currentEntry;

    final searchResults = chordState.searchQuery.trim().isEmpty
        ? const <ChordEntry>[]
        : ChordDatabase.search(chordState.searchQuery);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF4FAFD),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            const _ChordsHeader(),
            const SizedBox(height: 14),
            _SearchBar(
              controller: _searchController,
              onChanged: notifier.setSearchQuery,
              onClear: () {
                _searchController.clear();
                notifier.setSearchQuery('');
              },
            ),
            if (searchResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SearchResultsList(
                results: searchResults,
                onSelect: (e) {
                  _searchController.clear();
                  notifier.selectChord(e.rootNote, e.quality);
                },
              ),
            ],
            const SizedBox(height: 14),
            _RootSelector(
              selectedRoot: chordState.selectedRoot,
              onSelected: notifier.selectRoot,
            ),
            const SizedBox(height: 10),
            _QualitySelector(
              selectedQuality: chordState.selectedQuality,
              onSelected: notifier.selectQuality,
            ),
            const SizedBox(height: 16),
            if (entry == null)
              _UnavailableChordCard(
                root: chordState.selectedRoot,
                quality: chordState.selectedQuality,
              )
            else ...[
              _ChordCard(
                entry: entry,
                variationIndex: chordState.variationIndex,
              ),
              const SizedBox(height: 20),
              _RelatedChordsSection(entry: entry, notifier: notifier),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChordsHeader extends StatelessWidget {
  const _ChordsHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkPrimary : const Color(0xFF6757E2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppColors.darkPrimary : const Color(0xFF6C5CE7)).withValues(alpha: 0.24),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PickTuner',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF161D1F),
                    letterSpacing: -0.2,
                    height: 1.0,
                  ),
                ),
                Text(
                  'ACORDES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF464554),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AppPreferencesScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.settings_outlined,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF464554),
                size: 22,
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkPrimary : const Color(0xFF4E3BC8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF767586),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Buscar acorde (ej. Am, C7, G)...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF767586),
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF161D1F),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE8EFF1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 15,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF767586),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  final List<ChordEntry> results;
  final ValueChanged<ChordEntry> onSelect;

  const _SearchResultsList({required this.results, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: results.take(6).map((e) {
          return ListTile(
            dense: true,
            title: Text(
              e.symbol,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : Colors.black,
              ),
            ),
            subtitle: Text(
              e.spanishName,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : Colors.black54,
              ),
            ),
            onTap: () => onSelect(e),
          );
        }).toList(),
      ),
    );
  }
}

class _RootSelector extends StatelessWidget {
  final String selectedRoot;
  final ValueChanged<String> onSelected;

  const _RootSelector({required this.selectedRoot, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _kRootPills.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final root = _kRootPills[index];
          final isSelected = root == selectedRoot;
          return GestureDetector(
            onTap: () => onSelected(root),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.darkPrimary : const Color(0xFF6757E2))
                    : (isDark ? AppColors.darkSurface : Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? (isDark ? AppColors.darkPrimary : const Color(0xFF6C5CE7)).withValues(alpha: 0.28)
                        : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: isSelected ? 12 : 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    root,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextPrimary : const Color(0xFF464554)),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 5),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSecondary : const Color(0xFF6DFAD2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QualitySelector extends StatelessWidget {
  final ChordQuality selectedQuality;
  final ValueChanged<ChordQuality> onSelected;

  const _QualitySelector({
    required this.selectedQuality,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ChordQuality.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final quality = ChordQuality.values[index];
          final isSelected = quality == selectedQuality;
          return GestureDetector(
            onTap: () => onSelected(quality),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.darkPrimary : const Color(0xFF4E3BC8))
                    : (isDark ? AppColors.darkSurface : Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                quality.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : const Color(0xFF464554)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UnavailableChordCard extends StatelessWidget {
  final String root;
  final ChordQuality quality;

  const _UnavailableChordCard({required this.root, required this.quality});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final symbol = '$root${quality.symbolSuffix}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.construction_rounded,
            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF767586),
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            '$symbol aún no está en el banco',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: isDark ? AppColors.darkTextPrimary : Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Estamos agregando digitaciones verificadas poco a poco.\nElige otra raíz o calidad mientras tanto.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChordCard extends ConsumerStatefulWidget {
  final ChordEntry entry;
  final int variationIndex;

  const _ChordCard({required this.entry, required this.variationIndex});

  @override
  ConsumerState<_ChordCard> createState() => _ChordCardState();
}

class _ChordCardState extends ConsumerState<_ChordCard> {
  bool _isFavorite = false;
  bool _isPlaying = false;

  Future<void> _playChord(ChordVariation variation) async {
    setState(() => _isPlaying = true);
    await ChordAudioSynth.playVariation(variation);
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entry = widget.entry;
    final variation =
        entry.variations[widget.variationIndex.clamp(
          0,
          entry.variations.length - 1,
        )];
    final notifier = ref.read(chordBankProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkPrimary : const Color(0xFF6C5CE7)).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          entry.spanishName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkPrimary.withValues(alpha: 0.25)
                                : const Color(0xFFE4DFFF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            entry.symbol,
                            style: TextStyle(
                              color: isDark ? AppColors.darkSecondary : const Color(0xFF4E3BC8),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      entry.intervalsLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF464554),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isFavorite = !_isFavorite),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE8EFF1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: _isFavorite
                        ? (isDark ? AppColors.darkTertiary : const Color(0xFFBA1A1A))
                        : (isDark ? AppColors.darkTextSecondary : const Color(0xFF464554)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: AspectRatio(
              aspectRatio: 240 / 200,
              child: CustomPaint(painter: FretboardPainter(variation, isDark: isDark)),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              final labels = ['E', 'A', 'D', 'G', 'B', 'e'];
              return SizedBox(
                width: 40,
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF767586),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _playChord(variation),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _isPlaying
                    ? (isDark ? AppColors.darkSecondary : const Color(0xFF6DFAD2))
                    : (isDark ? AppColors.darkPrimary.withValues(alpha: 0.3) : const Color(0xFFE4DFFF)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isPlaying ? Icons.music_note : Icons.volume_up,
                    size: 20,
                    color: _isPlaying && isDark
                        ? AppColors.darkBackground
                        : (isDark ? AppColors.darkSecondary : const Color(0xFF4E3BC8)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isPlaying ? 'Reproduciendo...' : 'Escuchar Acorde',
                    style: TextStyle(
                      color: _isPlaying && isDark
                          ? AppColors.darkBackground
                          : (isDark ? AppColors.darkSecondary : const Color(0xFF4E3BC8)),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (entry.variations.length > 1) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFEEF5F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      size: 18,
                      color: isDark ? AppColors.darkTextPrimary : Colors.black,
                    ),
                    onPressed: notifier.previousVariation,
                  ),
                  Column(
                    children: [
                      Text(
                        'Posición ${widget.variationIndex + 1} de ${entry.variations.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(entry.variations.length, (i) {
                          final active = i == widget.variationIndex;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: active ? 8 : 6,
                            height: active ? 8 : 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? (isDark ? AppColors.darkSecondary : const Color(0xFF4E3BC8))
                                  : (isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.4) : const Color(0xFFC7C4D7)),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: isDark ? AppColors.darkTextPrimary : Colors.black,
                    ),
                    onPressed: notifier.nextVariation,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RelatedChordsSection extends StatelessWidget {
  final ChordEntry entry;
  final ChordBankNotifier notifier;

  const _RelatedChordsSection({required this.entry, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final related = computeRelatedChords(entry);
    if (related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Acordes Relacionados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : Colors.black,
              ),
            ),
            Text(
              'ESCALA ${entry.symbol.toUpperCase()}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkSecondary : const Color(0xFF4E3BC8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: related.map((r) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () =>
                      notifier.selectChord(r.entry.rootNote, r.entry.quality),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          r.entry.symbol,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          r.relationLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF767586),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

