import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roambot/commons/widgets/custom_app_bar.dart';
import 'package:roambot/screens/About.dart';
import 'package:roambot/screens/PrivacyPolicy.dart';
import 'package:roambot/screens/TermsOfUse.dart';
import 'package:roambot/screens/landing_screen.dart';
import 'package:roambot/screens/login_screen.dart';
import 'package:roambot/screens/profile_screen.dart';
import 'package:roambot/utils/constants.dart';
import 'package:animations/animations.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  // void _showLogoutConfirmation(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Icon(Icons.logout, size: 40, color: Colors.red),
  //         content: const Text(
  //           'Are you sure you want to log out?',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(fontSize: 16),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               _logout(context);
  //             },
  //             child: const Text('Log out', style: TextStyle(color: Colors.red)),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showLogoutConfirmation(BuildContext context) {
    final colors = GlassColors.dark(); // Or `.light()` if using light mode

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout",
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Dialog(
              backgroundColor: colors.glassButton.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colors.glassBorder.withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, size: 48, color: colors.icon),
                    const SizedBox(height: 16),
                    Text(
                      "Log out?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Are you sure you want to log out?",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.text.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.background,
                            foregroundColor: colors.text,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _logout(context);
                          },
                          child: const Text("Log out"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Logged out successfully")));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LandingScreen()),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Log out failed. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = GlassColors.dark();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      backgroundColor: colors.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final name = data?['name'] ?? 'Explorer';
          final photoUrl = data?['photoUrl'];

          int filled = 0;
          if (name.toString().trim().isNotEmpty) filled++;
          if (photoUrl?.toString().trim().isNotEmpty ?? false) filled++;

          double completion = filled / 2;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.glassStart, colors.glassEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colors.glassBorder),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    photoUrl != null
                                        ? NetworkImage(photoUrl)
                                        : const AssetImage(
                                              'assets/default_avatar.png',
                                            )
                                            as ImageProvider,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Hi, $name',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSections(context, colors),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSections(BuildContext context, GlassColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Profile",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colors.icon,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildTile(
          Icons.person,
          "Edit personal information",
          const ProfileScreen(),
          colors,
        ),

        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "More",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colors.icon,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildTile(Icons.question_mark_sharp, "About", const About(), colors),
        const SizedBox(height: 10),
        _buildTile(
          Icons.shield_sharp,
          "Terms of use",
          const TermsOfUse(),
          colors,
        ),
        const SizedBox(height: 10),
        _buildTile(
          Icons.privacy_tip_outlined,
          "Privacy Policy",
          const PrivacyPolicy(),
          colors,
        ),
        const SizedBox(height: 10),

        _buildTile(Icons.logout_outlined, "Log out", () {
          _showLogoutConfirmation(context);
        }, colors),
      ],
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    dynamic targetOrCallback,
    GlassColors colors,
  ) {
    // If it's a screen (Widget), use OpenContainer
    if (targetOrCallback is Widget) {
      return OpenContainer(
        transitionDuration: const Duration(milliseconds: 500),
        transitionType: ContainerTransitionType.fadeThrough,
        closedColor: colors.glassButton,
        openColor: colors.background,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.glassBorder.withOpacity(0.3)),
        ),
        openBuilder: (context, _) => targetOrCallback,
        closedBuilder:
            (context, openContainer) => ListTile(
              leading: Icon(icon, color: colors.icon),
              title: Text(
                title,
                style: TextStyle(fontSize: 14, color: colors.text),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: colors.icon.withOpacity(0.6),
              ),
              onTap: openContainer,
            ),
      );
    }

    // Otherwise, fallback to regular ListTile (for logout etc.)
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colors.glassButton,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.glassBorder.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Icon(icon, color: colors.icon),
        title: Text(title, style: TextStyle(fontSize: 14, color: colors.text)),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: colors.icon.withOpacity(0.6),
        ),
        onTap: targetOrCallback,
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
