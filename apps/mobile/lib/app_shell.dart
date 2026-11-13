import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'consultation.dart';
import 'api_client.dart';
import 'guest_mode.dart';
import 'home.dart';
import 'library_screen.dart';
import 'profile.dart';
import 'sessions_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;
  bool? _webAccess;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      GuestMode.isEnabled().then((guest) {
        if (mounted) setState(() => _webAccess = guest || ApiClient.webHasSession);
      });
    }
  }

  void _selectTab(int value) {
    if (value == _index) return;
    if (kIsWeb) {
      const routes = ['/home', '/library', '/sessions', '/consultation', '/profile'];
      Navigator.pushNamed(context, routes[value]);
    } else {
      setState(() => _index = value);
    }
  }

  final _pages = const [
    HomePage(),
    LibraryScreen(),
    SessionsScreen(),
    ConsultationPage(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && _webAccess != true) {
      return Scaffold(body: Center(child: _webAccess == null
          ? const CircularProgressIndicator()
          : Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Sign in to continue your session.'),
              const SizedBox(height: 12),
              if (!ApiClient.demoBuild) ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
                child: const Text('Sign in'),
              ),
              TextButton(onPressed: () async {
                await GuestMode.startReview();
                if (mounted) setState(() => _webAccess = true);
              }, child: const Text('Review synthetic demo')),
            ])));
    }
    final wide = MediaQuery.sizeOf(context).width >= 840;
    const destinations = [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Library'),
      NavigationDestination(icon: Icon(Icons.self_improvement_outlined), selectedIcon: Icon(Icons.self_improvement), label: 'Sessions'),
      NavigationDestination(icon: Icon(Icons.health_and_safety_outlined), selectedIcon: Icon(Icons.health_and_safety), label: 'Care'),
      NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
    ];
    return Scaffold(
      body: Row(children: [
        if (wide) NavigationRail(
          selectedIndex: _index,
          extended: MediaQuery.sizeOf(context).width >= 1100,
          onDestinationSelected: _selectTab,
          destinations: destinations.map((item) => NavigationRailDestination(
            icon: item.icon, selectedIcon: item.selectedIcon, label: Text(item.label),
          )).toList(),
        ),
        Expanded(child: IndexedStack(index: _index, children: _pages)),
      ]),
      bottomNavigationBar: wide ? null : NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectTab,
        destinations: destinations,
      ),
    );
  }
}
