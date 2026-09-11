import 'package:flutter/material.dart';

class MoodScaleOption {
  const MoodScaleOption({
    required this.score,
    required this.label,
    required this.explanation,
    required this.icon,
    required this.recommendationTag,
  });

  final int score;
  final String label;
  final String explanation;
  final IconData icon;
  final String recommendationTag;

  String get shortLabel => '$score - $label';
  String get semanticLabel => '$score out of 5, $label. $explanation';
}

class MoodScale {
  static const options = [
    MoodScaleOption(
      score: 1,
      label: 'Very Low',
      explanation: 'I am struggling significantly today.',
      icon: Icons.sentiment_very_dissatisfied,
      recommendationTag: 'sad',
    ),
    MoodScaleOption(
      score: 2,
      label: 'Low',
      explanation: 'I am feeling down, anxious, or emotionally unsettled.',
      icon: Icons.sentiment_dissatisfied,
      recommendationTag: 'anxious',
    ),
    MoodScaleOption(
      score: 3,
      label: 'Neutral',
      explanation: 'I am neither particularly low nor positive.',
      icon: Icons.sentiment_neutral,
      recommendationTag: 'tired',
    ),
    MoodScaleOption(
      score: 4,
      label: 'Good',
      explanation: 'I am generally feeling positive or calm.',
      icon: Icons.sentiment_satisfied,
      recommendationTag: 'calm',
    ),
    MoodScaleOption(
      score: 5,
      label: 'Very Good',
      explanation: 'I am feeling happy, calm, hopeful, or energised.',
      icon: Icons.sentiment_very_satisfied,
      recommendationTag: 'calm',
    ),
  ];

  static MoodScaleOption byScore(int score) {
    return options.firstWhere(
      (option) => option.score == score,
      orElse: () => options[2],
    );
  }
}
