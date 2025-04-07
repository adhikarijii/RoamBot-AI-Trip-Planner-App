import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roambot/commons/widgets/customElevatedButtons.dart';
import 'package:roambot/screens/profile_screen.dart';
import 'package:roambot/screens/trip_creation_screen.dart';
import 'package:roambot/screens/trip_planner_screen.dart';
import 'package:roambot/screens/user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? name;
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          name = data['name'] ?? '';
          photoUrl = data['photoUrl'];
        });
      }
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome${name != null && name!.isNotEmpty ? ', $name!' : '!'}',
        ),
        backgroundColor: const Color.fromARGB(255, 135, 238, 164),
        elevation: 4,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ).then((_) => _loadProfile()); // Reload profile after update
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage:
                    photoUrl != null
                        ? NetworkImage(photoUrl!)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButtons(
              bcolor: const Color.fromARGB(255, 231, 231, 86),
              child: 'Profile',
              fcolor: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            customButtons(
              bcolor: const Color.fromARGB(255, 134, 252, 75),
              child: 'Plan Trip',
              fcolor: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TripCreationScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            customButtons(
              bcolor: const Color.fromARGB(255, 52, 248, 255),
              child: 'My Trips',
              fcolor: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TripPlannerScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
