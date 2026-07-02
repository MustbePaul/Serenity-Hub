import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';
import 'login.dart'; // Assuming you have a login.dart file

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
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

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final AuthResponse response = await Supabase.instance.client.auth
            .signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              data: {'username': _usernameController.text.trim()},
            );

        final User? user = response.user;

        if (user != null) {
          try {
            final List<dynamic> data =
                await Supabase.instance.client.from('profiles').insert([
                  {
                    'id': user.id,
                    'email': user.email,
                    'username': _usernameController.text.trim(),
                  },
                ]).select();

            if (data.isEmpty) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sign up successful!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }
            } else {
              debugPrint('Profile insert response: $data');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Sign up successful, but potential issue creating profile. Check logs.',
                    ),
                    backgroundColor: Colors.orangeAccent,
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }
            }
          } catch (e) {
            debugPrint('Unexpected error during profile creation: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Sign up successful, but unexpected error creating profile: $e',
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Sign up failed: Could not retrieve user information.',
                ),
                backgroundColor: Colors.orangeAccent,
              ),
            );
          }
        }
      } on AuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign up failed: ${e.message}'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Determine if the screen width is large (e.g., for tablets)
              bool isLargeScreen = constraints.maxWidth > 600;

              // Calculate the width of the form container
              double containerWidth =
                  isLargeScreen ? 400 : constraints.maxWidth * 0.9;

              // Adjust vertical spacing based on screen height
              double verticalSpacing = constraints.maxHeight > 700 ? 20 : 16;

              // Adjust padding for the container
              EdgeInsets containerPadding = EdgeInsets.all(
                isLargeScreen ? 24 : 20,
              );

              // Adjust font size for the title
              double titleFontSize = isLargeScreen ? 28 : 24;

              return Container(
                width: containerWidth,
                padding: containerPadding,
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
                      Text(
                        'SIGN UP',
                        textAlign: TextAlign.center,
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
                      SizedBox(height: verticalSpacing * 1.5),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: verticalSpacing),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                        validator: _validateUsername,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: verticalSpacing),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
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
                        onFieldSubmitted: (_) => _submitForm(),
                      ),
                      SizedBox(height: verticalSpacing * 2),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('SIGN UP'),
                        ),
                      SizedBox(height: verticalSpacing),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                        },
                        child: const Text(
                          'Already have an account? Login',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
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
