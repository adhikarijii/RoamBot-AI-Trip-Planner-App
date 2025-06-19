import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(Icons.logout, size: 40, color: Colors.red),
          content: const Text(
            'Are you sure you want to log out?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
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
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout failed. Please try again.")),
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
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        '${widget.title}${widget.userName != null ? ' - ${widget.userName}' : ''}',
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        GestureDetector(
          onTap: () => _openProfile(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage:
                  widget.profileImageUrl != null
                      ? NetworkImage(widget.profileImageUrl!)
                      : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _showLogoutConfirmation(context),
          color: Colors.white,
        ),
      ],
      backgroundColor: theme.colorScheme.primary,
      elevation: 4,
    );
  }
}
