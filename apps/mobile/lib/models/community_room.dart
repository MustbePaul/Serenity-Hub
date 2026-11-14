class CommunityRoom {
  const CommunityRoom({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconKey,
    this.sortOrder = 0,
  });

  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? iconKey;
  final int sortOrder;

  factory CommunityRoom.fromJson(Map<String, dynamic> json) {
    int intValue(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return CommunityRoom(
      id: intValue(json['id']),
      name: json['name']?.toString() ?? 'Serenity Circle',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      iconKey: json['icon_key']?.toString(),
      sortOrder: intValue(json['sort_order']),
    );
  }
}
