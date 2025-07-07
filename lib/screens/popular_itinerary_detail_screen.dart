import 'package:flutter/material.dart';
import 'package:roambot/commons/widgets/custom_app_bar.dart';

class PopularItineraryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const PopularItineraryDetailScreen({Key? key, required this.trip})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> itinerary = List<String>.from(trip['days'] ?? []);
    final List<String> tips = List<String>.from(trip['tips'] ?? []);
    final String? imageAsset = trip['imageAsset'];

    return Scaffold(
      appBar: CustomAppBar(title: trip['title']),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageAsset != null)
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: Image.asset(
                  imageAsset,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Itinerary",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ...itinerary.map(
                    (day) => Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.calendar_today, color: Colors.blue),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(day, style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (tips.isNotEmpty) ...[
                    SizedBox(height: 24),
                    Text(
                      "Travel Tips",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    ...tips.map(
                      (tip) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(tip, style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
