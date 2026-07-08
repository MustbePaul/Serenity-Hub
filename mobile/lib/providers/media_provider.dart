import 'package:flutter/foundation.dart';

import '../api_client.dart';
import '../models/media_asset.dart';
import '../models/media_progress.dart';

class MediaProvider extends ChangeNotifier {
  MediaProvider({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;
  List<MediaAsset> items = [];
  List<MediaProgress> progress = [];
  bool loading = false;
  String? error;

  Future<void> load({String? type, String? query}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      if (type == 'article') {
        items = await _api.fetchArticleResources(query: query);
      } else {
        final media = await _api.fetchMedia(type: type, query: query);
        final articles =
            type == null || type == 'all'
                ? await _api.fetchArticleResources(query: query)
                : <MediaAsset>[];
        items = [...articles, ...media];
      }
    } catch (e) {
      error = 'We could not load the library just now.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadProgress() async {
    try {
      progress = await _api.fetchMyMediaProgress();
      notifyListeners();
    } catch (_) {
      progress = [];
      notifyListeners();
    }
  }
}
