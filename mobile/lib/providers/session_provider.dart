import 'package:flutter/foundation.dart';

import '../api_client.dart';
import '../models/wellness_session.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;
  List<WellnessSession> sessions = [];
  bool loading = false;
  String? error;

  List<WellnessSession> get featured =>
      sessions.where((session) => session.isFeatured).toList();

  Future<void> load({String? category, String? mood, bool? featured}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      sessions = await _api.fetchWellnessSessions(
        category: category,
        mood: mood,
        featured: featured,
      );
    } catch (_) {
      error = 'We could not load serenity sessions right now.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
