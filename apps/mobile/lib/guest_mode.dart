import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class GuestMode {
  static const _key = 'offline_guest';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> startReview() async {
    final prefs = await SharedPreferences.getInstance();
    ApiClient.clearWebToken();
    for (final key in prefs.getKeys().where((key) => key.startsWith('api_cache_') || key == 'pending_mood_checkins')) {
      await prefs.remove(key);
    }
    await prefs.setBool(_key, true);
    await prefs.remove('api_token');
  }

  static Future<void> endReview() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
