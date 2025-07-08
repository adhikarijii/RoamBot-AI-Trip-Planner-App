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
    _startCarouselTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startCarouselTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_pageController.hasClients) {
        if (_currentCarouselIndex < 2) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        _startCarouselTimer();
      }
    });
  }

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
                  : null,
          child:
              (photoUrl == null || photoUrl.isEmpty)
                  ? const Icon(Icons.person, size: 18)
                  : null,
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
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            //   // child: _buildDestinationCarousel(),
            //   // child: NoticeCard(),
            // ),
            const SizedBox(height: 10),
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

  // Widget _buildDestinationCarousel() {
  //   final popularDestinations = [
  //     {
  //       'image': 'assets/uttarakhand.jpeg',
  //       'title': 'Uttarakhand',
  //       'subtitle': 'Dev Bhoomi Uttarakhand',
  //     },
  //     {
  //       'image': 'assets/sikkim.jpeg',
  //       'title': 'Sikkim',
  //       'subtitle': 'Valley of Rice',
  //     },
  //     {
  //       'image': 'assets/spiti.jpeg',
  //       'title': 'Spiti',
  //       'subtitle': 'Winter Wonderland',
  //     },
  //   ];

  //   return SizedBox(
  //     height: 150,
  //     child: PageView.builder(
  //       controller: _pageController,
  //       onPageChanged: (index) => setState(() => _currentCarouselIndex = index),
  //       itemCount: popularDestinations.length,
  //       itemBuilder: (context, index) {
  //         final destination = popularDestinations[index];
  //         return Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.circular(16),
  //             child: Stack(
  //               fit: StackFit.expand,
  //               children: [
  //                 Image.asset(destination['image']!, fit: BoxFit.cover),
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     gradient: LinearGradient(
  //                       begin: Alignment.bottomCenter,
  //                       end: Alignment.topCenter,
  //                       colors: [
  //                         Colors.black.withOpacity(0.7),
  //                         Colors.transparent,
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 Positioned(
  //                   left: 16,
  //                   bottom: 16,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         destination['title']!,
  //                         style: const TextStyle(
  //                           color: Colors.white,
  //                           fontSize: 22,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       Text(
  //                         destination['subtitle']!,
  //                         style: TextStyle(
  //                           color: Colors.white.withOpacity(0.9),
  //                           fontSize: 14,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildQuoteCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.airplanemode_active,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Inspiration',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    travelQuote!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(
      duration: 500.ms,
      begin: 0.1,
      curve: Curves.easeOut,
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Plan Your Next Adventure',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.flight_takeoff,
                label: 'New Trip',
                color: theme.colorScheme.primaryContainer,
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
              child: _buildActionButton(
                context,
                icon: Icons.map,
                label: 'My Trips',
                color: theme.colorScheme.secondaryContainer,
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
              child: _buildActionButton(
                context,
                icon: Icons.explore,
                label: 'Upcoming Trips/Tours',
                color: theme.colorScheme.tertiaryContainer,
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
              child: _buildActionButton(
                context,
                icon: Icons.favorite,
                label: 'Popular Itineraries',
                color: Colors.green.shade100,
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
              child: _buildActionButton(
                context,
                icon: Icons.explore,
                label: 'Detail Itinerary',
                color: theme.colorScheme.errorContainer,
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
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          children: [
            Icon(icon, size: 21),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
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
