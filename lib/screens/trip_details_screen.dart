import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:roambot/commons/widgets/custom_app_bar.dart';

class TripDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> trip;
  late final pw.Font font;

  TripDetailsScreen({Key? key, required this.trip}) : super(key: key) {
    font = pw.Font();
  }

  String _formatDate(Timestamp timestamp) {
    return DateFormat('MMM d, yyyy').format(timestamp.toDate());
  }

  // Future<void> _generatePdf(BuildContext context) async {
  //   // Load a font that supports Unicode
  //   final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
  //   final ttf = pw.Font.ttf(fontData);

  //   final pdf = pw.Document();

  //   final String destination = trip['destination'] ?? 'Unknown';
  //   final String startDate = _formatDate(trip['startDate']);
  //   final String endDate = _formatDate(trip['endDate']);
  //   final String budget = trip['budget'] ?? 'N/A';
  //   final String people = trip['people'] ?? 'N/A';
  //   final String itinerary = trip['itinerary'] ?? 'No itinerary available';

  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a4,
  //       build: (context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Text(
  //               'Trip Details',
  //               style: pw.TextStyle(
  //                 fontSize: 24,
  //                 fontWeight: pw.FontWeight.bold,
  //                 font: ttf,
  //               ),
  //             ),
  //             pw.SizedBox(height: 20),
  //             pw.Text(
  //               'Destination: $destination',
  //               style: pw.TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: pw.FontWeight.bold,
  //                 font: ttf,
  //               ),
  //             ),
  //             pw.SizedBox(height: 10),
  //             pw.Row(
  //               children: [
  //                 pw.Text(
  //                   'Dates: $startDate - $endDate',
  //                   style: pw.TextStyle(font: ttf),
  //                 ),
  //                 pw.SizedBox(width: 20),
  //                 pw.Text(
  //                   'Group Size: $people people',
  //                   style: pw.TextStyle(font: ttf),
  //                 ),
  //               ],
  //             ),
  //             pw.Text('Budget: ₹$budget', style: pw.TextStyle(font: ttf)),
  //             pw.SizedBox(height: 20),
  //             pw.Text(
  //               'Itinerary:',
  //               style: pw.TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: pw.FontWeight.bold,
  //                 font: ttf,
  //               ),
  //             ),
  //             pw.SizedBox(height: 8),
  //             pw.Text(itinerary, style: pw.TextStyle(font: ttf)),
  //           ],
  //         );
  //       },
  //     ),
  //   );

  //   try {
  //     await Printing.layoutPdf(
  //       onLayout: (PdfPageFormat format) async => pdf.save(),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to generate PDF: ${e.toString()}')),
  //     );
  //   }
  // }
  Future<void> _generatePdf(BuildContext context) async {
    // Load a font that supports most text (but not emojis)
    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    // Sanitize function to strip emojis and U+FE0F
    String sanitizeForPdf(String input) {
      final emojiRegex = RegExp(
        r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\uFE0F]',
        unicode: true,
      );
      return input.replaceAll(emojiRegex, '');
    }

    final String destination = sanitizeForPdf(trip['destination'] ?? 'Unknown');
    final String startDate = _formatDate(trip['startDate']);
    final String endDate = _formatDate(trip['endDate']);
    final String budget = sanitizeForPdf(trip['budget'] ?? 'N/A');
    final String people = sanitizeForPdf(trip['people'] ?? 'N/A');

    String rawItinerary = trip['itinerary'] ?? 'No itinerary available';
    String itinerary = sanitizeForPdf(rawItinerary).trim();

    if (itinerary.isEmpty) {
      itinerary = 'No itinerary available (emojis not supported in PDF)';
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Trip Details',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: ttf,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Destination: $destination',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  font: ttf,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Text(
                    'Dates: $startDate - $endDate',
                    style: pw.TextStyle(font: ttf),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    'Group Size: $people people',
                    style: pw.TextStyle(font: ttf),
                  ),
                ],
              ),
              pw.Text('Budget: ₹$budget', style: pw.TextStyle(font: ttf)),
              pw.SizedBox(height: 20),
              pw.Text(
                'Itinerary:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  font: ttf,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(itinerary, style: pw.TextStyle(font: ttf)),
            ],
          );
        },
      ),
    );

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: ${e.toString()}')),
      );
    }
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'Trip Details'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip['destination'] ?? 'Unknown Destination',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal[900],
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  '${_formatDate(trip['startDate'])} - ${_formatDate(trip['endDate'])}',
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(width: 16),
                Icon(Icons.people, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  '${trip['people'] ?? 'N/A'} people',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    color: Colors.teal[50],
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            'Budget',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.teal[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '₹${trip['budget'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildInfoCard(
              'Itinerary',
              trip['itinerary'] ?? 'No itinerary available',
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _generatePdf(context),
                icon: Icon(Icons.picture_as_pdf),
                label: Text('Download PDF'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
