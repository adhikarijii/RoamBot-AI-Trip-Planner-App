import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    const String content = '''
RoamBot values your privacy. Here's how we handle your data:

1. Data Collection:
   We collect basic personal information (like name, email, profile photo) and trip data to provide personalized experiences.

2. Use of Data:
   Your data is used only to improve your travel planning experience. We do not sell or share it with third parties.

3. Storage:
   All data is securely stored in Firebase services, including Firestore and Firebase Storage.

4. Permissions:
   The app may request access to your device storage (for photo uploads) and location (for personalized suggestions in future versions).

5. Third-Party Services:
   RoamBot uses Firebase, Google Sign-In, and Gemini AI for itinerary generation.

''';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms Of Use',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}
