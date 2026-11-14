import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api_client.dart';
import '../guest_mode.dart';
import '../models/community_identity.dart';
import '../models/community_message.dart';
import '../models/community_reaction_summary.dart';
import '../models/community_room.dart';
import '../models/community_safety_result.dart';
import '../services/community_realtime_service.dart';

class CommunityProvider extends ChangeNotifier {
  CommunityProvider({
    ApiClient? apiClient,
    CommunityRealtimeService? realtimeService,
  }) : _api = apiClient ?? ApiClient(),
       _realtime = realtimeService ?? CommunityRealtimeService();

  final ApiClient _api;
  final CommunityRealtimeService _realtime;
  Timer? _pollTimer;
  StreamSubscription<CommunityRealtimeEvent>? _realtimeEvents;
  StreamSubscription<CommunityRealtimeStatus>? _realtimeStatuses;
  bool _refreshing = false;
  int _currentPage = 0;
  int _lastPage = 1;
  final Set<String> _blockedIdentityIds = {};

  CommunityIdentity? identity;
  List<CommunityRoom> rooms = [];
  CommunityRoom? selectedRoom;
  List<CommunityMessage> messages = [];
  List<CommunityMessage> replies = [];
  CommunitySafetyResult? lastSafetyResult;
  bool guestMode = false;
  bool loadingHome = false;
  bool loadingMessages = false;
  bool loadingOlder = false;
  bool posting = false;
  bool loadingReplies = false;
  bool postingReply = false;
  String? error;
  String? messageError;
  String? replyError;
  CommunityRealtimeStatus realtimeStatus = CommunityRealtimeStatus.disconnected;
  bool hasUnseenNewMessages = false;

  bool get hasMoreMessages => _currentPage < _lastPage;
  bool get isPolling => _pollTimer?.isActive ?? false;

  Future<void> loadHome() async {
    loadingHome = true;
    error = null;
    guestMode = await GuestMode.isEnabled();
    notifyListeners();
    if (guestMode) {
      loadingHome = false;
      notifyListeners();
      return;
    }
    try {
      identity = await _api.fetchCommunityIdentity();
      rooms = await _api.fetchCommunityRooms();
    } on ApiException catch (exception) {
      error = exception.message;
    } catch (_) {
      error =
          'We could not load Serenity Circle. Check your connection and try again.';
    } finally {
      loadingHome = false;
      notifyListeners();
    }
  }

  Future<void> openRoom(CommunityRoom room) async {
    await leaveRoom();
    selectedRoom = room;
    messages = [];
    hasUnseenNewMessages = false;
    _currentPage = 0;
    _lastPage = 1;
    await loadMessages(initial: true);
    _listenForRealtime();
    await _realtime.subscribeToRoom(room.slug);
    startPolling();
  }

  Future<void> leaveRoom() async {
    stopPolling();
    await _realtimeEvents?.cancel();
    await _realtimeStatuses?.cancel();
    _realtimeEvents = null;
    _realtimeStatuses = null;
    await _realtime.unsubscribeFromRoom();
  }

  Future<void> loadMessages({bool initial = false, bool silent = false}) async {
    final room = selectedRoom;
    if (room == null || _refreshing) return;
    _refreshing = true;
    if (!silent) {
      loadingMessages = initial;
      messageError = null;
      notifyListeners();
    }
    try {
      final page = await _api.fetchCommunityMessages(roomSlug: room.slug);
      _currentPage = page.currentPage;
      _lastPage = page.lastPage;
      messages = _mergeNewest(page.messages, messages);
    } on ApiException catch (exception) {
      if (!silent) messageError = exception.message;
    } catch (_) {
      if (!silent) {
        messageError =
            'We couldn\'t load the conversation. Check your connection and try again.';
      }
    } finally {
      _refreshing = false;
      loadingMessages = false;
      notifyListeners();
    }
  }

  Future<void> loadOlderMessages() async {
    final room = selectedRoom;
    if (room == null || loadingOlder || !hasMoreMessages) return;
    loadingOlder = true;
    notifyListeners();
    try {
      final page = await _api.fetchCommunityMessages(
        roomSlug: room.slug,
        page: _currentPage + 1,
      );
      _currentPage = page.currentPage;
      _lastPage = page.lastPage;
      messages = _mergeOlder(messages, page.messages);
    } finally {
      loadingOlder = false;
      notifyListeners();
    }
  }

