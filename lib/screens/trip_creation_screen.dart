// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:roambot/services/gemini_services.dart';
// import 'package:roambot/utils/constants.dart';
// import 'package:roambot/commons/widgets/custom_app_bar.dart';

// class TripCreationScreen extends StatefulWidget {
//   const TripCreationScreen({Key? key}) : super(key: key);

//   @override
//   State<TripCreationScreen> createState() => _TripCreationScreenState();
// }

// class _TripCreationScreenState extends State<TripCreationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _destinationController = TextEditingController();
//   final TextEditingController _budgetController = TextEditingController();
//   final TextEditingController _peopleController = TextEditingController();

//   DateTime? _startDate;
//   DateTime? _endDate;
//   String? _generatedItinerary;
//   bool _isLoading = false;

//   Future<void> _pickDate(BuildContext context, bool isStartDate) async {
//     final initialDate =
//         isStartDate
//             ? (_startDate ?? DateTime.now())
//             : (_endDate ?? (_startDate ?? DateTime.now()));
//     final firstDate =
//         isStartDate ? DateTime.now() : (_startDate ?? DateTime.now());
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: firstDate,
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStartDate) {
//           _startDate = picked;
//           if (_endDate != null && _endDate!.isBefore(picked)) {
//             _endDate = null;
//           }
//         } else {
//           _endDate = picked;
//         }
//       });
//     }
//   }

//   String cleanAndFormatItinerary(String itinerary) {
//     return itinerary
//         // Convert markdown headings to readable sections
//         .replaceAllMapped(
//           RegExp(r'^#+\s+(.*)', multiLine: true),
//           (match) =>
//               '\n${match.group(1)?.toUpperCase()}\n${'-' * (match.group(1)?.length ?? 0)}\n',
//         )
//         // Convert lists to bullet points
//         .replaceAllMapped(
//           RegExp(r'^\s*[\-*+]\s+(.*)', multiLine: true),
//           (match) => '• ${match.group(1)}',
//         )
//         // Clean other markdown
//         .replaceAll('**', '')
//         .replaceAll('__', '')
//         .replaceAll(RegExp(r'`{1,3}'), '')
//         .replaceAllMapped(
//           RegExp(r'\[(.*?)\]\(.*?\)'),
//           (match) => match.group(1) ?? '',
//         )
//         .replaceAll(RegExp(r'\n{3,}'), '\n\n')
//         .trim();
//   }

//   Future<void> _generateAndSaveTrip() async {
//     if (_formKey.currentState == null ||
//         !_formKey.currentState!.validate() ||
//         _startDate == null ||
//         _endDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill all fields and select dates'),
//         ),
//       );
//       return;
//     }

//     final destination = _destinationController.text.trim();
//     final budget = _budgetController.text.trim();
//     final people = _peopleController.text.trim();

//     setState(() => _isLoading = true);

//     //     final prompt = '''
//     // Create a detailed itinerary for a trip to $destination from ${DateFormat('MMMM d, yyyy').format(_startDate!)} to ${DateFormat('MMMM d, yyyy').format(_endDate!)}.
//     // The budget is ₹$budget and number of people going is $people. Break the itinerary day-wise and include places to visit, activities, and estimated time. And also include the contact details of local Hotel, homestay owners.
//     // ''';
//     final prompt = '''
// Create a comprehensive, day-by-day travel itinerary for a trip to $destination from ${DateFormat('MMMM d, yyyy').format(_startDate!)} to ${DateFormat('MMMM d, yyyy').format(_endDate!)} for $people people with a budget of ₹$budget.

// Please structure the itinerary with the following details for each day:
// 1. Day number and date (format: "Day 1: Monday, June 10, 2024")
// 2. Morning, afternoon, and evening activities with time slots
// 3. Key attractions to visit with brief descriptions (50 words max each)
// 4. Recommended dining options (breakfast, lunch, dinner) with price ranges
// 5. Transportation options between locations with estimated costs
// 6. Estimated daily expenditure breakdown
// 7. Travel tips and precautions for the day

// Additional required information:
// - Contact details of 2-3 recommended hotels/homestays with price ranges
// - Emergency contacts (local police, hospital, embassy)
// - Packing suggestions based on the destination and season
// - Cultural norms/etiquette to be aware of
// - Budget-saving tips specific to the location

// Formatting guidelines:
// - Use clear section headings (## Day 1 ##)
// - Separate different elements with blank lines
// - Use bullet points for lists
// - Bold important information like **Budget tip:**
// - Keep time estimates in 24-hour format (e.g., 14:00-15:30)
// - Include approximate walking distances/times between nearby attractions

// Make the itinerary practical, realistic, and optimized for time and budget constraints. Prioritize must-see attractions while allowing for adequate rest time.
// ''';

//     try {
//       final itinerary = await GeminiService().generateTripPlan(prompt);
//       // final cleanedItinerary = itinerary.replaceAll(RegExp(r'[#*`_]'), '');
//       final cleanedItinerary = cleanAndFormatItinerary(itinerary);

//       setState(() {
//         _generatedItinerary = cleanedItinerary;
//         _isLoading = false;
//       });

//       _showItineraryPreviewDialog(cleanedItinerary);
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to generate itinerary: ${e.toString()}'),
//         ),
//       );
//     }
//   }

//   Future<void> _showItineraryPreviewDialog(String itinerary) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             insetPadding: const EdgeInsets.all(16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             title: const Text('Itinerary Preview'),
//             content: SizedBox(
//               height: MediaQuery.of(context).size.height * 0.5,
//               width: double.maxFinite,
//               child: SingleChildScrollView(child: Text(itinerary)),
//             ),
//             actionsAlignment: MainAxisAlignment.spaceBetween,
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Edit'),
//               ),
//               FilledButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _saveTrip();
//                 },
//                 child: const Text('Save Trip'),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _saveTrip() async {
//     try {
//       await FirebaseFirestore.instance.collection('trips').add({
//         'userId': currentUserId,
//         'destination': _destinationController.text.trim(),
//         'startDate': Timestamp.fromDate(_startDate!),
//         'endDate': Timestamp.fromDate(_endDate!),
//         'budget': _budgetController.text.trim(),
//         'people': _peopleController.text.trim(),
//         'createdAt': Timestamp.now(),
//         'itinerary': _generatedItinerary ?? '',
//       });

//       if (mounted) {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder:
//               (ctx) => AlertDialog(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 title: const Text('Success'),
//                 content: const Text('Trip has been saved successfully!'),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(ctx).pop();
//                       Navigator.of(context).pop(); // Pop TripCreationScreen
//                     },
//                     child: const Text('OK'),
//                   ),
//                 ],
//               ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Failed to save trip')));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(title: 'Plan a Trip'),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Form(
//                   key: _formKey,
//                   child: Padding(
//                     padding: const EdgeInsets.all(10),
//                     child: Column(
//                       children: [
//                         // Your form fields here
//                         TextFormField(
//                           controller: _destinationController,
//                           decoration: InputDecoration(
//                             labelText: 'Destination',
//                             prefixIcon: const Icon(Icons.location_on),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           validator:
//                               (value) =>
//                                   value == null || value.isEmpty
//                                       ? 'Enter destination'
//                                       : null,
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: OutlinedButton.icon(
//                                 onPressed: () => _pickDate(context, true),
//                                 icon: const Icon(Icons.calendar_today),
//                                 label: Text(
//                                   _startDate == null
//                                       ? 'Start Date'
//                                       : DateFormat(
//                                         'MMM d, yyyy',
//                                       ).format(_startDate!),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: OutlinedButton.icon(
//                                 onPressed:
//                                     _startDate == null
//                                         ? null
//                                         : () => _pickDate(context, false),
//                                 icon: const Icon(Icons.calendar_month),
//                                 label: Text(
//                                   _endDate == null
//                                       ? 'End Date'
//                                       : DateFormat(
//                                         'MMM d, yyyy',
//                                       ).format(_endDate!),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _budgetController,
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                             labelText: 'Budget (₹)',
//                             prefixIcon: const Icon(Icons.currency_rupee),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           validator:
//                               (value) =>
//                                   value == null || value.isEmpty
//                                       ? 'Enter budget'
//                                       : null,
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _peopleController,
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                             labelText: 'Number of People',
//                             prefixIcon: const Icon(Icons.people),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           validator:
//                               (value) =>
//                                   value == null || value.isEmpty
//                                       ? 'Enter number of people'
//                                       : null,
//                         ),
//                         const SizedBox(height: 24),
//                         FilledButton.icon(
//                           icon: const Icon(Icons.flight_takeoff),
//                           label: const Text('Generate Itinerary'),
//                           onPressed: _generateAndSaveTrip,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//     );
//   }
// }

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:roambot/services/gemini_services.dart';
import 'package:roambot/utils/constants.dart';
import 'package:roambot/commons/widgets/custom_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class TripCreationScreen extends StatefulWidget {
  const TripCreationScreen({Key? key}) : super(key: key);

  @override
  State<TripCreationScreen> createState() => _TripCreationScreenState();
}

class _TripCreationScreenState extends State<TripCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _generatedItinerary;
  bool _isLoading = false;

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
    return itinerary
        // Convert markdown headings to readable sections
        .replaceAllMapped(
          RegExp(r'^#+\s+(.*)', multiLine: true),
          (match) =>
              '\n${match.group(1)?.toUpperCase()}\n${'-' * (match.group(1)?.length ?? 0)}\n',
        )
        // Convert lists to bullet points
        .replaceAllMapped(
          RegExp(r'^\s*[\-*+]\s+(.*)', multiLine: true),
          (match) => '• ${match.group(1)}',
        )
        // Clean other markdown
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll(RegExp(r'`{1,3}'), '')
        .replaceAllMapped(
          RegExp(r'\[(.*?)\]\(.*?\)'),
          (match) => match.group(1) ?? '',
        )
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
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

    final destination = _destinationController.text.trim();
    final budget = _budgetController.text.trim();
    final people = _peopleController.text.trim();

    setState(() => _isLoading = true);

    final prompt = '''
Create a comprehensive, day-by-day travel itinerary for a trip to $destination from ${DateFormat('MMMM d, yyyy').format(_startDate!)} to ${DateFormat('MMMM d, yyyy').format(_endDate!)} for $people people with a budget of ₹$budget.

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
• [Hotel/Homestay Name] - [Price range], [Contact info], [Brief description]
• [Second Option] - [Details]

## Travel Tips ##
• [Tip 1]
• [Tip 2]

## Emergency Contacts ##
• Police: [Number]
• Hospital: [Number]

Include relevant emojis in the response where appropriate (🏨 for hotels, 🚗 for transport, etc.).
''';

    try {
      final itinerary = await GeminiService().generateTripPlan(prompt);
      final cleanedItinerary = cleanAndFormatItinerary(itinerary);

      setState(() {
        _generatedItinerary = cleanedItinerary;
        _isLoading = false;
      });

      _showItineraryPreviewDialog(cleanedItinerary);
    } catch (e) {
      setState(() => _isLoading = false);
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
            insetPadding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Your Trip Itinerary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: ItineraryDisplayWidget(
                          itinerary: itinerary,
                          destination: _destinationController.text.trim(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
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
                  ],
                ),
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
        'Check out my trip itinerary to ${_destinationController.text.trim()}:\n\n$itinerary',
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
        'destination': _destinationController.text.trim(),
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
    return Scaffold(
      appBar: const CustomAppBar(title: 'Plan a Trip'),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _destinationController,
                          decoration: InputDecoration(
                            labelText: 'Destination',
                            prefixIcon: const Icon(Icons.location_on),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter destination'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickDate(context, true),
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  _startDate == null
                                      ? 'Start Date'
                                      : DateFormat(
                                        'MMM d, yyyy',
                                      ).format(_startDate!),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    _startDate == null
                                        ? null
                                        : () => _pickDate(context, false),
                                icon: const Icon(Icons.calendar_month),
                                label: Text(
                                  _endDate == null
                                      ? 'End Date'
                                      : DateFormat(
                                        'MMM d, yyyy',
                                      ).format(_endDate!),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Budget (₹)',
                            prefixIcon: const Icon(Icons.currency_rupee),
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
                          decoration: InputDecoration(
                            labelText: 'Number of People',
                            prefixIcon: const Icon(Icons.people),
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
              ),
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
        _buildDestinationHeader(context),
        const SizedBox(height: 16),
        ...sections.map((section) => _buildItinerarySection(section)),
      ],
    );
  }

  Widget _buildDestinationHeader(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            _getDestinationImageUrl(destination),
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              destination,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
                      if (activity['image'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: activity['image']!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                            ),
                          ),
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
            'image': _getPlaceImageUrl(parts[1].trim()),
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

  String _getDestinationImageUrl(String destination) {
    return 'https://source.unsplash.com/800x400/?$destination,tourism';
  }

  String _getPlaceImageUrl(String place) {
    return 'https://source.unsplash.com/400x200/?${place.split(' ').first},landmark';
  }
}
