import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'models/wellness_session.dart';
import 'serenity_theme.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key, required this.session});

  final WellnessSession session;

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  final _narration = AudioPlayer();
  final _background = AudioPlayer();
  Timer? _timer;
  int _phaseIndex = 0;
  int _remaining = 0;
  bool _running = false;
  bool _muted = false;
  bool _completed = false;
  double _narrationVolume = 0.8;
  double _backgroundVolume = 0.35;

  List<_BreathPhase> get _phases {
    final session = widget.session;
    return [
      _BreathPhase('Inhale', session.inhaleSeconds ?? 4),
      if ((session.holdSeconds ?? 0) > 0)
        _BreathPhase('Hold', session.holdSeconds!),
      _BreathPhase('Exhale', session.exhaleSeconds ?? 4),
      if ((session.secondHoldSeconds ?? 0) > 0)
        _BreathPhase('Hold', session.secondHoldSeconds!),
    ];
  }

  _BreathPhase get _phase => _phases[_phaseIndex];

  @override
  void initState() {
    super.initState();
    _remaining = _phase.seconds;
    _prepareAudio();
  }

  Future<void> _prepareAudio() async {
    try {
      final narrationUrl = widget.session.narrationMedia?.fileUrl;
      final backgroundUrl = widget.session.backgroundAudio?.fileUrl;
      if (narrationUrl != null && narrationUrl.isNotEmpty) {
        await _narration.setUrl(narrationUrl);
      }
      if (backgroundUrl != null && backgroundUrl.isNotEmpty) {
        await _background.setUrl(backgroundUrl);
        await _background.setLoopMode(LoopMode.one);
      }
      await _applyVolumes();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Audio guidance is unavailable. Silent mode still works.',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _narration.dispose();
    _background.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _completed = false;
    });
    if (!_muted) {
      _narration.play();
      _background.play();
    }
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _pause() {
    setState(() => _running = false);
    _timer?.cancel();
    _timer = null;
    _narration.pause();
    _background.pause();
  }

  void _restart() {
    _pause();
    _narration.seek(Duration.zero);
    _background.seek(Duration.zero);
    setState(() {
      _phaseIndex = 0;
      _remaining = _phase.seconds;
      _completed = false;
    });
  }

  void _tick() {
    if (!_running) return;
    if (_remaining > 1) {
      setState(() => _remaining -= 1);
      return;
    }
    final next = (_phaseIndex + 1) % _phases.length;
    setState(() {
      _phaseIndex = next;
      _remaining = _phases[next].seconds;
      _completed = next == 0;
    });
  }

  Future<void> _applyVolumes() async {
    await _narration.setVolume(_muted ? 0 : _narrationVolume);
    await _background.setVolume(_muted ? 0 : _backgroundVolume);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final session = widget.session;
    final transcript = session.transcript ?? session.mediaAsset.transcript;

    return Scaffold(
      appBar: AppBar(title: Text(session.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            session.breathingPattern ?? 'Breathing practice',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            session.instructions ??
                'Breathe at a comfortable pace. Pause or stop if this does not feel supportive.',
          ),
          const SizedBox(height: 16),
          Semantics(
            label: '${_phase.label}. $_remaining seconds remaining.',
            liveRegion: true,
            child: Center(
              child: AnimatedContainer(
                duration:
                    reduceMotion
                        ? Duration.zero
                        : Duration(seconds: _phase.seconds),
                width: _phase.label == 'Inhale' ? 220 : 150,
                height: _phase.label == 'Inhale' ? 220 : 150,
                decoration: BoxDecoration(
                  color: serenityMint,
                  shape: BoxShape.circle,
                  border: Border.all(color: serenityTeal, width: 3),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${_phase.label}\n$_remaining',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (_completed)
            const Card(
              color: serenityWarm,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Cycle completed. You can continue, pause, or stop here.',
                ),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _running ? _pause : _start,
                icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                label: Text(_running ? 'Pause' : 'Start'),
              ),
              OutlinedButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.replay),
                label: const Text('Restart'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _muted = !_muted);
                  _applyVolumes();
                },
                icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                label: Text(_muted ? 'Muted' : 'Mute'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _VolumeSlider(
            label: 'Narration volume',
            value: _narrationVolume,
            onChanged: (value) {
              setState(() => _narrationVolume = value);
              _applyVolumes();
            },
          ),
          _VolumeSlider(
            label: 'Background volume',
            value: _backgroundVolume,
            onChanged: (value) {
              setState(() => _backgroundVolume = value);
              _applyVolumes();
            },
          ),
          if (transcript?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text(
              'Transcript',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(transcript!),
          ],
        ],
      ),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Row(
        children: [
          SizedBox(width: 132, child: Text(label)),
          Expanded(child: Slider(value: value, onChanged: onChanged)),
        ],
      ),
    );
  }
}

class _BreathPhase {
  const _BreathPhase(this.label, this.seconds);

  final String label;
  final int seconds;
}
