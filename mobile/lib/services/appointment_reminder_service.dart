import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/appointment.dart';

class AppointmentReminderService {
  AppointmentReminderService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
    );
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    await initialize();
    final android =
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final macos = await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return android ?? ios ?? macos ?? true;
  }

  Future<void> scheduleFor(Appointment appointment) async {
    if (kIsWeb || !appointment.canManage) return;
    final allowed = await requestPermissions();
    if (!allowed) return;
    await cancelFor(appointment.id);
    final reminderAt = appointment.scheduledStart.subtract(
      const Duration(hours: 24),
    );
    if (reminderAt.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      appointment.id,
      'Serenity Hub appointment',
      'You have an upcoming Serenity Hub appointment.',
      tz.TZDateTime.from(reminderAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'appointments',
          'Appointments',
          channelDescription: 'Neutral reminders for upcoming appointments.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelFor(int appointmentId) async {
    if (kIsWeb) return;
    await initialize();
    await _plugin.cancel(appointmentId);
  }
}
