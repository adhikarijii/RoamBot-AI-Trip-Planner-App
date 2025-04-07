import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'screens/landing_screen.dart'; // <--- Add this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoamBot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 49, 248, 185),
        ),
        fontFamily: 'Outfit',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        ),
      ),
      // Set LandingScreen as the first screen
      home: const LandingScreen(),
      routes: {'/auth': (context) => const AuthGate()},
    );
  }
}
