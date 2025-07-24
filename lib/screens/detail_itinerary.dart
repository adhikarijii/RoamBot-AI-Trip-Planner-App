import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http show head;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:roambot/commons/widgets/loading_screen.dart';
import 'package:roambot/services/gemini_services.dart';
import 'package:roambot/utils/constants.dart';
import 'package:roambot/commons/widgets/custom_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetailItinerary extends StatefulWidget {
  const DetailItinerary({Key? key}) : super(key: key);

  @override
  State<DetailItinerary> createState() => _DetailItineraryState();
}

class _DetailItineraryState extends State<DetailItinerary> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _destinationfromController =
      TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();
  final TextEditingController _destinationtoController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _generatedItinerary;
  bool _isLoading = false;

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

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final initialDate =
        isStartDate
            ? (_startDate ?? DateTime.now())
            : (_endDate ?? (_startDate ?? DateTime.now()));
    final firstDate =
        isStartDate ? DateTime.now() : (_startDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String cleanAndFormatItinerary(String itinerary) {
    // Split into lines and process each one
    final lines = itinerary.split('\n');
    final formattedLines = <String>[];

    for (var line in lines) {
      if (line.trim().isEmpty) {
        // Preserve empty lines for paragraph spacing
        formattedLines.add('');
        continue;
      }

      // Handle section headers
      if (line.startsWith('##')) {
        formattedLines.add('');
        formattedLines.add(line.replaceAll('#', '').trim().toUpperCase());
        formattedLines.add('');
        continue;
      }

      // Handle bullet points
      if (line.trim().startsWith('•') ||
          line.trim().startsWith('-') ||
          line.trim().startsWith('*')) {
        formattedLines.add(line.trim());
        continue;
      }

      // Handle numbered lists
      if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
        formattedLines.add(line.trim());
        continue;
      }

      // Regular text - ensure it's properly spaced
      if (formattedLines.isNotEmpty &&
          formattedLines.last.isNotEmpty &&
          !formattedLines.last.endsWith('\n')) {
        formattedLines.add(line);
      } else {
        formattedLines.add(line);
      }
    }

    // Join with proper spacing
    return formattedLines.join('\n').trim();
  }

  Future<void> _generateAndSaveTrip() async {
    if (_formKey.currentState == null ||
        !_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select dates'),
        ),
      );
      return;
    }

    final destinationfrom = _destinationfromController.text.trim();
    final destinationto = _destinationtoController.text.trim();
    final budget = _budgetController.text.trim();
    final people = _peopleController.text.trim();
    final description = _descriptionController.text.trim();

    // Show full-screen loading screen
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder:
            (_, __, ___) =>
                const LoadingScreen(message: "Generating your itinerary..."),
      ),
    );

    final prompt = '''
Create a comprehensive, day-by-day travel itinerary for a trip from $destinationfrom to $destinationto from ${DateFormat('MMMM d, yyyy').format(_startDate!)} to ${DateFormat('MMMM d, yyyy').format(_endDate!)} for $people people with a budget of ₹$budget by considering $description.

FORMATTING REQUIREMENTS:
- Use ## Section Headers ## for major sections
- Use bullet points (•) for lists
- Put each activity on its own line
- Include blank lines between sections
- Use emojis where appropriate (🏨 for hotels, 🚗 for transport, etc.)
- Keep descriptions concise (1-2 sentences)

STRUCTURE THE RESPONSE AS FOLLOWS:

## Destination Overview ##
[Brief 2-3 paragraph introduction about the destination]

## Day 1: [Day Name], [Date] ##
• 08:00-09:00: Breakfast at [Place Name] - [Brief description]
• 09:30-12:00: Visit [Attraction 1] - [Description, 50 words max]
• 12:30-13:30: Lunch at [Restaurant] - [Cuisine type, price range]
• 14:00-17:00: Activity at [Location] - [Details]
• 19:00-21:00: Dinner at [Restaurant] - [Recommendation]
[Include transportation notes between locations]

## Day 2: [Day Name], [Date] ##
[Same structure as above]

## Recommended Accommodations ##
• [Hotel/Homestay Name] - [Price range], [Contact info (Mobile Numbers by searching from web)], [Brief description]
 • [Second Option] - [Details]

## Travel Tips ##
• [Tip 1]
• [Tip 2]

## Emergency Contacts ##
• Police: [Number]
• Hospital: [Number]
''';

    try {
      final itinerary = await GeminiService().generateTripPlan(prompt);

      Navigator.of(context).pop(); // close the loading screen

      _generatedItinerary = itinerary;
      _showItineraryPreviewDialog(
        itinerary,
      ); // Show dialog or navigate to another screen
    } catch (e) {
      Navigator.of(context).pop(); // close the loading screen

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate itinerary: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> _showItineraryPreviewDialog(String itinerary) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Your Trip Itinerary',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Destination Header
                          ItineraryDisplayWidget(
                            itinerary: itinerary,
                            destination: _destinationtoController.text.trim(),
                          ),
                          const SizedBox(height: 20),
                          // Itinerary Content
                          if (_generatedItinerary != null)
                            Text(
                              _generatedItinerary!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          else
                            const Text(
                              'No itinerary content was generated.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Edit Details'),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _shareItinerary(itinerary),
                              icon: const Icon(Icons.share),
                              tooltip: 'Share Itinerary',
                            ),
                            IconButton(
                              onPressed: () => _printItinerary(itinerary),
                              icon: const Icon(Icons.print),
                              tooltip: 'Print Itinerary',
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _saveTrip();
                              },
                              child: const Text('Save Trip'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _printItinerary(String itinerary) async {
    try {
      await Printing.layoutPdf(onLayout: (format) => _generatePdf(itinerary));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to print: $e')));
      }
    }
  }

  Future<Uint8List> _generatePdf(String itinerary) async {
    // Implement your PDF generation logic here
    // This is a placeholder - you'll need to implement actual PDF generation
    final doc = await Printing.convertHtml(
      format: PdfPageFormat.a4,
      html: '<h1>Trip Itinerary</h1><p>$itinerary</p>',
    );
    return doc;
  }

  Future<void> _shareItinerary(String itinerary) async {
    try {
      await Share.share(
        'Check out my trip itinerary to ${_destinationtoController.text.trim()}:\n\n$itinerary',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
      }
    }
  }

  Future<void> _saveTrip() async {
    try {
      await FirebaseFirestore.instance.collection('trips').add({
        'userId': currentUserId,
        'destinationFrom': _destinationfromController.text.trim(),
        'destination': _destinationtoController.text.trim(),
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'budget': _budgetController.text.trim(),
        'people': _peopleController.text.trim(),
        'createdAt': Timestamp.now(),
        'itinerary': _generatedItinerary ?? '',
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('Success'),
                content: const Text('Trip has been saved successfully!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop(); // Pop TripCreationScreen
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save trip')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = GlassColors.dark();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: colors.background,
          appBar: const CustomAppBar(title: 'Plan a Trip'),
          body:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildGlassCard(
                            colors: colors,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  DestinationSearchField(
                                    controller: _destinationfromController,
                                    onSelected: (destination) {
                                      debugPrint("Selected: $destination");
                                    },
                                    labeltext: 'Destination From',
                                  ),
                                  const SizedBox(height: 16),
                                  DestinationSearchField(
                                    controller: _destinationtoController,
                                    onSelected: (destination) {
                                      debugPrint("Selected: $destination");
                                    },
                                    labeltext: 'Destination To',
                                  ),

                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed:
                                              () => _pickDate(context, true),
                                          icon: Icon(
                                            Icons.calendar_today,
                                            color: colors.icon,
                                          ),
                                          label: Text(
                                            _startDate == null
                                                ? 'Start Date'
                                                : DateFormat(
                                                  'MMM d, yyyy',
                                                ).format(_startDate!),
                                            style: TextStyle(
                                              color: colors.text,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed:
                                              _startDate == null
                                                  ? null
                                                  : () =>
                                                      _pickDate(context, false),
                                          icon: Icon(
                                            Icons.calendar_month,
                                            color: colors.icon,
                                          ),
                                          label: Text(
                                            _endDate == null
                                                ? 'End Date'
                                                : DateFormat(
                                                  'MMM d, yyyy',
                                                ).format(_endDate!),
                                            style: TextStyle(
                                              color: colors.text,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _budgetController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: colors.text,
                                    ), // Text input color
                                    decoration: InputDecoration(
                                      labelText: 'Budget (₹)',
                                      labelStyle: TextStyle(
                                        color: colors.icon,
                                      ), // Label text color
                                      prefixIcon: Icon(
                                        Icons.currency_rupee,
                                        color: colors.icon,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator:
                                        (value) =>
                                            value == null || value.isEmpty
                                                ? 'Enter budget'
                                                : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _peopleController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: colors.text,
                                    ), // Text input color
                                    decoration: InputDecoration(
                                      labelText: 'Number of People',
                                      labelStyle: TextStyle(
                                        color: colors.icon,
                                      ), // Label text color
                                      prefixIcon: Icon(
                                        Icons.people,
                                        color: colors.icon,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator:
                                        (value) =>
                                            value == null || value.isEmpty
                                                ? 'Enter number of people'
                                                : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _descriptionController,
                                    maxLength: 250,
                                    maxLines: 3,
                                    style: TextStyle(
                                      color: colors.text,
                                    ), // Text input color
                                    decoration: InputDecoration(
                                      labelText: 'Any other descriotion...',
                                      labelStyle: TextStyle(
                                        color: colors.icon,
                                      ), // Label text color
                                      prefixIcon: Icon(
                                        Icons.description,
                                        color: colors.icon,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  FilledButton.icon(
                                    icon: const Icon(Icons.flight_takeoff),
                                    label: const Text('Generate Itinerary'),
                                    onPressed: _generateAndSaveTrip,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        ),

        // --- Custom Loader Overlay ---
        if (_isLoading) const LoadingScreen(),
      ],
    );
  }
}

class ItineraryDisplayWidget extends StatelessWidget {
  final String itinerary;
  final String destination;

  const ItineraryDisplayWidget({
    super.key,
    required this.itinerary,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final sections = _parseItinerary(itinerary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _buildDestinationHeader(context),
        Center(
          child: Text(
            destination,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        ...sections.map((section) => _buildItinerarySection(section)),
      ],
    );
  }

  Widget _buildItinerarySection(Map<String, dynamic> section) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (section['icon'] != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(section['icon']),
                  ),
                Text(
                  section['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (section['type'] == 'day')
              _buildDaySection(section)
            else if (section['type'] == 'hotels')
              _buildHotelsSection(section)
            else
              Text(section['content']),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section['date'] ?? '',
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        ...section['activities'].map<Widget>(
          (activity) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  child: Text(
                    activity['time'] ?? '⏰',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (activity['description'] != null)
                        Text(
                          activity['description']!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotelsSection(Map<String, dynamic> section) {
    return Column(
      children:
          section['hotels']
              .map<Widget>(
                (hotel) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🏨 ${hotel['name']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('📞 ${hotel['phone']}'),
                      Text('💰 ${hotel['price']}'),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  List<Map<String, dynamic>> _parseItinerary(String itinerary) {
    final lines = itinerary.split('\n');
    final sections = <Map<String, dynamic>>[];
    Map<String, dynamic>? currentSection;

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.startsWith('##') && line.endsWith('##')) {
        if (currentSection != null) sections.add(currentSection);
        final title = line.replaceAll('#', '').trim();
        currentSection = {
          'title': title,
          'content': '',
          'type': _getSectionType(title),
        };

        if (currentSection['type'] == 'day') {
          currentSection['activities'] = [];
        } else if (currentSection['type'] == 'hotels') {
          currentSection['hotels'] = [];
        }
      } else if (currentSection != null && currentSection['type'] == 'day') {
        if (line.contains(':')) {
          final parts = line.split(':');
          currentSection['activities'].add({
            'time': parts[0].trim(),
            'title': parts[1].trim(),
            // 'image': _getPlaceImageUrl(parts[1].trim()),
          });
        } else {
          if (currentSection['activities'].isNotEmpty) {
            final lastActivity = currentSection['activities'].last;
            lastActivity['description'] = line.trim();
          }
        }
      } else if (currentSection != null && currentSection['type'] == 'hotels') {
        if (line.contains('•')) {
          currentSection['hotels'].add({
            'name': line.replaceAll('•', '').trim(),
            'phone': 'Not specified',
            'price': 'Not specified',
          });
        }
      } else if (currentSection != null) {
        currentSection['content'] += '$line\n';
      }
    }

    if (currentSection != null) sections.add(currentSection);

    for (var section in sections) {
      section['icon'] = _getSectionIcon(section['title']);
    }

    return sections;
  }

  String _getSectionType(String title) {
    if (title.toLowerCase().startsWith('day')) return 'day';
    if (title.toLowerCase().contains('hotel') ||
        title.toLowerCase().contains('stay'))
      return 'hotels';
    if (title.toLowerCase().contains('emergency')) return 'emergency';
    return 'general';
  }

  IconData? _getSectionIcon(String title) {
    if (title.toLowerCase().startsWith('day')) return Icons.calendar_today;
    if (title.toLowerCase().contains('hotel')) return Icons.hotel;
    if (title.toLowerCase().contains('emergency')) return Icons.warning;
    if (title.toLowerCase().contains('tip')) return Icons.lightbulb;
    if (title.toLowerCase().contains('pack')) return Icons.luggage;
    return null;
  }
}

Future<List<String>> fetchGeoNamesCities(String query) async {
  final username = 'adhikari__ji'; // Replace with your GeoNames username
  final url =
      'http://api.geonames.org/searchJSON?name_startsWith=$query&maxRows=10&orderby=relevance&featureClass=P&username=$username';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List names = data['geonames'];
    return names
        .map<String>((e) => '${e['name']}, ${e['countryName']}')
        .toSet()
        .toList();
  } else {
    return [];
  }
}

class DestinationSearchField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSelected;
  final String labeltext;

  const DestinationSearchField({
    super.key,
    required this.controller,
    required this.onSelected,
    required this.labeltext,
  });

  @override
  State<DestinationSearchField> createState() => _DestinationSearchFieldState();
}

class _DestinationSearchFieldState extends State<DestinationSearchField> {
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];
  OverlayEntry? _overlayEntry;

  void _onTextChanged(String query) async {
    if (query.isEmpty) {
      _removeOverlay();
      return;
    }

    final results = await fetchGeoNamesCities(query);
    setState(() {
      _suggestions = results;
    });
    _showOverlay();
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder:
          (_) => Positioned(
            left: offset.dx,
            top: offset.dy + size.height,
            width: size.width,
            child: Material(
              elevation: 4,
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children:
                    _suggestions
                        .map(
                          (s) => ListTile(
                            title: Text(s),
                            onTap: () {
                              widget.controller.text = s;
                              widget.onSelected(s);
                              _removeOverlay();
                            },
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      style: TextStyle(color: Colors.white), // <-- Input text color
      decoration: InputDecoration(
        labelText: widget.labeltext, // ← uses externally provided label
        labelStyle: TextStyle(color: Color(0xFF2CE0D0)), // Label text color
        prefixIcon: const Icon(
          Icons.location_on,
          color: const Color(0xFF2CE0D0),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Enter destination' : null,
      onChanged: _onTextChanged,
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
