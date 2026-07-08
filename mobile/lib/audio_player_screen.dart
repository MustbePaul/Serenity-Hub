import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'api_client.dart';
import 'media_detail_screen.dart';
import 'models/media_asset.dart';
import 'models/wellness_session.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key, required this.media, this.session});

  final MediaAsset media;
  final WellnessSession? session;

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final _api = ApiClient();
  final _player = AudioPlayer();
  Timer? _saveTimer;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
    _saveTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _saveProgress(),
    );
  }

  Future<void> _init() async {
    if (widget.media.fileUrl.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'This audio session does not have a playable file yet.';
      });
      return;
    }

    try {
      await _player.setUrl(widget.media.fileUrl);
    } catch (_) {
      _error = 'We could not open this audio. Please try another resource.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _saveProgress();
    _player.dispose();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    final duration =
        _player.duration ??
        Duration(seconds: widget.media.durationSeconds ?? 1);
    if (duration.inSeconds <= 0) return;
    final position = _player.position;
    try {
      await _api.saveMediaProgress(
        mediaId: widget.media.id,
        wellnessSessionId: widget.session?.id,
        resourceId: widget.session?.resourceId,
        progressSeconds: position.inSeconds.clamp(0, duration.inSeconds),
        durationSeconds: duration.inSeconds,
        isCompleted: position.inSeconds / duration.inSeconds >= 0.95,
      );
    } catch (_) {
      // Progress is helpful but should never interrupt playback.
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.session?.title ?? widget.media.title;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            widget.session?.description ??
                widget.media.description ??
                'A guided Serenity Hub audio practice.',
          ),
          const SizedBox(height: 16),
          const DisclaimerBox(),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Text(_error!)
          else
            _Controls(player: _player),
          if (widget.media.transcript?.isNotEmpty == true) ...[
            const SizedBox(height: 24),
            Text(
              'Transcript',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(widget.media.transcript!),
          ],
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.player});

  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = player.duration ?? Duration.zero;
        final max =
            duration.inMilliseconds <= 0
                ? 1.0
                : duration.inMilliseconds.toDouble();
        final value = position.inMilliseconds.clamp(0, max.toInt()).toDouble();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                StreamBuilder<PlayerState>(
                  stream: player.playerStateStream,
                  builder: (context, state) {
                    final playing = state.data?.playing ?? false;
                    return IconButton.filled(
                      iconSize: 36,
                      onPressed: playing ? player.pause : player.play,
                      icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                    );
                  },
                ),
                Slider(
                  value: value,
                  min: 0,
                  max: max,
                  onChanged:
                      (next) =>
                          player.seek(Duration(milliseconds: next.round())),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(_format(position)), Text(_format(duration))],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
