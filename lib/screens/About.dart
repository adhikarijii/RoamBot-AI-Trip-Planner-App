import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    const String content = '''
RoamBot is your intelligent travel companion powered by AI. Whether you're planning a solo getaway, a group adventure, or a budget-friendly escape, RoamBot helps you generate personalized travel itineraries in seconds.

Key Features:
• AI-Powered Trip Planning
• Smart Itinerary Generation
• Budget & Group Based Recommendations
• Saved Trips & Profile Management
• Real-Time Travel Tips & Daily Jokes

RoamBot was built with love to make your travel planning faster, smarter, and more fun.

Developed by Rahul Singh Adhikari
''';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About RoamBot',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(content, style: TextStyle(fontSize: 16, height: 1.5)),
        ),
      ),
    );
  }
}
