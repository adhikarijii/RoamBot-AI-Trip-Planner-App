import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:roambot/commons/widgets/customFontSize.dart';
import 'package:shimmer/shimmer.dart';

class NoticeCard extends StatefulWidget {
  const NoticeCard({super.key});

  @override
  State<NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard> {
  List<dynamic> posts = [];

  bool isLoading = true;

  final String pageId = '722764994245753';
  final String accessToken =
      'EAASG5SlvIBIBPIO307cclyZCWIn3DMUVanZAvBppg3Le3S72tMuIhauLx39vrP7nGPSfExxRWhX2ZCX6eV0SOJ0EKhWYgZAttpm6uiFl8JvHgzULXvbKU0SrgeqtyJWi2wHwuhGNOpZCleMZA0uvFKVmUPChUfCpeNMOfVKwH7Wsir2pbJ5jiH9OFU5C5ac9Y3aUl0lYNr';

  @override
  void initState() {
    super.initState();
    fetchFacebookPosts();
  }

  Future<void> fetchFacebookPosts() async {
    final url = Uri.parse(
      'https://graph.facebook.com/v22.0/$pageId/posts?fields=message,created_time,full_picture&access_token=$accessToken',
    );

    final response = await http.get(url);
    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // debugPrint('Raw Post Data: $data');
      if (!mounted) return;
      setState(() {
        posts = data['data'];
        isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      // print('Failed to load posts: ${response.body}');
    }
  }

  Widget buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1A2327),
      highlightColor: const Color.fromARGB(255, 27, 58, 36),
      child: Row(
        children: [
          Container(
            height: 120.h,
            width: 80.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: Container(height: 12.h, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return buildShimmerLoader();
    }

    if (posts.isEmpty) {
      return const Center(child: Text('No recent posts.'));
    }

    final topPosts = posts.take(5).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Colors.black26,
      color: const Color(0xFF1A2327).withOpacity(0.8),
      child: Padding(
        padding: EdgeInsets.fromLTRB(9, 5, 9, 5),
        child: CarouselSlider.builder(
          itemCount: topPosts.length,
          options: CarouselOptions(
            height: 130.h,
            autoPlay: true,
            autoPlayCurve: Curves.easeInOut,
            enlargeCenterPage: true,
            viewportFraction: 0.95,
            autoPlayInterval: Duration(seconds: 9),
            enableInfiniteScroll: false,
          ),
          itemBuilder: (context, index, realIdx) {
            final post = topPosts[index];
            final String message = post['message'] ?? 'No content';
            final String time = post['created_time'] ?? '';
            final String? imageUrl = post['full_picture'];
            final formattedDate = DateFormat(
              'dd MMM, yyyy – hh:mm a',
            ).format(DateTime.parse(time).toLocal());

            return Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      imageUrl != null
                          ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            height: 140.h,
                            width: 120.w,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.grey.shade50,
                                  child: Container(
                                    height: 120.h,
                                    width: 100.w,
                                    color: Colors.white,
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.broken_image),
                          )
                          : Container(
                            height: 100.h,
                            width: 80.w,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.article_outlined),
                          ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: customFontSize(context, 12),
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        message,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: customFontSize(context, 13),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
