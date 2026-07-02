import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
    ).hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final AuthResponse response = await Supabase.instance.client.auth
            .signInWithPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );

        final User? user = response.user;

        if (user != null) {
          final profile =
              await Supabase.instance.client
                  .from('profiles')
                  .select()
                  .eq('id', user.id)
                  .maybeSingle();

          if (profile == null) {
            try {
              await Supabase.instance.client
                  .from('profiles')
                  .insert({
                    'id': user.id,
                    'email': user.email,
                    'username': user.email?.split('@')[0] ?? 'user',
                  })
                  .select()
                  .single();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile created.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (profileError) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Unexpected error creating profile: $profileError',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid email or password.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      } on AuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.message}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isSmallScreen = screenWidth < 360;
    final isLandscape = screenWidth > screenHeight;

    // Adaptive sizing
    final double titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final double buttonTextSize = isSmallScreen ? 14.0 : 16.0;
    final double linkTextSize = isSmallScreen ? 12.0 : 14.0;
    final double containerPadding = isSmallScreen ? 12.0 : 20.0;
    final double verticalSpacing = isSmallScreen ? 12.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              // Apply padding to the content, not the scroll view
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8.0 : 16.0,
                vertical: 16.0,
              ),
              child: SizedBox(
                width:
                    double
                        .infinity, // This makes the SizedBox expand to fill available width
                child: Container(
                  padding: EdgeInsets.all(containerPadding),
                  decoration: BoxDecoration(
                    color: const Color(0xC9FFC0CB),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                    border: Border.all(color: Colors.black),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'LOGIN',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ) ??
                              TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: verticalSpacing),
                        TextFormField(
                          controller: _emailController,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                isSmallScreen ? 4 : 8,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 16,
                              horizontal: isSmallScreen ? 10 : 16,
                            ),
                            isDense: isSmallScreen,
                          ),
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                        SizedBox(height: verticalSpacing),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                isSmallScreen ? 4 : 8,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 16,
                              horizontal: isSmallScreen ? 10 : 16,
                            ),
                            isDense: isSmallScreen,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: isSmallScreen ? 18 : 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: _validatePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                        SizedBox(height: verticalSpacing),
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 10 : 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    isSmallScreen ? 4 : 8,
                                  ),
                                ),
                              ),
                              child: Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: buttonTextSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: verticalSpacing * 0.5),
                        // Adjust links layout based on screen size
                        isSmallScreen || isLandscape
                            ? Column(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/recovery');
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: linkTextSize,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/signup',
                                    );
                                  },
                                  child: Text(
                                    "Don't have an account? Sign Up",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: linkTextSize,
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/recovery');
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: linkTextSize,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/signup',
                                    );
                                  },
                                  child: Text(
                                    "No account? Sign Up",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: linkTextSize,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
