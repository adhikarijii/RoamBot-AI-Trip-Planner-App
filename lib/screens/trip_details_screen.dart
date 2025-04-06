import 'package:flutter/material.dart';
import 'package:roambot/widgets/custom_app_bar.dart';

class TripDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final String? itineraryRaw = trip['itinerary'];
    final String itinerary = _cleanItinerary(itineraryRaw);

    return Scaffold(
      appBar: CustomAppBar(title: trip['destination'] ?? 'Trip Details'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Destination: ${trip['destination']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Start Date: ${trip['startDate']}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'End Date: ${trip['endDate']}',
              style: const TextStyle(fontSize: 16),
            ),
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
            itinerary.isNotEmpty
                ? Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      itinerary,
                      style: const TextStyle(fontSize: 16, height: 1.5),
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

  String _cleanItinerary(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return raw
        .replaceAll(RegExp(r'Day \d+:', caseSensitive: false), '')
        .replaceAll(RegExp(r'[#*]'), '')
        .replaceAll(RegExp(r'\n{2,}'), '\n')
        .trim();
  }
}
