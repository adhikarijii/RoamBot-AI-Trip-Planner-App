import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roambot/utils/constants.dart';
import 'package:roambot/screens/trip_details_screen.dart';
import 'package:roambot/widgets/custom_app_bar.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({Key? key}) : super(key: key);

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  late Future<List<DocumentSnapshot>> _tripListFuture;

  @override
  void initState() {
    super.initState();
    _tripListFuture = _fetchTrips();
  }

  Future<List<DocumentSnapshot>> _fetchTrips() async {
    try {
      print('Current User ID: $currentUserId');
      final snapshot =
          await FirebaseFirestore.instance
              .collection('trips')
              .where('userId', isEqualTo: currentUserId)
              .orderBy('startDate', descending: true)
              .get();
      return snapshot.docs;
    } catch (e) {
      print('Firestore fetch error: $e');
      rethrow;
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ('My Trips')),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _tripListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading trips'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No trips found.'));
          }

          final trips = snapshot.data!;
          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              final destination = trip['destination'] ?? '';
              final startDate = _formatDate(trip['startDate']);
              final endDate = _formatDate(trip['endDate']);
              final itinerary = trip['itinerary'] ?? '';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(destination),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$startDate - $endDate'),
                      const SizedBox(height: 4),
                      if (itinerary.isNotEmpty)
                        Text(
                          'Itinerary: ${itinerary.length > 60 ? itinerary.substring(0, 60) + '...' : itinerary}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => TripDetailsScreen(
                              trip: trip.data() as Map<String, dynamic>,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
