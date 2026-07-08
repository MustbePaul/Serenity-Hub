import 'package:flutter/foundation.dart';

import '../api_client.dart';
import '../models/media_progress.dart';
import '../models/recommendation.dart';

class RecommendationProvider extends ChangeNotifier {
  RecommendationProvider({ApiClient? apiClient})
    : _api = apiClient ?? ApiClient();

  final ApiClient _api;
  Recommendation? recommendation;
  List<MediaProgress> progress = [];
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.fetchRecommendations(),
        _api.fetchMyMediaProgress(),
      ]);
      recommendation = results[0] as Recommendation;
      progress = results[1] as List<MediaProgress>;
    } catch (_) {
      error = 'Personal recommendations need sign in and a live connection.';
      recommendation = null;
      progress = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
