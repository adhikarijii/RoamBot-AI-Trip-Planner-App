import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final _model = GenerativeModel(
    model: 'gemini-1.5-pro',
    apiKey: 'AIzaSyAltC6kAmMNGvKP8n-0UDn5jD8E0GleyNY',
  );

  Future<String> generateTripPlan(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text?.replaceAll(RegExp(r'[#*`_~>-]'), '').trim() ??
          "No response from AI.";
    } catch (e) {
      print("❌ GeminiService Error: $e");
      return "Itinerary generation failed.";
    }
  }
}
