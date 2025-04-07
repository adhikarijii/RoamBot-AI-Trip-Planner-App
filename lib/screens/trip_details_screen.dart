import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:roambot/widgets/custom_app_bar.dart';

class TripDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripDetailsScreen({Key? key, required this.trip}) : super(key: key);

  String _formatDate(Timestamp timestamp) {
    return DateFormat('MMM d, yyyy').format(timestamp.toDate());
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    final String destination = trip['destination'] ?? 'Unknown';
    final String startDate = _formatDate(trip['startDate']);
    final String endDate = _formatDate(trip['endDate']);
    final String budget = trip['budget'] ?? 'N/A';
    final String people = trip['people'] ?? 'N/A';
    final String itinerary = trip['itinerary'] ?? 'No itinerary available';

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Text(
                'Trip to $destination',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('From: $startDate'),
              pw.Text('To: $endDate'),
              pw.Text('Budget: ₹$budget'),
              pw.Text('People: $people'),
              pw.SizedBox(height: 20),
              pw.Text(
                'Itinerary:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(itinerary),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: ('Trip Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Destination: ${trip['destination']}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Start Date: ${_formatDate(trip['startDate'])}'),
            Text('End Date: ${_formatDate(trip['endDate'])}'),
            const SizedBox(height: 8),
            Text('Budget: ₹${trip['budget']}'),
            Text('People: ${trip['people']}'),
            const SizedBox(height: 16),
            Text(
              'Itinerary:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(trip['itinerary'] ?? 'No itinerary found'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _generatePdf(context),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Download PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
