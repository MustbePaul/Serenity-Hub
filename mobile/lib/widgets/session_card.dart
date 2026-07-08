import 'package:flutter/material.dart';

import '../models/wellness_session.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.session, required this.onTap});

  final WellnessSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          session.mediaAsset.isVideo
              ? Icons.ondemand_video_outlined
              : Icons.self_improvement_outlined,
        ),
        title: Text(
          session.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${_label(session.category)} - ${_duration(session.estimatedDurationSeconds ?? session.mediaAsset.durationSeconds)}',
          maxLines: 2,
        ),
        trailing:
            session.isFeatured
                ? const Icon(Icons.star, color: Color(0xFFE3A72F))
                : const Icon(Icons.arrow_forward),
      ),
    );
  }

  String _label(String value) => value
      .split('-')
      .map(
        (part) =>
            part.isEmpty
                ? part
                : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');

  String _duration(int? seconds) {
    if (seconds == null || seconds <= 0) return 'Self-paced';
    final minutes = (seconds / 60).ceil();
    return '$minutes min';
  }
}
