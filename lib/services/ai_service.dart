// lib/services/ai_service.dart

import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/constants.dart';

class AIService {
  final _model = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);

  Future<String?> generateItinerary(
    String destination,
    String startDate,
    String endDate,
  ) async {
    final prompt = '''
Create a detailed travel itinerary for a trip to $destination from $startDate to $endDate.
Include daily plans with top places to visit, food suggestions, and travel tips.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      print('AI Error: $e');
      return null;
    }
  }
}
