import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:roambot/commons/widgets/customConfirmationBox.dart'
    show customConfirmationBox;
import 'package:roambot/screens/upcoming_trips_screen.dart';
import 'package:roambot/screens/detail_itinerary.dart';
import 'package:roambot/screens/fb_page.dart';
import 'package:roambot/screens/popular_itineraries.dart';
import 'package:roambot/screens/profile_screen.dart';
import 'package:roambot/screens/trip_creation_screen.dart';
import 'package:roambot/screens/my_trips_screen.dart';
import 'package:roambot/screens/trip_details_screen.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String? name;
  String? photoUrl;
  String? travelQuote;
  late AnimationController _animationController;
  int _currentCarouselIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _loadProfile();
    // _loadTravelQuote();
    // _startCarouselTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // void _startCarouselTimer() {
  //   Future.delayed(const Duration(seconds: 5), () {
  //     if (_pageController.hasClients) {
  //       if (_currentCarouselIndex < 2) {
  //         _pageController.nextPage(
  //           duration: const Duration(milliseconds: 500),
  //           curve: Curves.easeInOut,
  //         );
  //       } else {
  //         _pageController.animateToPage(
  //           0,
  //           duration: const Duration(milliseconds: 500),
  //           curve: Curves.easeInOut,
  //         );
  //       }
  //       _startCarouselTimer();
  //     }
  //   });
  // }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          name = data['name'] ?? 'Explorer';
          photoUrl = data['photoUrl'];
        });
      }
    }
  }

  // Future<void> _loadTravelQuote() async {
  //   final prompt = "Give me an inspiring travel quote less than 15 words";
  //   final response = await GeminiService().generateTripPlan(prompt);
  //   setState(() => travelQuote = response.trim());
  // }

  void _logout(BuildContext context) {
    customConfirmationBox.show(
      context: context,
      text: 'Are you sure you want to log out?',
      onPressedYes: () async {
        Navigator.of(context).pop();
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Logged out successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      },
    );
  }

  Widget _buildUserHeader(ThemeData theme) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Text("Hello, Explorer!");

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Hello...");
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final name = data?['name'] ?? 'Explorer';

        return Text(
          'Hello, $name!',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const CircleAvatar(child: Icon(Icons.person, size: 18));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;

        final photoUrl = data?['photoUrl'];
        return CircleAvatar(
          radius: 18,
          backgroundImage:
              (photoUrl != null && photoUrl.isNotEmpty)
                  ? NetworkImage(photoUrl)
                  : const AssetImage('assets/default_avatar.png')
                      as ImageProvider,
          // child:
          //     (photoUrl == null || photoUrl.isEmpty)
          //         ? const Icon(Icons.person, size: 18)
          //         : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: _buildUserHeader(theme),
        // backgroundColor: theme.colorScheme.primary,
        backgroundColor: Colors.teal,

        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: _buildUserAvatar(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
            color: theme.colorScheme.onPrimary,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            InkWell(
              child: NoticeCard(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UpcomingTripsScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildQuickActions(context, theme),
                  const SizedBox(height: 24),
                  _buildUpcomingTrips(theme),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TripCreationScreen()),
              );
            },
            // backgroundColor: theme.colorScheme.primary,
            backgroundColor: Colors.teal,
            foregroundColor: theme.colorScheme.onPrimary,
            child: const Icon(Icons.add),
          )
          .animate(controller: _animationController)
          .shake(hz: 0.5, curve: Curves.easeInOut),
    );
  }

  Widget _buildDestinationCarousel() {
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance.collection('popular_destinations').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No destinations found.'));
        }

        final destinations =
            snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'image': data['imageurl'] as String,
                'title': data['title'] as String,
                'subtitle': data['subtitle'] as String,
              };
            }).toList();

        return SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged:
                (index) => setState(() => _currentCarouselIndex = index),
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final destination = destinations[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(destination['image']!, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destination['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              destination['subtitle']!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Widget _buildQuickActions(BuildContext context, ThemeData theme) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       Text(
  //         'Plan Your Next Adventure',
  //         style: TextStyle(
  //           fontSize: 18,
  //           fontWeight: FontWeight.bold,
  //           color: theme.colorScheme.onSurface,
  //         ),
  //       ),
  //       const SizedBox(height: 15),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: _buildGlassActionButton(
  //               context,
  //               icon: Icons.flight_takeoff,
  //               label: 'New Trip',
  //               // color: theme.colorScheme.primaryContainer,
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (_) => const TripCreationScreen(),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: _buildGlassActionButton(
  //               context,
  //               icon: Icons.map,
  //               label: 'My Trips',
  //               // color: theme.colorScheme.secondaryContainer,
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(builder: (_) => const MyTripsScreen()),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 12),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: _buildGlassActionButton(
  //               context,
  //               icon: Icons.explore,
  //               label: 'Tour Packages',
  //               // color: theme.colorScheme.tertiaryContainer,
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(builder: (_) => UpcomingTripsScreen()),
  //                 );
  //               },
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: _buildGlassActionButton(
  //               context,
  //               icon: Icons.favorite,
  //               label: 'Popular Itineraries',
  //               // color: Colors.green.shade100,
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (_) => PopularItinerariesScreen(),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 12),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: _buildGlassActionButton(
  //               context,
  //               icon: Icons.explore,
  //               label: "Customized Itinerary",
  //               // label: 'Detail Itinerary',
  //               // color: theme.colorScheme.errorContainer,
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(builder: (_) => DetailItinerary()),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }
  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 15, 39, 28),
            Color.fromARGB(255, 32, 67, 58),
            Color.fromARGB(255, 44, 100, 89),
          ],
          //  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Plan Your Next Adventure',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildGlassActionButton(
                  context,
                  icon: Icons.flight_takeoff,
                  label: 'New Trip',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TripCreationScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGlassActionButton(
                  context,
                  icon: Icons.map,
                  label: 'My Trips',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyTripsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildGlassActionButton(
                  context,
                  icon: Icons.explore,
                  label: 'Tour Packages',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UpcomingTripsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGlassActionButton(
                  context,
                  icon: Icons.favorite,
                  label: 'Popular Itineraries',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PopularItinerariesScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildGlassActionButton(
                  context,
                  icon: Icons.auto_fix_high,
                  label: "Customized Itinerary",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailItinerary()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildActionButton(
  //   BuildContext context, {
  //   required IconData icon,
  //   required String label,
  //   required Color color,
  //   required VoidCallback onTap,
  // }) {
  //   return Material(
  //     color: color,
  //     borderRadius: BorderRadius.circular(16),
  //     elevation: 3,
  //     shadowColor: Colors.black26,
  //     child: InkWell(
  //       onTap: onTap,
  //       borderRadius: BorderRadius.circular(16),
  //       splashColor: Colors.white24,
  //       highlightColor: Colors.white10,
  //       child: Container(
  //         width: 80,
  //         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
  //         decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(icon, size: 26, color: Colors.black),
  //             const SizedBox(height: 6),
  //             Text(
  //               label,
  //               textAlign: TextAlign.center,
  //               style: const TextStyle(
  //                 fontSize: 13,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.black,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildGlassActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 90,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 26, color: Colors.white),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTrips(ThemeData theme) {
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('trips')
              .where(
                'userId',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '',
              )
              .where('startDate', isGreaterThanOrEqualTo: Timestamp.now())
              .orderBy('startDate', descending: false)
              .limit(3)
              .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error fetching trips: ${snapshot.error}');
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        print('Fetched ${snapshot.data?.docs.length} trips');

        final trips = snapshot.data?.docs ?? [];

        if (trips.isEmpty) {
          return Column(
            children: [
              Text(
                'No upcoming trips',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              // const SizedBox(height: 16),
              // OutlinedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => const TripCreationScreen(),
              //       ),
              //     );
              //   },
              //   child: const Text('Plan your first trip'),
              // ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Trips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyTripsScreen()),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            ...trips.map((trip) {
              final data = trip.data() as Map<String, dynamic>;
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TripDetailsScreen(trip: data),
                    ),
                  );
                },
                child: _buildTripCard(data, theme),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Container(
            //   width: 60,
            //   height: 60,
            //   decoration: BoxDecoration(
            //     color: theme.colorScheme.primary.withOpacity(0.1),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Icon(
            //     Icons.airplanemode_active,
            //     color: theme.colorScheme.primary,
            //     size: 30,
            //   ),
            // ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip['destination'] ?? 'Unknown Destination',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(trip['startDate'])} - ${_formatDate(trip['endDate'])}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
