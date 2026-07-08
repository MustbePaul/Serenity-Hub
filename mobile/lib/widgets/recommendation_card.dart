import 'package:flutter/material.dart';

import '../models/recommendation.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onTap,
  });

  final Recommendation recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final first =
        recommendation.sessions.isNotEmpty
            ? recommendation.sessions.first.title
            : recommendation.media.isNotEmpty
            ? recommendation.media.first.title
            : 'Explore a featured session';
    return Card(
      color: const Color(0xFFE6F6F3),
      child: ListTile(
        leading: const Icon(Icons.auto_awesome_outlined),
        title: Text(
          recommendation.headline,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(first, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
