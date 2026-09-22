import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/chord_database.dart';
import '../../domain/models/chord_models.dart';

class ChordBankState {
  final String selectedRoot;
  final ChordQuality selectedQuality;
  final int variationIndex;
  final String searchQuery;

  const ChordBankState({
    this.selectedRoot = 'A',
    this.selectedQuality = ChordQuality.minor,
    this.variationIndex = 0,
    this.searchQuery = '',
  });

  ChordEntry? get currentEntry =>
      ChordDatabase.lookup(selectedRoot, selectedQuality);

  ChordBankState copyWith({
    String? selectedRoot,
    ChordQuality? selectedQuality,
    int? variationIndex,
    String? searchQuery,
  }) {
    return ChordBankState(
      selectedRoot: selectedRoot ?? this.selectedRoot,
      selectedQuality: selectedQuality ?? this.selectedQuality,
      variationIndex: variationIndex ?? this.variationIndex,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ChordBankNotifier extends StateNotifier<ChordBankState> {
  ChordBankNotifier() : super(const ChordBankState());

  void selectRoot(String root) {
    state = state.copyWith(selectedRoot: root, variationIndex: 0);
  }

  void selectQuality(ChordQuality quality) {
    state = state.copyWith(selectedQuality: quality, variationIndex: 0);
  }

  void selectChord(String root, ChordQuality quality) {
    state = state.copyWith(
      selectedRoot: root,
      selectedQuality: quality,
      variationIndex: 0,
      searchQuery: '',
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void nextVariation() {
    final entry = state.currentEntry;
    if (entry == null) return;
    final next = (state.variationIndex + 1) % entry.variations.length;
    state = state.copyWith(variationIndex: next);
  }

  void previousVariation() {
    final entry = state.currentEntry;
    if (entry == null) return;
    final count = entry.variations.length;
    final prev = (state.variationIndex - 1 + count) % count;
    state = state.copyWith(variationIndex: prev);
  }
}

final chordBankProvider =
    StateNotifierProvider<ChordBankNotifier, ChordBankState>((ref) {
      return ChordBankNotifier();
    });
