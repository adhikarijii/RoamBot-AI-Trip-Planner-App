import 'package:flutter/material.dart';
import 'package:roambot/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';

class TripDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final String? itinerary = trip['itinerary'];
    final String cleanedItinerary =
        itinerary != null
            ? itinerary.replaceAll(RegExp(r'[#*]'), '').trim()
            : '';

    final startDate =
        trip['startDate'] != null
            ? (trip['startDate'] is String
                ? trip['startDate']
                : DateFormat('MMM d, yyyy').format(trip['startDate'].toDate()))
            : 'N/A';

    final endDate =
        trip['endDate'] != null
            ? (trip['endDate'] is String
                ? trip['endDate']
                : DateFormat('MMM d, yyyy').format(trip['endDate'].toDate()))
            : 'N/A';

    return Scaffold(
      appBar: CustomAppBar(title: trip['destination'] ?? 'Trip Details'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Destination: ${trip['destination'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Start Date: $startDate',
              style: const TextStyle(fontSize: 16),
            ),
            Text('End Date: $endDate', style: const TextStyle(fontSize: 16)),
            if (trip['budget'] != null)
              Text(
                'Budget: ₹${trip['budget']}',
                style: const TextStyle(fontSize: 16),
              ),
            if (trip['people'] != null)
              Text(
                'People: ${trip['people']}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            const Text(
              'AI Itinerary:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            cleanedItinerary.isNotEmpty
                ? Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(top: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      cleanedItinerary,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                )
                : const Text(
                  'Itinerary not yet generated.',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
          ],
        ),
      ),
    );
  }
}
