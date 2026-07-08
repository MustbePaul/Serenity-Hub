import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio_player_screen.dart';
import 'media_detail_screen.dart';
import 'models/media_asset.dart';
import 'providers/media_provider.dart';
import 'video_player_screen.dart';
import 'widgets/category_filter_chips.dart';
import 'widgets/media_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _provider = MediaProvider();
  final _search = TextEditingController();
  String _type = 'all';

  @override
  void initState() {
    super.initState();
    _provider.load();
    _provider.loadProgress();
  }

  @override
  void dispose() {
    _search.dispose();
    _provider.dispose();
    super.dispose();
  }

  Future<void> _load() => _provider.load(type: _type, query: _search.text);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(title: const Text('Library')),
        body: Consumer<MediaProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Search articles, audio, video...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        onPressed: _load,
                        icon: const Icon(Icons.arrow_forward),
                        tooltip: 'Search',
                      ),
                    ),
                    onSubmitted: (_) => _load(),
                  ),
                ),
                CategoryFilterChips(
                  values: const ['all', 'article', 'audio', 'video'],
                  selected: _type,
                  onSelected: (value) {
                    setState(() => _type = value);
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
                            : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.items.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final media = provider.items[index];
                                final progress =
                                    provider.progress
                                        .where(
                                          (item) =>
                                              item.mediaAsset.id == media.id,
                                        )
                                        .firstOrNull
                                        ?.progressPercent ??
                                    0;
                                return MediaCard(
                                  media: media,
                                  progressPercent: progress,
                                  onTap: () => _openMedia(media),
                                );
                              },
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

  void _openMedia(MediaAsset media) {
    final page =
        media.isAudio
            ? AudioPlayerScreen(media: media)
            : media.isVideo
            ? VideoPlayerScreen(media: media)
            : MediaDetailScreen(media: media);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => page))
        .then((_) => _provider.loadProgress());
  }
}
