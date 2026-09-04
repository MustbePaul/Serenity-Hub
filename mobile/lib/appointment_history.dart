import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'api_client.dart';
import 'guest_mode.dart';
import 'models/appointment.dart';
import 'serenity_theme.dart';

class AppointmentHistoryPage extends StatefulWidget {
  const AppointmentHistoryPage({super.key});

  @override
  State<AppointmentHistoryPage> createState() => _AppointmentHistoryPageState();
}

class _AppointmentHistoryPageState extends State<AppointmentHistoryPage> {
  final _api = ApiClient();
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
                      ),
                      _AppointmentSection(title: 'Past', appointments: past),
                      _AppointmentSection(
                        title: 'Cancelled',
                        appointments: cancelled,
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}

class _AppointmentSection extends StatelessWidget {
  const _AppointmentSection({required this.title, required this.appointments});

  final String title;
  final List<Appointment> appointments;

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
        ...appointments.map((appointment) => _AppointmentCard(appointment)),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard(this.appointment);

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'EEE d MMM yyyy',
    ).format(appointment.scheduledStart);
    final start = DateFormat('HH:mm').format(appointment.scheduledStart);
    final end = DateFormat('HH:mm').format(appointment.scheduledEnd);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event_note_outlined),
        title: Text(appointment.therapistName),
        subtitle: Text(
          '$date, $start - $end\n${appointment.mode.replaceAll('_', ' ')} - ${appointment.status}',
        ),
        isThreeLine: true,
      ),
    );
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
