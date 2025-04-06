import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roambot/screens/trip_creation_screen.dart';
import 'package:roambot/screens/trip_details_screen.dart';
import 'package:roambot/utils/constants.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({Key? key}) : super(key: key);

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  List<Map<String, dynamic>> _allTrips = [];
  List<Map<String, dynamic>> _filteredTrips = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    setState(() => _isLoading = true);

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('trips')
              .where('userId', isEqualTo: currentUserId)
              .orderBy('createdAt', descending: true)
              .get();

      final trips =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      setState(() {
        _allTrips = trips;
        _applySearch();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching trips: $e');
      setState(() => _isLoading = false);
    }
  }

  void _applySearch() {
    setState(() {
      _filteredTrips =
          _searchQuery.isEmpty
              ? _allTrips
              : _allTrips
                  .where(
                    (trip) => trip['destination']
                        .toString()
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()),
                  )
                  .toList();
    });
  }

  Future<void> _confirmDelete(String tripId) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Trip'),
            content: const Text('Are you sure you want to delete this trip?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (result == true) {
      await FirebaseFirestore.instance.collection('trips').doc(tripId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Trip deleted')));
      _fetchTrips();
    }
  }

  void _editTrip(Map<String, dynamic> tripData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TripCreationScreen(key: UniqueKey())),
    ).then((_) => _fetchTrips());
  }

  void _openTripDetails(Map<String, dynamic> trip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TripDetailsScreen(trip: trip)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchTrips),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search destination...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _applySearch();
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredTrips.isEmpty
                      ? const Center(child: Text('No trips found.'))
                      : ListView.builder(
                        itemCount: _filteredTrips.length,
                        itemBuilder: (_, index) {
                          final trip = _filteredTrips[index];
                          final destination = trip['destination'];
                          final startDate = _formatDate(trip['startDate']);
                          final endDate = _formatDate(trip['endDate']);
                          final budget = trip['budget'] ?? 'N/A';

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              title: Text(
                                destination,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('From: $startDate'),
                                  Text('To: $endDate'),
                                  Text('Budget: ₹$budget'),
                                ],
                              ),
                              onTap: () => _openTripDetails(trip),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _editTrip(trip),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _confirmDelete(trip['id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TripCreationScreen()),
          );
          _fetchTrips();
        },
        label: const Text('Plan Trip'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat.yMMMd().format(date.toDate());
    } else if (date is DateTime) {
      return DateFormat.yMMMd().format(date);
    }
    return 'Invalid date';
  }
}
