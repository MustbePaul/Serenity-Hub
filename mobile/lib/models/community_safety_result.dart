class CommunitySafetyResult {
  const CommunitySafetyResult({
    required this.flags,
    required this.requiresReview,
    this.supportiveNotice,
  });

  final List<String> flags;
  final bool requiresReview;
  final String? supportiveNotice;

  bool get shouldShowSupport => requiresReview || supportiveNotice != null;

  factory CommunitySafetyResult.fromJson(Map<String, dynamic>? json) {
    return CommunitySafetyResult(
      flags:
          (json?['flags'] as List? ?? const [])
              .map((item) => item.toString())
              .toList(),
      requiresReview: json?['requires_review'] == true,
      supportiveNotice: json?['supportive_notice']?.toString(),
    );
  }
}
