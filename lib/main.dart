import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Importar Riverpod

import 'package:picktuner_mobile/features/tuner/presentation/screens/tuner_screen.dart';

void main() {
  runApp(
    // 2. Envolver la aplicación completa en ProviderScope
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PickTuner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TunerScreen(),
    );
  }
}
