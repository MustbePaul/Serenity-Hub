import 'package:flutter/material.dart';

import 'api_client.dart';
import 'guest_mode.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _api = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'user@serenityhub.test');
  final _passwordController = TextEditingController(text: 'password');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await _api.post('/auth/login', {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });
      await _api.saveToken(response['data']['token'].toString());
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/app', (_) => false);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome back',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text('Use your Serenity Hub account to continue.'),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator:
                          (value) =>
                              value == null || !value.contains('@')
                                  ? 'Enter a valid email.'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed:
                              () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.length < 8
                                  ? 'Password must be at least 8 characters.'
                                  : null,
                      onFieldSubmitted: (_) => _login(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            () => Navigator.pushNamed(context, '/recovery'),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    _isLoading
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        )
                        : ElevatedButton(
                          onPressed: _login,
                          child: const Text('Sign in'),
                        ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed:
                          () => Navigator.pushReplacementNamed(
                            context,
                            '/signup',
                          ),
                      child: const Text('Create account'),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () async {
                        await GuestMode.startReview();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/app',
                            (_) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Review as guest'),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'No backend needed. Uses built-in demo content and disables live account actions.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
