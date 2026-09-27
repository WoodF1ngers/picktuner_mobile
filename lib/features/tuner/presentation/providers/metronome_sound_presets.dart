/// Presets de sonido del metrónomo.
///
/// Los nombres son intencionalmente editables: puedes cambiar únicamente
/// `name` sin tocar la lógica de reproducción.
class MetronomeSoundPreset {
  final String id;
  final String name;
  final String normalAsset;
  final String accentAsset;

  const MetronomeSoundPreset({
    required this.id,
    required this.name,
    required this.normalAsset,
    required this.accentAsset,
  });
}

const metronomeSoundPresets = <MetronomeSoundPreset>[
  MetronomeSoundPreset(
    id: 'ableton',
    name: 'Ableton',
    normalAsset: 'DAWs/Ableton/Metronome.wav',
    accentAsset: 'DAWs/Ableton/MetronomeUp.wav',
  ),
  MetronomeSoundPreset(
    id: 'cubase',
    name: 'Cubase',
    normalAsset: 'DAWs/Cubase/Metronome.wav',
    accentAsset: 'DAWs/Cubase/MetronomeUp.wav',
  ),
  MetronomeSoundPreset(
    id: 'fl_studio',
    name: 'FL Studio',
    normalAsset: 'DAWs/FL Studio/Metronome.wav',
    accentAsset: 'DAWs/FL Studio/MetronomeUp.wav',
  ),
  MetronomeSoundPreset(
    id: 'logic',
    name: 'Logic',
    normalAsset: 'DAWs/Logic/Metronome.wav',
    accentAsset: 'DAWs/Logic/MetronomeUp.wav',
  ),
  MetronomeSoundPreset(
    id: 'maschine',
    name: 'Maschine',
    normalAsset: 'DAWs/Maschine/Metronome.wav',
    accentAsset: 'DAWs/Maschine/MetronomeUp.wav',
  ),
  MetronomeSoundPreset(
    id: 'mpc',
    name: 'MPC',
    normalAsset: 'DAWs/MPC/Metronome.wav',
    accentAsset: 'DAWs/MPC/MetronomeUp.wav',
  ),
  MetronomeSoundPreset(
    id: 'pro_tools_default',
    name: 'Pro Tools · Default',
    normalAsset: 'DAWs/Pro Tools/Default/Metronome.wav',
    accentAsset: 'DAWs/Pro Tools/Default/MetronomeUp.wav',
  ),
  MetronomeSoundPreset(
    id: 'pro_tools_marimba',
    name: 'Pro Tools · Marimba',
    normalAsset: 'DAWs/Pro Tools/Marimba/Metronome.wav',
    accentAsset: 'DAWs/Pro Tools/Marimba/MetronomeUp.wav',
  ),
  MetronomeSoundPreset(
    id: 'reason',
    name: 'Reason',
    normalAsset: 'DAWs/Reason/Metronome.wav',
    accentAsset: 'DAWs/Reason/MetronomeUp.wav',
  ),
  MetronomeSoundPreset(
    id: 'sonar',
    name: 'Sonar',
    normalAsset: 'DAWs/Sonar/Metronome.wav',
    accentAsset: 'DAWs/Sonar/MetronomeUp.wav',
  ),
];

MetronomeSoundPreset metronomePresetById(String id) {
  return metronomeSoundPresets.firstWhere(
    (preset) => preset.id == id,
    orElse: () => metronomeSoundPresets.first,
  );
}
