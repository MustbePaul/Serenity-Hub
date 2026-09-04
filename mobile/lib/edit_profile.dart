import 'package:flutter/material.dart';

import 'api_client.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, this.currentUser});

  final Map<String, dynamic>? currentUser;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _api = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fill(widget.currentUser);
    if (widget.currentUser == null) _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _birthDateController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final response = await _api.get('/auth/me');
      _fill(Map<String, dynamic>.from(response['data'] as Map));
    } catch (_) {
      // Keep editable defaults if the profile cannot be loaded.
    }
  }

  void _fill(Map<String, dynamic>? user) {
    final profile = user?['profile'] is Map ? user!['profile'] as Map : null;
    _nameController.text = user?['name']?.toString() ?? 'Serenity User';
    _phoneController.text = profile?['phone']?.toString() ?? '';
    _genderController.text = profile?['gender']?.toString() ?? '';
    _birthDateController.text = profile?['date_of_birth']?.toString() ?? '';
    _emergencyNameController.text =
        profile?['emergency_contact_name']?.toString() ?? '';
    _emergencyPhoneController.text =
        profile?['emergency_contact_phone']?.toString() ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _api.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text,
        gender: _genderController.text,
        dateOfBirth: _birthDateController.text,
        emergencyContactName: _emergencyNameController.text,
        emergencyContactPhone: _emergencyPhoneController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      Navigator.pop(context);
    } on ApiException catch (error) {
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
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Personal details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Enter your name.'
                          : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _genderController,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _birthDateController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Date of birth YYYY-MM-DD',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return null;
                return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)
                    ? null
                    : 'Use YYYY-MM-DD.';
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Emergency contact',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emergencyNameController,
              decoration: const InputDecoration(
                labelText: 'Contact name',
                prefixIcon: Icon(Icons.contact_emergency_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emergencyPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Contact phone',
                prefixIcon: Icon(Icons.call_outlined),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon:
                  _saving
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
