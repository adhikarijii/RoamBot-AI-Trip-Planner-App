import 'package:flutter/material.dart';
import 'package:roambot/screens/trip_planner_screen.dart';
import 'package:roambot/screens/trip_creation_screen.dart';
import 'package:roambot/widgets/custom_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ('RoamBot Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TripCreationScreen()),
                );
              },
              child: const Text('Plan Trip'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TripPlannerScreen()),
                );
              },
              child: const Text('My Trips'),
            ),
          ],
        ),
      ),
    );
  }
}
