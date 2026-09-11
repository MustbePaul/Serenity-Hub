import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'api_client.dart';
import 'guest_mode.dart';
import 'models/appointment.dart';
import 'models/appointment_slot.dart';
import 'services/appointment_reminder_service.dart';
import 'serenity_theme.dart';

class AppointmentHistoryPage extends StatefulWidget {
  const AppointmentHistoryPage({super.key});

  @override
  State<AppointmentHistoryPage> createState() => _AppointmentHistoryPageState();
}

class _AppointmentHistoryPageState extends State<AppointmentHistoryPage> {
  final _api = ApiClient();
  final _reminders = AppointmentReminderService();
  List<Appointment> _appointments = [];
  bool _loading = true;
  bool _guestMode = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final guestMode = await GuestMode.isEnabled();
    if (guestMode) {
      setState(() {
        _guestMode = true;
        _appointments = [];
        _loading = false;
      });
      return;
    }

    try {
      final appointments = await _api.fetchAppointments();
      setState(() {
        _guestMode = false;
        _appointments = appointments;
      });
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(
        () =>
            _error =
                'Unable to connect. Check your internet connection and try again.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cancelled =
        _appointments.where((appointment) => appointment.isCancelled).toList();
    final upcoming =
        _appointments
            .where(
              (appointment) => !appointment.isCancelled && !appointment.isPast,
            )
            .toList();
    final past =
        _appointments
            .where(
              (appointment) => !appointment.isCancelled && appointment.isPast,
            )
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Appointment history')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_guestMode)
                      Card(
                        color: serenityBlue,
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Guest review mode does not create live appointments.',
                          ),
                        ),
                      ),
                    if (_error != null)
                      _StateMessage(message: _error!, onRetry: _load)
                    else if (_appointments.isEmpty)
                      _StateMessage(
                        message: 'No appointments yet.',
                        onRetry: _load,
                      )
                    else ...[
                      _AppointmentSection(
                        title: 'Upcoming',
                        appointments: upcoming,
                        onChanged: _load,
                        api: _api,
                        reminders: _reminders,
                      ),
                      _AppointmentSection(
                        title: 'Past',
                        appointments: past,
                        onChanged: _load,
                        api: _api,
                        reminders: _reminders,
                      ),
                      _AppointmentSection(
                        title: 'Cancelled',
                        appointments: cancelled,
                        onChanged: _load,
                        api: _api,
                        reminders: _reminders,
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}

class _AppointmentSection extends StatelessWidget {
  const _AppointmentSection({
    required this.title,
    required this.appointments,
    required this.onChanged,
    required this.api,
    required this.reminders,
  });

  final String title;
  final List<Appointment> appointments;
  final Future<void> Function() onChanged;
  final ApiClient api;
  final AppointmentReminderService reminders;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        ...appointments.map(
          (appointment) => _AppointmentCard(
            appointment: appointment,
            api: api,
            reminders: reminders,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.api,
    required this.reminders,
    required this.onChanged,
  });

  final Appointment appointment;
  final ApiClient api;
  final AppointmentReminderService reminders;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'EEE d MMM yyyy',
    ).format(appointment.scheduledStart);
    final start = DateFormat('HH:mm').format(appointment.scheduledStart);
    final end = DateFormat('HH:mm').format(appointment.scheduledEnd);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_note_outlined),
              title: Text(appointment.therapistName),
              subtitle: Text(
                '$date, $start - $end\n'
                '${appointment.mode.replaceAll('_', ' ')} - ${appointment.statusLabel}\n'
                '${appointment.preparationGuidance}',
              ),
              isThreeLine: true,
            ),
            if (appointment.canManage)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _reschedule(context),
                    icon: const Icon(Icons.edit_calendar_outlined),
                    label: const Text('Reschedule'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _cancel(context),
                    icon: const Icon(Icons.event_busy_outlined),
                    label: const Text('Cancel'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel appointment?'),
            content: const Text(
              'This keeps the appointment in your history and releases the time slot if it is still upcoming.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Cancel appointment'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    try {
      await api.cancelAppointment(appointment.id);
      await reminders.cancelFor(appointment.id);
      await onChanged();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Appointment cancelled.')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not cancel this appointment.')),
        );
      }
    }
  }

  Future<void> _reschedule(BuildContext context) async {
    final slots = await _loadSlots(context);
    if (!context.mounted || slots.isEmpty) return;
    final slot = await showDialog<AppointmentSlot>(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: const Text('Choose a new time'),
            children:
                slots
                    .map(
                      (slot) => SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, slot),
                        child: Text(
                          DateFormat('EEE d MMM, HH:mm').format(slot.startsAt),
                        ),
                      ),
                    )
                    .toList(),
          ),
    );
    if (slot == null) return;
    try {
      final updated = await api.rescheduleAppointment(
        appointmentId: appointment.id,
        availabilitySlotId: slot.id,
      );
      await reminders.cancelFor(appointment.id);
      await reminders.scheduleFor(updated);
      await onChanged();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment rescheduled.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not reschedule this appointment.'),
          ),
        );
      }
    }
  }

  Future<List<AppointmentSlot>> _loadSlots(BuildContext context) async {
    try {
      return await api.fetchAvailability(
        therapistId: appointment.therapistId,
        date: appointment.scheduledStart,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No available slots could be loaded.')),
        );
      }
      return [];
    }
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
