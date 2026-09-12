import 'package:flutter/material.dart';

import '../models/community_identity.dart';
import '../models/community_message.dart';
import '../serenity_theme.dart';

const communityReactionTypes = ['support', 'relate', 'encouragement', 'hug'];

const communityReactionLabels = {
  'support': 'Support',
  'relate': 'I relate',
  'encouragement': 'Encouragement',
  'hug': 'You\'re not alone',
};

const communityReportReasons = {
  'harassment': 'Harassment or bullying',
  'hate': 'Hate or discrimination',
  'spam': 'Spam',
  'sexual_content': 'Sexual content',
  'self_harm_concern': 'I\'m concerned about this person\'s safety',
  'threat_or_violence': 'Threat or violence',
  'privacy_or_personal_information': 'Personal or private information',
  'misinformation_or_harmful_advice': 'Harmful advice or misinformation',
  'other': 'Other',
};

class CommunityAvatar extends StatelessWidget {
  const CommunityAvatar({super.key, required this.identity, this.size = 40});

  final CommunityIdentity identity;
  final double size;

  @override
  Widget build(BuildContext context) {
    final seed = identity.avatarSeed ?? identity.id;
    final color = Color(0xFF000000 | (seed.hashCode & 0x00FFFFFF));
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Color.alphaBlend(
        color.withValues(alpha: 0.12),
        serenityMint,
      ),
      child: Text(
        identity.displayName.isEmpty
            ? '?'
            : identity.displayName.characters.first.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class CommunityMessageTile extends StatelessWidget {
  const CommunityMessageTile({
    super.key,
    required this.message,
    required this.onReply,
    required this.onReact,
    required this.onReport,
    required this.onBlock,
    required this.onDelete,
  });

  final CommunityMessage message;
  final VoidCallback onReply;
  final ValueChanged<String> onReact;
  final VoidCallback onReport;
  final VoidCallback onBlock;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = message.isMine ? serenityMint : Colors.white;
    return Semantics(
      label: 'Message from ${message.identity.displayName}',
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommunityAvatar(identity: message.identity),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.identity.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(_relativeTime(message.createdAt)),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Message actions',
                    onSelected: (value) {
                      switch (value) {
                        case 'reply':
                          onReply();
                        case 'report':
                          onReport();
                        case 'block':
                          onBlock();
                        case 'delete':
                          onDelete();
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'reply',
                            child: Text('Reply'),
                          ),
                          if (message.isMine)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete message'),
                            )
                          else ...[
                            const PopupMenuItem(
                              value: 'report',
                              child: Text('Report'),
                            ),
                            const PopupMenuItem(
                              value: 'block',
                              child: Text('Block this anonymous user'),
                            ),
                          ],
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(message.body ?? 'Message removed'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    communityReactionTypes.map((type) {
                      final selected = message.hasReaction(type);
                      final count = message.reactions.countFor(type);
                      return Semantics(
                        button: true,
                        selected: selected,
                        label:
                            '${communityReactionLabels[type]}, $count reactions',
                        child: ActionChip(
                          avatar:
                              selected
                                  ? const Icon(Icons.check_circle, size: 18)
                                  : const Icon(
                                    Icons.add_reaction_outlined,
                                    size: 18,
                                  ),
                          label: Text(
                            '${communityReactionLabels[type]} $count',
                          ),
                          onPressed: () => onReact(type),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onReply,
                icon: const Icon(Icons.reply),
                label: Text(
                  message.replyCount == 1
                      ? '1 reply'
                      : '${message.replyCount} replies',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime? date) {
    if (date == null) return 'Just now';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class CommunityComposer extends StatefulWidget {
  const CommunityComposer({
    super.key,
    required this.hintText,
    required this.loading,
    required this.onSubmit,
  });

  final String hintText;
  final bool loading;
  final Future<bool> Function(String body) onSubmit;

  @override
  State<CommunityComposer> createState() => _CommunityComposerState();
}

class _CommunityComposerState extends State<CommunityComposer> {
  static const maxLength = 2000;
  final _controller = TextEditingController();
  bool _showBlankError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _controller.text;
    if (body.trim().isEmpty) {
      setState(() => _showBlankError = true);
      return;
    }
    final sent = await widget.onSubmit(body);
    if (sent && mounted) {
      _controller.clear();
      setState(() => _showBlankError = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final length = _controller.text.characters.length;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          12,
          8,
          12,
          MediaQuery.of(context).viewInsets.bottom + 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              key: const Key('community-composer-field'),
              controller: _controller,
              minLines: 1,
              maxLines: 5,
              maxLength: maxLength,
              onChanged: (_) => setState(() => _showBlankError = false),
              decoration: InputDecoration(
                hintText: widget.hintText,
                errorText:
                    _showBlankError
                        ? 'Write a few words before sending.'
                        : null,
                suffixIcon: IconButton(
                  tooltip: 'Send message',
                  onPressed: widget.loading ? null : _send,
                  icon:
                      widget.loading
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.send),
                ),
              ),
            ),
            if (length > maxLength - 200)
              Text(
                '$length / $maxLength',
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
      ),
    );
  }
}
