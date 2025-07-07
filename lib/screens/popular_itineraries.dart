import 'package:flutter/material.dart';
import 'package:roambot/commons/widgets/custom_app_bar.dart';
import 'popular_itinerary_detail_screen.dart';

class PopularItinerariesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> popularTrips = [
    {
      "title": "Char Dham Yatra (10 Days)",
      "imageAsset": "assets/images/char_dham.jpeg",
      "days": [
        "Day 1: Arrival in Haridwar/Rishikesh - Visit Har Ki Pauri, Mansa Devi Temple, attend Ganga Aarti.",
        "Day 2: Haridwar to Barkot (200 km, 7–8 hrs) - Optional Mussoorie stop.",
        "Day 3: Barkot to Yamunotri and back (42 km drive + 6 km trek).",
        "Day 4: Barkot to Uttarkashi (150 km, 6–7 hrs) - Visit Vishwanath Temple.",
        "Day 5: Uttarkashi to Gangotri and back (100 km each way).",
        "Day 6: Uttarkashi to Guptkashi/Sitapur (220 km, 8–9 hrs).",
        "Day 7: Guptkashi to Kedarnath (30 km drive + 16 km trek) - Visit Kedarnath Temple.",
        "Day 8: Kedarnath to Pipalkoti via Guptkashi (16 km trek + 130 km drive).",
        "Day 9: Pipalkoti to Badrinath (70 km, 3–4 hrs) - Visit Temple, Mana Village, Falls.",
        "Day 10: Badrinath to Haridwar/Rishikesh (300 km, 10–12 hrs) - End of Yatra.",
      ],
      "tips": [
        "Use shared taxis/buses between stops.",
        "Helicopter optional for Kedarnath (₹2,000–₹4,000 one way).",
        "GMVN guesthouses and Dharamshalas recommended.",
        "Best time: May–June, Sept–Oct (avoid monsoon).",
        "Essentials: Warm clothes, raincoat, trekking shoes, cash, medicines.",
        "Budget: ₹15,000–₹25,000 per person (excluding helicopter).",
      ],
    },
    {
      "title": "Panch Kedar Yatra (5 Days)",
      "imageAsset": "assets/images/panch_kedar.jpeg",
      "days": [
        "Day 1: Haridwar to Kedarnath – Darshan and overnight stay.",
        "Day 2: Kedarnath to Chopta – Visit Tungnath and Chandrashila.",
        "Day 3: Chopta to Rudranath via Panar Bugyal.",
        "Day 4: Rudranath to Madhyamaheshwar.",
        "Day 5: Kalpeshwar darshan and return to Joshimath/Haridwar.",
      ],
      "tips": [
        "Best season: May–June & Sept–Oct.",
        "Budget lodges or camps (₹700–₹1,200/night).",
        "Carry trekking shoes, raincoat, torch.",
        "Budget: ₹8,000–₹12,000 approx.",
      ],
    },
    {
      "title": "Panch Kailash Yatra (12 Days)",
      "imageAsset": "assets/images/panch_kailash.jpeg",
      "days": [
        "Day 1-2: Delhi to Adi Kailash base (via Dharchula)",
        "Day 3: Trek to Adi Kailash (Parvati Sarovar, Om Parvat)",
        "Day 4-5: Travel to Kinnaur Kailash trek base.",
        "Day 6: Kinnaur Kailash trek (Shivling base).",
        "Day 7-8: Travel to Manimahesh Kailash (Bharmour).",
        "Day 9: Manimahesh trek & darshan.",
        "Day 10-11: Harsil & Shrikhand Mahadev base visit.",
        "Day 12: Rest day or Shrikhand base trek optional.",
      ],
      "tips": [
        "Physically challenging; good fitness required.",
        "Budget: ₹30,000–₹45,000 (excluding Mansarovar).",
      ],
    },
    {
      "title": "12 Jyotirlingas Tour (Flexible)",
      "imageAsset": "assets/images/jyotirlingas.jpg",
      "days": [
        "Somnath, Nageshwar, Bhimashankar, Trimbakeshwar, Grishneshwar, Omkareshwar, Mahakaleshwar, Vaidyanath, Kashi Vishwanath, Rameshwaram, Mallikarjuna.",
      ],
      "tips": [
        "Split by region: West, Central, South India.",
        "Budget-friendly by train; temple stays available.",
        "Budget: ₹35,000–₹55,000.",
      ],
    },
    {
      "title": "Leh–Ladakh Circuit (7 Days)",
      "imageAsset": "assets/images/leh_ladakh.jpeg",
      "days": [
        "Day 1: Arrival in Leh.",
        "Day 2: Local sightseeing.",
        "Day 3: Leh to Nubra via Khardung La.",
        "Day 4: Nubra to Pangong.",
        "Day 5: Pangong to Leh.",
        "Day 6: Monastery visits.",
        "Day 7: Fly out.",
      ],
      "tips": [
        "Acclimatize properly, carry ID proof.",
        "Budget: ₹18,000–₹28,000.",
      ],
    },
    {
      "title": "Spiti Valley Road Trip (6 Days)",
      "imageAsset": "assets/images/spiti.jpeg",
      "days": [
        "Day 1: Manali to Kaza.",
        "Day 2: Kaza – Ki Monastery, Kibber.",
        "Day 3: Hikkim, Langza, Komic.",
        "Day 4: Dhankar, Tabo.",
        "Day 5: Pin Valley.",
        "Day 6: Return to Manali.",
      ],
      "tips": [
        "Road rough, use SUV or local driver.",
        "Budget: ₹12,000–₹18,000.",
      ],
    },
    {
      "title": "Golden Triangle (Delhi–Agra–Jaipur) (5 Days)",
      "imageAsset": "assets/images/golden_triangle.jpeg",
      "days": [
        "Day 1: Delhi – India Gate, Qutub Minar.",
        "Day 2: Delhi to Agra – Taj Mahal.",
        "Day 3: Fatehpur Sikri, Jaipur travel.",
        "Day 4: Jaipur – Amber Fort, Hawa Mahal.",
        "Day 5: Return to Delhi.",
      ],
      "tips": ["Budget: ₹10,000–₹15,000.", "Best time: Oct–Mar."],
    },
    {
      'title': 'Tungnath–Chandrashila Trek (2 Days)',
      'imageAsset': 'assets/images/tungnath.jpg',
      'days': [
        'Day 1: Reach Chopta – Acclimatize and explore local meadows.',
        'Day 2: Trek to Tungnath Temple and Chandrashila peak – Return to Chopta.',
      ],
      'tips': [
        'Short yet steep trek – start early morning.',
        'Great for sunrise/sunset photography at Chandrashila.',
        'Best time: April–June, Sept–Nov.',
        'Budget: ₹3,000–₹5,000 (shared stay/transport).',
      ],
    },
    {
      'title': 'Kedarnath Yatra (3 Days)',
      'imageAsset': 'assets/images/kedarnath.jpeg',
      'days': [
        'Day 1: Haridwar to Gaurikund – Night stay.',
        'Day 2: Trek to Kedarnath (16 km) – Darshan and night halt in Dharamshala.',
        'Day 3: Return to Gaurikund and travel back to Rudraprayag/Haridwar.',
      ],
      'tips': [
        'Start early for the trek – carry snacks & water.',
        'Helicopter available from Phata/Sersi/Guptkashi.',
        'GMVN and temple trust accommodation available.',
        'Budget: ₹5,000–₹10,000 depending on stay mode.',
      ],
    },
    {
      'title': 'Yulla Kanda Trek (2 Days)',
      'imageAsset': 'assets/images/yulla_kanda.jpg',
      'days': [
        'Day 1: Start from Naitwar – Trek to campsite near Yulla lake.',
        'Day 2: Visit Yulla Kanda lake – Return to base.',
      ],
      'tips': [
        'Offbeat trail – less crowded, carry essentials.',
        'Best for experienced trekkers or guided groups.',
        'Pack warm clothes – cold even in summer.',
        'Budget: ₹3,000–₹6,000 approx.',
      ],
    },
    {
      'title': 'Valley of Flowers Trek (4 Days)',
      'imageAsset': 'assets/images/valley_of_flowers.jpeg',
      'days': [
        'Day 1: Haridwar to Govindghat – Night stay.',
        'Day 2: Trek to Ghangaria (13 km).',
        'Day 3: Visit Valley of Flowers and return to Ghangaria.',
        'Day 4: Return to Govindghat and travel back to Haridwar.',
      ],
      'tips': [
        'UNESCO World Heritage Site – peak bloom July–August.',
        'Moderate trek – carry rain gear and camera.',
        'Combine with Hemkund Sahib if time allows.',
        'Budget: ₹6,000–₹10,000.',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Popular Itineraries'),
      body: ListView.builder(
        itemCount: popularTrips.length,
        itemBuilder: (context, index) {
          final trip = popularTrips[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PopularItineraryDetailScreen(trip: trip),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.asset(
                      trip['imageAsset'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      trip['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
