import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'community_room_screen.dart';
import 'guest_mode.dart';
import 'models/community_identity.dart';
import 'models/community_room.dart';
import 'providers/community_provider.dart';
import 'serenity_theme.dart';
import 'widgets/community_widgets.dart';

class SerenityCircleScreen extends StatefulWidget {
  const SerenityCircleScreen({super.key, this.provider});

  final CommunityProvider? provider;

  @override
  State<SerenityCircleScreen> createState() => _SerenityCircleScreenState();
}

class _SerenityCircleScreenState extends State<SerenityCircleScreen> {
  late final CommunityProvider _provider =
      widget.provider ?? CommunityProvider();
  bool get _ownsProvider => widget.provider == null;

  @override
  void initState() {
    super.initState();
    _provider.loadHome();
  }

  @override
  void dispose() {
    if (_ownsProvider) _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(title: const Text('Serenity Circle')),
        body: Consumer<CommunityProvider>(
          builder: (context, provider, _) {
            if (provider.guestMode) return const _CircleGuestGate();
            return RefreshIndicator(
              onRefresh: provider.loadHome,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (provider.loadingHome) const LinearProgressIndicator(),
                  Text(
                    'Serenity Circle',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Share what you\'re carrying. Support someone who may be feeling the same.',
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: serenityBlue,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lock_outline),
                              SizedBox(width: 10),
                              Text(
                                'Your identity is private',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Other members see only your Serenity Circle name. Your personal Serenity Hub profile is not shown.',
                          ),
                          TextButton(
                            onPressed:
                                () => showDialog<void>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Circle safety'),
                                        content: const Text(
                                          'Serenity Hub securely retains account associations for safety and moderation.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('Got it'),
                                          ),
                                        ],
                                      ),
                                ),
                            child: const Text('How this works'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (provider.identity != null) ...[
                    const SizedBox(height: 12),
                    _IdentityCard(identity: provider.identity!),
                  ],
                  const SizedBox(height: 16),
                  if (provider.error != null)
                    _StateCard(
                      title: 'We couldn\'t load Serenity Circle',
                      message: provider.error!,
                      onRetry: provider.loadHome,
                    )
                  else if (!provider.loadingHome && provider.rooms.isEmpty)
                    _StateCard(
                      title: 'Rooms are resting',
                      message: 'Please check back in a little while.',
                      onRetry: provider.loadHome,
                    )
                  else
                    ...provider.rooms.map(
                      (room) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RoomCard(
                          room: room,
                          onTap: () async {
                            await provider.openRoom(room);
                            if (!context.mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => ChangeNotifierProvider.value(
                                      value: provider,
                                      child: const CommunityRoomScreen(),
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.identity});

  final CommunityIdentity identity;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CommunityAvatar(identity: identity),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You are ${identity.displayName}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'People in Serenity Circle will know you by this name.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.onTap});

  final CommunityRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_iconFor(room.iconKey ?? room.slug)),
        title: Text(room.name),
        subtitle: Text(room.description ?? 'A supportive shared room.'),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }

  IconData _iconFor(String key) {
    if (key.contains('anxiety')) return Icons.air;
    if (key.contains('relationship')) return Icons.favorite_border;
    if (key.contains('student')) return Icons.school_outlined;
    if (key.contains('work')) return Icons.work_outline;
    if (key.contains('wins')) return Icons.celebration_outlined;
    if (key.contains('feeling')) return Icons.mood_outlined;
    return Icons.forum_outlined;
  }
}

class _CircleGuestGate extends StatelessWidget {
  const _CircleGuestGate();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Join Serenity Circle',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to share anonymously with the Serenity Hub community.',
        ),
        const SizedBox(height: 12),
        Card(
          color: serenityMint,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Your Serenity Hub profile is hidden from other Circle members.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            await GuestMode.endReview();
            if (context.mounted) Navigator.pushNamed(context, '/login');
          },
          child: const Text('Sign in'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            await GuestMode.endReview();
            if (context.mounted) Navigator.pushNamed(context, '/signup');
          },
          child: const Text('Create account'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back'),
        ),
      ],
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
