import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'api_client.dart';
import 'guest_mode.dart';
import 'models/appointment_slot.dart';
import 'sample_data.dart';
import 'serenity_theme.dart';

class ConsultationPage extends StatefulWidget {
  const ConsultationPage({super.key});

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  final _api = ApiClient();
  List<Map<String, dynamic>> _therapists =
      sampleTherapists.map(Map<String, dynamic>.from).toList();
  bool _loading = false;
  bool _guestMode = false;

  @override
  void initState() {
    super.initState();
    _loadTherapists();
  }

  Future<void> _loadTherapists() async {
    setState(() => _loading = true);
    final guestMode = await GuestMode.isEnabled();
    try {
      final response = await _api.get('/therapists');
      setState(() {
        _guestMode = guestMode;
        _therapists =
            (response['data'] as List)
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList();
      });
    } catch (_) {
      setState(() {
        _guestMode = guestMode;
        _therapists = sampleTherapists.map(Map<String, dynamic>.from).toList();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showBookingSheet(Map<String, dynamic> therapist) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => _BookingSheet(
            api: _api,
            therapist: therapist,
            guestMode: _guestMode,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Care')),
      body: RefreshIndicator(
        onRefresh: _loadTherapists,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_loading) const LinearProgressIndicator(),
            Text(
              'Verified therapists',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Only approved professionals are shown in this directory.',
            ),
            if (_guestMode) ...[
              const SizedBox(height: 12),
              Card(
                color: serenityBlue,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Guest review mode uses sample therapist profiles and previews booking steps without creating appointments.',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ..._therapists.map(
              (therapist) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TherapistCard(
                  therapist: therapist,
                  onBook: () => _showBookingSheet(therapist),
                ),
              ),
            ),
            Card(
              color: serenityWarm,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'If you are in immediate danger or need urgent care, contact local emergency services or a trusted crisis support line.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingSheet extends StatefulWidget {
  const _BookingSheet({
    required this.api,
    required this.therapist,
    required this.guestMode,
  });

  final ApiClient api;
  final Map<String, dynamic> therapist;
  final bool guestMode;

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  final _reasonController = TextEditingController();
  late final List<String> _modes;
  late String _mode;
  late DateTime _selectedDate = _dates.first;
  List<AppointmentSlot> _slots = [];
  AppointmentSlot? _selectedSlot;
  bool _loadingSlots = false;
  bool _booking = false;
  String? _error;

  List<DateTime> get _dates {
    final now = DateTime.now();
    return List.generate(
      7,
      (index) => DateTime(now.year, now.month, now.day + index),
    );
  }

  @override
  void initState() {
    super.initState();
    _modes =
        ((widget.therapist['session_modes'] as List?) ?? ['online'])
            .map((value) => value.toString())
            .toList();
    _mode = _modes.first;
    _loadSlots();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _loadingSlots = true;
      _error = null;
      _selectedSlot = null;
    });

    if (widget.guestMode) {
      final day = _selectedDate;
      setState(() {
        _slots = [
          AppointmentSlot(
            id: -1,
            therapistId: therapistId(widget.therapist),
            startsAt: DateTime(day.year, day.month, day.day, 10),
            endsAt: DateTime(day.year, day.month, day.day, 11),
            status: 'available',
            timezone: 'Africa/Blantyre',
          ),
          AppointmentSlot(
            id: -2,
            therapistId: therapistId(widget.therapist),
            startsAt: DateTime(day.year, day.month, day.day, 14),
            endsAt: DateTime(day.year, day.month, day.day, 15),
            status: 'available',
            timezone: 'Africa/Blantyre',
          ),
        ];
        _loadingSlots = false;
      });
      return;
    }

    try {
      final slots = await widget.api.fetchAvailability(
        therapistId: therapistId(widget.therapist),
        date: _selectedDate,
      );
      setState(() => _slots = slots);
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(
        () =>
            _error =
                'Unable to connect. Check your internet connection and try again.',
      );
    } finally {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  Future<void> _confirm() async {
    final slot = _selectedSlot;
    if (slot == null) return;

    if (widget.guestMode) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Guest review: booking preview completed without creating an appointment.',
          ),
        ),
      );
      return;
    }

    setState(() => _booking = true);
    try {
      await widget.api.bookAppointment(
        therapistId: therapistId(widget.therapist),
        availabilitySlotId: slot.id,
        mode: _mode,
        reason: _reasonController.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully.')),
      );
    } on ApiException catch (error) {
      if (error.statusCode == 409) {
        await _loadSlots();
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'We could not complete your request. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE d MMM');
    final timeFormat = DateFormat('HH:mm');
    final selectedSlot = _selectedSlot;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              therapistName(widget.therapist),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              widget.guestMode
                  ? 'Preview the booking flow with sample availability.'
                  : 'Choose a date and available time. The backend confirms the slot when you book.',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _mode,
              items:
                  _modes
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.replaceAll('_', ' ')),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _mode = value ?? _mode),
              decoration: const InputDecoration(labelText: 'Session mode'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final date = _dates[index];
                  final selected = _sameDay(date, _selectedDate);
                  return ChoiceChip(
                    label: Text(dateFormat.format(date)),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedDate = date);
                      _loadSlots();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_loadingSlots)
              const LinearProgressIndicator()
            else if (_error != null)
              _InlineMessage(message: _error!, onRetry: _loadSlots)
            else if (_slots.isEmpty)
              _InlineMessage(
                message: 'No available slots for this date.',
                onRetry: _loadSlots,
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _slots.map((slot) {
                      final selected = _selectedSlot?.id == slot.id;
                      return ChoiceChip(
                        label: Text(
                          '${timeFormat.format(slot.startsAt)} - ${timeFormat.format(slot.endsAt)}',
                        ),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedSlot = slot),
                      );
                    }).toList(),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Reason optional'),
            ),
            const SizedBox(height: 16),
            if (selectedSlot != null)
              Card(
                color: serenityMint,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '${therapistName(widget.therapist)}\n${DateFormat('EEE d MMM, HH:mm').format(selectedSlot.startsAt)}\n${_mode.replaceAll('_', ' ')} session',
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _booking || selectedSlot == null ? null : _confirm,
              icon:
                  _booking
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.event_available),
              label: Text(_booking ? 'Booking...' : 'Confirm booking'),
            ),
          ],
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(message)),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

