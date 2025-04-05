import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roambot/services/gemini_services.dart';
import 'package:roambot/utils/constants.dart';
import 'package:roambot/widgets/custom_app_bar.dart';

class TripCreationScreen extends StatefulWidget {
  final bool isEdit;
  final String? tripId;
  final Map<String, dynamic>? existingTrip;

  const TripCreationScreen({
    Key? key,
    this.isEdit = false,
    this.tripId,
    this.existingTrip,
  }) : super(key: key);

  @override
  State<TripCreationScreen> createState() => _TripCreationScreenState();
}

class _TripCreationScreenState extends State<TripCreationScreen> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate
              ? (_startDate ?? DateTime.now())
              : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveTrip() async {
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
      ).showSnackBar(const SnackBar(content: Text('Please enter all fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isEdit && widget.tripId != null) {
        // Update existing trip
        await FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripId)
            .update({
              'destination': destination,
              'startDate': Timestamp.fromDate(_startDate!),
              'endDate': Timestamp.fromDate(_endDate!),
              'budget': budget,
              'people': people,
              'updatedAt': Timestamp.now(),
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip updated successfully!')),
        );
      } else {
        // Add new trip
        final docRef = await FirebaseFirestore.instance
            .collection('trips')
            .add({
              'userId': currentUserId,
              'destination': destination,
              'startDate': Timestamp.fromDate(_startDate!),
              'endDate': Timestamp.fromDate(_endDate!),
              'budget': budget,
              'people': people,
              'createdAt': Timestamp.now(),
              'itinerary': '',
            });

        final prompt = '''
      Generate a travel itinerary for a trip to $destination from ${DateFormat('MMM d, yyyy').format(_startDate!)} to ${DateFormat('MMM d, yyyy').format(_endDate!)}.
      The trip is for $people people with a total budget of ₹$budget.
      Keep the plan realistic, organized by day, and suggest activities and places accordingly.
      Avoid using hashtags (#) or asterisks (*).
      ''';

        final geminiService = GeminiService();
        final itinerary = await geminiService.generateTripPlan(prompt);

        await docRef.update({'itinerary': itinerary});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip and itinerary saved!')),
        );
      }

      Navigator.pop(context); // Go back to home screen
    } catch (e) {
      print('❌ Error generating itinerary: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Itinerary generation failed.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingTrip != null) {
      _destinationController.text = widget.existingTrip!['destination'] ?? '';
      _startDate = widget.existingTrip!['startDate']?.toDate();
      _endDate = widget.existingTrip!['endDate']?.toDate();
      _budgetController.text = widget.existingTrip!['budget']?.toString() ?? '';
      _peopleController.text = widget.existingTrip!['people']?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Plan a Trip'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                  children: [
                    TextField(
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => _pickDate(context, true),
                            child: Text(
                              _startDate == null
                                  ? 'Select Start Date'
                                  : 'Start: ${DateFormat('MMM d, yyyy').format(_startDate!)}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () => _pickDate(context, false),
                            child: Text(
                              _endDate == null
                                  ? 'Select End Date'
                                  : 'End: ${DateFormat('MMM d, yyyy').format(_endDate!)}',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Budget (in ₹)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _peopleController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Number of People',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveTrip,
                      child: const Text('Save Trip'),
                    ),
                  ],
                ),
      ),
    );
  }
}
