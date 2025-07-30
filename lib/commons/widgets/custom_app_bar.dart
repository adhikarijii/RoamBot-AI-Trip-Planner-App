import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roambot/screens/landing_screen.dart';
import 'package:roambot/screens/login_screen.dart';
import 'package:roambot/screens/profile_screen.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String? userName;
  final String? profileImageUrl;

  const CustomAppBar({
    super.key,
    required this.title,
    this.userName,
    this.profileImageUrl,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isNavigating = false;

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

  void _showLogoutConfirmation(BuildContext context) {
    final colors = GlassColors.dark();

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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Logged out successfully")));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LandingScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Log out failed. Please try again.")),
      );
    }
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        '${widget.title}${widget.userName != null ? ' - ${widget.userName}' : ''}',
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        // OpenContainer(
        //   transitionType: ContainerTransitionType.fadeThrough,
        //   transitionDuration: const Duration(milliseconds: 500),
        //   closedElevation: 0,
        //   openElevation: 0,
        //   closedColor: Colors.transparent,
        //   openColor: Colors.transparent,
        //   closedShape: const CircleBorder(),
        //   openBuilder: (context, _) => const ProfileScreen(),
        //   closedBuilder:
        //       (context, openContainer) => Padding(
        //         padding: const EdgeInsets.all(8.0),
        //         child: CircleAvatar(
        //           backgroundImage:
        //               widget.profileImageUrl != null
        //                   ? NetworkImage(widget.profileImageUrl!)
        //                   : const AssetImage('assets/default_avatar.png')
        //                       as ImageProvider,
        //         ),
        //       ),
        // ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _showLogoutConfirmation(context),
          color: Colors.white,
        ),
      ],
      backgroundColor: const Color(0xFF1A2327),
      elevation: 4,
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
