import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'community_thread_screen.dart';
import 'crisis_support.dart';
import 'models/community_message.dart';
import 'providers/community_provider.dart';
import 'serenity_theme.dart';
import 'widgets/community_widgets.dart';

class CommunityRoomScreen extends StatefulWidget {
  const CommunityRoomScreen({super.key});

  @override
  State<CommunityRoomScreen> createState() => _CommunityRoomScreenState();
}

class _CommunityRoomScreenState extends State<CommunityRoomScreen> {
  final _scrollController = ScrollController();
  CommunityProvider? _provider;
  bool _privacyReminderVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadOlder);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider ??= context.read<CommunityProvider>();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    final provider = _provider;
    if (provider != null) unawaited(provider.leaveRoom());
    super.dispose();
  }

  void _maybeLoadOlder() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 240) {
      context.read<CommunityProvider>().loadOlderMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, provider, _) {
        final room = provider.selectedRoom;
        return Scaffold(
          appBar: AppBar(
            title: Text(room?.name ?? 'Serenity Circle'),
            actions: [
              IconButton(
                tooltip: 'Room information',
                onPressed:
                    () => showDialog<void>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text(room?.name ?? 'Serenity Circle'),
                            content: Text(
                              room?.description ??
                                  'A supportive shared conversation room.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Done'),
                              ),
                            ],
                          ),
                    ),
                icon: const Icon(Icons.info_outline),
              ),
            ],
          ),
          body: Column(
            children: [
              if (provider.loadingMessages) const LinearProgressIndicator(),
              if (provider.messageError != null)
                _InlineError(
                  message: provider.messageError!,
                  onRetry: () => provider.loadMessages(initial: true),
                ),
              Expanded(
                child: Stack(
                  children: [
                    provider.loadingMessages
                        ? const Center(child: CircularProgressIndicator())
                        : provider.messages.isEmpty
                        ? const _EmptyRoom()
                        : ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.all(12),
                          itemCount:
                              provider.messages.length +
                              (provider.loadingOlder ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= provider.messages.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final message = provider.messages[index];
                            return CommunityMessageTile(
                              message: message,
                              onReply: () => _openThread(provider, message),
                              onReact:
                                  (reaction) => provider.toggleReaction(
                                    message,
                                    reaction,
                                  ),
                              onReport: () => _showReport(provider, message),
                              onBlock: () => _confirmBlock(provider, message),
                              onDelete: () => _confirmDelete(provider, message),
                            );
                          },
                        ),
                    if (provider.hasUnseenNewMessages)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 12,
                        child: Center(
                          child: FilledButton.tonal(
                            onPressed: () {
                              provider.markNewMessagesSeen();
                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              );
                            },
                            child: const Text('New messages'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_privacyReminderVisible)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  child: Card(
                    color: serenityWarm,
                    child: ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Protect your privacy'),
                      subtitle: const Text(
                        'Avoid sharing phone numbers, addresses, passwords or information that could identify you.',
                      ),
                      trailing: IconButton(
                        tooltip: 'Dismiss privacy reminder',
                        onPressed:
                            () =>
                                setState(() => _privacyReminderVisible = false),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ),
                ),
              CommunityComposer(
                hintText: 'Share what\'s on your mind...',
                loading: provider.posting,
                onSubmit: (body) async {
                  final safety = await provider.postMessage(body);
                  if (safety?.shouldShowSupport == true && context.mounted) {
                    await _showSafetySupport(context);
                  }
                  return safety != null && provider.messageError == null;
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openThread(CommunityProvider provider, CommunityMessage message) {
    provider.loadReplies(message);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider.value(
              value: provider,
              child: CommunityThreadScreen(parent: message),
            ),
      ),
    );
  }

  Future<void> _showReport(
    CommunityProvider provider,
    CommunityMessage message,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReportSheet(provider: provider, message: message),
    );
  }

  Future<void> _confirmBlock(
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
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.provider, required this.message});

  final CommunityProvider provider;
  final CommunityMessage message;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
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

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: serenityWarm,
      child: ListTile(
        title: const Text('We couldn\'t load the conversation'),
        subtitle: Text(message),
        trailing: TextButton(onPressed: onRetry, child: const Text('Retry')),
      ),
    );
  }
}

class _EmptyRoom extends StatelessWidget {
  const _EmptyRoom();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.forum_outlined, size: 40),
            const SizedBox(height: 10),
            Text(
              'It\'s quiet here',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to share something with the Circle.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Even a few words can help someone else feel less alone.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
