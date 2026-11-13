import 'package:flutter/material.dart';
import 'package:serenity_hub/home.dart';
import 'package:serenity_hub/bookmark.dart';
import 'package:serenity_hub/consultation.dart';
import 'package:serenity_hub/search.dart';
import 'package:serenity_hub/profile.dart';

const Color darkPink = Color(
  0xFFC2185B,
); // Using the same color constant from BookmarkPage

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Schedule',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.pink, // Matching the BookmarkPage color scheme
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: darkPink,
          labelColor: darkPink,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Inter'),
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past Sessions')],
        ),
      ),
      body: Column(
        children: [
          _buildNavigationBar(
            context,
          ), // Navigation at the top like in BookmarkPage
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildUpcomingSessionsTab(), _buildPastSessionsTab()],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSessionBottomSheet(context),
        tooltip: 'Add new session',
        backgroundColor: darkPink,
        child: const Icon(Icons.add),
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
            isActive: true,
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
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSessionsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle('Upcoming Sessions'),
        _buildUpcomingSessionCard(),
        const SizedBox(height: 16),
        _buildSectionTitle('Notifications & Reminders'),
        _buildNotificationsCard(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.pink,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildPastSessionsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Past Sessions'),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Placeholder for a real data source
              itemBuilder: (context, index) {
                return _buildPastSessionCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessionCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_available, color: darkPink),
                const SizedBox(width: 8),
                const Text(
                  'Therapy Session',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkPink,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildSessionInfoRow(Icons.person, 'Dr. Sarah Thompson'),
            _buildSessionInfoRow(Icons.calendar_today, 'Monday, Feb 19, 2025'),
            _buildSessionInfoRow(Icons.access_time, '3:00 PM - 4:00 PM'),
            _buildSessionInfoRow(Icons.video_call, 'Online (Zoom)'),
            const SizedBox(height: 16),
            // UPDATED: Replace Row with Wrap to handle overflow
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 8, // horizontal spacing
              runSpacing: 8, // vertical spacing when wrapped
              children: [
                _buildActionButton(
                  onPressed: () {},
                  color: Colors.blue,
                  icon: Icons.video_call,
                  label: 'Join',
                ),
                _buildActionButton(
                  onPressed: () {},
                  color: Colors.orange,
                  icon: Icons.edit_calendar,
                  label: 'Reschedule',
                ),
                _buildActionButton(
                  onPressed: () => _showCancelConfirmation(context),
                  color: Colors.red,
                  icon: Icons.cancel,
                  label: 'Cancel',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastSessionCard(int index) {
    // Example data - in a real app, this would come from a data source
    final pastSessions = [
      {
        'title': 'Group Therapy: Managing Anxiety Together',
        'date': 'Jan 15, 2025',
        'therapist': 'Dr. Sarah Thompson',
        'imagePath': 'assets/group_therapy.jpg',
      },
      {
        'title': 'Individual Consultation',
        'date': 'Jan 8, 2025',
        'therapist': 'Dr. Michael Chen',
        'imagePath': 'assets/consultation.jpg',
      },
      {
        'title': 'Stress Management Workshop',
        'date': 'Dec 20, 2024',
        'therapist': 'Dr. Lisa Johnson',
        'imagePath': 'assets/stress_management.jpg',
      },
      {
        'title': 'Mindfulness Practice Session',
        'date': 'Dec 10, 2024',
        'therapist': 'Dr. James Wilson',
        'imagePath': 'assets/mindfulness.jpg',
      },
      {
        'title': 'Sleep Hygiene Consultation',
        'date': 'Nov 28, 2024',
        'therapist': 'Dr. Emma Davis',
        'imagePath': 'assets/sleep_hygiene.jpg',
      },
    ];

    final session =
        index < pastSessions.length ? pastSessions[index] : pastSessions[0];

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            session['imagePath']!,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback for missing images
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: Icon(Icons.event_note, color: darkPink),
              );
            },
          ),
        ),
        title: Text(
          session['title']!,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: darkPink,
            fontFamily: 'Inter',
          ),
        ),
        subtitle: Text(
          '${session['date']} • ${session['therapist']}',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_circle_outline, color: darkPink),
          tooltip: 'Listen to recorded session',
          onPressed: () {},
        ),
        onTap: () => _showSessionDetails(context, session),
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, color: darkPink),
                const SizedBox(width: 8),
                const Text(
                  'Upcoming Reminders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkPink,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.pink.shade100,
                child: const Icon(Icons.notifications, color: darkPink),
              ),
              title: const Text(
                'Upcoming session in 30 minutes',
                style: TextStyle(fontFamily: 'Inter'),
              ),
              subtitle: const Text(
                'Dr. Sarah Thompson • 3:00 PM',
                style: TextStyle(fontFamily: 'Inter'),
              ),
              dense: true,
            ),
            SwitchListTile(
              title: const Text(
                'Email reminders',
                style: TextStyle(fontFamily: 'Inter'),
              ),
              subtitle: const Text(
                'Receive reminders 24h before session',
                style: TextStyle(fontFamily: 'Inter'),
              ),
              value: true,
              activeThumbColor: darkPink,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            SwitchListTile(
              title: const Text(
                'SMS notifications',
                style: TextStyle(fontFamily: 'Inter'),
              ),
              subtitle: const Text(
                'Get text alerts 1h before session',
                style: TextStyle(fontFamily: 'Inter'),
              ),
              value: true,
              activeThumbColor: darkPink,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: darkPink),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  // UPDATED: Smaller buttons with reduced padding and font size
  Widget _buildActionButton({
    required VoidCallback onPressed,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 12, // Smaller text
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ), // Smaller padding
      ),
    );
  }

  void _showAddSessionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule a New Session',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkPink,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Select Expert',
                    hint: 'Choose a therapist',
                    items: const [
                      'Dr. Sarah Thompson',
                      'Dr. Michael Chen',
                      'Dr. Lisa Johnson',
                      'Dr. James Wilson',
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePickerField(
                          label: 'Date',
                          hint: 'Select a date',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimePickerField(
                          label: 'Time',
                          hint: 'Select time',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Session Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  RadioGroup<String>(
                    groupValue: 'online',
                    onChanged: (_) {},
                    child: Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text(
                              'Online',
                              style: TextStyle(fontFamily: 'Inter'),
                            ),
                            value: 'online',
                            activeColor: darkPink,
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text(
                              'In-Person',
                              style: TextStyle(fontFamily: 'Inter'),
                            ),
                            value: 'in-person',
                            activeColor: darkPink,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  // UPDATED: Using Wrap instead of Row for payment methods to prevent overflow
                  RadioGroup<String>(
                    groupValue: 'card',
                    onChanged: (_) {},
                    child: Wrap(
                      spacing: 12,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(value: 'card', activeColor: darkPink),
                            const Text(
                              'Card',
                              style: TextStyle(fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(
                              value: 'wallet',
                              activeColor: darkPink,
                            ),
                            const Text(
                              'Wallet',
                              style: TextStyle(fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(
                              value: 'mobile',
                              activeColor: darkPink,
                            ),
                            const Text(
                              'Mobile',
                              style: TextStyle(fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showBookingConfirmation(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirm Booking',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontFamily: 'Inter'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: darkPink, width: 2),
            ),
          ),
          style: const TextStyle(fontFamily: 'Inter'),
          items:
              items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontFamily: 'Inter'),
                  ),
                );
              }).toList(),
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildDatePickerField({required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          readOnly: true,
          style: const TextStyle(fontFamily: 'Inter'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontFamily: 'Inter'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: Icon(Icons.calendar_today, color: darkPink),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: darkPink, width: 2),
            ),
          ),
          onTap: () async {
            // Date picker logic would go here
          },
        ),
      ],
    );
  }

  Widget _buildTimePickerField({required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          readOnly: true,
          style: const TextStyle(fontFamily: 'Inter'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontFamily: 'Inter'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: Icon(Icons.access_time, color: darkPink),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: darkPink, width: 2),
            ),
          ),
          onTap: () async {
            // Time picker logic would go here
          },
        ),
      ],
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Cancel Session?',
              style: TextStyle(
                color: darkPink,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure you want to cancel your session with Dr. Sarah Thompson on Monday, Feb 19, 2025?\n\n'
              'Note: Cancellations within 24 hours may incur a fee.',
              style: TextStyle(fontFamily: 'Inter'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'KEEP SESSION',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Session cancelled successfully',
                        style: TextStyle(fontFamily: 'Inter'),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text(
                  'CANCEL SESSION',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
              ),
            ],
          ),
    );
  }

  void _showBookingConfirmation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Session booked successfully',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSessionDetails(BuildContext context, Map<String, String> session) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['title']!,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkPink,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${session['date']}',
                  style: const TextStyle(fontFamily: 'Inter'),
                ),
                Text(
                  'Therapist: ${session['therapist']}',
                  style: const TextStyle(fontFamily: 'Inter'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Session Notes:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Key topics discussed: Anxiety management techniques, breathing exercises, and cognitive restructuring.',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text(
                      'Listen to Recorded Session',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkPink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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

    if (routeName != '/schedule') {
      // Don't navigate if already on Schedule
      if (pageMap.containsKey(routeName)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => pageMap[routeName]!),
        );
      } else {
        Navigator.pushNamed(context, routeName);
      }
    }
  }
}
