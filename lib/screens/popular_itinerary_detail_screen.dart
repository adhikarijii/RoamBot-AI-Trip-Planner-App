import 'dart:ui';
import 'package:flutter/material.dart';

class PopularItineraryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const PopularItineraryDetailScreen({Key? key, required this.trip})
    : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final List<String> itinerary = List<String>.from(trip['days'] ?? []);
    final List<String> tips = List<String>.from(trip['tips'] ?? []);
    final String? imageAsset = trip['imageAsset'];
    final colors = GlassColors.dark();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(trip['title']),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (imageAsset != null)
              _buildGlassCard(
                colors: colors,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imageAsset,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildGlassCard(
              colors: colors,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Itinerary",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colors.icon,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...itinerary.map(
                      (day) => _buildGlassCard(
                        colors: colors,
                        blurSigma: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.calendar_today, color: colors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  day,
                                  style: TextStyle(color: colors.text),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (tips.isNotEmpty) ...[
                      SizedBox(height: 24),
                      Text(
                        "Travel Tips",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colors.icon,
                        ),
                      ),
                      SizedBox(height: 10),
                      ...tips.map(
                        (tip) => _buildGlassCard(
                          colors: colors,
                          blurSigma: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.tips_and_updates_outlined,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: TextStyle(color: colors.text),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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
