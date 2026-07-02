// lib/models/search_result.dart

class SearchResult {
  final String title;
  final String description;
  final String metadata;
  final String routeName;
  final String type; // article, video, expert, community

  SearchResult({
    required this.title,
    required this.description,
    required this.metadata,
    required this.routeName,
    required this.type,
  });
}