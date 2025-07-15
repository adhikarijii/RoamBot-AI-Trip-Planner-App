import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:roambot/commons/widgets/custom_app_bar.dart';

class TripDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  TripDetailsScreen({Key? key, required this.trip}) : super(key: key);

  String _formatDate(Timestamp timestamp) {
    return DateFormat('MMM d, yyyy').format(timestamp.toDate());
  }

  Future<void> _generateAndSavePdf(BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Load fonts
      final baseFontData = await rootBundle.load(
        'assets/fonts/NotoSans-Regular.ttf',
      );
      final boldFontData = await rootBundle.load(
        'assets/fonts/NotoSans-Bold.ttf',
      );
      final emojiFontData = await rootBundle.load(
        'assets/fonts/NotoColorEmoji-Regular.ttf',
      );

      final baseFont = pw.Font.ttf(baseFontData);
      final boldFont = pw.Font.ttf(boldFontData);
      final emojiFont = pw.Font.ttf(emojiFontData);

      final rawItinerary = trip['itinerary'] ?? '';
      final itinerary =
          rawItinerary.trim().isEmpty
              ? 'No itinerary available.'
              : rawItinerary;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build:
              (context) => pw.DefaultTextStyle(
                style: pw.TextStyle(
                  font: baseFont,
                  fontSize: 12,
                  fontFallback: [emojiFont],
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Trip Details',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        fontFallback: [emojiFont],
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Text('Destination: ${trip['destination'] ?? 'Unknown'}'),
                    pw.Text(
                      'Dates: ${_formatDate(trip['startDate'])} - ${_formatDate(trip['endDate'])}',
                    ),
                    pw.Text('Group Size: ${trip['people'] ?? 'N/A'} people'),
                    pw.Text('Budget: ₹${trip['budget'] ?? 'N/A'}'),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Itinerary:',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 16,
                        fontFallback: [emojiFont],
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(itinerary),
                  ],
                ),
              ),
        ),
      );

      // Save logic
      Directory dir;
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Storage permission denied')));
          return;
        }
        dir = (await getExternalStorageDirectory())!;
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final filePath =
          '${dir.path}/trip_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF saved to $filePath')));
      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF generation failed: ${e.toString()}')),
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
                onPressed: () => _generateAndSavePdf(context),
                icon: Icon(Icons.download),
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
