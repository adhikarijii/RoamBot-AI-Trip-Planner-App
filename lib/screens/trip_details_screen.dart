import 'dart:io';
import 'dart:ui';
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

  Widget _buildGlassCard({
    required Widget child,
    required GlassColors colors,
    double blurSigma = 10,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.glassStart.withOpacity(0.7),
                colors.glassEnd.withOpacity(0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.glassBorder.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: -5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = GlassColors.dark();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: CustomAppBar(title: 'Trip Details'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGlassCard(
              colors: colors,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip['destination'] ?? 'Unknown Destination',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: colors.icon,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${_formatDate(trip['startDate'])} - ${_formatDate(trip['endDate'])}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: colors.icon),
                        SizedBox(width: 8),
                        Text(
                          '${trip['people'] ?? 'N/A'} people',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGlassCard(
                            colors: colors,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Budget',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors.primary,
                                          ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '₹${trip['budget'] ?? 'N/A'}',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors.text,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildGlassCard(
                      colors: colors,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Itinerary',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              trip['itinerary'] ?? 'No itinerary available',

                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // _buildInfoCard(
                    //   'Itinerary',
                    //   trip['itinerary'] ?? 'No itinerary available',
                    // ),
                    SizedBox(height: 24),
                    // Center(
                    //   child: ElevatedButton.icon(
                    //     onPressed: () => _generateAndSavePdf(context),
                    //     icon: Icon(Icons.download),
                    //     label: Text('Download PDF'),
                    //     style: ElevatedButton.styleFrom(
                    //       padding: EdgeInsets.symmetric(
                    //         horizontal: 24,
                    //         vertical: 12,
                    //       ),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassColors {
  final Color background;
  final Color appBar;
  final Color primary;
  final Color onPrimary;
  final Color text;
  final Color icon;
  final Color glassStart;
  final Color glassEnd;
  final Color glassBorder;
  final Color glassButton;
  final Color shadow;

  GlassColors({
    required this.background,
    required this.appBar,
    required this.primary,
    required this.onPrimary,
    required this.text,
    required this.icon,
    required this.glassStart,
    required this.glassEnd,
    required this.glassBorder,
    required this.glassButton,
    required this.shadow,
  });

  factory GlassColors.dark() {
    return GlassColors(
      background: const Color(0xFF0D0F14), // Deep dark background
      appBar: const Color(0xFF1A2327), // Dark teal app bar
      primary: const Color(0xFF2CE0D0), // Vibrant teal
      onPrimary: const Color(0xFF0D0F14), // Dark text for light elements
      text: const Color(0xFFE0F3FF), // Light text
      icon: const Color(0xFF2CE0D0), // Teal icons
      glassStart: const Color(0xFF1A2327).withOpacity(0.8), // Dark teal glass
      glassEnd: const Color(0xFF253A3E).withOpacity(0.6), // Lighter teal glass
      glassBorder: const Color(
        0xFF3FE0D0,
      ).withOpacity(0.15), // Subtle teal border
      glassButton: const Color(
        0xFF1E2A2D,
      ).withOpacity(0.4), // Dark glass buttons
      shadow: Colors.black.withOpacity(0.5), // Deep shadows
    );
  }

  factory GlassColors.light() {
    return GlassColors(
      background: const Color(0xFFF5F7FA),
      appBar: const Color(0x804E8C87),
      primary: const Color(0xFF4E8C87),
      onPrimary: Colors.white,
      text: const Color(0xFF2D3748),
      icon: const Color(0xFF4E8C87),
      glassStart: const Color(0x90A5D8D3),
      glassEnd: const Color(0x60E2F3F0),
      glassBorder: Colors.white.withOpacity(0.4),
      glassButton: Colors.white.withOpacity(0.3),
      shadow: const Color(0x554A5568),
    );
  }
}
