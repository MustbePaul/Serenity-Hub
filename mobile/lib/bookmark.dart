import 'package:flutter/material.dart';

import 'sample_data.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = sampleResources.take(2).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Saved resources',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bookmarks sync through /api/v1/bookmarks when signed in.',
          ),
          const SizedBox(height: 16),
          ...saved.map(
            (resource) => Card(
              child: ListTile(
                leading: const Icon(Icons.bookmark),
                title: Text(resource['title'].toString()),
                subtitle: Text(resource['summary'].toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.bookmark_remove_outlined),
                  onPressed:
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Bookmark removal is wired to the Laravel API next.',
                          ),
                        ),
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
