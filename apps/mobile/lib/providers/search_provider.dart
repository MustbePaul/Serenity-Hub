import 'package:flutter/foundation.dart';
import 'package:serenity_hub/models/search_result.dart';

class SearchProvider extends ChangeNotifier {
  List<SearchResult> _searchResults = [];
  List<String> _recentSearches = [];
  String _lastQuery = '';
  bool _isLoading = false;

  List<SearchResult> get searchResults => _searchResults;
  List<String> get recentSearches => _recentSearches;
  String get lastQuery => _lastQuery;
  bool get isLoading => _isLoading;

  Future<void> search(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _lastQuery = query;
    notifyListeners();

    // Add to recent searches (avoid duplicates)
    if (!_recentSearches.contains(query)) {
      _recentSearches = [query, ..._recentSearches.take(4)];
    }

    // Simulate API call with delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock search results based on query
    _searchResults = _getMockResults(query);

    _isLoading = false;
    notifyListeners();
  }

  void clearResults() {
    _searchResults = [];
    _lastQuery = '';
    notifyListeners();
  }

  // Mock data for demonstration purposes
  List<SearchResult> _getMockResults(String query) {
    final lowercaseQuery = query.toLowerCase();

    // Sample data
    final allResults = [
      SearchResult(
        title: 'Article: 5-Minute Techniques to Reduce Anxiety',
        description:
            'A quick guide on deep breathing and visualization exercises to calm your mind.',
        metadata: '🕒 Published: 2 days ago | 👀 10.2K views',
        routeName: '/article_anxiety',
        type: 'article',
      ),
      SearchResult(
        title: 'Expert Advice: How to Handle Anxiety Attacks in Public',
        description:
            'One of the best ways to manage sudden anxiety attacks is by focusing on your five senses...',
        metadata: '👩‍⚕️ Dr. Sarah Thompson | 🏥 Licensed Therapist',
        routeName: '/expert_advice',
        type: 'expert',
      ),
      SearchResult(
        title: 'Community Discussion: What helps you when feeling anxious?',
        description:
            'I find that listening to calming music or stepping outside really helps!',
        metadata: '📝 85 Comments | ❤️ 312 Likes',
        routeName: '/community_discussion',
        type: 'community',
      ),
      SearchResult(
        title: 'Video: Guided Meditation for Anxiety Relief (10 mins)',
        description:
            'Listen to this calming meditation to relax your thoughts.',
        metadata: '▶️ YouTube | 15.6K Views',
        routeName: '/meditation_video',
        type: 'video',
      ),
      SearchResult(
        title: 'Article: Understanding Sleep Anxiety',
        description:
            'Learn why anxiety can impact your sleep and practical strategies to address it.',
        metadata: '🕒 Published: 1 week ago | 👀 8.7K views',
        routeName: '/article_sleep_anxiety',
        type: 'article',
      ),
      SearchResult(
        title: 'Video: Mindfulness Practices for Daily Life',
        description:
            'Simple mindfulness techniques you can incorporate into your everyday routine.',
        metadata: '▶️ YouTube | 22.3K Views',
        routeName: '/mindfulness_video',
        type: 'video',
      ),
      SearchResult(
        title: 'Expert Advice: Cognitive Behavioral Techniques for Depression',
        description:
            'Evidence-based CBT approaches that can help manage depression symptoms.',
        metadata: '👨‍⚕️ Dr. Michael Chen | 🏥 Clinical Psychologist',
        routeName: '/expert_depression',
        type: 'expert',
      ),
      SearchResult(
        title:
            'Community Discussion: Self-care routines that changed your life',
        description:
            'Share and discover self-care practices that have made a significant impact.',
        metadata: '📝 126 Comments | ❤️ 489 Likes',
        routeName: '/community_selfcare',
        type: 'community',
      ),
    ];

    // Filter results based on query
    return allResults.where((result) {
      return result.title.toLowerCase().contains(lowercaseQuery) ||
          result.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
