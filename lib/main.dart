import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/tuner/presentation/screens/main_shell_screen.dart';

void main() {
  runApp(const ProviderScope(child: PickTunerApp()));
}

class PickTunerApp extends StatelessWidget {
  const PickTunerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PickTuner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: const MainShellScreen(),
    );
  }
}
