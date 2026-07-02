import 'package:flutter/material.dart';
import 'package:serenity_hub/home.dart';
import 'package:serenity_hub/consultation.dart';
import 'package:serenity_hub/schedule.dart';
import 'package:serenity_hub/search.dart';
import 'package:serenity_hub/profile.dart';

const Color darkPink = Color(0xFFC2185B);

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookmarks'),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          _buildNavigationBar(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildBookmarkListSection(context),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 12, right: 12, bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavigationButton(context, Icons.home_filled, 'Home', '/home'),
          _buildNavigationButton(
            context,
            Icons.chat_bubble_rounded,
            'Consult',
            '/consultation',
          ),
          _buildNavigationButton(
            context,
            Icons.calendar_today_rounded,
            'Schedule',
            '/schedule',
          ),
          _buildNavigationButton(
            context,
            Icons.search_rounded,
            'Search',
            '/search',
          ),
          _buildNavigationButton(
            context,
            Icons.person_rounded,
            'Profile',
            '/profile',
          ),
          _buildNavigationButton(
            context,
            Icons.bookmark_rounded,
            'Bookmarks',
            '/bookmark',
            isActive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    IconData icon,
    String label,
    String routeName, {
    bool isActive = false,
  }) {
    final color = isActive ? Colors.pink.shade400 : Colors.grey.shade600;

    return InkWell(
      onTap: () => _navigateToPage(context, routeName),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String routeName) {
    final pageMap = {
      '/profile': const Profile(),
      '/home': const HomePage(),
      '/bookmark': const BookmarkPage(),
      '/consultation': const ConsultationPage(),
      '/search': const SearchPage(),
      '/schedule': const SchedulePage(),
    };

    if (pageMap.containsKey(routeName)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => pageMap[routeName]!),
      );
    } else {
      Navigator.pushNamed(context, routeName);
    }
  }

  Widget _buildBookmarkListSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved Resources',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        ),
        const SizedBox(height: 16),
        _buildBookmarkItem(
          context,
          'Managing Panic Attacks',
          'Learn effective techniques to handle panic attacks.',
          'assets/panic_attack.jpg',
          '/article/panic_attacks',
        ),
        _buildBookmarkItem(
          context,
          'Dr. Emily Carter - Stress Management',
          'Expert tips from a renowned therapist.',
          'assets/doctor_emily.jpg',
          '/expert/emily_carter',
        ),
        _buildBookmarkItem(
          context,
          'Mindfulness Meditation Guide',
          'A step-by-step guide to practice mindfulness.',
          'assets/meditation.jpg',
          '/meditation_guide',
        ),
      ],
    );
  }

  Widget _buildBookmarkItem(
    BuildContext context,
    String title,
    String subtitle,
    String imagePath,
    String routeName,
  ) {
    // Improved card layout with constrained height and width
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 80),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image container with fixed size
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              ),
              // Text content with flexible width
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.pink,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // Remove bookmark button
              IconButton(
                icon: const Icon(
                  Icons.bookmark_remove,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  _removeBookmark(context, title);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeBookmark(BuildContext context, String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Removed "$title" from bookmarks.')));
    // Add code to actually remove the bookmark from your data source
  }
}
