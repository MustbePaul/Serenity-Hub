import 'community_identity.dart';
import 'community_reaction_summary.dart';

class CommunityMessage {
  const CommunityMessage({
    required this.id,
    this.parentId,
    required this.body,
    required this.identity,
    required this.reactions,
    required this.myReactions,
    required this.replyCount,
    required this.isMine,
    required this.status,
    this.createdAt,
    this.editedAt,
  });

  final int id;
  final int? parentId;
  final String? body;
  final CommunityIdentity identity;
  final CommunityReactionSummary reactions;
  final List<String> myReactions;
  final int replyCount;
  final bool isMine;
  final String status;
  final DateTime? createdAt;
  final DateTime? editedAt;

  bool hasReaction(String type) => myReactions.contains(type);

  CommunityMessage copyWith({
    String? body,
    CommunityReactionSummary? reactions,
    List<String>? myReactions,
    int? replyCount,
    String? status,
  }) {
    return CommunityMessage(
      id: id,
      parentId: parentId,
      body: body ?? this.body,
      identity: identity,
      reactions: reactions ?? this.reactions,
      myReactions: myReactions ?? this.myReactions,
      replyCount: replyCount ?? this.replyCount,
      isMine: isMine,
      status: status ?? this.status,
      createdAt: createdAt,
      editedAt: editedAt,
    );
  }

  factory CommunityMessage.fromJson(Map<String, dynamic> json) {
    int intValue(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    int? nullableIntValue(Object? value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    DateTime? dateValue(Object? value) {
      final text = value?.toString();
      if (text == null || text.isEmpty) return null;
      return DateTime.tryParse(text)?.toLocal();
    }

    final identityJson = json['anonymous_identity'];
    return CommunityMessage(
      id: intValue(json['id']),
      parentId: nullableIntValue(json['parent_id']),
      body: json['body']?.toString(),
      identity: CommunityIdentity.fromJson(
        identityJson is Map
            ? Map<String, dynamic>.from(identityJson)
            : const <String, dynamic>{},
      ),
      reactions: CommunityReactionSummary.fromJson(
        json['reactions'] is Map
            ? Map<String, dynamic>.from(json['reactions'] as Map)
            : null,
      ),
      myReactions:
          (json['my_reactions'] as List? ?? const [])
              .map((item) => item.toString())
              .toList(),
      replyCount: intValue(json['reply_count']),
      isMine: json['is_mine'] == true,
      status: json['status']?.toString() ?? 'published',
      createdAt: dateValue(json['created_at']),
      editedAt: dateValue(json['edited_at']),
    );
  }
}
