import 'package:flutter/material.dart';

import '../providers/tuner_settings_provider.dart';
import 'photo_headstock_inline_widget.dart';
import 'photo_headstock_widget.dart';

class GuitarHeadstockWidget extends StatelessWidget {
  final int activeStringNumber; // 1 (E agudo) a 6 (E grave)
  final Function(int) onSelectString;
  final List<String>? stringLabels;
  final HeadstockLayout layout;

  const GuitarHeadstockWidget({
    super.key,
    required this.activeStringNumber,
    required this.onSelectString,
    this.stringLabels,
    this.layout = HeadstockLayout.threeAndThree,
  });

  @override
  Widget build(BuildContext context) {
    if (layout == HeadstockLayout.threeAndThree) {
      return PhotoHeadstockWidget(
        activeStringNumber: activeStringNumber,
        stringLabels: stringLabels,
        onSelectString: onSelectString,
      );
    }

    return PhotoHeadstockInlineWidget(
      activeStringNumber: activeStringNumber,
      stringLabels: stringLabels,
      onSelectString: onSelectString,
    );
  }
}
