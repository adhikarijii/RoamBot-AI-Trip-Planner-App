import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roambot/commons/trip_postcard.dart';
import 'package:roambot/commons/widgets/custom_app_bar.dart';
import 'package:shimmer/shimmer.dart';

class UpcomingTripsScreen extends StatefulWidget {
  @override
  State<UpcomingTripsScreen> createState() => _UpcomingTripScreenState();
}

class _UpcomingTripScreenState extends State<UpcomingTripsScreen> {
  List<dynamic> posts = [];
  bool isLoading = true;

  final String pageId = '722764994245753';
  final String accessToken =
      'EAASG5SlvIBIBPIO307cclyZCWIn3DMUVanZAvBppg3Le3S72tMuIhauLx39vrP7nGPSfExxRWhX2ZCX6eV0SOJ0EKhWYgZAttpm6uiFl8JvHgzULXvbKU0SrgeqtyJWi2wHwuhGNOpZCleMZA0uvFKVmUPChUfCpeNMOfVKwH7Wsir2pbJ5jiH9OFU5C5ac9Y3aUl0lYNr';

  @override
  void initState() {
    super.initState();
    fetchFacebookTripPosts();
  }

  Future<void> fetchFacebookTripPosts() async {
    final url = Uri.parse(
      'https://graph.facebook.com/v22.0/$pageId/posts?fields=message,created_time,full_picture&access_token=$accessToken',
    );

    final response = await http.get(url);
    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final allPosts = data['data'];

      final tripPosts =
          allPosts.where((post) {
            final message = post['message']?.toLowerCase() ?? '';
            return message.contains('trip') || message.contains('#roambottrip');
          }).toList();

      setState(() {
        posts = tripPosts;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Widget buildShimmerLoader() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder:
          (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey.shade800,
            highlightColor: Colors.grey.shade700,
            child: Card(
              color: Colors.transparent,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              child: Container(height: 100),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final glassColors = GlassColors.dark();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: glassColors.background,
      appBar: const CustomAppBar(title: "Upcoming Tours"),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [glassColors.glassStart, glassColors.glassEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          isLoading
              ? buildShimmerLoader()
              : posts.isEmpty
              ? Center(
                child: Text(
                  "No upcoming trips yet.",
                  style: TextStyle(color: glassColors.text, fontSize: 16),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return TripPostCard(post: posts[index]);
                },
              ),
        ],
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
}
