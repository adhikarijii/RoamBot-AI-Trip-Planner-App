import 'package:flutter/material.dart';
import 'package:roambot/screens/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              // Headline
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Discover Your Next Adventure with ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'AI',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                    TextSpan(
                      text: ': Personalized Itineraries at Your Fingertips',
                      style: TextStyle(color: Colors.black, fontSize: 24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Subheading
              const Text(
                'Your personal trip planner and travel curator, creating custom itineraries tailored to your interests and budget.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              // CTA Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Get Started, It’s Free',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 30),

              // App Mockup
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/icon/landing1.png',
                    height: 370,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
