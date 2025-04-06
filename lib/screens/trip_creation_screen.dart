import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roambot/services/gemini_services.dart';
import 'package:roambot/utils/constants.dart';

class TripCreationScreen extends StatefulWidget {
  const TripCreationScreen({Key? key}) : super(key: key);

  @override
  State<TripCreationScreen> createState() => _TripCreationScreenState();
}

class _TripCreationScreenState extends State<TripCreationScreen> {
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _peopleController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
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
        if (isStartDate)
          _startDate = picked;
        else
          _endDate = picked;
      });
    }
  }

  Future<void> _saveTrip() async {
    final destination = _destinationController.text.trim();
    final budget = _budgetController.text.trim();
    final people = _peopleController.text.trim();

    if (destination.isEmpty ||
        budget.isEmpty ||
        people.isEmpty ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter all fields')));
      return;
    }

    setState(() => _isLoading = true);

    final prompt =
        "Plan a trip to $destination from ${DateFormat.yMMMd().format(_startDate!)} to ${DateFormat.yMMMd().format(_endDate!)} for $people people with a budget of ₹$budget.";

    try {
      final gemini = GeminiService();
      final itinerary = await gemini.generateTripPlan(prompt);

      await FirebaseFirestore.instance.collection('trips').add({
        'userId': currentUserId,
        'destination': destination,
        'startDate': _startDate,
        'endDate': _endDate,
        'budget': budget,
        'people': people,
        'itinerary': itinerary,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Trip saved successfully!')));
      Navigator.pop(context);
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error saving trip')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan Trip')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(labelText: 'Destination'),
            ),
            TextField(
              controller: _budgetController,
              decoration: const InputDecoration(labelText: 'Budget'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _peopleController,
              decoration: const InputDecoration(labelText: 'Number of People'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _pickDate(context, true),
                    child: Text(
                      _startDate == null
                          ? 'Pick Start Date'
                          : DateFormat.yMMMd().format(_startDate!),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => _pickDate(context, false),
                    child: Text(
                      _endDate == null
                          ? 'Pick End Date'
                          : DateFormat.yMMMd().format(_endDate!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: _saveTrip,
                  child: const Text('Save Trip'),
                ),
          ],
        ),
      ),
    );
  }
}
