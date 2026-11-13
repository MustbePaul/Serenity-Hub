class CommunityReactionSummary {
  const CommunityReactionSummary({
    required this.support,
    required this.relate,
    required this.encouragement,
    required this.hug,
  });

  final int support;
  final int relate;
  final int encouragement;
  final int hug;

  int countFor(String type) {
    return switch (type) {
      'support' => support,
      'relate' => relate,
      'encouragement' => encouragement,
      'hug' => hug,
      _ => 0,
    };
  }

  factory CommunityReactionSummary.fromJson(Map<String, dynamic>? json) {
    int intValue(String key) {
      final value = json?[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return CommunityReactionSummary(
      support: intValue('support'),
      relate: intValue('relate'),
      encouragement: intValue('encouragement'),
      hug: intValue('hug'),
    );
  }
}
