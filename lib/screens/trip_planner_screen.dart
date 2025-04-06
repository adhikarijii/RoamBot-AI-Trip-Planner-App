import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roambot/screens/trip_details_screen.dart';
import 'package:roambot/utils/constants.dart';
import 'package:intl/intl.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({Key? key}) : super(key: key);

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  List<DocumentSnapshot> _allTrips = [];
  List<DocumentSnapshot> _filteredTrips = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
    _searchController.addListener(_filterTrips);
  }

  Future<void> _fetchTrips() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('trips')
            .where('userId', isEqualTo: currentUserId)
            .orderBy('createdAt', descending: true)
            .get();
    setState(() {
      _allTrips = snapshot.docs;
      _filteredTrips = _allTrips;
      _isLoading = false;
    });
  }

  void _filterTrips() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTrips =
          _allTrips.where((doc) {
            final dest = (doc['destination'] ?? '').toString().toLowerCase();
            return dest.contains(query);
          }).toList();
    });
  }

  Future<void> _deleteTrip(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Delete'),
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
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('trips').doc(id).delete();
      _fetchTrips();
    }
  }

  void _showTripDetails(DocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => TripDetailsScreen(trip: doc.data() as Map<String, dynamic>),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search destination...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        _filteredTrips.isEmpty
                            ? const Center(child: Text('No trips found.'))
                            : ListView.builder(
                              itemCount: _filteredTrips.length,
                              itemBuilder: (_, index) {
                                final trip = _filteredTrips[index];
                                final startDate =
                                    (trip['startDate'] as Timestamp).toDate();
                                final endDate =
                                    (trip['endDate'] as Timestamp).toDate();
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: ListTile(
                                    onTap: () => _showTripDetails(trip),
                                    title: Text(
                                      trip['destination'] ?? 'Unknown',
                                    ),
                                    subtitle: Text(
                                      '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}\n'
                                      'Budget: ₹${trip['budget']} | People: ${trip['people']}',
                                    ),
                                    isThreeLine: true,
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteTrip(trip.id),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
