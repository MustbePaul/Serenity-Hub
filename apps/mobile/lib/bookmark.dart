import 'package:flutter/material.dart';

import 'api_client.dart';
import 'guest_mode.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final _api = ApiClient();
  List<Map<String, dynamic>> _bookmarks = [];
  bool _loading = true;
  bool _guestMode = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final guestMode = await GuestMode.isEnabled();
    if (guestMode) {
      setState(() {
        _guestMode = true;
        _bookmarks = [];
        _loading = false;
      });
      return;
    }

    try {
      final bookmarks = await _api.fetchBookmarks();
      setState(() {
        _guestMode = false;
        _bookmarks = bookmarks;
      });
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(
        () =>
            _error =
                'Unable to connect. Check your internet connection and try again.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(Map<String, dynamic> bookmark) async {
    final resource = bookmark['resource'];
    final resourceId =
        resource is Map
            ? _asInt(resource['id'])
            : _asInt(bookmark['resource_id']);
    if (resourceId == 0) return;
    final previous = List<Map<String, dynamic>>.from(_bookmarks);
    setState(() {
      _bookmarks.removeWhere(
        (item) => _asInt(item['id']) == _asInt(bookmark['id']),
      );
    });
    try {
      await _api.removeBookmark(resourceId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bookmark removed.')));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _bookmarks = previous);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'We could not remove that bookmark. Please try again.',
            ),
          ),
        );
      }
    }
  }

  void _openResource(Map<String, dynamic> resource) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(resource['title']?.toString() ?? 'Saved resource'),
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
      appBar: AppBar(title: const Text('Saved')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Saved resources',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    if (_guestMode)
                      const Text(
                        'Guest review mode does not sync personal bookmarks.',
                      )
                    else if (_error != null)
                      _StateMessage(message: _error!, onRetry: _load)
                    else if (_bookmarks.isEmpty)
                      _StateMessage(
                        message: 'No saved resources yet.',
                        onRetry: _load,
                      )
                    else
                      ..._bookmarks.map((bookmark) {
                        final resource =
                            bookmark['resource'] is Map
                                ? Map<String, dynamic>.from(
                                  bookmark['resource'] as Map,
                                )
                                : <String, dynamic>{};
                        final category =
                            resource['category'] is Map
                                ? resource['category']['name']?.toString()
                                : 'Resource';
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.bookmark),
                            title: Text(resource['title']?.toString() ?? ''),
                            subtitle: Text(
                              '$category - ${resource['summary'] ?? ''}',
                            ),
                            isThreeLine: true,
                            onTap: () => _openResource(resource),
                            trailing: IconButton(
                              icon: const Icon(Icons.bookmark_remove_outlined),
                              onPressed: () => _remove(bookmark),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
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
