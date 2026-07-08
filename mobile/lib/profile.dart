import 'package:flutter/material.dart';

import 'api_client.dart';
import 'edit_profile.dart';
import 'help_support.dart';
import 'settings.dart';
import 'serenity_theme.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _api = ApiClient();
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final response = await _api.get('/auth/me');
      setState(
        () => _user = Map<String, dynamic>.from(response['data'] as Map),
      );
    } catch (_) {
      setState(() {
        _user = {
          'name': 'Serenity User',
          'email': 'user@serenityhub.test',
          'role': 'user',
        };
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    try {
      await _api.post('/auth/logout', {});
    } catch (_) {
      // Token may already be invalid locally.
    }
    await _api.clearToken();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadProfile,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: serenityMint,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: serenityTeal,
                              foregroundColor: Colors.white,
                              child: Text(
                                (user?['name']?.toString().isNotEmpty ?? false)
                                    ? user!['name'].toString()[0]
                                    : 'S',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?['name']?.toString() ??
                                        'Serenity User',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  Text(user?['email']?.toString() ?? ''),
                                  Text('Role: ${user?['role'] ?? 'user'}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProfileTile(
                      icon: Icons.edit_outlined,
                      title: 'Edit profile',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          ),
                    ),
                    _ProfileTile(
                      icon: Icons.notifications_outlined,
                      title: 'Settings and privacy',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          ),
                    ),
                    _ProfileTile(
                      icon: Icons.help_outline,
                      title: 'Help and urgent support',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HelpSupportPage(),
                            ),
                          ),
                    ),
                    _ProfileTile(
                      icon: Icons.event_note_outlined,
                      title: 'Appointment history',
                      onTap:
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Appointment history uses /appointments in the next pass.',
                              ),
                            ),
                          ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: serenityWarm,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Serenity Hub provides wellness support and access to professionals. It does not provide emergency treatment or diagnosis.',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Log out'),
                    ),
                  ],
                ),
              ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
