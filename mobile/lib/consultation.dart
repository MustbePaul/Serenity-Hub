import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'api_client.dart';
import 'sample_data.dart';
import 'serenity_theme.dart';

class ConsultationPage extends StatefulWidget {
  const ConsultationPage({super.key});

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  final _api = ApiClient();
  List<Map<String, dynamic>> _therapists = sampleTherapists.map(Map<String, dynamic>.from).toList();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadTherapists();
  }

  Future<void> _loadTherapists() async {
    setState(() => _loading = true);
    try {
      final response = await _api.get('/therapists');
      setState(() {
        _therapists = (response['data'] as List).map((item) => Map<String, dynamic>.from(item as Map)).toList();
      });
    } catch (_) {
      setState(() => _therapists = sampleTherapists.map(Map<String, dynamic>.from).toList());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showBookingSheet(Map<String, dynamic> therapist) async {
    final modes = ((therapist['session_modes'] as List?) ?? ['online']).map((value) => value.toString()).toList();
    String mode = modes.first;
    final reasonController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(therapistName(therapist), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Choose a session mode. The Laravel API enforces slot locking when a real availability slot is selected.'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: mode,
                    items: modes.map((item) => DropdownMenuItem(value: item, child: Text(item.replaceAll('_', ' ')))).toList(),
                    onChanged: (value) => setSheetState(() => mode = value ?? mode),
                    decoration: const InputDecoration(labelText: 'Session mode'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Reason (optional)'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking flow connected to /appointments once a slot is chosen.')));
                    },
                    child: const Text('Continue to slot selection'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    reasonController.dispose();
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
            Text('Verified therapists', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Only approved professionals are shown in this directory.'),
            const SizedBox(height: 16),
            ..._therapists.map((therapist) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TherapistCard(therapist: therapist, onBook: () => _showBookingSheet(therapist)),
                )),
            Card(
              color: serenityWarm,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('If you are in immediate danger or need urgent care, contact local emergency services or a trusted crisis support line.'),
              ),
            ),
          ],
        ),
      ),
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
    final fee = NumberFormat('#,##0', 'en_MW').format(therapist['consultation_fee'] ?? 0);
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
                      Text(therapistName(therapist), style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text('${therapist['location'] ?? 'Remote'} • MWK $fee'),
                    ],
                  ),
                ),
                const Tooltip(message: 'Verified therapist', child: Icon(Icons.verified, color: serenityTeal)),
              ],
            ),
            const SizedBox(height: 12),
            Text(specialties.isEmpty ? 'Mental wellness support' : specialties),
            const SizedBox(height: 12),
            ElevatedButton.icon(onPressed: onBook, icon: const Icon(Icons.event_available), label: const Text('Book session')),
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