  Future<CommunitySafetyResult?> postMessage(String body) async {
    final room = selectedRoom;
    final trimmed = body.trim();
    if (room == null || trimmed.isEmpty || posting) return null;
    posting = true;
    messageError = null;
    lastSafetyResult = null;
    notifyListeners();
    try {
      final result = await _api.postCommunityMessage(
        roomSlug: room.slug,
        body: trimmed,
      );
      messages = _mergeNewest([result.message], messages);
      hasUnseenNewMessages = false;
      lastSafetyResult = result.safety;
      return result.safety;
    } on ApiException catch (exception) {
      messageError = exception.message;
    } catch (_) {
      messageError = 'Your message wasn\'t sent. Please try again.';
    } finally {
      posting = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> loadReplies(CommunityMessage message) async {
    loadingReplies = true;
    replyError = null;
    replies = [];
    notifyListeners();
    try {
      final page = await _api.fetchCommunityReplies(messageId: message.id);
      replies = page.messages;
    } on ApiException catch (exception) {
      replyError = exception.message;
    } catch (_) {
      replyError = 'We could not load replies. Please try again.';
    } finally {
      loadingReplies = false;
      notifyListeners();
    }
  }

  Future<CommunitySafetyResult?> postReply({
    required CommunityMessage parent,
    required String body,
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty || postingReply) return null;
    postingReply = true;
    replyError = null;
    notifyListeners();
    try {
      final result = await _api.postCommunityReply(
        messageId: parent.id,
        body: trimmed,
      );
      replies = _mergeOlder(replies, [result.message]);
      _replaceMessage(parent.copyWith(replyCount: parent.replyCount + 1));
      lastSafetyResult = result.safety;
      return result.safety;
    } on ApiException catch (exception) {
      replyError = exception.message;
    } catch (_) {
      replyError = 'Your reply wasn\'t sent. Please try again.';
    } finally {
      postingReply = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> toggleReaction(CommunityMessage message, String reaction) async {
    try {
      final updated =
          message.hasReaction(reaction)
              ? await _api.removeCommunityReaction(
                messageId: message.id,
                reaction: reaction,
              )
              : await _api.addCommunityReaction(
                messageId: message.id,
                reaction: reaction,
              );
      _replaceMessage(updated);
    } on ApiException catch (exception) {
      messageError = exception.message;
    } catch (_) {
      messageError = 'We could not update that reaction. Please try again.';
    }
    notifyListeners();
  }

  Future<void> reportMessage({
    required CommunityMessage message,
    required String reason,
    String? details,
  }) async {
    await _api.reportCommunityMessage(
      messageId: message.id,
      reason: reason,
      details: details,
    );
  }

  Future<void> blockIdentity(CommunityIdentity target) async {
    await _api.blockCommunityIdentity(target.id);
    applyLocalBlock(target);
    notifyListeners();
  }

  void applyLocalBlock(CommunityIdentity target) {
    _blockedIdentityIds.add(target.id);
    messages =
        messages.where((message) => message.identity.id != target.id).toList();
    replies =
        replies.where((message) => message.identity.id != target.id).toList();
  }

  Future<void> unblockIdentity(CommunityIdentity target) async {
    await _api.unblockCommunityIdentity(target.id);
    _blockedIdentityIds.remove(target.id);
    notifyListeners();
  }

  Future<void> deleteMessage(CommunityMessage message) async {
    await _api.deleteCommunityMessage(message.id);
    _removeMessage(message.id);
    notifyListeners();
  }

  Future<void> handleAppBackgrounded() async {
    stopPolling();
    await _realtime.unsubscribeFromRoom();
  }

  Future<void> handleAppResumed() async {
    final room = selectedRoom;
    if (room == null) return;
    await loadMessages(silent: true);
    await _realtime.subscribeToRoom(room.slug);
    if (realtimeStatus != CommunityRealtimeStatus.connected) startPolling();
  }

  void handleRealtimeEvent(CommunityRealtimeEvent event) {
    final room = selectedRoom;
    if (room == null) return;
    if (event.roomSlug != null && event.roomSlug != room.slug) return;

    switch (event.type) {
      case CommunityRealtimeEventType.messageCreated:
        final message = event.message;
        if (message == null ||
            _blockedIdentityIds.contains(message.identity.id)) {
          return;
        }
        final existed =
            messages.any((item) => item.id == message.id) ||
            replies.any((item) => item.id == message.id);
        if (message.status == 'hidden' || message.status == 'removed') return;
        if (message.body == null) return;
        if (message.parentId == null) {
          messages = _mergeNewest([message], messages);
          if (!message.isMine && !existed) hasUnseenNewMessages = true;
        } else {
          replies = _mergeOlder(replies, [message]);
          messages =
              messages
                  .map(
                    (item) =>
                        item.id == message.parentId && !existed
                            ? item.copyWith(replyCount: item.replyCount + 1)
                            : item,
                  )
                  .toList();
          if (!message.isMine && !existed) {
            hasUnseenNewMessages = true;
          }
        }
      case CommunityRealtimeEventType.messageRemoved:
        final messageId = event.messageId;
        if (messageId != null) _removeMessage(messageId);
      case CommunityRealtimeEventType.reactionUpdated:
        final messageId = event.messageId;
        final reactions = event.reactions;
        if (messageId != null && reactions != null) {
          _updateReactions(messageId, reactions);
        }
    }
    notifyListeners();
  }

  void markNewMessagesSeen() {
    hasUnseenNewMessages = false;
    notifyListeners();
  }

  void startPolling() {
    stopPolling();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => loadMessages(silent: true),
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _listenForRealtime() {
    _realtimeEvents?.cancel();
    _realtimeStatuses?.cancel();
    _realtimeEvents = _realtime.events.listen(handleRealtimeEvent);
    _realtimeStatuses = _realtime.statuses.listen((status) {
      realtimeStatus = status;
      if (status == CommunityRealtimeStatus.connected) {
        stopPolling();
        loadMessages(silent: true);
      } else if (status == CommunityRealtimeStatus.reconnecting ||
          status == CommunityRealtimeStatus.fallback) {
        startPolling();
      }
      notifyListeners();
    });
  }

  List<CommunityMessage> _mergeNewest(
    List<CommunityMessage> incoming,
    List<CommunityMessage> existing,
  ) {
    final byId = <int, CommunityMessage>{};
    for (final message in [...incoming, ...existing]) {
      if (!_blockedIdentityIds.contains(message.identity.id)) {
        byId[message.id] = message;
      }
    }
    return byId.values.toList()..sort((a, b) => b.id.compareTo(a.id));
  }

  List<CommunityMessage> _mergeOlder(
    List<CommunityMessage> existing,
    List<CommunityMessage> incoming,
  ) {
    final byId = <int, CommunityMessage>{};
    for (final message in [...existing, ...incoming]) {
      if (!_blockedIdentityIds.contains(message.identity.id)) {
        byId[message.id] = message;
      }
    }
    return byId.values.toList()..sort((a, b) => b.id.compareTo(a.id));
  }

  void _replaceMessage(CommunityMessage updated) {
    messages =
        messages.map((item) => item.id == updated.id ? updated : item).toList();
    replies =
        replies.map((item) => item.id == updated.id ? updated : item).toList();
  }

  void _removeMessage(int messageId) {
    messages = messages.where((item) => item.id != messageId).toList();
    replies = replies.where((item) => item.id != messageId).toList();
  }

  void _updateReactions(int messageId, CommunityReactionSummary reactions) {
    CommunityMessage merge(CommunityMessage message) =>
        message.id == messageId
            ? message.copyWith(reactions: reactions)
            : message;
    messages = messages.map(merge).toList();
    replies = replies.map(merge).toList();
  }

  @override
  void dispose() {
    stopPolling();
    _realtimeEvents?.cancel();
    _realtimeStatuses?.cancel();
    _realtime.dispose();
    super.dispose();
  }
}