class _TherapistCard extends StatelessWidget {
  const _TherapistCard({required this.therapist, required this.onBook});

  final Map<String, dynamic> therapist;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final specialties = ((therapist['specialties'] as List?) ?? [])
        .map((item) => item is Map ? item['name'].toString() : item.toString())
        .join(', ');
    final fee = NumberFormat(
      '#,##0',
      'en_MW',
    ).format(therapist['consultation_fee'] ?? 0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: serenityMint,
                  child: Text(therapistName(therapist).substring(0, 1)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        therapistName(therapist),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(therapist['location'] ?? 'Remote'),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('-'),
                          ),
                          Text('MWK $fee'),
                        ],
                      ),
                    ],
                  ),
                ),
                const Tooltip(
                  message: 'Verified therapist',
                  child: Icon(Icons.verified, color: serenityTeal),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(specialties.isEmpty ? 'Mental wellness support' : specialties),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onBook,
              icon: const Icon(Icons.event_available),
              label: const Text('Book session'),
            ),
          ],
        ),
      ),
    );
  }
}

String therapistName(Map<String, dynamic> therapist) {
  final user = therapist['user'];
  if (user is Map && user['name'] != null) return user['name'].toString();
  return therapist['name']?.toString() ?? 'Verified therapist';
}

int therapistId(Map<String, dynamic> therapist) {
  final value = therapist['id'];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
