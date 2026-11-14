import 'package:flutter/foundation.dart';

import '../api_client.dart';
import '../models/wellness_session.dart';
import '../offline_content.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;
  List<WellnessSession> sessions = [];
  bool loading = false;
  String? error;
  bool usingOfflineContent = false;

  List<WellnessSession> get featured =>
      sessions.where((session) => session.isFeatured).toList();

  Future<void> load({String? category, String? mood, bool? featured}) async {
    loading = true;
    error = null;
    usingOfflineContent = false;
    notifyListeners();
    try {
      sessions = await _api.fetchWellnessSessions(
        category: category,
        mood: mood,
        featured: featured,
      );
    } catch (_) {
      final wanted = category ?? 'all';
      sessions =
          offlineSessions
              .where((session) => wanted == 'all' || session.category == wanted)
              .toList();
      usingOfflineContent = true;
      if (sessions.isEmpty) {
        error = 'This session category is not saved for guest review yet.';
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
