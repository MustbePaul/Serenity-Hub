import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio_player_screen.dart';
import 'models/wellness_session.dart';
import 'providers/session_provider.dart';
import 'video_player_screen.dart';
import 'widgets/category_filter_chips.dart';
import 'widgets/session_card.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final _provider = SessionProvider();
  String _category = 'all';

  @override
  void initState() {
    super.initState();
    _provider.load();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _load() => _provider.load(category: _category);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(title: const Text('Sessions')),
        body: Consumer<SessionProvider>(
          builder: (context, provider, _) {
            final featured = provider.featured;
            return Column(
              children: [
                const SizedBox(height: 8),
                CategoryFilterChips(
                  values: const [
                    'all',
                    'breathing',
                    'sleep',
                    'anxiety',
                    'stress',
                    'reflection',
                  ],
                  selected: _category,
                  onSelected: (value) {
                    setState(() => _category = value);
                    _load();
                  },
                ),
                if (provider.loading) const LinearProgressIndicator(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child:
                        provider.error != null
                            ? ListView(
                              padding: const EdgeInsets.all(16),
                              children: [Text(provider.error!)],
                            )
                            : ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                if (featured.isNotEmpty) ...[
                                  Text(
                                    'Featured sessions',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 8),
                                  ...featured.map(
                                    (session) => SessionCard(
                                      session: session,
                                      onTap: () => _openSession(session),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                Text(
                                  'All sessions',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                ...provider.sessions.map(
                                  (session) => SessionCard(
                                    session: session,
                                    onTap: () => _openSession(session),
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openSession(WellnessSession session) {
    final media = session.mediaAsset;
    final page =
        media.isVideo
            ? VideoPlayerScreen(media: media, session: session)
            : AudioPlayerScreen(media: media, session: session);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}
