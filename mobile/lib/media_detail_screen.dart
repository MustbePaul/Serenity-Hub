import 'package:flutter/material.dart';

import 'models/media_asset.dart';

const safetyDisclaimer =
    'Serenity Hub provides wellness education and emotional support tools. It does not replace emergency services, diagnosis, therapy, or medical treatment. If you are in immediate danger, contact local emergency services or a trusted person now.';

class MediaDetailScreen extends StatelessWidget {
  const MediaDetailScreen({super.key, required this.media});

  final MediaAsset media;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(media.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (media.thumbnailUrl?.isNotEmpty == true)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                media.thumbnailUrl!,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            media.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            media.description?.isNotEmpty == true
                ? media.description!
                : 'A Serenity Hub self-care resource.',
          ),
          const SizedBox(height: 16),
          _Disclaimer(),
          if (media.transcript?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text(
              'Transcript',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(media.transcript!),
          ],
        ],
      ),
    );
  }
}

class DisclaimerBox extends StatelessWidget {
  const DisclaimerBox({super.key});

  @override
  Widget build(BuildContext context) => const _Disclaimer();
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            const Expanded(child: Text(safetyDisclaimer)),
          ],
        ),
      ),
    );
  }
}
