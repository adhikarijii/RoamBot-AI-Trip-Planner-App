import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:roambot/commons/widgets/customConfirmationBox.dart'
    show customConfirmationBox;
import 'package:roambot/screens/fb_page.dart';
import 'package:roambot/screens/upcoming_trips_screen.dart';
import 'package:roambot/screens/customized_itinerary.dart';
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
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _loadProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        );
      },
    );
  }

  String _getCountdownString(Timestamp? startTimestamp) {
    if (startTimestamp == null) return 'Starts soon';
    final now = DateTime.now();
    final start = startTimestamp.toDate();
    final diff = start.difference(now);

    if (diff.isNegative) return 'Started';

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    if (days > 0) {
      return 'Starts in: $days day${days == 1 ? '' : 's'} $hours hr';
    } else if (hours > 0) {
      return 'Starts in: $hours hr $minutes min';
    } else {
      return 'Starts in: $minutes min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = GlassColors.dark(); // Force dark mode for glass effect

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: _buildUserHeader(theme),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: colors.appBar.withOpacity(0.7),
                border: Border(
                  bottom: BorderSide(
                    color: colors.glassBorder.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
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
            color: colors.text,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Notice Card with enhanced glass effect
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildGlassCard(
                child: InkWell(
                  child: NoticeCard(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UpcomingTripsScreen()),
                    );
                  },
                ),
                colors: colors,
                blurSigma: 12,
              ),
            ),
            const SizedBox(height: 24),
            // Quick Actions with enhanced glass effect
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildGlassQuickActions(context, theme, colors),
            ),
            const SizedBox(height: 24),
            // Upcoming Trips with glass effect
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildGlassCard(
                child: _buildUpcomingTrips(colors),
                colors: colors,
                blurSigma: 12,
              ),
            ),
            const SizedBox(height: 24),
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
            backgroundColor: colors.primary.withOpacity(0.9),
            foregroundColor: colors.onPrimary,
            child: const Icon(Icons.add),
          )
          .animate(controller: _animationController)
          .shake(hz: 0.5, curve: Curves.easeInOut),
    );
  }

  Widget _buildGlassCard({
    required Widget child,
    required GlassColors colors,
    double blurSigma = 10,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.glassStart.withOpacity(0.7),
                colors.glassEnd.withOpacity(0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.glassBorder.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: -5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassQuickActions(
    BuildContext context,
    ThemeData theme,
    GlassColors colors,
  ) {
    return _buildGlassCard(
      colors: colors,
      blurSigma: 15,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Plan Your Next Adventure',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.icon,
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
                    colors: colors,
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
                        MaterialPageRoute(
                          builder: (_) => const MyTripsScreen(),
                        ),
                      );
                    },
                    colors: colors,
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
                        MaterialPageRoute(
                          builder: (_) => UpcomingTripsScreen(),
                        ),
                      );
                    },
                    colors: colors,
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
                    colors: colors,
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
                    colors: colors,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required GlassColors colors,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colors.glassButton.withOpacity(0.25),
              border: Border.all(
                color: colors.glassBorder.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 26, color: colors.icon),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, GlassColors colors) {
    return _buildGlassCard(
      colors: colors,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Plan Your Next Adventure',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 20),
            _actionRow(context, colors, [
              _actionButton(
                context,
                'New Trip',
                Icons.flight_takeoff,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TripCreationScreen()),
                ),
                colors,
              ),
              _actionButton(
                context,
                'My Trips',
                Icons.map,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyTripsScreen()),
                ),
                colors,
              ),
            ]),
            const SizedBox(height: 12),
            _actionRow(context, colors, [
              _actionButton(
                context,
                'Tour Packages',
                Icons.explore,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UpcomingTripsScreen()),
                ),
                colors,
              ),
              _actionButton(
                context,
                'Popular',
                Icons.favorite,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PopularItinerariesScreen()),
                ),
                colors,
              ),
            ]),
            const SizedBox(height: 12),
            _actionButton(
              context,
              'Customized Itinerary',
              Icons.auto_fix_high,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailItinerary()),
              ),
              colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionRow(
    BuildContext context,
    GlassColors colors,
    List<Widget> buttons,
  ) {
    return Row(
      children:
          buttons
              .map(
                (e) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: e,
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _actionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
    GlassColors colors,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colors.glassButton.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.glassBorder.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.icon),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: colors.text, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTrips(GlassColors colors) {
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('trips')
              .where(
                'userId',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '',
              )
              .where('startDate', isGreaterThanOrEqualTo: Timestamp.now())
              .orderBy('startDate')
              .limit(3)
              .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          );
        }
        final trips = snapshot.data?.docs ?? [];
        if (trips.isEmpty) {
          return Text(
            'No upcoming trips',
            style: TextStyle(color: colors.text.withOpacity(0.6)),
          );
        }
        return _buildGlassCard(
          colors: colors,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Trips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.icon,
                  ),
                ),
                const SizedBox(height: 12),
                ...trips.map((trip) {
                  final data = trip.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(
                      data['destination'] ?? 'Unknown',
                      style: TextStyle(color: colors.text),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_formatDate(data['startDate'])} - ${_formatDate(data['endDate'])}',
                          style: TextStyle(color: colors.text.withOpacity(0.6)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCountdownString(data['startDate']),
                          style: TextStyle(
                            color: colors.primary.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    trailing: Icon(Icons.chevron_right, color: colors.icon),
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TripDetailsScreen(trip: data),
                          ),
                        ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
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
      appBar: const Color(0x804E8C87),
      primary: const Color(0xFF4E8C87),
      onPrimary: Colors.white,
      text: const Color(0xFF2D3748),
      icon: const Color(0xFF4E8C87),
      glassStart: const Color(0x90A5D8D3),
      glassEnd: const Color(0x60E2F3F0),
      glassBorder: Colors.white.withOpacity(0.4),
      glassButton: Colors.white.withOpacity(0.3),
      shadow: const Color(0x554A5568),
    );
  }
}
