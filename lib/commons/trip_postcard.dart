import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripPostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const TripPostCard({super.key, required this.post});

  void _showImageDialog(BuildContext context, String imageUrl) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Image Viewer",
      pageBuilder:
          (context, animation, secondaryAnimation) => Stack(
            children: [
              // Blurred Background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: const SizedBox.expand(),
              ),
              // Dark overlay
              Container(color: Colors.black.withOpacity(0.6)),

              // Image
              Center(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.white,
                        ),
                  ),
                ),
              ),

              // Close button
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final glass = GlassColors.dark();

    final message = post['message'] ?? 'No message';
    final imageUrl = post['full_picture'];
    final createdTime = post['created_time'];

    final formattedDate =
        createdTime != null
            ? DateFormat.yMMMMd().add_jm().format(DateTime.parse(createdTime))
            : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [glass.glassStart, glass.glassEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: glass.glassBorder),
        boxShadow: [
          BoxShadow(
            color: glass.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              GestureDetector(
                onTap: () => _showImageDialog(context, imageUrl),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => const SizedBox(
                          height: 220,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: glass.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      background: const Color(0xFF0D0F14),
      appBar: const Color(0xFF1A2327),
      primary: const Color(0xFF2CE0D0),
      onPrimary: const Color(0xFF0D0F14),
      text: const Color(0xFFE0F3FF),
      icon: const Color(0xFF2CE0D0),
      glassStart: const Color(0xFF1A2327).withOpacity(0.8),
      glassEnd: const Color(0xFF253A3E).withOpacity(0.6),
      glassBorder: const Color(0xFF3FE0D0).withOpacity(0.15),
      glassButton: const Color(0xFF1E2A2D).withOpacity(0.4),
      shadow: Colors.black.withOpacity(0.5),
    );
  }
}
