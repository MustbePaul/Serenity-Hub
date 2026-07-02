// home.dart
import 'package:flutter/material.dart';
import 'package:serenity_hub/bookmark.dart';
import 'package:serenity_hub/consultation.dart';
import 'package:serenity_hub/profile.dart';
import 'package:serenity_hub/schedule.dart';
import 'package:serenity_hub/search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mock data for featured experts
  final List<Map<String, String>> _featuredExperts = [
    {
      'name': 'Dr. E Vance',
      'specialty': 'Clinical Psychologist',
      'image': 'assets/expert1.jpg', // Replace with actual image path
    },
    {
      'name': 'Sarah Miller',
      'specialty': 'Licensed Therapist',
      'image': 'assets/expert2.jpg', // Replace with actual image path
    },
    {
      'name': 'James Carter',
      'specialty': 'Counselor',
      'image': 'assets/expert3.jpg', // Replace with actual image path
    },
  ];

  // Mock data for helpful resources
  final List<Map<String, String>> _helpfulResources = [
    {
      'title': '5-Minute Meditation for Beginners',
      'description': 'A simple guided meditation to calm your mind.',
      'link': '/meditation_beginner',
    },
    {
      'title': 'Understanding Anxiety',
      'description': 'Learn about the common symptoms and causes of anxiety.',
      'link': '/understanding_anxiety',
    },
    {
      'title': 'Tips for Better Sleep',
      'description': 'Practical advice to improve your sleep hygiene.',
      'link': '/better_sleep_tips',
    },
  ];

  // Mock data for bookmarked items (replace with actual logic)
  final List<Map<String, String>> _bookmarkedItems = [
    {
      'title': 'Article: Managing Stress at Work',
      'type': 'Article',
      'link': '/stress_management',
    },
    {
      'title': 'Expert Profile: Dr. Eleanor Vance',
      'type': 'Expert',
      'link': '/expert_eleanor',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenWidth = MediaQuery.of(context).size.width;

    // Define responsive breakpoints
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isLargeScreen = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Serenity Hub', style: TextStyle(color: Colors.pink)),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.pink.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.pink),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications will go here')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Add refresh functionality when implemented
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: isSmallScreen ? 12.0 : 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingSection(context),
                  const SizedBox(height: 16),
                  if (_bookmarkedItems.isNotEmpty)
                    _buildBookmarksSection(context, isSmallScreen),
                  if (_bookmarkedItems.isNotEmpty) const SizedBox(height: 16),
                  _buildFeaturedExpertsSection(context, isSmallScreen),
                  const SizedBox(height: 16),
                  _buildHelpfulResourcesSection(context, isSmallScreen),
                  const SizedBox(height: 16),
                  _buildQuickActionsSection(
                    context,
                    isSmallScreen,
                    isMediumScreen,
                    isLargeScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, isSmallScreen),
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    final now = DateTime.now();
    String greeting;
    if (now.hour < 12) {
      greeting = 'Good morning';
    } else if (now.hour < 18) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'How are you feeling today?',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBookmarksSection(BuildContext context, bool isSmallScreen) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate card width and height based on screen width
    final cardWidth = isSmallScreen ? screenWidth * 0.75 : screenWidth * 0.7;
    final cardHeight = isSmallScreen ? 80.0 : 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Bookmarks',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: cardHeight,
          child:
              _bookmarkedItems.isEmpty
                  ? const Center(child: Text('No bookmarks yet'))
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _bookmarkedItems.length,
                    itemBuilder: (context, index) {
                      final bookmark = _bookmarkedItems[index];
                      return Card(
                        margin: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, bookmark['link']!);
                          },
                          child: Container(
                            width: cardWidth,
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bookmark['title']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bookmark['type']!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildFeaturedExpertsSection(
    BuildContext context,
    bool isSmallScreen,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate card width and height based on screen width
    final expertCardWidth =
        isSmallScreen ? 110.0 : (screenWidth < 600 ? 130.0 : 150.0);
    final cardHeight = isSmallScreen ? 150.0 : 170.0;
    final avatarRadius = isSmallScreen ? 35.0 : 40.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Experts',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _featuredExperts.length,
            itemBuilder: (context, index) {
              final expert = _featuredExperts[index];
              return Card(
                margin: const EdgeInsets.only(right: 10),
                clipBehavior: Clip.antiAlias,
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Navigating to ${expert['name']}\'s profile',
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: expertCardWidth,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: avatarRadius,
                            backgroundImage: AssetImage(expert['image']!),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            expert['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expert['specialty']!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHelpfulResourcesSection(
    BuildContext context,
    bool isSmallScreen,
  ) {
    // Adjust padding and font size based on screen size
    final horizontalPadding = isSmallScreen ? 8.0 : 12.0;
    final titleFontSize = isSmallScreen ? 14.0 : 15.0;
    final descFontSize = isSmallScreen ? 12.0 : 13.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Helpful Resources',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _helpfulResources.length,
          itemBuilder: (context, index) {
            final resource = _helpfulResources[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 4,
                ),
                title: Text(
                  resource['title']!,
                  style: TextStyle(fontSize: titleFontSize),
                ),
                subtitle: Text(
                  resource['description']!,
                  style: TextStyle(fontSize: descFontSize),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pushNamed(context, resource['link']!);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(
    BuildContext context,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isLargeScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Use LayoutBuilder for better responsiveness
        LayoutBuilder(
          builder: (context, constraints) {
            // On larger screens, show buttons in a row
            if (isLargeScreen) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _buildQuickActionButtons(context, isSmallScreen),
              );
            }
            // On medium screens, use a fixed count grid
            else if (isMediumScreen) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
                children: _buildQuickActionButtons(context, isSmallScreen),
              );
            }
            // On small screens, use a responsive grid
            else {
              return Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                alignment: WrapAlignment.spaceEvenly,
                children: _buildQuickActionButtons(context, isSmallScreen),
              );
            }
          },
        ),
      ],
    );
  }

  List<Widget> _buildQuickActionButtons(
    BuildContext context,
    bool isSmallScreen,
  ) {
    // Button configuration based on screen size
    final buttonSize = isSmallScreen ? 80.0 : 100.0;
    final iconSize = isSmallScreen ? 24.0 : 30.0;
    final fontSize = isSmallScreen ? 12.0 : 14.0;

    return [
      _buildQuickActionButton(
        context,
        'Consult',
        Icons.chat,
        () => _navigateToPage(context, const ConsultationPage()),
        buttonSize,
        iconSize,
        fontSize,
      ),
      _buildQuickActionButton(
        context,
        'Schedule',
        Icons.calendar_today,
        () => _navigateToPage(context, const SchedulePage()),
        buttonSize,
        iconSize,
        fontSize,
      ),
      _buildQuickActionButton(
        context,
        'Search',
        Icons.search,
        () => _navigateToPage(context, const SearchPage()),
        buttonSize,
        iconSize,
        fontSize,
      ),
    ];
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
    double size,
    double iconSize,
    double fontSize,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isSmallScreen) {
    // Use a more responsive approach for bottom navigation
    if (isSmallScreen) {
      // For very small screens, show only essential navigation items
      return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Consult'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0: // Home
              return;
            case 1: // Consult
              _navigateToPage(context, const ConsultationPage());
              break;
            case 2: // Schedule
              _navigateToPage(context, const SchedulePage());
              break;
            case 3: // Profile
              _navigateToPage(context, const Profile());
              break;
          }
        },
      );
    } else {
      // For normal screens, show all navigation items with labels
      return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Consult'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) => _navigateToBottomBarPage(context, index),
      );
    }
  }

  void _navigateToBottomBarPage(BuildContext context, int index) {
    // Don't navigate if already on home page
    if (index == 0) return;

    // Map index to page
    final pages = [
      null, // Home (index 0)
      const ConsultationPage(),
      const SchedulePage(),
      const SearchPage(),
      const BookmarkPage(),
      const Profile(),
    ];

    if (index < pages.length && pages[index] != null) {
      _navigateToPage(context, pages[index]!);
    }
  }

  // Helper method to navigate to pages
  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
