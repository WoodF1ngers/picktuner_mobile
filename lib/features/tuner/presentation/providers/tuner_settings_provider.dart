import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/instrument_tuning.dart';
import '../../domain/tuning_database.dart';

enum HeadstockLayout { threeAndThree, inline }

class TunerSettingsState {
  final InstrumentTuning appliedTuning;
  final HeadstockLayout headstockLayout;
  final double referenceA4;

  const TunerSettingsState({
    required this.appliedTuning,
    this.headstockLayout = HeadstockLayout.threeAndThree,
    this.referenceA4 = 440.0,
  });

  TunerSettingsState copyWith({
    InstrumentTuning? appliedTuning,
    HeadstockLayout? headstockLayout,
    double? referenceA4,
  }) {
    return TunerSettingsState(
      appliedTuning: appliedTuning ?? this.appliedTuning,
      headstockLayout: headstockLayout ?? this.headstockLayout,
      referenceA4: referenceA4 ?? this.referenceA4,
    );
  }
}

class TunerSettingsNotifier extends StateNotifier<TunerSettingsState> {
  TunerSettingsNotifier()
    : super(TunerSettingsState(appliedTuning: TuningDatabase.defaultTuning));

  void applyTuning(InstrumentTuning tuning) {
    state = state.copyWith(appliedTuning: tuning);
  }

  void setHeadstockLayout(HeadstockLayout layout) {
    state = state.copyWith(headstockLayout: layout);
  }
}

final tunerSettingsProvider =
    StateNotifierProvider<TunerSettingsNotifier, TunerSettingsState>((ref) {
      return TunerSettingsNotifier();
    });
