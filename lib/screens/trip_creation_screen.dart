import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roambot/services/gemini_services.dart';
import 'package:roambot/utils/constants.dart';
import 'package:roambot/commons/widgets/custom_app_bar.dart';

class TripCreationScreen extends StatefulWidget {
  const TripCreationScreen({Key? key}) : super(key: key);

  @override
  State<TripCreationScreen> createState() => _TripCreationScreenState();
}

class _TripCreationScreenState extends State<TripCreationScreen> {
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

  Future<void> _generateAndSaveTrip() async {
    final destination = _destinationController.text.trim();
    final budget = _budgetController.text.trim();
    final people = _peopleController.text.trim();

    if (destination.isEmpty ||
        _startDate == null ||
        _endDate == null ||
        budget.isEmpty ||
        people.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    final prompt = '''
Create a detailed itinerary for a trip to $destination from ${DateFormat('MMMM d, yyyy').format(_startDate!)} to ${DateFormat('MMMM d, yyyy').format(_endDate!)}.
The budget is ₹$budget and number of people going is $people. Break the itinerary day-wise and include places to visit, activities, and estimated time.
''';

    try {
      final itinerary = await GeminiService().generateTripPlan(prompt);

      // Clean unwanted symbols
      final cleanedItinerary = itinerary.replaceAll(RegExp(r'[#*`_~>-]'), '');

      setState(() {
        _generatedItinerary = cleanedItinerary;
        _isLoading = false;
      });
      _showItineraryPreviewDialog(cleanedItinerary);
    } catch (e) {
      setState(() => _isLoading = false);
      print("Itinerary generation error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate itinerary')),
      );
    }
  }

  Future<void> _showItineraryPreviewDialog(String itinerary) async {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Itinerary Preview'),
            content: SingleChildScrollView(child: Text(itinerary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Edit'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _saveTrip();
                },
                child: const Text('Save Trip'),
              ),
            ],
          ),
    );
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

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Trip has been saved successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      print('Error saving trip: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save trip')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ('Plan a Trip')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _pickDate(context, true),
                            icon: const Icon(Icons.date_range),
                            label: Text(
                              _startDate == null
                                  ? 'Select Start Date'
                                  : DateFormat(
                                    'MMM d, yyyy',
                                  ).format(_startDate!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton.icon(
                            onPressed:
                                _startDate == null
                                    ? null
                                    : () => _pickDate(context, false),
                            icon: const Icon(Icons.date_range_outlined),
                            label: Text(
                              _endDate == null
                                  ? 'Select End Date'
                                  : DateFormat('MMM d, yyyy').format(_endDate!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Budget (₹)',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _peopleController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Number of People',
                        prefixIcon: Icon(Icons.people),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.flight_takeoff_sharp),
                      label: const Text('Plan Trip'),
                      onPressed: _generateAndSaveTrip,
                    ),
                  ],
                ),
              ),
    );
  }
}
