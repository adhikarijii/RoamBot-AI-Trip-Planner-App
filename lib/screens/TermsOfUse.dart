import 'package:flutter/material.dart';
import 'package:roambot/commons/widgets/customFontSize.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({super.key});

  @override
  Widget build(BuildContext context) {
    const String content = '''
By using RoamBot, you agree to the following Terms of Use:

1. Use of Service:
   You agree to use the app only for lawful purposes and not for any fraudulent or malicious activity.

2. Account Responsibility:
   You are responsible for maintaining the confidentiality of your account and are liable for all activities under it.

3. Content Ownership:
   All generated itineraries are for personal use only. Do not redistribute or sell any AI-generated content.

4. Modifications:
   We may modify the app or terms without prior notice. Continued use of the app indicates your acceptance.

5. Limitation of Liability:
   RoamBot does not guarantee the accuracy or availability of travel suggestions and is not liable for trip-related losses.

''';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms Of Use',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(fontSize: customFontSize(context, 14)),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
