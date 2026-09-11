import 'media_asset.dart';

class WellnessSession {
  const WellnessSession({
    required this.id,
    required this.title,
    required this.category,
    required this.mediaAsset,
    this.description,
    this.sessionType,
    this.instructions,
    this.transcript,
    this.breathingPattern,
    this.inhaleSeconds,
    this.holdSeconds,
    this.exhaleSeconds,
    this.secondHoldSeconds,
    this.backgroundAudio,
    this.narrationMedia,
    this.demonstrationVideo,
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
  final String? sessionType;
  final String? instructions;
  final String? transcript;
  final String? breathingPattern;
  final int? inhaleSeconds;
  final int? holdSeconds;
  final int? exhaleSeconds;
  final int? secondHoldSeconds;
  final MediaAsset? backgroundAudio;
  final MediaAsset? narrationMedia;
  final MediaAsset? demonstrationVideo;
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
      sessionType: json['session_type']?.toString(),
      instructions: json['instructions']?.toString(),
      transcript: json['transcript']?.toString(),
      breathingPattern: json['breathing_pattern']?.toString(),
      inhaleSeconds:
          json['inhale_seconds'] == null
              ? null
              : _asInt(json['inhale_seconds']),
      holdSeconds:
          json['hold_seconds'] == null ? null : _asInt(json['hold_seconds']),
      exhaleSeconds:
          json['exhale_seconds'] == null
              ? null
              : _asInt(json['exhale_seconds']),
      secondHoldSeconds:
          json['second_hold_seconds'] == null
              ? null
              : _asInt(json['second_hold_seconds']),
      backgroundAudio: _optionalMedia(json['background_audio']),
      narrationMedia: _optionalMedia(json['narration_media']),
      demonstrationVideo: _optionalMedia(json['demonstration_video']),
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

  bool get hasBreathingPattern =>
      inhaleSeconds != null && exhaleSeconds != null && category == 'breathing';
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

MediaAsset? _optionalMedia(Object? value) {
  if (value is Map<String, dynamic>) {
    return MediaAsset.fromJson(value);
  }
  if (value is Map) {
    return MediaAsset.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}
