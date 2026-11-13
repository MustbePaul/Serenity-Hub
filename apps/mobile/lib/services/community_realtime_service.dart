import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../api_client.dart';
import '../models/community_message.dart';
import '../models/community_reaction_summary.dart';

enum CommunityRealtimeStatus { disconnected, connected, reconnecting, fallback }

enum CommunityRealtimeEventType {
  messageCreated,
  messageRemoved,
  reactionUpdated,
}

class CommunityRealtimeEvent {
  const CommunityRealtimeEvent._({
    required this.type,
    this.message,
    this.messageId,
    this.reactions,
    this.roomSlug,
  });

  final CommunityRealtimeEventType type;
  final CommunityMessage? message;
  final int? messageId;
  final CommunityReactionSummary? reactions;
  final String? roomSlug;

  factory CommunityRealtimeEvent.messageCreated(
    CommunityMessage message, {
    String? roomSlug,
  }) {
    return CommunityRealtimeEvent._(
      type: CommunityRealtimeEventType.messageCreated,
      message: message,
      roomSlug: roomSlug,
    );
  }

  factory CommunityRealtimeEvent.messageRemoved({
    required int messageId,
    String? roomSlug,
  }) {
    return CommunityRealtimeEvent._(
      type: CommunityRealtimeEventType.messageRemoved,
      messageId: messageId,
      roomSlug: roomSlug,
    );
  }

  factory CommunityRealtimeEvent.reactionUpdated({
    required int messageId,
    required CommunityReactionSummary reactions,
    String? roomSlug,
  }) {
    return CommunityRealtimeEvent._(
      type: CommunityRealtimeEventType.reactionUpdated,
      messageId: messageId,
      reactions: reactions,
      roomSlug: roomSlug,
    );
  }
}

typedef WebSocketConnector = WebSocketChannel Function(Uri uri);

class CommunityRealtimeService {
  CommunityRealtimeService({
    ApiClient? apiClient,
    WebSocketConnector? connector,
    String? socketUrl,
    String? appKey,
  }) : _api = apiClient ?? ApiClient(),
       _connector = connector ?? WebSocketChannel.connect,
       _socketUrl = socketUrl ??
           (const String.fromEnvironment('COMMUNITY_WS_URL').isNotEmpty
               ? const String.fromEnvironment('COMMUNITY_WS_URL')
               : (kIsWeb ? 'ws://127.0.0.1:8080' : 'ws://10.0.2.2:8080')),
       _appKey =
           appKey ??
           const String.fromEnvironment(
             'COMMUNITY_WS_APP_KEY',
             defaultValue: 'local-serenity-key',
           );

  final ApiClient _api;
  final WebSocketConnector _connector;
  final String _socketUrl;
  final String _appKey;
  final StreamController<CommunityRealtimeEvent> _events =
      StreamController<CommunityRealtimeEvent>.broadcast();
  final StreamController<CommunityRealtimeStatus> _statuses =
      StreamController<CommunityRealtimeStatus>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  String? _roomSlug;
  String? _socketId;
  bool _disposed = false;
  bool _manuallyDisconnected = false;
  int _attempt = 0;

  Stream<CommunityRealtimeEvent> get events => _events.stream;
  Stream<CommunityRealtimeStatus> get statuses => _statuses.stream;

  Future<void> subscribeToRoom(String roomSlug) async {
    _roomSlug = roomSlug;
    _manuallyDisconnected = false;
    await _connect();
  }

  Future<void> unsubscribeFromRoom() async {
    final slug = _roomSlug;
    if (slug != null) {
      _send({
        'event': 'pusher:unsubscribe',
        'data': {'channel': _channelName(slug)},
      });
    }
    _roomSlug = null;
    await disconnect();
  }

  Future<void> disconnect() async {
    _manuallyDisconnected = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
    _socketId = null;
    if (!_disposed) _statuses.add(CommunityRealtimeStatus.disconnected);
  }

  Future<void> dispose() async {
    _disposed = true;
    await disconnect();
    await _events.close();
    await _statuses.close();
  }

  Future<void> _connect() async {
    if (_disposed || _roomSlug == null) return;
    await _subscription?.cancel();
    await _channel?.sink.close();

    try {
      final uri = Uri.parse(
        '$_socketUrl/app/$_appKey?protocol=7&client=serenity-flutter&version=1.0&flash=false',
      );
      _channel = _connector(uri);
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  Future<void> _handleMessage(dynamic raw) async {
    final decoded = _decode(raw);
    if (decoded == null) return;

    final event = decoded['event']?.toString() ?? '';
    final data = _decode(decoded['data']) ?? const <String, dynamic>{};

    if (event == 'pusher:connection_established') {
      _socketId = data['socket_id']?.toString();
      await _authorizeAndSubscribe();
      return;
    }

    if (event == 'pusher_internal:subscription_succeeded') {
      _attempt = 0;
      _statuses.add(CommunityRealtimeStatus.connected);
      return;
    }

    if (event.endsWith('CommunityMessageCreated')) {
      final messageJson = data['message'];
      if (messageJson is Map) {
        _events.add(
          CommunityRealtimeEvent.messageCreated(
            CommunityMessage.fromJson(Map<String, dynamic>.from(messageJson)),
            roomSlug: _roomSlugFrom(data),
          ),
        );
      }
    } else if (event.endsWith('CommunityMessageRemoved')) {
      final id = _intValue(data['message_id']);
      if (id != null) {
        _events.add(
          CommunityRealtimeEvent.messageRemoved(
            messageId: id,
            roomSlug: _roomSlugFrom(data),
          ),
        );
      }
    } else if (event.endsWith('CommunityReactionUpdated')) {
      final id = _intValue(data['message_id']);
      final reactionsJson = data['reactions'];
      if (id != null && reactionsJson is Map) {
        _events.add(
          CommunityRealtimeEvent.reactionUpdated(
            messageId: id,
            reactions: CommunityReactionSummary.fromJson(
              Map<String, dynamic>.from(reactionsJson),
            ),
            roomSlug: _roomSlugFrom(data),
          ),
        );
      }
    }
  }

  Future<void> _authorizeAndSubscribe() async {
    final slug = _roomSlug;
    final socketId = _socketId;
    if (slug == null || socketId == null) return;

    try {
      final channel = _channelName(slug);
      final auth = await _api.post('/community/broadcasting/auth', {
        'socket_id': socketId,
        'channel_name': channel,
      });
      _send({
        'event': 'pusher:subscribe',
        'data': {'channel': channel, 'auth': auth['auth']},
      });
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed || _manuallyDisconnected || _roomSlug == null) return;
    _statuses.add(
      _attempt == 0
          ? CommunityRealtimeStatus.reconnecting
          : CommunityRealtimeStatus.fallback,
    );
    _reconnectTimer?.cancel();
    final delay = Duration(seconds: _attempt < 3 ? 2 + _attempt : 10);
    _attempt += 1;
    _reconnectTimer = Timer(delay, _connect);
  }

  void _send(Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode(payload));
  }

  Map<String, dynamic>? _decode(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    return null;
  }

  String _channelName(String slug) => 'private-community.room.$slug';

  int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String? _roomSlugFrom(Map<String, dynamic> data) {
    final room = data['room'];
    if (room is Map) return room['slug']?.toString();
    return null;
  }
}
