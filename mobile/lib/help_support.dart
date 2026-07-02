import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final List<String> _categories = [
    'General Inquiry',
    'Technical Issue',
    'Billing Question',
    'Feature Request',
    'Other',
  ];
  String _selectedCategory = 'General Inquiry';
  bool _isUrgent = false;
  bool _isSubmitting = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Support message sent! We\'ll get back to you soon.',
              style: TextStyle(fontFamily: 'Inter'),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 4),
          ),
        );

        // Clear form
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        setState(() {
          _selectedCategory = 'General Inquiry';
          _isUrgent = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not launch URL',
              style: TextStyle(fontFamily: 'Inter'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Inter'),
          tabs: const [
            Tab(text: 'FAQs'),
            Tab(text: 'Contact Us'),
            Tab(text: 'Resources'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFaqTab(), _buildContactTab(), _buildResourcesTab()],
      ),
    );
  }

  Widget _buildFaqTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: 'Search FAQs...',
                          hintStyle: const TextStyle(fontFamily: 'Inter'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFaqSection('Account Management', [
                  _faqItem(
                    question: 'How do I change my password?',
                    answer:
                        'Go to Edit Profile and tap on the change password option. You\'ll need to enter your current password followed by your new password twice to confirm.',
                  ),
                  _faqItem(
                    question: 'How do I update my profile information?',
                    answer:
                        'Go to the Profile tab and tap on Edit Profile. From there, you can modify your personal information, profile picture, and notification preferences.',
                  ),
                  _faqItem(
                    question: 'Can I delete my account?',
                    answer:
                        'Yes. Go to Settings > Account > Delete Account. Please note that this action is permanent and all your data will be removed from our servers after a 30-day grace period.',
                  ),
                ]),
                const SizedBox(height: 16),
                _buildFaqSection('Technical Support', [
                  _faqItem(
                    question: 'The app keeps crashing, what should I do?',
                    answer:
                        'First, try restarting the app. If that doesn\'t work, try restarting your device. If the issue persists, make sure your app is updated to the latest version. You can also try clearing the app cache in your device settings.',
                  ),
                  _faqItem(
                    question: 'How do I report a bug?',
                    answer:
                        'You can report bugs through the Contact Us form. Select "Technical Issue" as the category and provide as much detail as possible about what happened and the steps to reproduce the issue.',
                  ),
                ]),
                const SizedBox(height: 16),
                _buildFaqSection('Billing & Subscription', [
                  _faqItem(
                    question: 'How do I change my subscription plan?',
                    answer:
                        'Go to Settings > Subscription > Manage Plan. From there, you can view available plans and make changes to your current subscription.',
                  ),
                  _faqItem(
                    question: 'How do I update my payment method?',
                    answer:
                        'Go to Settings > Payment Methods. You can add a new payment method or edit existing ones. Your next billing cycle will use the payment method you set as default.',
                  ),
                  _faqItem(
                    question: 'When will I be charged for my subscription?',
                    answer:
                        "You will be charged at the beginning of each billing cycle. You can find your next billing date in Settings > Subscription.",
                  ),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _faqItem({required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.thumb_up_outlined, size: 16),
                label: const Text(
                  'Helpful',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Thanks for your feedback!',
                        style: TextStyle(fontFamily: 'Inter'),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.thumb_down_outlined, size: 16),
                label: const Text(
                  'Not helpful',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'We\'ll work on improving this answer.',
                        style: TextStyle(fontFamily: 'Inter'),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(fontFamily: 'Inter'),
                          decoration: InputDecoration(
                            labelText: 'Your Name',
                            labelStyle: const TextStyle(fontFamily: 'Inter'),
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontFamily: 'Inter'),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: const TextStyle(fontFamily: 'Inter'),
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          style: const TextStyle(fontFamily: 'Inter'),
                          decoration: InputDecoration(
                            labelText: 'Issue Category',
                            labelStyle: const TextStyle(fontFamily: 'Inter'),
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items:
                              _categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: const TextStyle(fontFamily: 'Inter'),
                                  ),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _messageController,
                          style: const TextStyle(fontFamily: 'Inter'),
                          decoration: InputDecoration(
                            labelText: 'Your Message',
                            labelStyle: const TextStyle(fontFamily: 'Inter'),
                            prefixIcon: const Icon(Icons.message),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: 'Please describe your issue in detail...',
                            hintStyle: const TextStyle(fontFamily: 'Inter'),
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a message';
                            }
                            if (value.trim().length < 10) {
                              return 'Please provide more details (at least 10 characters)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: _isUrgent,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isUrgent = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              'Mark as urgent',
                              style: TextStyle(fontFamily: 'Inter'),
                            ),
                            const Tooltip(
                              message:
                                  'Urgent issues will be prioritized for faster response.',
                              child: Icon(Icons.info_outline, size: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _isSubmitting ? null : _submitForm,
                            icon:
                                _isSubmitting
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.send),
                            label: Text(
                              _isSubmitting ? 'Sending...' : 'Submit',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Other Ways to Reach Us',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _contactMethod(
                    icon: Icons.phone,
                    title: 'Call Support',
                    description: 'Available Mon-Fri, 9 AM - 5 PM EST',
                    actionText: '+1 (555) 123-4567',
                    onTap: () => _launchUrl('tel:+15551234567'),
                  ),
                  const Divider(),
                  _contactMethod(
                    icon: Icons.chat,
                    title: 'Live Chat',
                    description: 'Chat with a support agent in real-time',
                    actionText: 'Start Chat',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Live chat would open here',
                            style: TextStyle(fontFamily: 'Inter'),
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _contactMethod(
                    icon: Icons.email,
                    title: 'Email Support',
                    description: 'We\'ll respond within 24 hours',
                    actionText: 'support@example.com',
                    onTap: () => _launchUrl('mailto:support@example.com'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactMethod({
    required IconData icon,
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          fontFamily: 'Inter',
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
        ),
      ),
      trailing: TextButton(
        onPressed: onTap,
        child: Text(actionText, style: const TextStyle(fontFamily: 'Inter')),
      ),
    );
  }

  Widget _buildResourcesTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Helpful Resources',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                _resourceItem(
                  title: 'Getting Started Guide',
                  description:
                      'Learn the basics of using our app with this comprehensive guide.',
                  url: 'https://example.com/getting-started',
                ),
                const SizedBox(height: 12),
                _resourceItem(
                  title: 'Video Tutorials',
                  description:
                      'Watch our step-by-step video tutorials to master key features.',
                  url: 'https://example.com/video-tutorials',
                ),
                const SizedBox(height: 12),
                _resourceItem(
                  title: 'Community Forum',
                  description:
                      'Connect with other users and find solutions in our community forum.',
                  url: 'https://example.com/community-forum',
                ),
                const SizedBox(height: 12),
                _resourceItem(
                  title: 'API Documentation',
                  description:
                      'Developers can find detailed information about our API here.',
                  url: 'https://example.com/api-documentation',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _resourceItem({
    required String title,
    required String description,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Icon(Icons.link, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Inter',
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
