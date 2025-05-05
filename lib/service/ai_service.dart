import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  // Load your key from env (flutter_dotenv) or other secure store
  static final _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  static const String _model = 'gemini-1.5-flash-latest';

  /// Sends [prompt] to the LLM and returns the assistant's reply.
  static Future<String> getAISuggestions(String prompt) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      //'model': 'gemini-2.0-flash:',
      // Use a valid model ID
      'contents': [
        {
          'parts': [
            // System instructions can often be included here or as the first user part
            {
              'text':
                  'You are a business assistant that analyzes sales and inventory data to provide actionable suggestions. Format your response clearly using Markdown. Use bold Markdown syntax for headings (e.g., **Heading Title**). Use bullet points for lists where appropriate. show calculation pkr and give suggestion according to the Pakistani market.',
            },
            {'text': prompt}
          ]
        }
      ],
      // Optional: Add generationConfig if needed (e.g., temperature, maxOutputTokens)
      // 'generationConfig': {
      //   'temperature': 0.7,
      // }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'] as String;
        } else {
          // Log the full error body for debugging
          throw Exception(
              'AI request failed (${response.statusCode}): ${response.body}');
        }
      } else {
        // Log the full error body for debugging
        throw Exception(
            'AI request failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // Handle JSON parsing errors or other exceptions
      throw Exception('Failed to parse AI response: $e');
    }
  }
}
