import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'consultation.dart';
import 'login.dart';
import 'signup.dart';
import 'recovery.dart';
import 'home.dart';
import 'profile.dart';
import 'bookmark.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://example.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'replace-with-supabase-anon-key',
  );

  // Temporary while Supabase-backed screens are migrated to the Laravel API.
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const SerenityHubApp());
}

class SerenityHubApp extends StatelessWidget {
  const SerenityHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor:
            Colors
                .white, // Keeping the background white to match ConsultationPage
        primaryColor:
            Colors.pink.shade400, // Using a shade of pink for primary elements
        appBarTheme: AppBarTheme(
          backgroundColor:
              Colors.white, // AppBar background white to match ConsultationPage
          titleTextStyle: const TextStyle(
            color: Colors.pink, // Pink title for AppBar
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter', // Consistent font
          ),
          iconTheme: IconThemeData(
            color: Colors.pink.shade700,
          ), // Pink icons in AppBar
        ),
        textTheme: TextTheme(
          bodyLarge: const TextStyle(
            color: Colors.black87, // Slightly darker text
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter', // Consistent font
          ),
          bodyMedium: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter', // Consistent font
          ),
          bodySmall: TextStyle(
            color: Colors.grey.shade600, // Slightly lighter small text
            fontSize: 14,
            fontWeight: FontWeight.w300,
            fontFamily: 'Inter', // Consistent font
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.pink,
        ).copyWith(
          secondary:
              Colors.pink.shade100, // A lighter pink for secondary accents
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ), // More rounded buttons
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ), // Comfortable padding
            textStyle: const TextStyle(
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ), // Clear text style
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.pink.shade400,
            side: BorderSide(color: Colors.pink.shade400),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ), // More rounded buttons
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ), // Comfortable padding
            textStyle: const TextStyle(
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ), // Clear text style
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.pink.shade300),
          ), // Rounded borders
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.pink.shade400, width: 2),
          ), // Focused border
          labelStyle: TextStyle(
            color: Colors.pink.shade700,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ), // Styled label
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontFamily: 'Inter',
          ), // Styled hint
          prefixIconColor: Colors.pink.shade500,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ), // Comfortable input padding
        ),
        iconTheme: IconThemeData(
          color: Colors.pink.shade700,
        ), // Default icon color
      ),
      home: const WelcomeScreen(), // Set WelcomeScreen as the initial screen
      routes: {
        '/login': (context) => const Login(),
        '/signup': (context) => const SignUp(),
        '/recovery': (context) => const Recovery(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const Profile(),
        '/consultation': (context) => const ConsultationPage(),
        '/bookmark': (context) => const BookmarkPage(),
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serenity Hub')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double containerWidth =
                constraints.maxWidth > 600 ? 450 : constraints.maxWidth * 0.85;
            double verticalPadding = constraints.maxHeight > 700 ? 30 : 20;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: containerWidth,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xC9FFC0CB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            child: Text(
                              'WELCOME TO SERENITY HUB',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: isLargeScreen(constraints) ? 42 : 36,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          SizedBox(height: verticalPadding),
                          Text(
                            'Serenity Hub promotes mental well-being by offering accessible guidance, expert support, and a safe space for self-care, empowering individuals with personalized resources and professional consultations.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: isLargeScreen(constraints) ? 22 : 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: verticalPadding * 1.5),
                          HubButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            text: 'LOGIN',
                          ),
                          SizedBox(height: verticalPadding / 2),
                          HubButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            text: 'SIGNUP',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HubButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const HubButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double buttonWidth =
            constraints.maxWidth > 600 ? 350 : constraints.maxWidth * 0.7;
        double buttonPadding = constraints.maxWidth > 600 ? 16 : 14;
        double fontSize = constraints.maxWidth > 600 ? 22 : 20;

        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA7C7E7),
            minimumSize: Size(buttonWidth, 55),
            padding: EdgeInsets.symmetric(
              horizontal: buttonPadding,
              vertical: buttonPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.black,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

bool isLargeScreen(BoxConstraints constraints) {
  return constraints.maxWidth > 600;
}
