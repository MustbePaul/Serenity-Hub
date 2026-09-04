import 'package:shared_preferences/shared_preferences.dart';

class GuestMode {
  static const _key = 'offline_guest';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> startReview() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    await prefs.remove('api_token');
  }

  static Future<void> endReview() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
