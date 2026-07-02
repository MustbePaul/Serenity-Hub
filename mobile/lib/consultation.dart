import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serenity_hub/bookmark.dart';
import 'package:serenity_hub/schedule.dart';
import 'package:serenity_hub/search.dart';
import 'package:serenity_hub/profile.dart';

class ConsultationPage extends StatefulWidget {
  const ConsultationPage({super.key});

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  final ScrollController _scrollController = ScrollController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedSessionType;
  String? _selectedPaymentMethod;
  double _priceRange = 10000; // Default price in MWK
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _mockExperts = [
    {
      'name': 'Dr. Sarah Thompson',
      'specialty': 'Therapist, Anxiety & Stress Management',
      'rating': 4.8,
      'reviews': 125,
      'price': 15000, // Price per session in MWK
      'image': 'assets/doctor_sarah.jpg',
    },
    {
      'name': 'Dr. John Williams',
      'specialty': 'Counselor, Depression & Trauma',
      'rating': 4.5,
      'reviews': 90,
      'price': 10000, // Price per session in MWK
      'image': 'assets/doctor_john.jpg',
    },
    {
      'name': 'Mrs. Alice Banda',
      'specialty': 'Child and Adolescent Psychology',
      'rating': 4.9,
      'reviews': 75,
      'price': 12000, // Price per session in MWK
      'image': 'assets/doctor_alice.jpg',
    },
    {
      'name': 'Mr. David Phiri',
      'specialty': 'Relationship Counseling',
      'rating': 4.6,
      'reviews': 110,
      'price': 18000, // Price per session in MWK
      'image': 'assets/doctor_david.jpg',
    },
    // Add more mock experts here with their prices in MWK
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink.shade400,
              onPrimary: Colors.white,
              secondary: Colors.pink.shade100,
              onSecondary: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.pink.shade700, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink.shade400,
              onPrimary: Colors.white,
              secondary: Colors.pink.shade100,
              onSecondary: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.pink.shade700, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _confirmBooking() {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _selectedSessionType == null ||
        _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields before confirming your booking.',
          ),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Booking",
            style: TextStyle(color: Colors.pink.shade700),
          ),
          content: Text(
            "Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}\n"
            "Time: ${_selectedTime!.format(context)}\n"
            "Session: $_selectedSessionType\n"
            "Payment: $_selectedPaymentMethod",
            style: const TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade400,
                foregroundColor: Colors.white,
              ),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Consultations'),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.pink.shade700,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNavigationBar(context),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildFilterSection(),
              const SizedBox(height: 20),
              _buildExpertListSection(),
              const SizedBox(height: 20),
              _buildScheduleSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: Colors.pink.shade400,
        tooltip: 'Scroll to top',
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            isActive: true,
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

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Search Experts',
        hintText: 'Search by Name, Specialty, or Condition',
        prefixIcon: Icon(Icons.search, color: Colors.pink.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.pink.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          items:
              ['Chat', 'Video', 'Audio'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.black87),
                  ),
                );
              }).toList(),
          onChanged: (value) => setState(() => _selectedSessionType = value),
          decoration: InputDecoration(
            labelText: 'Session Type',
            labelStyle: TextStyle(color: Colors.pink.shade700),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.pink.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Price Range (MWK): ${NumberFormat('#,##0', 'en_MW').format(_priceRange.round())}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.pink.shade700,
          ),
        ),
        Slider(
          value: _priceRange,
          onChanged: (value) => setState(() => _priceRange = value),
          min: 0,
          max: 50000, // Adjusted maximum price in MWK
          divisions: 100, // Keep a reasonable number of divisions
          activeColor: Colors.pink.shade400,
          inactiveColor: Colors.pink.shade100,
          thumbColor: Colors.pink.shade400,
          label: NumberFormat('#,##0', 'en_MW').format(_priceRange.round()),
        ),
      ],
    );
  }

  // Fixed expert list section - replaced Table with Row and Column layout
  Widget _buildExpertListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Experts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.pink.shade900,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mockExperts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final expert = _mockExperts[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Expert image
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage(expert['image'] as String),
                      backgroundColor: Colors.pink.shade100,
                    ),

                    // Expert details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expert['name'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.pink.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              expert['specialty'] as String,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${expert['rating']} (${expert['reviews']} reviews)',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Price: MWK ${NumberFormat('#,##0', 'en_MW').format(expert['price'])}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Book Now button - fixed width to prevent overflow
                    SizedBox(
                      width: 100, // Fixed width for button
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          "Book Now",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule Your Consultation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.pink.shade900,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => _selectDate(context),
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          label: Text(
            _selectedDate == null
                ? 'Select Date'
                : DateFormat('yyyy-MM-dd').format(_selectedDate!),
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => _selectTime(context),
          icon: const Icon(Icons.timer, color: Colors.white),
          label: Text(
            _selectedTime == null
                ? 'Select Time'
                : _selectedTime!.format(context),
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Added payment method dropdown
        DropdownButtonFormField<String>(
          items:
              ['Mobile Money', 'Bank Transfer', 'Cash'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.black87),
                  ),
                );
              }).toList(),
          onChanged: (value) => setState(() => _selectedPaymentMethod = value),
          decoration: InputDecoration(
            labelText: 'Payment Method',
            labelStyle: TextStyle(color: Colors.pink.shade700),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.pink.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _confirmBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text("Confirm Booking", style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
