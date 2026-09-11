import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models/media_asset.dart';
import 'models/media_progress.dart';
import 'models/recommendation.dart';
import 'models/wellness_session.dart';
import 'models/appointment.dart';
import 'models/appointment_slot.dart';
import 'models/support_contact.dart';
import 'guest_mode.dart';

class ApiClient {
  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
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
    await GuestMode.endReview();
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

  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _send('PATCH', path, body: body);
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

  Future<List<AppointmentSlot>> fetchAvailability({
    required int therapistId,
    DateTime? date,
  }) async {
    final params = <String, String>{if (date != null) 'date': _dateOnly(date)};
    final response = await get(
      _withQuery('/therapists/$therapistId/availability', params),
    );
    return _list(response).map(AppointmentSlot.fromJson).toList();
  }

  Future<Appointment> bookAppointment({
    required int therapistId,
    required int availabilitySlotId,
    required String mode,
    String? reason,
  }) async {
    final response = await post('/appointments', {
      'therapist_id': therapistId,
      'availability_slot_id': availabilitySlotId,
      'mode': mode,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });
    return Appointment.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<List<Appointment>> fetchAppointments() async {
    final response = await get('/appointments');
    return _list(response).map(Appointment.fromJson).toList();
  }

  Future<Appointment> cancelAppointment(
    int appointmentId, {
    String? reason,
  }) async {
    final response = await patch('/appointments/$appointmentId/cancel', {
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });
    return Appointment.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<Appointment> rescheduleAppointment({
    required int appointmentId,
    required int availabilitySlotId,
  }) async {
    final response = await patch('/appointments/$appointmentId/reschedule', {
      'availability_slot_id': availabilitySlotId,
    });
    return Appointment.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<List<SupportContact>> fetchSupportContacts({
    String? countryCode,
    bool? emergency,
    bool? crisis,
  }) async {
    final params = <String, String>{
      if (countryCode != null && countryCode.trim().isNotEmpty)
        'country_code': countryCode.trim().toUpperCase(),
      if (emergency != null) 'is_emergency_service': emergency ? '1' : '0',
      if (crisis != null) 'is_crisis_support': crisis ? '1' : '0',
    };
    final response = await get(_withQuery('/support-contacts', params));
    return _list(response).map(SupportContact.fromJson).toList();
  }

  Future<void> submitMood({
    required int moodScore,
    List<String> tags = const [],
    String? note,
  }) async {
    await post('/mood-checkins', {
      'mood_score': moodScore,
      if (tags.isNotEmpty) 'tags': tags,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });
  }

  Future<List<Map<String, dynamic>>> fetchBookmarks() async {
    final response = await get('/bookmarks');
    return _list(response);
  }

  Future<void> addBookmark(int resourceId) async {
    await post('/resources/$resourceId/bookmark', {});
  }

  Future<void> removeBookmark(int resourceId) async {
    await delete('/resources/$resourceId/bookmark');
  }

  Future<void> submitSupportTicket({
    required String subject,
    required String message,
    String priority = 'normal',
  }) async {
    await post('/support-tickets', {
      'subject': subject,
      'message': message,
      'priority': priority,
    });
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? avatarUrl,
  }) async {
    final response = await patch('/profile', {
      'name': name,
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (gender != null && gender.trim().isNotEmpty) 'gender': gender.trim(),
      if (dateOfBirth != null && dateOfBirth.trim().isNotEmpty)
        'date_of_birth': dateOfBirth.trim(),
      if (emergencyContactName != null &&
          emergencyContactName.trim().isNotEmpty)
        'emergency_contact_name': emergencyContactName.trim(),
      if (emergencyContactPhone != null &&
          emergencyContactPhone.trim().isNotEmpty)
        'emergency_contact_phone': emergencyContactPhone.trim(),
      if (avatarUrl != null && avatarUrl.trim().isNotEmpty)
        'avatar_url': avatarUrl.trim(),
    });
    return Map<String, dynamic>.from(response['data'] as Map);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    if (await GuestMode.isEnabled()) {
      throw ApiException('Guest review mode is using built-in sample content.');
    }

    final uri = Uri.parse('$baseUrl$path');
    final authToken = await token;
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    try {
      final response = switch (method) {
        'POST' => await _httpClient
            .post(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 15)),
        'PATCH' => await _httpClient
            .patch(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 15)),
        'DELETE' => await _httpClient
            .delete(uri, headers: headers)
            .timeout(const Duration(seconds: 15)),
        _ => await _httpClient
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15)),
      };

      final decoded = _decodeBody(response.body);
      if (response.statusCode >= 400) {
        throw ApiException(
          _friendlyMessage(response.statusCode, decoded['message']?.toString()),
          statusCode: response.statusCode,
        );
      }
      if (method == 'GET') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey(uri), response.body);
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on Object catch (error) {
      if (method == 'GET') {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(_cacheKey(uri));
        if (cached != null) {
          return _decodeBody(cached);
        }
      }
      if (error is SocketException || error is TimeoutException) {
        throw ApiException(
          'Unable to connect. Check your internet connection and try again.',
        );
      }
      throw ApiException('Could not reach Serenity Hub. Please try again.');
    }
  }

  Map<String, dynamic> _decodeBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw const FormatException('Unexpected API response.');
  }

  String _friendlyMessage(int statusCode, String? message) {
    if (statusCode == 401) {
      return 'Your session has expired. Please sign in again.';
    }
    if (statusCode == 409) {
      return 'That appointment time is no longer available. Please choose another time.';
    }
    if (statusCode == 422) {
      return message ?? 'Please check the form and try again.';
    }
    return 'We could not complete your request. Please try again.';
  }

  String _cacheKey(Uri uri) =>
      'api_cache_${base64Url.encode(utf8.encode(uri.toString()))}';

  String _withQuery(String path, Map<String, String> params) {
    if (params.isEmpty) return path;
    return '$path?${Uri(queryParameters: params).query}';
  }

  String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<Map<String, dynamic>> _list(Map<String, dynamic> response) {
    return (response['data'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
