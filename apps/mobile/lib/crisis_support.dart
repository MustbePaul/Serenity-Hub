import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api_client.dart';
import 'models/support_contact.dart';
import 'serenity_theme.dart';

const crisisSafetyNotice =
    'Serenity Hub is not an emergency service. If you or another person is in immediate danger, contact an appropriate local emergency service or go to the nearest health facility.';

Future<void> showCrisisSupportSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const CrisisSupportSheet(),
  );
}

class CrisisSupportSheet extends StatefulWidget {
  const CrisisSupportSheet({super.key});

  @override
  State<CrisisSupportSheet> createState() => _CrisisSupportSheetState();
}

class _CrisisSupportSheetState extends State<CrisisSupportSheet> {
  final _api = ApiClient();
  List<SupportContact> _contacts = [];
  bool _loading = true;
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
    try {
      _contacts = (await _api.fetchSupportContacts()).where((contact) => !contact.isDemo).toList();
    } on ApiException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Support contacts are not available offline yet.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This action is not available on this device.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Crisis support',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              color: serenityWarm,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(crisisSafetyNotice),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_contacts.isEmpty)
              _StateMessage(
                message:
                    _error ??
                    'No verified crisis contacts are available on this device yet.',
                onRetry: _load,
              )
            else ...[
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error!),
                ),
              ..._contacts.map((contact) => _ContactCard(contact: contact, open: _open)),
            ],
          ],
        );
      },
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.contact, required this.open});

  final SupportContact contact;
  final Future<void> Function(Uri uri) open;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  contact.serviceName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (contact.isEmergencyService) const Chip(label: Text('Emergency')),
                if (contact.isCrisisSupport) const Chip(label: Text('Crisis support')),
              ],
            ),
            const SizedBox(height: 6),
            Text(contact.countryName),
            if (contact.description != null) ...[
              const SizedBox(height: 6),
              Text(contact.description!),
            ],
            if (contact.availabilityText != null) ...[
              const SizedBox(height: 6),
              Text(contact.availabilityText!),
            ],
            if (contact.isDemo) ...[
              const SizedBox(height: 8),
              const Text(
                'Development placeholder: replace with verified production contact details before release.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (contact.phoneNumber != null && !contact.isDemo)
                  OutlinedButton.icon(
                    onPressed: () => open(Uri(scheme: 'tel', path: contact.phoneNumber)),
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                  ),
                if (contact.smsNumber != null && !contact.isDemo)
                  OutlinedButton.icon(
                    onPressed: () => open(Uri(scheme: 'sms', path: contact.smsNumber)),
                    icon: const Icon(Icons.sms_outlined),
                    label: const Text('SMS'),
                  ),
                if (contact.whatsappNumber != null && !contact.isDemo)
                  OutlinedButton.icon(
                    onPressed: () => open(Uri.parse('https://wa.me/${contact.whatsappNumber}')),
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('WhatsApp'),
                  ),
                if (contact.websiteUrl != null)
                  OutlinedButton.icon(
                    onPressed: () => open(Uri.parse(contact.websiteUrl!)),
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Website'),
                  ),
                if (contact.email != null && !contact.isDemo)
                  OutlinedButton.icon(
                    onPressed: () => open(Uri(scheme: 'mailto', path: contact.email)),
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email'),
                  ),
              ],
            ),
          ],
        ),
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
    return Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}
