import 'package:flutter/material.dart';
import 'package:serenity_hub/home.dart';
import 'package:serenity_hub/bookmark.dart';
import 'package:serenity_hub/consultation.dart';
import 'package:serenity_hub/schedule.dart';
import 'package:serenity_hub/profile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';

  // Mock search results
  List<Map<String, String>> _searchResults = [];
  List<String> _recentSearches = ['anxiety', 'sleep', 'meditation'];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    _searchQuery = _searchController.text.trim();
    if (_searchQuery.isNotEmpty) {
      setState(() {
        _isSearching = true;

        // Add to recent searches (avoid duplicates)
        if (!_recentSearches.contains(_searchQuery)) {
          _recentSearches = [_searchQuery, ..._recentSearches.take(4)];
        }
      });

      // Simulate API call with delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _searchResults = _getMockResults(_searchQuery);
          });
        }
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
    setState(() {
      _searchQuery = '';
      _searchResults = [];
    });
  }

  // Mock data for demonstration purposes
  List<Map<String, String>> _getMockResults(String query) {
    final lowercaseQuery = query.toLowerCase();

    // Sample data with explicit String types
    final allResults = <Map<String, String>>[
      {
        'title': 'Article: 5-Minute Techniques to Reduce Anxiety',
        'description':
            'A quick guide on deep breathing and visualization exercises to calm your mind.',
        'metadata': '🕒 Published: 2 days ago | 👀 10.2K views',
        'routeName': '/article_anxiety',
        'type': 'article',
      },
      {
        'title': 'Expert Advice: How to Handle Anxiety Attacks in Public',
        'description':
            'One of the best ways to manage sudden anxiety attacks is by focusing on your five senses...',
        'metadata': '👩‍⚕️ Dr. Sarah Thompson | 🏥 Licensed Therapist',
        'routeName': '/expert_advice',
        'type': 'expert',
      },
      {
        'title': 'Community Discussion: What helps you when feeling anxious?',
        'description':
            'I find that listening to calming music or stepping outside really helps!',
        'metadata': '📝 85 Comments | ❤️ 312 Likes',
        'routeName': '/community_discussion',
        'type': 'community',
      },
      {
        'title': 'Video: Guided Meditation for Anxiety Relief (10 mins)',
        'description':
            'Listen to this calming meditation to relax your thoughts.',
        'metadata': '▶️ YouTube | 15.6K Views',
        'routeName': '/meditation_video',
        'type': 'video',
      },
      {
        'title': 'Article: Understanding Sleep Anxiety',
        'description':
            'Learn why anxiety can impact your sleep and practical strategies to address it.',
        'metadata': '🕒 Published: 1 week ago | 👀 8.7K views',
        'routeName': '/article_sleep_anxiety',
        'type': 'article',
      },
      {
        'title': 'Video: Mindfulness Practices for Daily Life',
        'description':
            'Simple mindfulness techniques you can incorporate into your everyday routine.',
        'metadata': '▶️ YouTube | 22.3K Views',
        'routeName': '/mindfulness_video',
        'type': 'video',
      },
      {
        'title':
            'Expert Advice: Cognitive Behavioral Techniques for Depression',
        'description':
            'Evidence-based CBT approaches that can help manage depression symptoms.',
        'metadata': '👨‍⚕️ Dr. Michael Chen | 🏥 Clinical Psychologist',
        'routeName': '/expert_depression',
        'type': 'expert',
      },
      {
        'title':
            'Community Discussion: Self-care routines that changed your life',
        'description':
            'Share and discover self-care practices that have made a significant impact.',
        'metadata': '📝 126 Comments | ❤️ 489 Likes',
        'routeName': '/community_selfcare',
        'type': 'community',
      },
    ];

    // Filter results based on query
    return allResults.where((result) {
      return result['title']!.toLowerCase().contains(lowercaseQuery) ||
          result['description']!.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _clearSearch,
              tooltip: 'Clear search',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kBottomNavigationBarHeight),
          child: _buildTopNavigationBar(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child:
                _isSearching
                    ? _buildLoadingIndicator()
                    : _buildSearchResults(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Searching...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.primaryContainer.withValues(
        alpha: 0.1,
      ), // Subtle background
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(fontFamily: 'Inter'),
              decoration: InputDecoration(
                hintText: 'Search for topics, articles, experts...',
                hintStyle: const TextStyle(fontFamily: 'Inter'),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: _clearSearch,
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 12.0,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(),
              onChanged: (value) {
                setState(() {}); // Refresh UI to update clear button visibility
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 16.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_searchQuery.isEmpty && _searchResults.isEmpty) {
      return _buildSearchSuggestions();
    }

    if (_searchResults.isEmpty && _searchQuery.isNotEmpty) {
      return _buildNoResultsFound();
    }

    return _buildResultsList(_searchResults);
  }

  Widget _buildSearchSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Popular topics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildTopicChip('Anxiety'),
              _buildTopicChip('Meditation'),
              _buildTopicChip('Sleep'),
              _buildTopicChip('Stress'),
              _buildTopicChip('Depression'),
              _buildTopicChip('Mindfulness'),
              _buildTopicChip('Self-care'),
              _buildTopicChip('Therapy'),
            ],
          ),
          const SizedBox(height: 24.0),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'Recent searches',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          if (_recentSearches.isEmpty)
            const Text(
              'No recent searches',
              style: TextStyle(fontFamily: 'Inter'),
            )
          else
            Column(
              children:
                  _recentSearches
                      .map(
                        (search) => ListTile(
                          leading: const Icon(
                            Icons.history,
                            color: Colors.grey,
                          ),
                          title: Text(
                            search,
                            style: const TextStyle(fontFamily: 'Inter'),
                          ),
                          trailing: const Icon(
                            Icons.north_west,
                            size: 16,
                            color: Colors.grey,
                          ),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            _searchController.text = search;
                            _performSearch();
                          },
                        ),
                      )
                      .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTopicChip(String label) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          fontFamily: 'Inter',
        ),
      ),
      onPressed: () {
        _searchController.text = label;
        _performSearch();
      },
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    );
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "$_searchQuery"',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontFamily: 'Inter'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try different keywords or check your spelling',
            style: TextStyle(color: Colors.grey, fontFamily: 'Inter'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<Map<String, String>> results) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildSearchResultItem(
          context,
          result['title']!,
          result['description']!,
          result['metadata']!,
          result['routeName']!,
          result['type']!,
        );
      },
    );
  }

  Widget _buildSearchResultItem(
    BuildContext context,
    String title,
    String subtitle,
    String additionalInfo,
    String routeName,
    String type,
  ) {
    IconData typeIcon = Icons.article;
    Color typeColor =
        Theme.of(context).colorScheme.primary; // Default primary color

    // Determine icon and color based on content type
    switch (type) {
      case 'article':
        typeIcon = Icons.article;
        typeColor = Colors.blue.shade400;
        break;
      case 'video':
        typeIcon = Icons.play_circle;
        typeColor = Colors.red.shade400;
        break;
      case 'expert':
        typeIcon = Icons.person;
        typeColor = Colors.purple.shade400;
        break;
      case 'community':
        typeIcon = Icons.forum;
        typeColor = Colors.green.shade400;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 1, // Subtle shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(typeIcon, color: typeColor),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[700],
                            fontFamily: 'Inter',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                additionalInfo,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.bookmark_border, size: 16.0),
                    label: const Text(
                      'Save',
                      style: TextStyle(fontFamily: 'Inter'),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    onPressed: () {
                      // Implement bookmark functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Saved "$title" to bookmarks',
                            style: const TextStyle(fontFamily: 'Inter'),
                          ),
                        ),
                      );
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.share, size: 16.0),
                    label: const Text(
                      'Share',
                      style: TextStyle(fontFamily: 'Inter'),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    onPressed: () {
                      // Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Sharing "$title"',
                            style: const TextStyle(fontFamily: 'Inter'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 3, // Search page index
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Consult'),
        BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookmarks'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (index) {
        _navigateToTopBarPage(context, index);
      },
    );
  }

  void _navigateToTopBarPage(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const ConsultationPage();
        break;
      case 2:
        page = const SchedulePage();
        break;
      case 3:
        return; // Already on search page
      case 4:
        page = const BookmarkPage();
        break;
      case 5:
        page = const Profile();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
