import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey =
      String.fromEnvironment('AIzaSyDwf19cVEy1ZNr2XHiOVLJUg5dsO-rVN5c');

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> sendMessage({
    required String message,
    required String language,
    List<Content> history = const [],
  }) async {
    try {
      final systemPrompt = '''
You are a friendly and patient language tutor helping a student learn $language.
Respond primarily in $language, but provide English translations and explanations 
for grammar, vocabulary, and cultural context when helpful. Keep responses concise 
and encouraging. Gently correct any mistakes the student makes.
''';

      final chat = _model.startChat(
        history: [
          Content.text(systemPrompt),
          Content.model([
            TextPart(
              'Understood! I am ready to help teach $language. '
              'Let\'s begin whenever you are ready!',
            )
          ]),
          ...history,
        ],
      );

      final response = await chat.sendMessage(Content.text(message));
      return response.text ?? 'Sorry, I could not generate a response.';
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }
}
