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
          session.hasBreathingPattern
              ? Icons.air
              : session.mediaAsset.isVideo
              ? Icons.ondemand_video_outlined
              : Icons.self_improvement_outlined,
        ),
        title: Text(
          session.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${_label(session.category)} - ${_duration(session.estimatedDurationSeconds ?? session.mediaAsset.durationSeconds)}\n${_modes(session)}',
          maxLines: 2,
        ),
        trailing:
            session.isFeatured
                ? const Icon(Icons.star, color: Color(0xFFE3A72F))
                : const Icon(Icons.arrow_forward),
      ),
    );
  }

  String _modes(WellnessSession session) {
    final modes = <String>['Read'];
    if (session.mediaAsset.isAudio || session.narrationMedia != null) {
      modes.add('Listen');
    }
    if (session.mediaAsset.isVideo || session.demonstrationVideo != null) {
      modes.add('Watch');
    }
    if (session.hasBreathingPattern) modes.add('Visual guide');
    return modes.join(', ');
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
