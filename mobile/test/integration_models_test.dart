import 'package:flutter_test/flutter_test.dart';
import 'package:serenity_hub/models/appointment.dart';
import 'package:serenity_hub/models/appointment_slot.dart';

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
}
