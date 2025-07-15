// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:roambot/commons/widgets/customFontSize.dart';
// import 'package:roambot/screens/trip_details_screen.dart';
// import 'package:roambot/screens/trip_edit_screen.dart';
// import 'package:roambot/utils/constants.dart';
// import 'package:roambot/commons/widgets/custom_app_bar.dart';

// class MyTripsScreen extends StatefulWidget {
//   const MyTripsScreen({super.key});

//   @override
//   State<MyTripsScreen> createState() => _MyTripsScreenState();
// }

// class _MyTripsScreenState extends State<MyTripsScreen> {
//   String _searchQuery = '';
//   final DateTime _currentDate = DateTime.now();
//   bool _showCompletedTrips = true;
//   String _sortBy = 'date';
//   bool _sortAscending = true;

//   Future<void> _confirmDelete(BuildContext context, String tripId) async {
//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Delete Trip'),
//           content: const Text('Are you sure you want to delete this trip?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(false),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(true),
//               child: const Text('Delete', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete == true) {
//       await FirebaseFirestore.instance.collection('trips').doc(tripId).delete();
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Trip deleted successfully')),
//         );
//       }
//     }
//   }

//   Widget _buildSortButton() {
//     return IconButton(
//       icon: Icon(Icons.sort, color: Theme.of(context).primaryColor),
//       onPressed: () {
//         showModalBottomSheet(
//           context: context,
//           builder: (context) {
//             return Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ListTile(
//                   title: Text('Sort by Date', style: TextStyle(fontSize: 16)),
//                   trailing:
//                       _sortBy == 'date'
//                           ? Icon(
//                             _sortAscending
//                                 ? Icons.arrow_upward
//                                 : Icons.arrow_downward,
//                           )
//                           : null,
//                   onTap: () {
//                     setState(() {
//                       if (_sortBy == 'date') {
//                         _sortAscending = !_sortAscending;
//                       } else {
//                         _sortBy = 'date';
//                         _sortAscending = true;
//                       }
//                     });
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   title: const Text(
//                     'Sort by Budget',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   trailing:
//                       _sortBy == 'budget'
//                           ? Icon(
//                             _sortAscending
//                                 ? Icons.arrow_upward
//                                 : Icons.arrow_downward,
//                           )
//                           : null,
//                   onTap: () {
//                     setState(() {
//                       if (_sortBy == 'budget') {
//                         _sortAscending = !_sortAscending;
//                       } else {
//                         _sortBy = 'budget';
//                         _sortAscending = true;
//                       }
//                     });
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   title: const Text(
//                     'Sort by Destination',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   trailing:
//                       _sortBy == 'destination'
//                           ? Icon(
//                             _sortAscending
//                                 ? Icons.arrow_upward
//                                 : Icons.arrow_downward,
//                           )
//                           : null,
//                   onTap: () {
//                     setState(() {
//                       if (_sortBy == 'destination') {
//                         _sortAscending = !_sortAscending;
//                       } else {
//                         _sortBy = 'destination';
//                         _sortAscending = true;
//                       }
//                     });
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildTripCard(QueryDocumentSnapshot doc, {required bool isEditable}) {
//     final data = doc.data() as Map<String, dynamic>;
//     final startDate = (data['startDate'] as Timestamp).toDate();
//     final endDate = (data['endDate'] as Timestamp).toDate();
//     final dateRange =
//         '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}';
//     final isCompleted = endDate.isBefore(_currentDate);

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey.shade500, width: 1),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap:
//             () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => TripDetailsScreen(trip: data)),
//             ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       data['destination'] ?? '',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: isCompleted ? Colors.grey : Colors.black,
//                         fontSize: customFontSize(context, 20),
//                       ),
//                     ),
//                   ),
//                   if (isCompleted)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         'Completed',
//                         style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.calendar_today,
//                     size: 16,
//                     color: Colors.grey.shade600,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(dateRange, style: Theme.of(context).textTheme.bodySmall),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.currency_rupee,
//                     size: 16,
//                     color: Colors.grey.shade600,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     '₹${NumberFormat().format(data['budget'] is String ? double.tryParse(data['budget']) ?? 0 : data['budget'] ?? 0)}',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(Icons.people, size: 16, color: Colors.grey.shade600),
//                   const SizedBox(width: 8),
//                   Text(
//                     '${data['people']} people',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   if (isEditable)
//                     IconButton(
//                       icon: Icon(
//                         Icons.edit,
//                         size: 20,
//                         color: Colors.blue.shade600,
//                       ),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (_) =>
//                                     TripEditScreen(tripId: doc.id, trip: data),
//                           ),
//                         );
//                       },
//                     ),
//                   IconButton(
//                     icon: Icon(
//                       Icons.delete,
//                       size: 20,
//                       color: Colors.red.shade600,
//                     ),
//                     onPressed: () => _confirmDelete(context, doc.id),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<QueryDocumentSnapshot> _sortTrips(List<QueryDocumentSnapshot> trips) {
//     return trips..sort((a, b) {
//       final aData = a.data() as Map<String, dynamic>;
//       final bData = b.data() as Map<String, dynamic>;

//       switch (_sortBy) {
//         case 'date':
//           final aDate = (aData['startDate'] as Timestamp).toDate();
//           final bDate = (bData['startDate'] as Timestamp).toDate();
//           return _sortAscending
//               ? aDate.compareTo(bDate)
//               : bDate.compareTo(aDate);
//         case 'budget':
//           final aBudget =
//               aData['budget'] is String
//                   ? double.tryParse(aData['budget']) ?? 0
//                   : (aData['budget'] ?? 0).toDouble();
//           final bBudget =
//               bData['budget'] is String
//                   ? double.tryParse(bData['budget']) ?? 0
//                   : (bData['budget'] ?? 0).toDouble();
//           return _sortAscending
//               ? aBudget.compareTo(bBudget)
//               : bBudget.compareTo(aBudget);
//         case 'destination':
//           final aDest = (aData['destination'] ?? '').toString().toLowerCase();
//           final bDest = (bData['destination'] ?? '').toString().toLowerCase();
//           return _sortAscending
//               ? aDest.compareTo(bDest)
//               : bDest.compareTo(aDest);
//         default:
//           return 0;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: 'My Trips'),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 TextField(
//                   decoration: InputDecoration(
//                     hintText: 'Search trips...',
//                     prefixIcon: const Icon(Icons.search),
//                     filled: true,
//                     fillColor: Colors.grey.shade100,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       vertical: 0,
//                       horizontal: 16,
//                     ),
//                   ),
//                   onChanged:
//                       (value) =>
//                           setState(() => _searchQuery = value.toLowerCase()),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     FilterChip(
//                       label: const Text('Show Completed'),
//                       selected: _showCompletedTrips,
//                       onSelected:
//                           (value) =>
//                               setState(() => _showCompletedTrips = value),
//                       selectedColor: Theme.of(
//                         context,
//                       ).primaryColor.withOpacity(0.1),
//                       labelStyle: TextStyle(
//                         color:
//                             _showCompletedTrips
//                                 ? Theme.of(context).primaryColor
//                                 : Colors.grey,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     const Spacer(),
//                     _buildSortButton(),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream:
//                   FirebaseFirestore.instance
//                       .collection('trips')
//                       .where('userId', isEqualTo: currentUserId)
//                       .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.travel_explore,
//                           size: 64,
//                           color: Colors.grey.shade400,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No trips found',
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Add a new trip to get started',
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 final allTrips =
//                     snapshot.data!.docs.where((doc) {
//                       final data = doc.data() as Map<String, dynamic>;
//                       final destination =
//                           data['destination']?.toString().toLowerCase() ?? '';
//                       return destination.contains(_searchQuery);
//                     }).toList();

//                 final upcomingTrips = _sortTrips(
//                   allTrips.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final endDate = (data['endDate'] as Timestamp).toDate();
//                     return endDate.isAfter(_currentDate);
//                   }).toList(),
//                 );

//                 final completedTrips = _sortTrips(
//                   allTrips.where((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final endDate = (data['endDate'] as Timestamp).toDate();
//                     return !endDate.isAfter(_currentDate);
//                   }).toList(),
//                 );

//                 return RefreshIndicator(
//                   onRefresh: () async {
//                     // Force refresh the stream
//                     setState(() {});
//                   },
//                   child: ListView(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     children: [
//                       if (upcomingTrips.isNotEmpty) ...[
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 24),
//                           child: Text(
//                             'Upcoming Trips (${upcomingTrips.length})',
//                             style: Theme.of(
//                               context,
//                             ).textTheme.titleSmall?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                           ),
//                         ),
//                         ...upcomingTrips.map(
//                           (doc) => _buildTripCard(doc, isEditable: true),
//                         ),
//                       ],
//                       if (_showCompletedTrips && completedTrips.isNotEmpty) ...[
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 24),
//                           child: Text(
//                             'Completed Trips (${completedTrips.length})',
//                             style: Theme.of(
//                               context,
//                             ).textTheme.titleSmall?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ),
//                         ...completedTrips.map(
//                           (doc) => _buildTripCard(doc, isEditable: false),
//                         ),
//                       ],
//                       if (upcomingTrips.isEmpty && completedTrips.isEmpty)
//                         Center(
//                           child: Column(
//                             children: [
//                               Icon(
//                                 Icons.search_off,
//                                 size: 64,
//                                 color: Colors.grey.shade400,
//                               ),
//                               const SizedBox(height: 16),
//                               Text(
//                                 'No matching trips found',
//                                 style: Theme.of(context).textTheme.titleMedium,
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Replace the entire content of my_trips_screen.dart with this

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roambot/commons/widgets/customFontSize.dart';
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
  String _sortBy = 'date';
  bool _sortAscending = true;

  Future<void> _confirmDelete(BuildContext context, String tripId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Trip'),
          content: const Text('Are you sure you want to delete this trip?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await FirebaseFirestore.instance.collection('trips').doc(tripId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip deleted successfully')),
      );
    }
  }

  Widget _buildSortButton() {
    return IconButton(
      icon: Icon(Icons.sort, color: Theme.of(context).primaryColor),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Sort by Date', style: TextStyle(fontSize: 16)),
                  trailing:
                      _sortBy == 'date'
                          ? Icon(
                            _sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                          )
                          : null,
                  onTap: () {
                    setState(() {
                      if (_sortBy == 'date') {
                        _sortAscending = !_sortAscending;
                      } else {
                        _sortBy = 'date';
                        _sortAscending = true;
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                    'Sort by Budget',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing:
                      _sortBy == 'budget'
                          ? Icon(
                            _sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                          )
                          : null,
                  onTap: () {
                    setState(() {
                      if (_sortBy == 'budget') {
                        _sortAscending = !_sortAscending;
                      } else {
                        _sortBy = 'budget';
                        _sortAscending = true;
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                    'Sort by Destination',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing:
                      _sortBy == 'destination'
                          ? Icon(
                            _sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                          )
                          : null,
                  onTap: () {
                    setState(() {
                      if (_sortBy == 'destination') {
                        _sortAscending = !_sortAscending;
                      } else {
                        _sortBy = 'destination';
                        _sortAscending = true;
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
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
          final aBudget =
              (aData['budget'] is String)
                  ? double.tryParse(aData['budget']) ?? 0
                  : (aData['budget'] ?? 0).toDouble();
          final bBudget =
              (bData['budget'] is String)
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

  String _getCountdownText(DateTime startDate) {
    final difference = startDate.difference(DateTime.now());
    if (difference.isNegative) return 'Started';
    final days = difference.inDays;
    return days == 0
        ? 'Starts today!'
        : 'Starts in $days day${days > 1 ? 's' : ''}';
  }

  Widget _buildTripCard(
    QueryDocumentSnapshot doc,
    bool isEditable,
    GlassColors colors,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    final startDate = (data['startDate'] as Timestamp).toDate();
    final endDate = (data['endDate'] as Timestamp).toDate();
    final isCompleted = endDate.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.glassStart.withOpacity(0.6),
                  colors.glassEnd.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.glassBorder.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TripDetailsScreen(trip: data),
                    ),
                  ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.airplanemode_active, color: colors.icon),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            data['destination'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: colors.text,
                            ),
                          ),
                        ),
                        if (!isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getCountdownText(startDate),
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: colors.icon,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}',
                          style: TextStyle(color: colors.text.withOpacity(0.8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          size: 16,
                          color: colors.icon,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '₹${data['budget']}',
                          style: TextStyle(color: colors.text.withOpacity(0.8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: colors.icon),
                        const SizedBox(width: 6),
                        Text(
                          '${data['people']} people',
                          style: TextStyle(color: colors.text.withOpacity(0.8)),
                        ),
                      ],
                    ),
                    if (isEditable)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: colors.primary),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => TripEditScreen(
                                        tripId: doc.id,
                                        trip: data,
                                      ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red.shade400,
                            ),
                            onPressed: () => _confirmDelete(context, doc.id),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = GlassColors.dark();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: CustomAppBar(title: 'My Trips'),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('trips')
                .where('userId', isEqualTo: currentUserId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          final trips = snapshot.data?.docs ?? [];
          if (trips.isEmpty) {
            return Center(
              child: Text(
                'No trips found',
                style: TextStyle(color: colors.text.withOpacity(0.6)),
              ),
            );
          }

          final upcoming = _sortTrips(
            trips.where((doc) {
              final endDate = (doc['endDate'] as Timestamp).toDate();
              return endDate.isAfter(DateTime.now());
            }).toList(),
          );

          final completed = _sortTrips(
            trips.where((doc) {
              final endDate = (doc['endDate'] as Timestamp).toDate();
              return !endDate.isAfter(DateTime.now());
            }).toList(),
          );

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              if (upcoming.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Text(
                    'Upcoming Trips',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                ),
                ...upcoming.map((doc) => _buildTripCard(doc, true, colors)),
              ],
              if (_showCompletedTrips && completed.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Text(
                    'Completed Trips',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.text.withOpacity(0.6),
                    ),
                  ),
                ),
                ...completed.map((doc) => _buildTripCard(doc, false, colors)),
              ],
            ],
          );
        },
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
      appBar: const Color(0xFF4E8C87),
      primary: const Color(0xFF4E8C87),
      onPrimary: Colors.white,
      text: const Color(0xFF2D3748),
      icon: const Color(0xFF4E8C87),
      glassStart: const Color(0xFFA5D8D3),
      glassEnd: const Color(0xFFE2F3F0),
      glassBorder: Colors.white,
      glassButton: Colors.white,
      shadow: const Color(0xFF4A5568),
    );
  }
}
