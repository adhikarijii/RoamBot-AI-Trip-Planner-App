import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:roambot/commons/widgets/customFontSize.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({super.key});
  Widget _buildGlassCard({
    required Widget child,
    required GlassColors colors,
    double blurSigma = 10,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.glassStart.withOpacity(0.7),
                colors.glassEnd.withOpacity(0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.glassBorder.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: -5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = GlassColors.dark();
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
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text(
          'Terms Of Use',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A2327),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: _buildGlassCard(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                content,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: colors.text,
                ),
                textAlign: TextAlign.justify,
                // style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            colors: colors,
          ),
        ),
      ),
    );
  }
}

class GlassColors {
  final Color background;
  final Color appBar;
  final Color primary;
  final Color onPrimary;
  final Color text;
  final Color icon;
  final Color glassStart;
  final Color glassEnd;
  final Color glassBorder;
  final Color glassButton;
  final Color shadow;

  GlassColors({
    required this.background,
    required this.appBar,
    required this.primary,
    required this.onPrimary,
    required this.text,
    required this.icon,
    required this.glassStart,
    required this.glassEnd,
    required this.glassBorder,
    required this.glassButton,
    required this.shadow,
  });

  factory GlassColors.dark() {
    return GlassColors(
      background: const Color(0xFF0D0F14), // Deep dark background
      appBar: const Color(0xFF1A2327), // Dark teal app bar
      primary: const Color(0xFF2CE0D0), // Vibrant teal
      onPrimary: const Color(0xFF0D0F14), // Dark text for light elements
      text: const Color(0xFFE0F3FF), // Light text
      icon: const Color(0xFF2CE0D0), // Teal icons
      glassStart: const Color(0xFF1A2327).withOpacity(0.8), // Dark teal glass
      glassEnd: const Color(0xFF253A3E).withOpacity(0.6), // Lighter teal glass
      glassBorder: const Color(
        0xFF3FE0D0,
      ).withOpacity(0.15), // Subtle teal border
      glassButton: const Color(
        0xFF1E2A2D,
      ).withOpacity(0.4), // Dark glass buttons
      shadow: Colors.black.withOpacity(0.5), // Deep shadows
    );
  }

  factory GlassColors.light() {
    return GlassColors(
      background: const Color(0xFFF5F7FA),
      appBar: const Color(0x804E8C87),
      primary: const Color(0xFF4E8C87),
      onPrimary: Colors.white,
      text: const Color(0xFF2D3748),
      icon: const Color(0xFF4E8C87),
      glassStart: const Color(0x90A5D8D3),
      glassEnd: const Color(0x60E2F3F0),
      glassBorder: Colors.white.withOpacity(0.4),
      glassButton: Colors.white.withOpacity(0.3),
      shadow: const Color(0x554A5568),
    );
  }
}
