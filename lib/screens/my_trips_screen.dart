import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roambot/screens/trip_details_screen.dart';
import 'package:roambot/screens/trip_edit_screen.dart';
import 'package:roambot/utils/constants.dart';
import 'package:roambot/commons/widgets/custom_app_bar.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  String _searchQuery = '';
  final DateTime _currentDate = DateTime.now();
  bool _showCompletedTrips = true;
  String _sortBy = 'date'; // 'date', 'budget', 'destination'
  bool _sortAscending = true;

  Future<void> _confirmDelete(BuildContext context, String tripId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Trip'),
          content: const Text('Are you sure you want to delete this trip?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Confirm delete
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await FirebaseFirestore.instance.collection('trips').doc(tripId).delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip deleted successfully')),
        );
      }
    }
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      onSelected: (value) {
        setState(() {
          if (_sortBy == value) {
            _sortAscending = !_sortAscending;
          } else {
            _sortBy = value;
            _sortAscending = true;
          }
        });
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'date',
              child: Row(
                children: [
                  Icon(_sortBy == 'date' ? Icons.check : null),
                  const Text('Sort by Date'),
                  if (_sortBy == 'date')
                    Icon(
                      _sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                    ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'budget',
              child: Row(
                children: [
                  Icon(_sortBy == 'budget' ? Icons.check : null),
                  const Text('Sort by Budget'),
                  if (_sortBy == 'budget')
                    Icon(
                      _sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                    ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'destination',
              child: Row(
                children: [
                  Icon(_sortBy == 'destination' ? Icons.check : null),
                  const Text('Sort by Destination'),
                  if (_sortBy == 'destination')
                    Icon(
                      _sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                    ),
                ],
              ),
            ),
          ],
    );
  }

  Widget _buildFilterChip() {
    return FilterChip(
      label: const Text('Show Completed'),
      selected: _showCompletedTrips,
      onSelected: (value) => setState(() => _showCompletedTrips = value),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Text(
            '$title ($count)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(),
          if (title == 'Upcoming Trips') _buildSortButton(),
        ],
      ),
    );
  }

  // Widget _buildTripStatusBadge(DateTime startDate, DateTime endDate) {
  //   final now = DateTime.now();
  //   if (now.isAfter(startDate) && now.isBefore(endDate)) {
  //     return Chip(
  //       label: const Text('ONGOING'),
  //       backgroundColor: Colors.orange.withOpacity(0.2),
  //       labelStyle: const TextStyle(color: Colors.orange),
  //     );
  //   } else if (now.isAfter(endDate)) {
  //     return Chip(
  //       label: const Text('COMPLETED'),
  //       backgroundColor: Colors.green.withOpacity(0.2),
  //       labelStyle: const TextStyle(color: Colors.green),
  //     );
  //   }
  //   return Chip(
  //     label: const Text('UPCOMING'),
  //     backgroundColor: Colors.blue.withOpacity(0.2),
  //     labelStyle: const TextStyle(color: Colors.blue),
  //   );
  // }

  Widget _buildTripCard(QueryDocumentSnapshot doc, {required bool isEditable}) {
    final data = doc.data() as Map<String, dynamic>;
    final startDate = (data['startDate'] as Timestamp).toDate();
    final endDate = (data['endDate'] as Timestamp).toDate();
    final dateRange =
        '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}';

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        title: Row(
          children: [
            Expanded(
              child: Text(
                data['destination'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                  color: isEditable ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
            // _buildTripStatusBadge(startDate, endDate),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text('Dates: $dateRange'),
            Text(
              'Budget: ₹${NumberFormat().format(data['budget'] is String ? double.tryParse(data['budget']) ?? 0 : data['budget'] ?? 0)}',
            ),
            Text('People: ${data['people']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEditable)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                padding: const EdgeInsets.all(8),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => TripEditScreen(tripId: doc.id, trip: data),
                    ),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              padding: const EdgeInsets.all(8),
              onPressed: () => _confirmDelete(context, doc.id),
            ),
          ],
        ),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TripDetailsScreen(trip: data)),
            ),
      ),
    );
  }

  List<QueryDocumentSnapshot> _sortTrips(List<QueryDocumentSnapshot> trips) {
    return trips..sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      switch (_sortBy) {
        case 'date':
          final aDate = (aData['startDate'] as Timestamp).toDate();
          final bDate = (bData['startDate'] as Timestamp).toDate();
          return _sortAscending
              ? aDate.compareTo(bDate)
              : bDate.compareTo(aDate);
        case 'budget':
          // Handle both string and numeric budget values
          final aBudget =
              aData['budget'] is String
                  ? double.tryParse(aData['budget']) ?? 0
                  : (aData['budget'] ?? 0).toDouble();
          final bBudget =
              bData['budget'] is String
                  ? double.tryParse(bData['budget']) ?? 0
                  : (bData['budget'] ?? 0).toDouble();
          return _sortAscending
              ? aBudget.compareTo(bBudget)
              : bBudget.compareTo(aBudget);
        case 'destination':
          final aDest = (aData['destination'] ?? '').toString().toLowerCase();
          final bDest = (bData['destination'] ?? '').toString().toLowerCase();
          return _sortAscending
              ? aDest.compareTo(bDest)
              : bDest.compareTo(aDest);
        default:
          return 0;
      }
    });
  }

  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: _sortBy,
      icon: const Icon(Icons.sort),
      underline: Container(),
      items: [
        DropdownMenuItem(
          value: 'date',
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: 8),
              Text(
                'Date ${_sortBy == 'date'
                    ? _sortAscending
                        ? '↑'
                        : '↓'
                    : ''}',
              ),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'budget',
          child: Row(
            children: [
              const Icon(Icons.attach_money, size: 18),
              const SizedBox(width: 8),
              Text(
                'Budget ${_sortBy == 'budget'
                    ? _sortAscending
                        ? '↑'
                        : '↓'
                    : ''}',
              ),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'destination',
          child: Row(
            children: [
              const Icon(Icons.location_on, size: 18),
              const SizedBox(width: 8),
              Text(
                'Destination ${_sortBy == 'destination'
                    ? _sortAscending
                        ? '↑'
                        : '↓'
                    : ''}',
              ),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          if (_sortBy == value) {
            _sortAscending = !_sortAscending;
          } else {
            _sortBy = value!;
            _sortAscending = true;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'My Trips'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search trips by destination...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged:
                      (value) =>
                          setState(() => _searchQuery = value.toLowerCase()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildFilterChip(),
                    const Spacer(),
                    // const SizedBox(width: 8),
                    _buildSortDropdown(),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('trips')
                      .where('userId', isEqualTo: currentUserId)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No trips found.'));
                }

                // Filter trips
                final allTrips =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final destination =
                          data['destination']?.toString().toLowerCase() ?? '';
                      return destination.contains(_searchQuery);
                    }).toList();

                // Categorize trips
                final upcomingTrips = _sortTrips(
                  allTrips.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final endDate = (data['endDate'] as Timestamp).toDate();
                    return endDate.isAfter(_currentDate);
                  }).toList(),
                );

                final completedTrips = _sortTrips(
                  allTrips.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final endDate = (data['endDate'] as Timestamp).toDate();
                    return !endDate.isAfter(_currentDate);
                  }).toList(),
                );

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    // Upcoming Trips Section
                    if (upcomingTrips.isNotEmpty)
                      _buildSectionHeader(
                        'Upcoming Trips',
                        upcomingTrips.length,
                      ),
                    ...upcomingTrips.map(
                      (doc) => _buildTripCard(doc, isEditable: true),
                    ),

                    // Completed Trips Section
                    if (_showCompletedTrips && completedTrips.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Completed Trips',
                        completedTrips.length,
                      ),
                      ...completedTrips.map(
                        (doc) => _buildTripCard(doc, isEditable: false),
                      ),
                    ],

                    // Empty states
                    if (upcomingTrips.isEmpty && completedTrips.isEmpty)
                      const Center(child: Text('No matching trips found.')),
                    if (upcomingTrips.isEmpty &&
                        _showCompletedTrips &&
                        completedTrips.isNotEmpty)
                      const Center(child: Text('No upcoming trips found.')),
                    if (!_showCompletedTrips && upcomingTrips.isEmpty)
                      const Center(child: Text('No upcoming trips found.')),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
