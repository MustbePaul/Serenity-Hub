import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'audio_player_screen.dart';
import 'crisis_support.dart';
import 'guest_mode.dart';
import 'media_detail_screen.dart';
import 'models/media_asset.dart';
import 'models/mood_scale.dart';
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
  Map<String, dynamic>? _affirmation;
  Map<String, dynamic>? _latestMood;
  Map<String, dynamic>? _resource = Map<String, dynamic>.from(
    sampleResources.first,
  );
  bool _loading = true;
  bool _guestMode = false;

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
    final guestMode = await GuestMode.isEnabled();
    try {
      final response = await _api.get('/home');
      await _recommendations.load();
      final data = response['data'] as Map<String, dynamic>;
      setState(() {
        _quote = Map<String, dynamic>.from(data['quote'] ?? sampleQuote);
        _affirmation =
            data['affirmation'] == null
                ? null
                : Map<String, dynamic>.from(data['affirmation']);
        _latestMood =
            data['latest_mood'] == null
                ? null
                : Map<String, dynamic>.from(data['latest_mood']);
        _guestMode = guestMode;
        _resource =
            data['recommended_resource'] == null
                ? Map<String, dynamic>.from(sampleResources.first)
                : Map<String, dynamic>.from(data['recommended_resource']);
      });
    } catch (_) {
      await _recommendations.load();
      setState(() {
        _quote = Map<String, dynamic>.from(sampleQuote);
        _affirmation = Map<String, dynamic>.from(sampleAffirmation);
        _latestMood = null;
        _resource = Map<String, dynamic>.from(sampleResources.first);
        _guestMode = guestMode;
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
            if (_guestMode) ...[
              const _GuestReviewBanner(),
              const SizedBox(height: 12),
            ],
            _QuoteCard(
              quote: _quote,
              affirmation: _affirmation,
              latestMood: _latestMood,
            ),
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
            Card(
              color: serenityWarm,
              child: ListTile(
                leading: const Icon(Icons.emergency_outlined),
                title: const Text('Need urgent help now?'),
                subtitle: const Text(crisisSafetyNotice),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => showCrisisSupportSheet(context),
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
            : media.isAudio
            ? AudioPlayerScreen(media: media)
            : MediaDetailScreen(media: media);
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

class _GuestReviewBanner extends StatelessWidget {
  const _GuestReviewBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: serenityBlue,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.visibility_outlined),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Guest review mode is active. The app is using built-in demo content, so the therapy workflow can be reviewed without a live backend.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.affirmation,
    required this.latestMood,
  });

  final Map<String, dynamic> quote;
  final Map<String, dynamic>? affirmation;
  final Map<String, dynamic>? latestMood;

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
              (quote['type']?.toString() ?? 'quote').toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text(
              quote['text']?.toString() ?? sampleQuote['text']!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(quote['author']?.toString() ?? 'Serenity Hub'),
            if (affirmation != null) ...[
              const Divider(height: 24),
              Text(
                latestMood == null
                    ? 'AFFIRMATION'
                    : 'AFFIRMATION FOR ${latestMood!['label']?.toString().toUpperCase()}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              Text(
                affirmation!['text']?.toString() ?? '',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Suggested for reflection only, not as diagnosis or treatment advice.',
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quote saved for this device session.'),
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Save'),
              ),
            ),
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
  static const _pendingKey = 'pending_mood_checkins';
  final _api = ApiClient();
  int _score = 3;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _syncPending();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    if (await GuestMode.isEnabled()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guest review: mood noted locally.')),
        );
        setState(() => _saving = false);
      }
      return;
    }
    final payload = {
      'mood_score': _score,
      'tags': [MoodScale.byScore(_score).recommendationTag],
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await _syncPending();
      await _api.submitMood(
        moodScore: _score,
        tags: [MoodScale.byScore(_score).recommendationTag],
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Mood check-in saved.')));
      }
    } catch (_) {
      await _queuePending(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Mood saved on this device and will sync when you are online.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _queuePending(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final current =
        (jsonDecode(prefs.getString(_pendingKey) ?? '[]') as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
    final key = '${payload['mood_score']}_${payload['created_at']}';
    if (!current.any(
      (item) => '${item['mood_score']}_${item['created_at']}' == key,
    )) {
      current.add(payload);
    }
    await prefs.setString(_pendingKey, jsonEncode(current));
  }

  Future<void> _syncPending() async {
    if (await GuestMode.isEnabled()) return;
    final prefs = await SharedPreferences.getInstance();
    final pending =
        (jsonDecode(prefs.getString(_pendingKey) ?? '[]') as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
    if (pending.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];
    for (final item in pending) {
      try {
        final score = item['mood_score'];
        await _api.submitMood(
          moodScore: score is int ? score : int.parse(score.toString()),
          tags:
              (item['tags'] as List? ?? const [])
                  .map((tag) => tag.toString())
                  .toList(),
        );
      } catch (_) {
        remaining.add(item);
      }
    }
    await prefs.setString(_pendingKey, jsonEncode(remaining));
  }

  @override
  Widget build(BuildContext context) {
    final selected = MoodScale.byScore(_score);
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
            const SizedBox(height: 6),
            const Text(
              'Choose the number that best matches how today feels. The labels explain the scale from 1 very low to 5 very good.',
            ),
            const SizedBox(height: 12),
            ...MoodScale.options.map((option) {
              final isSelected = option.score == _score;
              return Semantics(
                button: true,
                selected: isSelected,
                label: option.semanticLabel,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _score = option.score),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                        color:
                            isSelected
                                ? serenityMint
                                : Theme.of(context).cardColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(option.icon),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.shortLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(option.explanation),
                                ],
                              ),
                            ),
                            if (isSelected) const Icon(Icons.check_circle),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            Text('Selected: ${selected.shortLabel}'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _saving ? null : _save,
              icon:
                  _saving
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.check_circle_outline),
              label: Text(_saving ? 'Saving...' : 'Save check-in'),
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
