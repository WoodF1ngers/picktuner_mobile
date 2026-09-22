import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter_audio_capture/flutter_audio_capture.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:pitch_detector_dart/pitch_detector.dart';

class AudioPitchService {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();

  late final PitchDetector _pitchDetector;

  final StreamController<double> _pitchStreamController =
      StreamController<double>.broadcast();

  Stream<double> get pitchStream => _pitchStreamController.stream;

  bool _isListening = false;

  bool get isListening => _isListening;

  static const int sampleRate = 44100;

  static const int bufferSize = 2048;

  final List<double> _sampleBuffer = [];

  // Historial pequeño para suavizar las lecturas (Filtro de mediana/promedio)

  final List<double> _pitchHistory = [];

  static const int _historySize = 3;

  // El análisis de pitch (autocorrelación sobre 2048 muestras) corre en el
  // hilo principal de la UI. Ejecutarlo en cada chunk (20-40 veces/seg)
  // satura ese hilo y compite con el renderizado de frames, lo que
  // finalmente se manifiesta como el congelamiento de la app. Limitamos el
  // análisis real a ~10 veces por segundo; es más que suficiente para un
  // afinador y reduce drásticamente el trabajo de CPU/GC en el hilo de UI.
  DateTime _lastAnalysis = DateTime.fromMillisecondsSinceEpoch(0);

  static const Duration _analysisInterval = Duration(milliseconds: 90);

  AudioPitchService() {
    _pitchDetector = PitchDetector(
      audioSampleRate: sampleRate.toDouble(),

      bufferSize: bufferSize,
    );
  }

  Future<bool> startListening() async {
    if (_isListening) return true;

    final status = await Permission.microphone.request();

    if (!status.isGranted) return false;

    try {
      await _audioCapture.init();

      await _audioCapture.start(
        _onAudioData,

        _onError,

        sampleRate: sampleRate,

        bufferSize: bufferSize,

        // El plugin espera por defecto solo 1s el primer dato de audio en
        // Android y lanza TimeoutException si no llega a tiempo (esto
        // causaba que el afinador pareciera "congelarse" sin dar ningún
        // aviso). Le damos más margen para que el motor de audio nativo
        // termine de inicializar antes de fallar.
        firstDataTimeout: const Duration(seconds: 5),
      );

      _isListening = true;

      return true;
    } catch (e) {
      debugPrint('Error iniciando captura: $e');

      _isListening = false;

      return false;
    }
  }

  Future<void> _onAudioData(dynamic rawBuffer) async {
    // Si todavía no toca analizar, no hacemos NINGÚN trabajo: ni convertir
    // el buffer nativo, ni acumularlo, ni recortarlo. Antes seguíamos
    // haciendo toda esa conversión y el sublist() en cada callback (20-40
    // veces/seg) aunque el resultado se fuera a descartar por el throttle
    // de análisis, lo que seguía generando basura constante. Ahora, fuera
    // de la ventana de análisis, el callback termina de inmediato.
    final now = DateTime.now();
    final bool dueForAnalysis =
        now.difference(_lastAnalysis) >= _analysisInterval;

    if (!dueForAnalysis) return;

    List<double> buffer = [];

    if (rawBuffer is Float32List) {
      buffer = rawBuffer.toList();
    } else if (rawBuffer is List) {
      buffer = rawBuffer.map((e) => (e as num).toDouble()).toList();
    }

    _sampleBuffer.addAll(buffer);

    if (_sampleBuffer.length < bufferSize) {
      // Aún no se acumulan suficientes muestras para un análisis; seguimos
      // acumulando en próximos callbacks sin hacer trabajo adicional.
      return;
    }

    // Tomamos solo el bloque más reciente de bufferSize muestras y
    // descartamos el resto del buffer (no necesitamos conservar el audio
    // viejo entre análisis).
    final chunk = _sampleBuffer.sublist(_sampleBuffer.length - bufferSize);

    _sampleBuffer.clear();

    _lastAnalysis = now;

    // Umbral ajustado: 0.003 evita ruido de fondo sin perder volumen de la guitarra

    if (!_hasEnoughVolume(chunk, threshold: 0.003)) {
      _pitchHistory.clear(); // Limpia el historial si entra en silencio

      return;
    }

    try {
      final result = await _pitchDetector.getPitchFromFloatBuffer(chunk);

      if (result.pitched && result.pitch > 0) {
        final double pitch = result.pitch;

        // Filtrar frecuencias fuera del rango útil de guitarra (E2 ~82Hz a E4 ~330Hz + armónicos hasta ~800Hz)

        if (pitch >= 60.0 && pitch <= 800.0) {
          final smoothedPitch = _smoothPitch(pitch);

          _pitchStreamController.add(smoothedPitch);
        }
      }
    } catch (e) {
      debugPrint('Error calculando pitch: $e');
    }
  }

  // Filtro de suavizado simple

  double _smoothPitch(double newPitch) {
    _pitchHistory.add(newPitch);

    if (_pitchHistory.length > _historySize) {
      _pitchHistory.removeAt(0);
    }

    double sum = _pitchHistory.reduce((a, b) => a + b);

    return sum / _pitchHistory.length;
  }

  bool _hasEnoughVolume(List<double> samples, {required double threshold}) {
    double sum = 0.0;

    for (var sample in samples) {
      sum += sample.abs();
    }

    double average = sum / samples.length;

    return average >= threshold;
  }

  void _onError(Object error) {
    debugPrint('Error en captura de audio: $error');
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    await _audioCapture.stop();

    _sampleBuffer.clear();

    _pitchHistory.clear();

    _isListening = false;
  }

  void dispose() {
    stopListening();

    _pitchStreamController.close();
  }
}
