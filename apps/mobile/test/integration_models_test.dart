import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:serenity_hub/breathing_exercise_screen.dart';
import 'package:serenity_hub/models/media_asset.dart';
import 'package:serenity_hub/models/appointment.dart';
import 'package:serenity_hub/models/appointment_slot.dart';
import 'package:serenity_hub/models/mood_scale.dart';
import 'package:serenity_hub/models/support_contact.dart';
import 'package:serenity_hub/models/wellness_session.dart';

void main() {
  test('appointment parses therapist and schedule fields', () {
    final appointment = Appointment.fromJson({
      'id': 7,
      'therapist': {
        'user': {'name': 'Dr Test'},
      },
      'scheduled_start': '2026-08-24T10:00:00.000000Z',
      'scheduled_end': '2026-08-24T11:00:00.000000Z',
      'mode': 'online',
      'status': 'confirmed',
      'reason': 'Initial consultation',
    });

    expect(appointment.id, 7);
    expect(appointment.therapistName, 'Dr Test');
    expect(appointment.mode, 'online');
    expect(appointment.status, 'confirmed');
    expect(appointment.reason, 'Initial consultation');
    expect(appointment.canManage, isFalse);
  });

  test('appointment slot parses nullable backend values safely', () {
    final slot = AppointmentSlot.fromJson({
      'id': '12',
      'therapist_id': 5,
      'starts_at': '2026-08-24T10:00:00.000000Z',
      'ends_at': '2026-08-24T11:00:00.000000Z',
      'status': 'available',
    });

    expect(slot.id, 12);
    expect(slot.therapistId, 5);
    expect(slot.status, 'available');
    expect(slot.timezone, 'Africa/Blantyre');
  });

  test(
    'mood scale exposes clear five point labels and recommendation tags',
    () {
      expect(MoodScale.options, hasLength(5));
      expect(MoodScale.byScore(1).shortLabel, '1 - Very Low');
      expect(MoodScale.byScore(2).recommendationTag, 'anxious');
      expect(MoodScale.byScore(5).semanticLabel, contains('Very Good'));
    },
  );

  test('support contact parses channels and identifies demo placeholders', () {
    final contact = SupportContact.fromJson({
      'id': 2,
      'country_code': 'ZZ',
      'country_name': 'Demo Country',
      'service_name': 'DEMO ONLY - Crisis support line required',
      'website_url': 'https://example.com/replace',
      'is_emergency_service': false,
      'is_crisis_support': true,
    });

    expect(contact.isDemo, isTrue);
    expect(contact.hasDirectAction, isTrue);
    expect(contact.isCrisisSupport, isTrue);
  });

  testWidgets('breathing screen can run silently', (tester) async {
    const session = WellnessSession(
      id: -1,
      title: 'Four-four breathing',
      category: 'breathing',
      breathingPattern: '4-4 breathing',
      inhaleSeconds: 4,
      holdSeconds: 4,
      exhaleSeconds: 4,
      instructions: 'Breathe gently.',
      mediaAsset: MediaAsset(
        id: -2,
        title: 'Silent breathing',
        mediaType: 'article',
        fileUrl: '',
      ),
    );

    await tester.pumpWidget(
      const TestApp(child: BreathingExerciseScreen(session: session)),
    );
    expect(find.text('Four-four breathing'), findsWidgets);
    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('Pause'), findsOneWidget);
    await tester.tap(find.text('Mute'));
    await tester.pump();
    expect(find.text('Muted'), findsOneWidget);
  });
}

class TestApp extends StatelessWidget {
  const TestApp({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(home: child);
}
