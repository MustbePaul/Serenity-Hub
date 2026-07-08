import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models/media_asset.dart';
import 'models/media_progress.dart';
import 'models/recommendation.dart';
import 'models/wellness_session.dart';

class ApiClient {
  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  final http.Client _httpClient;

  Future<String?> get token async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_token');
  }

  Future<void> saveToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_token', value);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
  }

  Future<Map<String, dynamic>> get(String path) async {
    return _send('GET', path);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    return _send('DELETE', path);
  }

  Future<List<MediaAsset>> fetchMedia({String? type, String? query}) async {
    final params = <String, String>{
      if (type != null && type != 'all') 'type': type,
      if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
    };
    final response = await get(_withQuery('/media', params));
    return _list(response).map(MediaAsset.fromJson).toList();
  }

  Future<List<MediaAsset>> fetchArticleResources({String? query}) async {
    final params = <String, String>{
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
    };
    final response = await get(_withQuery('/resources', params));
    return _list(response).map((resource) {
      return MediaAsset(
        id:
            -(resource['id'] is int
                ? resource['id'] as int
                : int.tryParse(resource['id']?.toString() ?? '') ?? 0),
        title: resource['title']?.toString() ?? 'Article',
        mediaType: 'article',
        fileUrl: resource['content_url']?.toString() ?? '',
        description: resource['summary']?.toString(),
        transcript: resource['body']?.toString(),
      );
    }).toList();
  }

  Future<MediaAsset> fetchMediaDetail(int id) async {
    final response = await get('/media/$id');
    return MediaAsset.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<List<WellnessSession>> fetchWellnessSessions({
    String? category,
    String? mood,
    bool? featured,
  }) async {
    final params = <String, String>{
      if (category != null && category != 'all') 'category': category,
      if (mood != null && mood.isNotEmpty) 'mood': mood,
      if (featured != null) 'featured': featured ? '1' : '0',
    };
    final response = await get(_withQuery('/wellness-sessions', params));
    return _list(response).map(WellnessSession.fromJson).toList();
  }

  Future<WellnessSession> fetchWellnessSession(int id) async {
    final response = await get('/wellness-sessions/$id');
    return WellnessSession.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<MediaProgress> saveMediaProgress({
    required int mediaId,
    required int progressSeconds,
    required int durationSeconds,
    int? resourceId,
    int? wellnessSessionId,
    bool isCompleted = false,
  }) async {
    final response = await post('/media/$mediaId/progress', {
      if (resourceId != null) 'resource_id': resourceId,
      if (wellnessSessionId != null) 'wellness_session_id': wellnessSessionId,
      'progress_seconds': progressSeconds,
      'duration_seconds': durationSeconds,
      'is_completed': isCompleted,
    });
    return MediaProgress.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<List<MediaProgress>> fetchMyMediaProgress() async {
    final response = await get('/me/media-progress');
    return _list(response).map(MediaProgress.fromJson).toList();
  }

  Future<Recommendation> fetchRecommendations() async {
    final response = await get('/me/recommendations');
    return Recommendation.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final authToken = await token;
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final response = switch (method) {
      'POST' => await _httpClient.post(
        uri,
        headers: headers,
        body: jsonEncode(body ?? {}),
      ),
      'DELETE' => await _httpClient.delete(uri, headers: headers),
      _ => await _httpClient.get(uri, headers: headers),
    };

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw ApiException(decoded['message']?.toString() ?? 'Request failed');
    }
    return decoded;
  }

  String _withQuery(String path, Map<String, String> params) {
    if (params.isEmpty) return path;
    return '$path?${Uri(queryParameters: params).query}';
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic> response) {
    return (response['data'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
