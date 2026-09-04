import 'package:flutter/material.dart';

import 'api_client.dart';
import 'sample_data.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _api = ApiClient();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _resources =
      sampleResources.map(Map<String, dynamic>.from).toList();
  final Set<int> _bookmarkedIds = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadResources();
    _loadBookmarks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadResources() async {
    setState(() => _loading = true);
    try {
      final query = Uri.encodeQueryComponent(_searchController.text.trim());
      final response = await _api.get(
        '/resources${query.isEmpty ? '' : '?q=$query'}',
      );
      setState(() {
        _resources =
            (response['data'] as List)
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList();
      });
    } catch (_) {
      final q = _searchController.text.toLowerCase();
      setState(() {
        _resources =
            sampleResources
                .where(
                  (item) =>
                      q.isEmpty ||
                      item['title'].toString().toLowerCase().contains(q) ||
                      item['summary'].toString().toLowerCase().contains(q),
                )
                .map(Map<String, dynamic>.from)
                .toList();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadBookmarks() async {
    try {
      final bookmarks = await _api.fetchBookmarks();
      setState(() {
        _bookmarkedIds
          ..clear()
          ..addAll(
            bookmarks
                .map((bookmark) {
                  final resource = bookmark['resource'];
                  return resource is Map
                      ? _asInt(resource['id'])
                      : _asInt(bookmark['resource_id']);
                })
                .where((id) => id != 0),
          );
      });
    } catch (_) {
      // Public resources remain usable when personal bookmarks are unavailable.
    }
  }

  Future<void> _toggleBookmark(Map<String, dynamic> resource) async {
    final id = _asInt(resource['id']);
    if (id == 0) return;
    final wasBookmarked = _bookmarkedIds.contains(id);
    setState(() {
      if (wasBookmarked) {
        _bookmarkedIds.remove(id);
      } else {
        _bookmarkedIds.add(id);
      }
    });
    try {
      if (wasBookmarked) {
        await _api.removeBookmark(id);
      } else {
        await _api.addBookmark(id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(wasBookmarked ? 'Bookmark removed.' : 'Saved.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (wasBookmarked) {
          _bookmarkedIds.add(id);
        } else {
          _bookmarkedIds.remove(id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'We could not update bookmarks. Please sign in and try again.',
          ),
        ),
      );
    }
  }

  void _openResource(Map<String, dynamic> resource) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(resource['title']?.toString() ?? 'Resource'),
            content: SingleChildScrollView(
              child: Text(
                resource['body']?.toString() ??
                    resource['summary']?.toString() ??
                    '',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stress, sleep, anxiety...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _loadResources,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
              onSubmitted: (_) => _loadResources(),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _resources.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final resource = _resources[index];
                final category =
                    resource['category'] is Map
                        ? resource['category']['name']?.toString()
                        : 'Resource';
                final bookmarked = _bookmarkedIds.contains(
                  _asInt(resource['id']),
                );
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: Text(resource['title']?.toString() ?? ''),
                    subtitle: Text('$category - ${resource['summary'] ?? ''}'),
                    isThreeLine: true,
                    onTap: () => _openResource(resource),
                    trailing: IconButton(
                      icon: Icon(
                        bookmarked ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      onPressed: () => _toggleBookmark(resource),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
