import 'package:flutter/material.dart';

class ProgressBadge extends StatelessWidget {
  const ProgressBadge({super.key, required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    if (percent <= 0) return const SizedBox.shrink();
    return Chip(
      avatar: const Icon(Icons.timelapse, size: 16),
      label: Text('${percent.round()}%'),
      visualDensity: VisualDensity.compact,
    );
  }
}
