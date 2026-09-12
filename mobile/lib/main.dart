import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'bookmark.dart';
import 'guest_mode.dart';
import 'login.dart';
import 'recovery.dart';
import 'search.dart';
import 'serenity_theme.dart';
import 'serenity_circle_screen.dart';
import 'signup.dart';
import 'ussd_prototype.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SerenityHubApp());
}

class SerenityHubApp extends StatelessWidget {
  const SerenityHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Serenity Hub',
      theme: serenityTheme(),
      home: const WelcomeScreen(),
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => const SignUp(),
        '/recovery': (context) => const Recovery(),
        '/app': (context) => const AppShell(),
        '/home': (context) => const AppShell(initialIndex: 0),
        '/resources': (context) => const AppShell(initialIndex: 1),
        '/library': (context) => const AppShell(initialIndex: 1),
        '/sessions': (context) => const AppShell(initialIndex: 2),
        '/consultation': (context) => const AppShell(initialIndex: 3),
        '/bookmark': (context) => const BookmarkPage(),
        '/profile': (context) => const AppShell(initialIndex: 4),
        '/search': (context) => const AppShell(initialIndex: 1),
        '/resource-search': (context) => const SearchPage(),
        '/circle': (context) => const SerenityCircleScreen(),
        '/ussd-prototype': (context) => const UssdPrototypePage(),
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Icon(
                Icons.spa_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Serenity Hub',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A secure space for daily grounding, self-care resources, and a safe bridge to professional support.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Card(
                color: serenityMint,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Serenity Hub supports wellness and access to care. It is not a replacement for emergency services, diagnosis, or medical treatment.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Sign in'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: const Text('Create account'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
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
              const SizedBox(height: 8),
              TextButton(
                onPressed:
                    () => Navigator.pushNamed(context, '/ussd-prototype'),
                child: const Text('Preview low-data USSD service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
