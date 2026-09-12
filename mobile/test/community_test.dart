import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:serenity_hub/community_room_screen.dart';
import 'package:serenity_hub/community_thread_screen.dart';
import 'package:serenity_hub/models/community_identity.dart';
import 'package:serenity_hub/models/community_message.dart';
import 'package:serenity_hub/models/community_reaction_summary.dart';
import 'package:serenity_hub/models/community_room.dart';
import 'package:serenity_hub/models/community_safety_result.dart';
import 'package:serenity_hub/providers/community_provider.dart';
import 'package:serenity_hub/serenity_circle_screen.dart';
import 'package:serenity_hub/services/community_realtime_service.dart';
import 'package:serenity_hub/widgets/community_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('CommunityRoom parses nullable backend values safely', () {
    final room = CommunityRoom.fromJson({
      'id': '2',
      'name': 'Stress & Anxiety',
      'slug': 'stress-anxiety',
      'description': null,
      'icon_key': 'anxiety',
      'sort_order': '3',
    });

    expect(room.id, 2);
    expect(room.name, 'Stress & Anxiety');
    expect(room.slug, 'stress-anxiety');
    expect(room.description, isNull);
    expect(room.sortOrder, 3);
  });

  test('CommunityIdentity parses anonymous fields only', () {
    final identity = CommunityIdentity.fromJson({
      'id': 'anon-code',
      'display_name': 'QuietMind42',
      'avatar_seed': 'leaf',
      'email': 'hidden@example.com',
    });

    expect(identity.id, 'anon-code');
    expect(identity.displayName, 'QuietMind42');
    expect(identity.avatarSeed, 'leaf');
  });

  test('CommunityMessage parses message payload', () {
    final message = communityMessage();

    expect(message.id, 10);
    expect(message.body, 'I need a quiet minute.');
    expect(message.identity.displayName, 'QuietMind42');
    expect(message.replyCount, 2);
    expect(message.isMine, isFalse);
  });

  test('reaction parsing supports all four positive types', () {
    final reactions = CommunityReactionSummary.fromJson({
      'support': '1',
      'relate': 2,
      'encouragement': 3,
      'hug': 4,
    });

    expect(reactions.countFor('support'), 1);
    expect(reactions.countFor('relate'), 2);
    expect(reactions.countFor('encouragement'), 3);
    expect(reactions.countFor('hug'), 4);
  });

  testWidgets('Circle Home renders header and privacy text', (tester) async {
    await tester.pumpWidget(
      testApp(SerenityCircleScreen(provider: filledProvider())),
    );
    await tester.pump();

    expect(find.text('Serenity Circle'), findsWidgets);
    expect(find.text('Your identity is private'), findsOneWidget);
  });

  testWidgets('Circle Home renders rooms from provider', (tester) async {
    await tester.pumpWidget(
      testApp(SerenityCircleScreen(provider: filledProvider())),
    );
    await tester.pump();

    expect(find.text('World Room'), findsOneWidget);
    expect(find.text('Stress & Anxiety'), findsOneWidget);
  });

  testWidgets('Circle Home renders anonymous identity', (tester) async {
    await tester.pumpWidget(
      testApp(SerenityCircleScreen(provider: filledProvider())),
    );
    await tester.pump();

    expect(find.text('You are QuietMind42'), findsOneWidget);
    expect(find.textContaining('hidden@example.com'), findsNothing);
  });

  testWidgets('message composer validates blank text', (tester) async {
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: CommunityComposer(
            hintText: 'Share',
            loading: false,
            onSubmit: (_) async => true,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Send message'));
    await tester.pump();

    expect(find.text('Write a few words before sending.'), findsOneWidget);
  });

  testWidgets('message composer sends nonblank text', (tester) async {
    String? sent;
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: CommunityComposer(
            hintText: 'Share',
            loading: false,
            onSubmit: (body) async {
              sent = body;
              return true;
            },
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('community-composer-field')),
      'Hello Circle',
    );
    await tester.tap(find.byTooltip('Send message'));
    await tester.pump();

    expect(sent, 'Hello Circle');
  });

  testWidgets('reaction interaction reaches provider', (tester) async {
    final provider = filledProvider();
    await tester.pumpWidget(providerApp(provider, const CommunityRoomScreen()));

    await tester.tap(find.textContaining('Support').first);
    await tester.pump();

    expect(provider.lastReaction, 'support');
  });

  testWidgets('thread screen renders original and replies', (tester) async {
    final provider =
        filledProvider()
          ..replies = [communityMessage(id: 11, body: 'I relate.')];
    await tester.pumpWidget(
      providerApp(
        provider,
        CommunityThreadScreen(parent: provider.messages.first),
      ),
    );

    expect(find.text('I need a quiet minute.'), findsOneWidget);
    expect(find.text('I relate.'), findsOneWidget);
  });

  testWidgets('report flow submits selected reason', (tester) async {
    final provider = filledProvider();
    await tester.pumpWidget(providerApp(provider, const CommunityRoomScreen()));

    await tester.tap(find.byTooltip('Message actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send report'));
    await tester.pumpAndSettle();

    expect(provider.reportedReason, 'harassment');
    expect(find.textContaining('Your report has been sent'), findsOneWidget);
  });

  testWidgets('block confirmation filters anonymous identity', (tester) async {
    final provider = filledProvider();
    await tester.pumpWidget(providerApp(provider, const CommunityRoomScreen()));

    await tester.tap(find.byTooltip('Message actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block this anonymous user'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block'));
    await tester.pumpAndSettle();

    expect(provider.blockedIdentity, 'anon-code');
  });

  testWidgets('own-message delete confirmation removes message', (
    tester,
  ) async {
    final provider =
        filledProvider()..messages = [communityMessage(id: 12, isMine: true)];
    await tester.pumpWidget(providerApp(provider, const CommunityRoomScreen()));

    await tester.tap(find.byTooltip('Message actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete message'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(provider.deletedMessageId, 12);
  });

  testWidgets('room shows loading state', (tester) async {
    final provider =
        filledProvider()
          ..loadingMessages = true
          ..messages = [];
    await tester.pumpWidget(providerApp(provider, const CommunityRoomScreen()));

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('room shows empty state', (tester) async {
    final provider = filledProvider()..messages = [];
    await tester.pumpWidget(providerApp(provider, const CommunityRoomScreen()));

    expect(find.text('It\'s quiet here'), findsOneWidget);
  });

  testWidgets('Circle Home shows API failure state', (tester) async {
    final provider =
        filledProvider()
          ..error = 'Network down'
          ..rooms = [];
    await tester.pumpWidget(testApp(SerenityCircleScreen(provider: provider)));
    await tester.pump();

    expect(find.text('Network down'), findsOneWidget);
  });

  testWidgets('guest mode is restricted from Circle posting', (tester) async {
    final provider = TestCommunityProvider()..guestMode = true;
    await tester.pumpWidget(testApp(SerenityCircleScreen(provider: provider)));
    await tester.pump();

    expect(find.text('Join Serenity Circle'), findsOneWidget);
    expect(find.textContaining('Sign in to share anonymously'), findsOneWidget);
  });

  testWidgets('safety prompt appears after supportive response', (
    tester,
  ) async {
    final provider = filledProvider()..safetyOnPost = true;
    await tester.pumpWidget(providerApp(provider, const CommunityRoomScreen()));

    await tester.enterText(
      find.byKey(const Key('community-composer-field')),
      'hard day',
    );
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();

    expect(find.text('We\'re here with you'), findsOneWidget);
  });

  testWidgets('message widgets do not expose account identity information', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        Scaffold(
          body: CommunityMessageTile(
            message: communityMessage(body: 'No account fields here'),
            onReply: () {},
            onReact: (_) {},
            onReport: () {},
            onBlock: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('hidden@example.com'), findsNothing);
    expect(find.textContaining('user_id'), findsNothing);
    expect(find.textContaining('555'), findsNothing);
  });

  test('provider deduplicates pagination and inserted messages', () async {
    final provider =
        TestCommunityProvider()
          ..selectedRoom = room()
          ..queuedMessages = [communityMessage(id: 2), communityMessage(id: 1)]
          ..olderMessages = [communityMessage(id: 1), communityMessage(id: 0)];

    await provider.loadMessages();
    await provider.loadOlderMessages();

    expect(provider.messages.map((message) => message.id), [2, 1, 0]);
  });

  test('provider polling lifecycle starts and stops', () {
    final provider = filledProvider();
    provider.startPolling();
    expect(provider.isPolling, isTrue);
    provider.stopPolling();
    expect(provider.isPolling, isFalse);
  });

  test('incoming live message is merged without duplicates', () {
    final provider = filledProvider();
    final incoming = communityMessage(id: 22, body: 'Live hello');

    provider.handleRealtimeEvent(
      CommunityRealtimeEvent.messageCreated(incoming),
    );
    provider.handleRealtimeEvent(
      CommunityRealtimeEvent.messageCreated(incoming),
    );

    expect(
      provider.messages.where((message) => message.id == 22),
      hasLength(1),
    );
    expect(provider.messages.first.body, 'Live hello');
  });

  test('reaction event updates counts while preserving my reactions', () {
    final provider =
        filledProvider()
          ..messages = [
            communityMessage(id: 31, myReactions: const ['support']),
          ];

    provider.handleRealtimeEvent(
      CommunityRealtimeEvent.reactionUpdated(
        messageId: 31,
        reactions: const CommunityReactionSummary(
          support: 5,
          relate: 1,
          encouragement: 0,
          hug: 0,
        ),
      ),
    );

    expect(provider.messages.first.reactions.support, 5);
    expect(provider.messages.first.myReactions, ['support']);
  });

  test('message removal event wins over later reaction update', () {
    final provider = filledProvider()..messages = [communityMessage(id: 41)];

    provider.handleRealtimeEvent(
      CommunityRealtimeEvent.messageRemoved(messageId: 41),
    );
    provider.handleRealtimeEvent(
      CommunityRealtimeEvent.reactionUpdated(
        messageId: 41,
        reactions: const CommunityReactionSummary(
          support: 9,
          relate: 0,
          encouragement: 0,
          hug: 0,
        ),
      ),
    );

    expect(provider.messages.any((message) => message.id == 41), isFalse);
  });

  test('blocked identity remains hidden for incoming events', () {
    final provider = filledProvider();
    final blocked = const CommunityIdentity(
      id: 'blocked-code',
      displayName: 'Blocked',
    );
    provider.applyLocalBlock(blocked);

    provider.handleRealtimeEvent(
      CommunityRealtimeEvent.messageCreated(
        communityMessage(id: 51, identityId: 'blocked-code'),
      ),
    );

    expect(provider.messages.any((message) => message.id == 51), isFalse);
  });

  test('pagination and live events merge in id order', () async {
    final provider =
        TestCommunityProvider()
          ..selectedRoom = room()
          ..queuedMessages = [communityMessage(id: 4), communityMessage(id: 3)]
          ..olderMessages = [communityMessage(id: 2), communityMessage(id: 1)];

    await provider.loadMessages();
    provider.handleRealtimeEvent(
      CommunityRealtimeEvent.messageCreated(communityMessage(id: 5)),
    );
    await provider.loadOlderMessages();

    expect(provider.messages.map((message) => message.id), [5, 4, 3, 2, 1]);
  });

  test('fallback realtime status starts polling and reconnect clears it', () {
    final provider = filledProvider();

    provider.realtimeStatus = CommunityRealtimeStatus.fallback;
    provider.startPolling();
    expect(provider.isPolling, isTrue);

    provider.realtimeStatus = CommunityRealtimeStatus.connected;
    provider.stopPolling();
    expect(provider.isPolling, isFalse);
  });
}

Widget testApp(Widget child) {
  return MaterialApp(
    routes: {
      '/login': (_) => const Scaffold(body: Text('Login')),
      '/signup': (_) => const Scaffold(body: Text('Signup')),
      '/consultation': (_) => const Scaffold(body: Text('Care')),
      '/resources': (_) => const Scaffold(body: Text('Resources')),
    },
    home: child,
  );
}

Widget providerApp(CommunityProvider provider, Widget child) {
  return testApp(ChangeNotifierProvider.value(value: provider, child: child));
}

CommunityRoom room() => const CommunityRoom(
  id: 1,
  name: 'World Room',
  slug: 'world-room',
  description: 'A shared supportive room.',
);

CommunityMessage communityMessage({
  int id = 10,
  String body = 'I need a quiet minute.',
  bool isMine = false,
  int? parentId,
  String identityId = 'anon-code',
  List<String> myReactions = const [],
}) {
  return CommunityMessage.fromJson({
    'id': id,
    'parent_id': parentId,
    'body': body,
    'anonymous_identity': {
      'id': identityId,
      'display_name': 'QuietMind42',
      'avatar_seed': 'leaf',
    },
    'reactions': {'support': 1, 'relate': 0, 'encouragement': 0, 'hug': 0},
    'my_reactions': myReactions,
    'reply_count': 2,
    'is_mine': isMine,
    'status': 'published',
    'created_at': '2026-09-11T10:00:00.000000Z',
  });
}

TestCommunityProvider filledProvider() {
  return TestCommunityProvider()
    ..identity = const CommunityIdentity(
      id: 'mine-code',
      displayName: 'QuietMind42',
      avatarSeed: 'leaf',
    )
    ..rooms = [
      room(),
      const CommunityRoom(
        id: 2,
        name: 'Stress & Anxiety',
        slug: 'stress-anxiety',
        description: 'A room for heavy days.',
      ),
    ]
    ..selectedRoom = room()
    ..messages = [communityMessage()];
}

class TestCommunityProvider extends CommunityProvider {
  List<CommunityMessage> queuedMessages = [];
  List<CommunityMessage> olderMessages = [];
  bool safetyOnPost = false;
  String? lastReaction;
  String? reportedReason;
  String? blockedIdentity;
  int? deletedMessageId;

  @override
  Future<void> loadHome() async {}

  @override
  Future<void> loadMessages({bool initial = false, bool silent = false}) async {
    if (queuedMessages.isNotEmpty) {
      messages = [
        ...queuedMessages,
        ...messages.where(
          (item) => !queuedMessages.any((incoming) => incoming.id == item.id),
        ),
      ]..sort((a, b) => b.id.compareTo(a.id));
    }
  }

  @override
  Future<void> loadOlderMessages() async {
    messages = [
      ...messages,
      ...olderMessages.where(
        (incoming) => !messages.any((item) => item.id == incoming.id),
      ),
    ]..sort((a, b) => b.id.compareTo(a.id));
  }

  @override
  Future<CommunitySafetyResult?> postMessage(String body) async {
    messages = [communityMessage(id: 99, body: body), ...messages];
    return CommunitySafetyResult(
      flags: safetyOnPost ? const ['support'] : const [],
      requiresReview: safetyOnPost,
      supportiveNotice: safetyOnPost ? 'support' : null,
    );
  }

  @override
  Future<void> toggleReaction(CommunityMessage message, String reaction) async {
    lastReaction = reaction;
  }

  @override
  Future<void> reportMessage({
    required CommunityMessage message,
    required String reason,
    String? details,
  }) async {
    reportedReason = reason;
  }

  @override
  Future<void> blockIdentity(CommunityIdentity target) async {
    blockedIdentity = target.id;
  }

  @override
  Future<void> deleteMessage(CommunityMessage message) async {
    deletedMessageId = message.id;
  }
}
