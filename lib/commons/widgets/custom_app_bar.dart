import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roambot/screens/login_screen.dart';
import 'package:roambot/screens/profile_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? userName;
  final String? profileImageUrl;

  const CustomAppBar({
    super.key,
    required this.title,
    this.userName,
    this.profileImageUrl,
  });

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Logged out successfully")));
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
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
      title: Text('$title${userName != null ? ' - $userName' : ''}'),
      actions: [
        GestureDetector(
          onTap: () => _openProfile(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage:
                  profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _logout(context),
        ),
      ],
      backgroundColor: const Color.fromARGB(255, 135, 238, 164),
      elevation: 4,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
