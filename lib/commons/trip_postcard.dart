import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class TripPostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const TripPostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String message = post['message'] ?? 'No content';
    final String? imageUrl = post['full_picture'];
    final String createdTime = post['created_time'];
    final formattedDate = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(DateTime.parse(createdTime).toLocal());

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading:
            imageUrl != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) =>
                            const CircularProgressIndicator(strokeWidth: 2),
                    errorWidget:
                        (context, url, error) =>
                            const Icon(Icons.image_not_supported),
                  ),
                )
                : const Icon(Icons.article_outlined, size: 40),
        title: Text(
          message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(formattedDate, style: TextStyle(color: Colors.grey[600])),
        ),
        onTap: () {
          // TODO: Optionally open full post or a details screen
        },
      ),
    );
  }
}
