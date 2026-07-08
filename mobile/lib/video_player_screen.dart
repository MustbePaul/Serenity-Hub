import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'api_client.dart';
import 'media_detail_screen.dart';
import 'models/media_asset.dart';
import 'models/wellness_session.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.media, this.session});

  final MediaAsset media;
  final WellnessSession? session;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final _api = ApiClient();
  VideoPlayerController? _controller;
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
        _error = 'This video does not have a playable file yet.';
      });
      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.media.fileUrl),
      );
      await controller.initialize();
      _controller =
          controller..addListener(() => mounted ? setState(() {}) : null);
    } catch (_) {
      _error = 'We could not open this video. Please try another resource.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _saveProgress();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final duration = controller.value.duration;
    if (duration.inSeconds <= 0) return;
    final position = controller.value.position;
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
                'A guided Serenity Hub video practice.',
          ),
          const SizedBox(height: 16),
          const DisclaimerBox(),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Text(_error!)
          else
            _VideoControls(controller: _controller!),
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

class _VideoControls extends StatelessWidget {
  const _VideoControls({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    final duration = value.duration;
    final position = value.position;
    final max =
        duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();
    final sliderValue =
        position.inMilliseconds.clamp(0, max.toInt()).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: value.aspectRatio == 0 ? 16 / 9 : value.aspectRatio,
              child: VideoPlayer(controller),
            ),
            Row(
              children: [
                IconButton.filled(
                  onPressed:
                      value.isPlaying ? controller.pause : controller.play,
                  icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                Expanded(
                  child: Slider(
                    value: sliderValue,
                    min: 0,
                    max: max,
                    onChanged:
                        (next) => controller.seekTo(
                          Duration(milliseconds: next.round()),
                        ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(_format(position)), Text(_format(duration))],
            ),
          ],
        ),
      ),
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
