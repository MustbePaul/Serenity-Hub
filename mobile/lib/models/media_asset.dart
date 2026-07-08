class MediaAsset {
  const MediaAsset({
    required this.id,
    required this.title,
    required this.mediaType,
    required this.fileUrl,
    this.description,
    this.thumbnailUrl,
    this.durationSeconds,
    this.transcript,
    this.resources = const [],
  });

  final int id;
  final String title;
  final String mediaType;
  final String fileUrl;
  final String? description;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final String? transcript;
  final List<Map<String, dynamic>> resources;

  bool get isAudio => mediaType == 'audio';
  bool get isVideo => mediaType == 'video';
  bool get isArticle =>
      mediaType == 'article' || mediaType == 'pdf' || mediaType == 'image';

  factory MediaAsset.fromJson(Map<String, dynamic> json) {
    return MediaAsset(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? 'Untitled',
      mediaType:
          json['media_type']?.toString() ??
          json['mediaType']?.toString() ??
          'article',
      fileUrl:
          json['file_url']?.toString() ?? json['fileUrl']?.toString() ?? '',
      description: json['description']?.toString(),
      thumbnailUrl:
          json['thumbnail_url']?.toString() ?? json['thumbnailUrl']?.toString(),
      durationSeconds:
          json['duration_seconds'] == null
              ? null
              : _asInt(json['duration_seconds']),
      transcript: json['transcript']?.toString(),
      resources:
          (json['resources'] as List? ?? const [])
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList(),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
