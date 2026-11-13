import 'media_asset.dart';
import 'wellness_session.dart';

class MediaProgress {
  const MediaProgress({
    required this.id,
    required this.mediaAsset,
    required this.progressSeconds,
    required this.durationSeconds,
    required this.progressPercent,
    required this.isCompleted,
    this.resourceId,
    this.wellnessSession,
    this.lastPlayedAt,
  });

  final int id;
  final MediaAsset mediaAsset;
  final int progressSeconds;
  final int durationSeconds;
  final double progressPercent;
  final bool isCompleted;
  final int? resourceId;
  final WellnessSession? wellnessSession;
  final DateTime? lastPlayedAt;

  factory MediaProgress.fromJson(Map<String, dynamic> json) {
    return MediaProgress(
      id: _asInt(json['id']),
      mediaAsset: MediaAsset.fromJson(
        Map<String, dynamic>.from(
          json['media_asset'] as Map? ?? json['mediaAsset'] as Map? ?? {},
        ),
      ),
      progressSeconds: _asInt(json['progress_seconds']),
      durationSeconds: _asInt(json['duration_seconds']),
      progressPercent: _asDouble(json['progress_percent']),
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
      resourceId:
          json['resource_id'] == null ? null : _asInt(json['resource_id']),
      wellnessSession:
          json['wellness_session'] is Map
              ? WellnessSession.fromJson(
                Map<String, dynamic>.from(json['wellness_session'] as Map),
              )
              : null,
      lastPlayedAt: DateTime.tryParse(json['last_played_at']?.toString() ?? ''),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
