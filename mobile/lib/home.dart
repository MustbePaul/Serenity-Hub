import 'package:flutter/material.dart';

import 'api_client.dart';
import 'audio_player_screen.dart';
import 'models/media_asset.dart';
import 'providers/recommendation_provider.dart';
import 'sample_data.dart';
import 'serenity_theme.dart';
import 'video_player_screen.dart';
import 'widgets/media_card.dart';
import 'widgets/recommendation_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _api = ApiClient();
  final _recommendations = RecommendationProvider();
  Map<String, dynamic> _quote = Map<String, dynamic>.from(sampleQuote);
  Map<String, dynamic>? _resource = Map<String, dynamic>.from(
    sampleResources.first,
  );
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  @override
  void dispose() {
    _recommendations.dispose();
    super.dispose();
  }

  Future<void> _loadHome() async {
    setState(() => _loading = true);
    try {
      final response = await _api.get('/home');
      await _recommendations.load();
      final data = response['data'] as Map<String, dynamic>;
      setState(() {
        _quote = Map<String, dynamic>.from(data['quote'] ?? sampleQuote);
        _resource =
            data['recommended_resource'] == null
                ? Map<String, dynamic>.from(sampleResources.first)
                : Map<String, dynamic>.from(data['recommended_resource']);
      });
    } catch (_) {
      await _recommendations.load();
      setState(() {
        _quote = Map<String, dynamic>.from(sampleQuote);
        _resource = Map<String, dynamic>.from(sampleResources.first);
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: _loadHome,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHome,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_loading) const LinearProgressIndicator(),
            Text(
              'Good ${_partOfDay()}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text('Take what helps today. Leave the rest.'),
            const SizedBox(height: 16),
            _QuoteCard(quote: _quote),
            const SizedBox(height: 12),
            const _MoodCheckIn(),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _recommendations,
              builder: (context, _) {
                final recommendation = _recommendations.recommendation;
                if (_recommendations.loading) {
                  return const LinearProgressIndicator();
                }
                if (recommendation == null) return const SizedBox.shrink();
                return RecommendationCard(
                  recommendation: recommendation,
                  onTap: () => Navigator.pushNamed(context, '/sessions'),
                );
              },
            ),
            AnimatedBuilder(
              animation: _recommendations,
              builder: (context, _) {
                final progress =
                    _recommendations.progress
                        .where((item) => !item.isCompleted)
                        .firstOrNull;
                if (progress == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Continue where you left off',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      MediaCard(
                        media: progress.mediaAsset,
                        progressPercent: progress.progressPercent,
                        onTap: () => _openMedia(progress.mediaAsset),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _ResourceCard(resource: _resource),
            const SizedBox(height: 12),
            Card(
              color: serenityBlue,
              child: ListTile(
                leading: const Icon(Icons.health_and_safety_outlined),
                title: const Text('Need professional support?'),
                subtitle: const Text(
                  'Browse verified therapists and choose an available session.',
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => Navigator.pushNamed(context, '/consultation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMedia(MediaAsset media) {
    final page =
        media.isVideo
            ? VideoPlayerScreen(media: media)
            : AudioPlayerScreen(media: media);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => page))
        .then((_) => _recommendations.load());
  }

  String _partOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 18) return 'afternoon';
    return 'evening';
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});

  final Map<String, dynamic> quote;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: serenityMint,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.format_quote),
            const SizedBox(height: 8),
            Text(
              quote['text']?.toString() ?? sampleQuote['text']!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(quote['author']?.toString() ?? 'Serenity Hub'),
          ],
        ),
      ),
    );
  }
}

class _MoodCheckIn extends StatefulWidget {
  const _MoodCheckIn();

  @override
  State<_MoodCheckIn> createState() => _MoodCheckInState();
}

class _MoodCheckInState extends State<_MoodCheckIn> {
  int _score = 3;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood check-in',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            Slider(
              value: _score.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_score',
              onChanged: (value) => setState(() => _score = value.round()),
            ),
            OutlinedButton.icon(
              onPressed:
                  () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Mood check-in saved locally for this prototype.',
                      ),
                    ),
                  ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Save check-in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.resource});

  final Map<String, dynamic>? resource;

  @override
  Widget build(BuildContext context) {
    final item = resource ?? sampleResources.first;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.menu_book_outlined),
        title: Text(item['title']?.toString() ?? ''),
        subtitle: Text(item['summary']?.toString() ?? ''),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => Navigator.pushNamed(context, '/resources'),
      ),
    );
  }
}
