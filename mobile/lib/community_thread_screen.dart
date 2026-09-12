import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'crisis_support.dart';
import 'models/community_message.dart';
import 'providers/community_provider.dart';
import 'widgets/community_widgets.dart';

class CommunityThreadScreen extends StatelessWidget {
  const CommunityThreadScreen({super.key, required this.parent});

  final CommunityMessage parent;

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Reply')),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    CommunityMessageTile(
                      message: parent,
                      onReply: () {},
                      onReact:
                          (reaction) =>
                              provider.toggleReaction(parent, reaction),
                      onReport:
                          parent.isMine
                              ? () {}
                              : () => _showReport(context, provider, parent),
                      onBlock:
                          parent.isMine
                              ? () {}
                              : () => _confirmBlock(context, provider, parent),
                      onDelete:
                          parent.isMine
                              ? () => _confirmDelete(context, provider, parent)
                              : () {},
                    ),
                    const Divider(height: 24),
                    if (provider.loadingReplies)
                      const Center(child: CircularProgressIndicator())
                    else if (provider.replyError != null)
                      _ThreadState(
                        message: provider.replyError!,
                        onRetry: () => provider.loadReplies(parent),
                      )
                    else if (provider.replies.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No replies yet. A gentle response can be enough.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...provider.replies.map(
                        (reply) => CommunityMessageTile(
                          message: reply,
                          onReply: () {},
                          onReact:
                              (reaction) =>
                                  provider.toggleReaction(reply, reaction),
                          onReport:
                              reply.isMine
                                  ? () {}
                                  : () => _showReport(context, provider, reply),
                          onBlock:
                              reply.isMine
                                  ? () {}
                                  : () =>
                                      _confirmBlock(context, provider, reply),
                          onDelete:
                              reply.isMine
                                  ? () =>
                                      _confirmDelete(context, provider, reply)
                                  : () {},
                        ),
                      ),
                  ],
                ),
              ),
              CommunityComposer(
                hintText: 'Write a supportive reply...',
                loading: provider.postingReply,
                onSubmit: (body) async {
                  final safety = await provider.postReply(
                    parent: parent,
                    body: body,
                  );
                  if (safety?.shouldShowSupport == true && context.mounted) {
                    await _showSafetySupport(context);
                  }
                  return safety != null && provider.replyError == null;
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _showReport(
  BuildContext context,
  CommunityProvider provider,
  CommunityMessage message,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ThreadReportSheet(provider: provider, message: message),
  );
}

Future<void> _confirmBlock(
  BuildContext context,
  CommunityProvider provider,
  CommunityMessage message,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Block this anonymous user?'),
          content: const Text(
            'You\'ll stop seeing messages from this Circle identity. They won\'t be notified.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Block'),
            ),
          ],
        ),
  );
  if (confirmed == true) await provider.blockIdentity(message.identity);
}

Future<void> _confirmDelete(
  BuildContext context,
  CommunityProvider provider,
  CommunityMessage message,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Remove this message?'),
          content: const Text(
            'This message will no longer appear in the Circle.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove'),
            ),
          ],
        ),
  );
  if (confirmed == true) await provider.deleteMessage(message);
}

class _ThreadReportSheet extends StatefulWidget {
  const _ThreadReportSheet({required this.provider, required this.message});

  final CommunityProvider provider;
  final CommunityMessage message;

  @override
  State<_ThreadReportSheet> createState() => _ThreadReportSheetState();
}

class _ThreadReportSheetState extends State<_ThreadReportSheet> {
  final _details = TextEditingController();
  String _reason = 'harassment';
  bool _submitting = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await widget.provider.reportMessage(
      message: widget.message,
      reason: _reason,
      details: _details.text,
    );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you. Your report has been sent for review.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Report message',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _reason,
              isExpanded: true,
              items:
                  communityReportReasons.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(
                            entry.value,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _reason = value ?? _reason),
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _details,
              maxLines: 4,
              maxLength: 1000,
              decoration: const InputDecoration(labelText: 'Details optional'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon:
                  _submitting
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.flag_outlined),
              label: Text(_submitting ? 'Sending...' : 'Send report'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showSafetySupport(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('We\'re here with you'),
          content: const Text(
            'It sounds like you may be going through something difficult.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showCrisisSupportSheet(context);
              },
              child: const Text('View support options'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/consultation');
              },
              child: const Text('Find a therapist'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/resources');
              },
              child: const Text('Explore calming resources'),
            ),
          ],
        ),
  );
}

class _ThreadState extends StatelessWidget {
  const _ThreadState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}
