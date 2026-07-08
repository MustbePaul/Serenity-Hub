import 'package:flutter/material.dart';

import '../models/media_asset.dart';
import 'progress_badge.dart';

class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    required this.media,
    this.progressPercent = 0,
    required this.onTap,
  });

  final MediaAsset media;
  final double progressPercent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (media.mediaType) {
      'audio' => Icons.headphones_outlined,
      'video' => Icons.play_circle_outline,
      _ => Icons.article_outlined,
    };
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: _Thumb(media: media, fallbackIcon: icon),
        title: Text(media.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          media.description?.isNotEmpty == true
              ? media.description!
              : _typeLabel(media.mediaType),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            progressPercent > 0
                ? ProgressBadge(percent: progressPercent)
                : const Icon(Icons.arrow_forward),
      ),
    );
  }

  String _typeLabel(String type) =>
      type.isEmpty
          ? 'Resource'
          : '${type[0].toUpperCase()}${type.substring(1)}';
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.media, required this.fallbackIcon});

  final MediaAsset media;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final url = media.thumbnailUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 56,
        height: 56,
        child:
            url == null || url.isEmpty
                ? ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(fallbackIcon),
                )
                : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => ColoredBox(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        child: Icon(fallbackIcon),
                      ),
                ),
      ),
    );
  }
}
