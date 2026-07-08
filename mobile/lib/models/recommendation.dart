import 'media_asset.dart';
import 'wellness_session.dart';

class Recommendation {
  const Recommendation({
    required this.headline,
    required this.sessions,
    required this.media,
    this.moodKey,
    this.categories = const [],
  });

  final String headline;
  final String? moodKey;
  final List<String> categories;
  final List<WellnessSession> sessions;
  final List<MediaAsset> media;

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      headline: json['headline']?.toString() ?? 'Recommended for you today',
      moodKey: json['mood_key']?.toString(),
      categories:
          (json['categories'] as List? ?? const [])
              .map((item) => item.toString())
              .toList(),
      sessions:
          (json['sessions'] as List? ?? const [])
              .whereType<Map>()
              .map(
                (item) =>
                    WellnessSession.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(),
      media:
          (json['media'] as List? ?? const [])
              .whereType<Map>()
              .map(
                (item) => MediaAsset.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(),
    );
  }
}
