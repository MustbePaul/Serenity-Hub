class CommunityIdentity {
  const CommunityIdentity({
    required this.id,
    required this.displayName,
    this.avatarSeed,
  });

  final String id;
  final String displayName;
  final String? avatarSeed;

  factory CommunityIdentity.fromJson(Map<String, dynamic> json) {
    return CommunityIdentity(
      id: json['id']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? 'Circle member',
      avatarSeed: json['avatar_seed']?.toString(),
    );
  }
}
