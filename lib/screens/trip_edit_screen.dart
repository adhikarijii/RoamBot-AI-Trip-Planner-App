import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roambot/services/gemini_services.dart';
import 'package:roambot/commons/widgets/custom_app_bar.dart';

class TripEditScreen extends StatefulWidget {
  final String tripId;
  final Map<String, dynamic> trip;

  const TripEditScreen({super.key, required this.tripId, required this.trip});

  @override
  State<TripEditScreen> createState() => _TripEditScreenState();
}

class _TripEditScreenState extends State<TripEditScreen> {
  late TextEditingController _destinationController;
  late TextEditingController _budgetController;
  late TextEditingController _peopleController;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _itinerary;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController(
      text: widget.trip['destination'],
    );
    _budgetController = TextEditingController(text: widget.trip['budget']);
    _peopleController = TextEditingController(text: widget.trip['people']);
    _startDate = (widget.trip['startDate'] as Timestamp).toDate();
    _endDate = (widget.trip['endDate'] as Timestamp).toDate();
    _itinerary = widget.trip['itinerary'];
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate! : _endDate!;
    final firstDate = isStart ? DateTime.now() : _startDate!;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
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

  Future<void> _regenerateItinerary() async {
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
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    final prompt = '''
Regenerate a detailed itinerary for a trip to $destination from ${DateFormat('MMMM d, yyyy').format(_startDate!)} to ${DateFormat('MMMM d, yyyy').format(_endDate!)}.
The budget is ₹$budget and number of people going is $people. Break the itinerary day-wise and include places to visit, activities, and estimated time. And also include the contact details of local Hotel, homestay owners. 
''';

    try {
      final response = await GeminiService().generateTripPlan(prompt);
      final cleaned = response.replaceAll(RegExp(r'[#*`_~>-]'), '');

      setState(() {
        _itinerary = cleaned;
        _isLoading = false;
      });

      _showItineraryPreviewDialog(cleaned);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate itinerary')),
      );
    }
  }

  void _showItineraryPreviewDialog(String itinerary) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            insetPadding: const EdgeInsets.all(16),
            title: const Text('Preview New Itinerary'),
            content: SingleChildScrollView(child: Text(itinerary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Edit'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await _saveChanges();
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
    );
  }

  Future<void> _saveChanges() async {
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .update({
            'destination': _destinationController.text.trim(),
            'startDate': Timestamp.fromDate(_startDate!),
            'endDate': Timestamp.fromDate(_endDate!),
            'budget': _budgetController.text.trim(),
            'people': _peopleController.text.trim(),
            'itinerary': _itinerary ?? '',
          });

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Trip updated successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save changes')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Edit Trip'),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TextField(
                        controller: _destinationController,
                        decoration: InputDecoration(
                          labelText: 'Destination',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _startDate == null
                                    ? 'Start Date'
                                    : DateFormat(
                                      'MMM d, yyyy',
                                    ).format(_startDate!),
                              ),
                              onPressed: () => _pickDate(context, true),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.event),
                              label: Text(
                                _endDate == null
                                    ? 'End Date'
                                    : DateFormat(
                                      'MMM d, yyyy',
                                    ).format(_endDate!),
                              ),
                              onPressed:
                                  _startDate == null
                                      ? null
                                      : () => _pickDate(context, false),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Budget (₹)',
                          prefixIcon: const Icon(Icons.currency_rupee_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _peopleController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'People',
                          prefixIcon: const Icon(Icons.people_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: ElevatedButton.icon(
                      //     icon: const Icon(Icons.auto_fix_high_outlined),
                      //     label: const Text('Regenerate Itinerary'),
                      //     style: ElevatedButton.styleFrom(
                      //       padding: const EdgeInsets.symmetric(vertical: 14),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //     ),
                      //     onPressed: _regenerateItinerary,
                      //   ),
                      // ),
                      FilledButton.icon(
                        icon: const Icon(Icons.auto_fix_high_outlined),
                        label: const Text('Regenerate Itinerary'),
                        onPressed: _regenerateItinerary,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
