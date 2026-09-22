import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

import 'models/chord_models.dart';

/// Sintetiza y reproduce el sonido de un acorde calculando la frecuencia
/// real de cada cuerda activa (afinación estándar + traste), en vez de
/// depender de archivos de audio grabados. Genera un WAV corto en memoria
/// y lo reproduce con `audioplayers` (BytesSource).
class ChordAudioSynth {
  ChordAudioSynth._();

  static const int _sampleRate = 44100;

  /// Frecuencias (Hz) de las 6 cuerdas al aire en afinación estándar,
  /// de la 6ta (Mi grave) a la 1ra (mi agudo).
  static const List<double> _openStringHz = [
    82.41,
    110.00,
    146.83,
    196.00,
    246.94,
    329.63,
  ];

  static final AudioPlayer _player = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  static Future<void> playVariation(ChordVariation variation) async {
    final frequencies = <double>[];

    for (int i = 0; i < variation.strings.length && i < _openStringHz.length; i++) {
      final pos = variation.strings[i];
      if (pos.status == StringStatus.muted) continue;

      final int fret = pos.status == StringStatus.fretted ? pos.fret : 0;
      frequencies.add(_openStringHz[i] * math.pow(2, fret / 12));
    }

    if (frequencies.isEmpty) return;

    final wavBytes = _synthesizeStrum(frequencies);

    try {
      await _player.stop();
      await _player.play(BytesSource(wavBytes));
    } catch (_) {
      // Reproducción best-effort: si falla, simplemente no suena.
    }
  }

  /// Genera un PCM 16-bit mono con cada cuerda entrando en un pequeño
  /// desfase (efecto de rasgueo) y una caída exponencial de volumen.
  static Uint8List _synthesizeStrum(List<double> frequencies) {
    const double noteDurationSeconds = 1.3;
    const double strumDelaySeconds = 0.045;

    final int totalSamples = (_sampleRate *
            (noteDurationSeconds + frequencies.length * strumDelaySeconds))
        .round();

    final Float64List mix = Float64List(totalSamples);

    for (int i = 0; i < frequencies.length; i++) {
      final double freq = frequencies[i];
      final int startSample = (i * strumDelaySeconds * _sampleRate).round();
      final int noteSamples = (noteDurationSeconds * _sampleRate).round();

      for (int s = 0; s < noteSamples; s++) {
        final int idx = startSample + s;
        if (idx >= totalSamples) break;

        final double t = s / _sampleRate;
        // Ataque instantáneo + caída exponencial, similar a pulsar una cuerda.
        final double envelope = math.exp(-t * 3.2);
        mix[idx] += math.sin(2 * math.pi * freq * t) * envelope * 0.2;
      }
    }

    // Normalizamos para evitar recorte (clipping) cuando varias cuerdas
    // suenan a la vez.
    double peak = 0;
    for (final v in mix) {
      if (v.abs() > peak) peak = v.abs();
    }
    final double normFactor = peak > 0.9 ? 0.9 / peak : 1.0;

    final Int16List pcm = Int16List(totalSamples);
    for (int i = 0; i < totalSamples; i++) {
      final double v = (mix[i] * normFactor).clamp(-1.0, 1.0);
      pcm[i] = (v * 32767).round();
    }

    return _pcm16ToWav(pcm, _sampleRate);
  }

  static Uint8List _pcm16ToWav(Int16List pcm, int sampleRate) {
    const int bitsPerSample = 16;
    const int channels = 1;
    final int byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final int blockAlign = channels * bitsPerSample ~/ 8;
    final int dataSize = pcm.length * 2;

    final ByteData header = ByteData(44);

    void writeAscii(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        header.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    header.setUint32(4, 36 + dataSize, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    writeAscii(36, 'data');
    header.setUint32(40, dataSize, Endian.little);

    final Uint8List bytes = Uint8List(44 + dataSize);
    bytes.setRange(0, 44, header.buffer.asUint8List());

    final ByteData pcmBytes = ByteData(dataSize);
    for (int i = 0; i < pcm.length; i++) {
      pcmBytes.setInt16(i * 2, pcm[i], Endian.little);
    }
    bytes.setRange(44, bytes.length, pcmBytes.buffer.asUint8List());

    return bytes;
  }
}
