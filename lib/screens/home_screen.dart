import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roambot/commons/widgets/custom_elevated_buttons.dart';
import 'package:roambot/screens/profile_screen.dart';
import 'package:roambot/screens/trip_creation_screen.dart';
import 'package:roambot/screens/trip_planner_screen.dart';
import 'package:roambot/services/gemini_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? name;
  String? photoUrl;
  String? travelQuote;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadTravelQuote();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          name = data['name'] ?? 'Traveler';
          photoUrl = data['photoUrl'];
        });
      }
    }
  }

  Future<void> _loadTravelQuote() async {
    final prompt = "Tell me a short travel quote suitable for daily use.";
    final response = await GeminiService().generateTripPlan(prompt);
    setState(() => travelQuote = response.trim());
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final avatar =
        photoUrl != null
            ? NetworkImage(photoUrl!)
            : const AssetImage('assets/default_avatar.png') as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${name ?? 'Traveler'}!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 4,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ).then((_) => _loadProfile());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CircleAvatar(radius: 18, backgroundImage: avatar),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
            color: Colors.white,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (travelQuote != null) _buildQuoteCard(),
          const SizedBox(height: 12),
          _buildTripSummaryCard(),
          const SizedBox(height: 24),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Card(
      color: Colors.orange.shade50,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.format_quote_rounded, color: Colors.deepOrange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                travelQuote!,
                style: const TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSummaryCard() {
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('trips')
              .where(
                'userId',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid,
              )
              .get(),
      builder: (context, snapshot) {
        final trips = snapshot.data?.docs ?? [];

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.teal.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.travel_explore_rounded, color: Colors.teal),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trip Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Total Trips: ${trips.length}'),
                      if (trips.isNotEmpty)
                        Text(
                          'Latest Trip: ${trips.first['destination']}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        customButtons(
          side: const BorderSide(width: 3.0, color: Colors.green),
          bcolor: Colors.white,
          child: '✈️ Plan a Trip',
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
          side: const BorderSide(width: 3.0, color: Colors.blue),
          bcolor: Colors.white,
          child: '🗺️ View My Trips',
          fcolor: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TripPlannerScreen()),
            );
          },
        ),
      ],
    );
  }
}
