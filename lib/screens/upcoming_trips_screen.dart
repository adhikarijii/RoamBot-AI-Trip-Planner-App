import 'dart:convert';
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
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Container(height: 80),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Upcoming Tours"),
      body:
          isLoading
              ? buildShimmerLoader()
              : posts.isEmpty
              ? const Center(child: Text("No upcoming trips yet."))
              : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return TripPostCard(post: posts[index]);
                },
              ),
    );
  }
}
