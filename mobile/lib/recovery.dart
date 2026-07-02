import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Recovery extends StatefulWidget {
  const Recovery({super.key});

  @override
  State<Recovery> createState() => _RecoveryState();
}

class _RecoveryState extends State<Recovery> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _sendRecoveryEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });

      try {
        await Supabase.instance.client.auth.resetPasswordForEmail(
          _emailController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Recovery email sent. Check your inbox.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSending = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recover Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool isLargeScreen = constraints.maxWidth > 600;
              final double containerWidth =
              isLargeScreen ? 400 : constraints.maxWidth * 0.9;
              final double verticalSpacing = isLargeScreen ? 40 : 30;
              final double titleFontSize = isLargeScreen ? 32 : 28;
              final double labelFontSize = isLargeScreen ? 18 : 16;
              final double buttonHeight = isLargeScreen ? 60 : 50;

              return Container(
                width: containerWidth,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xC9FFC0CB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: verticalSpacing * 0.8),
                      Text(
                        'RECOVER ACCOUNT',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600, fontSize: titleFontSize) ??
                            TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: verticalSpacing * 2),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: labelFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        validator: _validateEmail,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context)
                              .primaryColor
                              .withAlpha((255 * 0.08).toInt()),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          hintText: 'Enter your email',
                          hintStyle: const TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: verticalSpacing * 1.5),
                      _isSending
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _sendRecoveryEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B928),
                          minimumSize: Size(double.infinity, buttonHeight),
                        ),
                        child: const Text(
                          'SEND',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: verticalSpacing * 0.5),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}