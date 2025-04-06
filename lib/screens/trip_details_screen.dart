import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roambot/utils/constants.dart';

class TripDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripDetailsScreen({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startDate = (trip['startDate'] as Timestamp).toDate();
    final endDate = (trip['endDate'] as Timestamp).toDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut(); // assuming `auth` is in constants.dart
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Destination: ${trip['destination']}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Start Date: ${DateFormat('MMM d, yyyy').format(startDate)}'),
            Text('End Date: ${DateFormat('MMM d, yyyy').format(endDate)}'),
            const SizedBox(height: 8),
            Text('Budget: ₹${trip['budget']}'),
            Text('People: ${trip['people']}'),
            const Divider(height: 24),
            Text('Itinerary:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(trip['itinerary'] ?? 'No itinerary found'),
          ],
        ),
      ),
    );
  }
}
