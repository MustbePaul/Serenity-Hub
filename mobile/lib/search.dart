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
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadResources();
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
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: Text(resource['title']?.toString() ?? ''),
                    subtitle: Text('$category • ${resource['summary'] ?? ''}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      onPressed:
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Saved to bookmarks when signed in.',
                              ),
                            ),
                          ),
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
