import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening URLs

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings variables
  bool _darkModeEnabled = false;
  String _selectedTheme = 'System Default';
  double _textSize = 1.0;
  final String _appVersion =
      '1.0.0 (100)'; // Hardcoded version without package_info_plus
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkModeEnabled = prefs.getBool('dark_mode') ?? false;
      _selectedTheme = prefs.getString('theme') ?? 'System Default';
      _textSize = prefs.getDouble('text_size') ?? 1.0;
      _isLoading = false;
    });
  }

  void _resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in const ['notifications', 'dark_mode', 'location', 'auto_play_videos', 'language', 'theme', 'text_size', 'data_backup', 'biometric_auth']) {
      await prefs.remove(key);
    }

    // Re-initialize with defaults
    if (mounted) {
      setState(() {
        _darkModeEnabled = false;
        _selectedTheme = 'System Default';
        _textSize = 1.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All settings have been reset to defaults'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Settings'),
            content: const Text(
              'This will reset all settings to their default values. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetAllSettings();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('RESET'),
              ),
            ],
          ),
    );
  }

  Future<void> _exportSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allPrefs = prefs.getKeys();
      Map<String, dynamic> settings = {};

      for (String key in allPrefs) {
        settings[key] = prefs.get(key);
      }

      // For demonstration, just log the settings.
      debugPrint('Exported Settings: $settings');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings exported (check console for output)'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      // In a real app, you would save this 'settings' map to a file
      // (e.g., JSON) or upload it to a cloud service.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting settings: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _clearCache() async {
    // This is a placeholder. Clearing cache in Flutter might involve
    // deleting temporary files or resetting specific plugin caches.
    // The implementation depends heavily on what your app caches.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache clearing initiated (implementation needed)'),
        ),
      );
    }
    // In a real app, you would implement the logic to clear the app's cache here.
  }

  Future<void> _openUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $urlString')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset all settings',
            onPressed: _showResetConfirmationDialog,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool isLargeScreen = constraints.maxWidth > 600;
                  final double cardMargin = isLargeScreen ? 16.0 : 8.0;
                  final double sectionPadding = isLargeScreen ? 24.0 : 16.0;
                  final double listTilePadding = isLargeScreen ? 16.0 : 12.0;
                  final TextStyle sectionHeaderStyle = TextStyle(
                    fontSize: isLargeScreen ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  );
                  final TextStyle titleStyle = TextStyle(
                    fontSize: isLargeScreen ? 18 : 16,
                  );
                  final TextStyle subtitleStyle = TextStyle(
                    fontSize: isLargeScreen ? 14 : 12,
                  );

                  return ListView(
                    padding: EdgeInsets.all(sectionPadding),
                    children: [
                      _buildSectionHeader(
                        'Appearance',
                        style: sectionHeaderStyle,
                      ),
                      _buildSettingCard(
                        margin: cardMargin,
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text('Theme', style: titleStyle),
                              subtitle: Text(
                                _selectedTheme,
                                style: subtitleStyle,
                              ),
                              leading: const Icon(Icons.palette),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: null,
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text('Dark Mode', style: titleStyle),
                              subtitle: Text(
                                'Unavailable in this trial',
                                style: subtitleStyle,
                              ),
                              secondary: const Icon(Icons.dark_mode),
                              value: _darkModeEnabled,
                              onChanged: null,
                            ),
                            const Divider(height: 1),
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text('Text Size', style: titleStyle),
                              subtitle: Text(
                                'Unavailable in this trial',
                                style: subtitleStyle,
                              ),
                              leading: const Icon(Icons.text_fields),
                              trailing: SizedBox(
                                width: isLargeScreen ? 200 : 150,
                                child: Slider(
                                  value: _textSize,
                                  min: 0.8,
                                  max: 1.4,
                                  divisions: 6,
                                  label: _getTextSizeLabel(_textSize),
                                  onChanged: null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sectionPadding / 2),
                      _buildSectionHeader(
                        'Notifications',
                        style: sectionHeaderStyle,
                      ),
                      _buildSettingCard(
                        margin: cardMargin,
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: listTilePadding,
                          ),
                          title: Text('Push Notifications', style: titleStyle),
                          subtitle: Text(
                            'Unavailable in this trial',
                            style: subtitleStyle,
                          ),
                          secondary: const Icon(Icons.notifications),
                          value: false,
                          onChanged: null,
                        ),
                      ),
                      SizedBox(height: sectionPadding / 2),
                      _buildSectionHeader('Content', style: sectionHeaderStyle),
                      _buildSettingCard(
                        margin: cardMargin,
                        child: Column(
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text('Autoplay Videos', style: titleStyle),
                              subtitle: Text(
                                'Unavailable in this trial',
                                style: subtitleStyle,
                              ),
                              secondary: const Icon(Icons.play_circle),
                              value: false,
                              onChanged: null,
                            ),
                            const Divider(height: 1),
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text('Language', style: titleStyle),
                              subtitle: Text(
                                'English (other languages unavailable)',
                                style: subtitleStyle,
                              ),
                              leading: const Icon(Icons.language),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: null,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sectionPadding / 2),
                      _buildSectionHeader(
                        'Privacy & Security',
                        style: sectionHeaderStyle,
                      ),
                      _buildSettingCard(
                        margin: cardMargin,
                        child: Column(
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text(
                                'Location Services',
                                style: titleStyle,
                              ),
                              subtitle: Text(
                                'Unavailable in this trial',
                                style: subtitleStyle,
                              ),
                              secondary: const Icon(Icons.location_on),
                              value: false,
                              onChanged: null,
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text(
                                'Biometric Authentication',
                                style: titleStyle,
                              ),
                              subtitle: Text(
                                'Unavailable in this trial',
                                style: subtitleStyle,
                              ),
                              secondary: const Icon(Icons.fingerprint),
                              value: false,
                              onChanged: null,
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text('Data Backup', style: titleStyle),
                              subtitle: Text(
                                'Unavailable in this trial',
                                style: subtitleStyle,
                              ),
                              secondary: const Icon(Icons.backup),
                              value: false,
                              onChanged: null,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sectionPadding / 2),
                      _buildSectionHeader(
                        'Data Management',
                        style: sectionHeaderStyle,
                      ),
                      _buildSettingCard(
                        margin: cardMargin,
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text('Export Settings', style: titleStyle),
                              subtitle: Text(
                                'Save your settings to a file',
                                style: subtitleStyle,
                              ),
                              leading: const Icon(Icons.download),
                              onTap: _exportSettings,
                            ),
                            const Divider(height: 1),
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text('Clear Cache', style: titleStyle),
                              subtitle: Text(
                                'Free up space by removing temporary files',
                                style: subtitleStyle,
                              ),
                              leading: const Icon(Icons.cleaning_services),
                              onTap: _clearCache,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sectionPadding / 2),
                      _buildSectionHeader('About', style: sectionHeaderStyle),
                      _buildSettingCard(
                        margin: cardMargin,
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text('App Version', style: titleStyle),
                              subtitle: Text(_appVersion, style: subtitleStyle),
                              leading: const Icon(Icons.info),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text(
                                'Terms of Service',
                                style: titleStyle,
                              ),
                              leading: const Icon(Icons.description),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap:
                                  () => _openUrl(
                                    'https://example.com/terms',
                                  ), // Replace with your actual URL
                            ),
                            const Divider(height: 1),
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text('Privacy Policy', style: titleStyle),
                              leading: const Icon(Icons.privacy_tip),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap:
                                  () => _openUrl(
                                    'https://example.com/privacy',
                                  ), // Replace with your actual URL
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sectionPadding),
                      Center(
                        child: TextButton(
                          onPressed:
                              () => _openUrl(
                                'https://example.com/support',
                              ), // Replace with your actual support URL
                          child: Text(
                            'Need help? Contact Support',
                            style: titleStyle.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: sectionPadding / 2),
                    ],
                  );
                },
              ),
    );
  }

  Widget _buildSectionHeader(String title, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style:
            style ??
            TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child, double margin = 8.0}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: margin, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }

  String _getTextSizeLabel(double size) {
    if (size <= 0.8) return 'Smaller';
    if (size <= 0.9) return 'Small';
    if (size <= 1.0) return 'Normal';
    if (size <= 1.1) return 'Large';
    if (size <= 1.2) return 'Larger';
    if (size <= 1.3) return 'X-Large';
    return 'XX-Large';
  }
}
