import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  Future<String> sendMessage({
    required String message,
    required String language,
    List<Map<String, dynamic>> history = const [],
  }) async {
    try {
      final systemPrompt =
          'You are a friendly and patient language tutor helping a student learn $language. '
          'Respond primarily in $language, but provide English translations and explanations '
          'for grammar, vocabulary, and cultural context when helpful. Keep responses concise '
          'and encouraging. Gently correct any mistakes the student makes.';

      final List<Map<String, dynamic>> contents = [
        {
          'role': 'user',
          'parts': [
            {'text': systemPrompt}
          ]
        },
        {
          'role': 'model',
          'parts': [
            {
              'text':
                  'Understood! I am ready to help teach $language. Let\'s begin!'
            }
          ]
        },
        ...history,
        {
          'role': 'user',
          'parts': [
            {'text': message}
          ]
        },
      ];

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'contents': contents}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            'Sorry, I could not generate a response.';
      } else {
        throw Exception('API error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }
}
