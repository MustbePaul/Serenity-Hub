import 'media_asset.dart';

class WellnessSession {
  const WellnessSession({
    required this.id,
    required this.title,
    required this.category,
    required this.mediaAsset,
    this.description,
    this.targetMood,
    this.difficulty = 'beginner',
    this.estimatedDurationSeconds,
    this.resourceId,
    this.isFeatured = false,
  });

  final int id;
  final String title;
  final String category;
  final MediaAsset mediaAsset;
  final String? description;
  final String? targetMood;
  final String difficulty;
  final int? estimatedDurationSeconds;
  final int? resourceId;
  final bool isFeatured;

  factory WellnessSession.fromJson(Map<String, dynamic> json) {
    final media =
        json['media_asset'] is Map
            ? MediaAsset.fromJson(
              Map<String, dynamic>.from(json['media_asset'] as Map),
            )
            : MediaAsset.fromJson(
              Map<String, dynamic>.from(json['mediaAsset'] as Map? ?? {}),
            );

    return WellnessSession(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? 'Untitled session',
      category: json['category']?.toString() ?? 'mindfulness',
      mediaAsset: media,
      description: json['description']?.toString(),
      targetMood: json['target_mood']?.toString(),
      difficulty: json['difficulty']?.toString() ?? 'beginner',
      estimatedDurationSeconds:
          json['estimated_duration_seconds'] == null
              ? null
              : _asInt(json['estimated_duration_seconds']),
      resourceId:
          json['resource_id'] == null ? null : _asInt(json['resource_id']),
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
