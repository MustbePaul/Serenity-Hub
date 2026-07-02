import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_profile.dart';
import 'settings.dart';
import 'help_support.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> {
  final user = Supabase.instance.client.auth.currentUser;
  String? _name, _username, _phone, _location, _profilePictureUrl;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // Method to fetch profile data from Supabase, including profile picture
  void _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No user logged in';
      });
      return;
    }

    try {
      final response =
          await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', user!.id)
              .single();

      setState(() {
        _name = response['name'];
        _username = response['username'];
        _phone = response['phone'];
        _location = response['location'];
        _profilePictureUrl = response['profile_picture_url'];
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _name = _username = _phone = _location = 'N/A';
        _profilePictureUrl = null;
        _isLoading = false;
        _errorMessage = 'Failed to load profile data. Please try again later.';
      });
      debugPrint('Error fetching profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), elevation: 2),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty && user == null
              ? Center(child: Text(_errorMessage))
              : _buildProfileContent(context),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _fetchProfile();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            _buildProfileInfoCard(),
            const SizedBox(height: 20),
            _buildNavigationCard(context),
            const SizedBox(height: 20),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xC9FFC0CB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Profile Picture
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  _profilePictureUrl != null
                      ? CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(_profilePictureUrl!),
                      )
                      : const CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
            ),
            const SizedBox(height: 20),

            // Profile Info
            _buildProfileInfoRow(Icons.person, 'Name', _name ?? 'N/A', true),
            _buildProfileInfoRow(
              Icons.alternate_email,
              'Username',
              _username ?? 'N/A',
            ),
            _buildProfileInfoRow(Icons.email, 'Email', user?.email ?? 'N/A'),
            _buildProfileInfoRow(Icons.phone, 'Phone', _phone ?? 'N/A'),
            _buildProfileInfoRow(
              Icons.location_on,
              'Location',
              _location ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(
    IconData icon,
    String label,
    String value, [
    bool isTitle = false,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.pink.shade700),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.pink.shade900,
              fontSize: isTitle ? 16 : 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
                fontSize: isTitle ? 18 : 14,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xC9FFC0CB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNavigationButton(context, 'Edit Profile', Icons.edit, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              ).then((_) => _fetchProfile());
            }),
            const SizedBox(height: 12),
            _buildNavigationButton(context, 'Settings', Icons.settings, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            }),
            const SizedBox(height: 12),
            _buildNavigationButton(
              context,
              'Help & Support',
              Icons.help_outline,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Show confirmation dialog
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
          );

          if (shouldLogout == true) {
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          }
        },
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text('Logout', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
    );
  }
}
