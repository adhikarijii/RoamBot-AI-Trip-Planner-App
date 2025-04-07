import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Pop everything off the navigation stack
    Navigator.of(context).popUntil((route) => route.isFirst);

    // The AuthGate will rebuild to LoginScreen because user is now null
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: const Color.fromRGBO(183, 201, 226, 1.0),
      elevation: 4,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _logout(context),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
