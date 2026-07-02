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
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationEnabled = true;
  bool _autoPlayVideos = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System Default';
  double _textSize = 1.0;
  bool _dataBackupEnabled = false;
  bool _biometricAuthEnabled = false;
  final String _appVersion =
      '1.0.0 (100)'; // Hardcoded version without package_info_plus
  bool _isLoading = true;

  // Language options
  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Japanese',
    'Chinese',
    'Arabic',
  ];

  // Theme options
  final List<String> _themes = [
    'System Default',
    'Light',
    'Dark',
    'Blue',
    'Green',
  ];

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
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode') ?? false;
      _locationEnabled = prefs.getBool('location') ?? true;
      _autoPlayVideos = prefs.getBool('auto_play_videos') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _selectedTheme = prefs.getString('theme') ?? 'System Default';
      _textSize = prefs.getDouble('text_size') ?? 1.0;
      _dataBackupEnabled = prefs.getBool('data_backup') ?? false;
      _biometricAuthEnabled = prefs.getBool('biometric_auth') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _updateBoolSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    _showSavedIndicator();
  }

  Future<void> _updateStringSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    _showSavedIndicator();
  }

  Future<void> _updateDoubleSetting(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
    _showSavedIndicator();
  }

  void _showSavedIndicator() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Re-initialize with defaults
    if (mounted) {
      setState(() {
        _notificationsEnabled = true;
        _darkModeEnabled = false;
        _locationEnabled = true;
        _autoPlayVideos = true;
        _selectedLanguage = 'English';
        _selectedTheme = 'System Default';
        _textSize = 1.0;
        _dataBackupEnabled = false;
        _biometricAuthEnabled = false;
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

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Theme'),
            content: SizedBox(
              width: double.maxFinite,
              child: RadioGroup<String>(
                groupValue: _selectedTheme,
                onChanged: (value) {
                  Navigator.of(context).pop();
                  if (value != null) {
                    setState(() {
                      _selectedTheme = value;
                    });
                    _updateStringSetting('theme', value);
                    // In a real app, you might trigger a theme change here
                  }
                },
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _themes.length,
                  itemBuilder: (context, index) {
                    final theme = _themes[index];
                    return RadioListTile<String>(
                      title: Text(theme),
                      value: theme,
                    );
                  },
                ),
              ),
            ),
          ),
    );
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Language'),
            content: SizedBox(
              width: double.maxFinite,
              child: RadioGroup<String>(
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  Navigator.of(context).pop();
                  if (value != null) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                    _updateStringSetting('language', value);
                    // In a real app, you might trigger a locale change here
                  }
                },
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final language = _languages[index];
                    return RadioListTile<String>(
                      title: Text(language),
                      value: language,
                    );
                  },
                ),
              ),
            ),
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
                              onTap: _showThemeSelectionDialog,
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text('Dark Mode', style: titleStyle),
                              subtitle: Text(
                                'Enable dark theme throughout the app',
                                style: subtitleStyle,
                              ),
                              secondary: const Icon(Icons.dark_mode),
                              value: _darkModeEnabled,
                              onChanged: (val) {
                                setState(() => _darkModeEnabled = val);
                                _updateBoolSetting('dark_mode', val);
                                // In a real app, you would trigger a theme change here
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text('Text Size', style: titleStyle),
                              subtitle: Text(
                                _getTextSizeLabel(_textSize),
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
                                  onChanged: (val) {
                                    setState(() => _textSize = val);
                                    // In a real app, you might update text styles based on this value
                                  },
                                  onChangeEnd: (val) {
                                    _updateDoubleSetting('text_size', val);
                                  },
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
                            'Receive important updates',
                            style: subtitleStyle,
                          ),
                          secondary: const Icon(Icons.notifications),
                          value: _notificationsEnabled,
                          onChanged: (val) {
                            setState(() => _notificationsEnabled = val);
                            _updateBoolSetting('notifications', val);
                            // In a real app, you would toggle notification services here
                          },
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
                                'Play videos automatically as you scroll',
                                style: subtitleStyle,
                              ),
                              secondary: const Icon(Icons.play_circle),
                              value: _autoPlayVideos,
                              onChanged: (val) {
                                setState(() => _autoPlayVideos = val);
                                _updateBoolSetting('auto_play_videos', val);
                                // In a real app, you would control video playback behavior
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text('Language', style: titleStyle),
                              subtitle: Text(
                                _selectedLanguage,
                                style: subtitleStyle,
                              ),
                              leading: const Icon(Icons.language),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: _showLanguageSelectionDialog,
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
                                'Allow app to access your location',
                                style: subtitleStyle,
                              ),
                              secondary: const Icon(Icons.location_on),
                              value: _locationEnabled,
                              onChanged: (val) {
                                setState(() => _locationEnabled = val);
                                _updateBoolSetting('location', val);
                                // In a real app, you would toggle location permissions
                              },
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
                                'Use fingerprint or face ID to sign in',
                                style: subtitleStyle,
                              ),
                              secondary: const Icon(Icons.fingerprint),
                              value: _biometricAuthEnabled,
                              onChanged: (val) {
                                setState(() => _biometricAuthEnabled = val);
                                _updateBoolSetting('biometric_auth', val);
                                // In a real app, you would toggle biometric authentication
                              },
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: listTilePadding,
                              ),
                              title: Text('Data Backup', style: titleStyle),
                              subtitle: Text(
                                'Securely backup your data to the cloud',
                                style: subtitleStyle,
                              ),
                              secondary: const Icon(Icons.backup),
                              value: _dataBackupEnabled,
                              onChanged: (val) {
                                setState(() => _dataBackupEnabled = val);
                                _updateBoolSetting('data_backup', val);
                                // In a real app, you would trigger data backup functionality
                              },
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
