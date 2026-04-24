import 'package:google_generative_ai/google_generative_ai.dart';

/// Service for interacting with the Gemini API.
///
/// IMPORTANT: Replace [_apiKey] with your actual Gemini API key.
/// Get one for free at: https://aistudio.google.com/app/apikey
class GeminiService {
  // ⚠️ REPLACE THIS WITH YOUR ACTUAL GEMINI API KEY
  static const String _apiKey = 'AIzaSyD3C3DVTUSPnj7fMvLFfPNECROXFiIUKFU';

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  /// Sends a user message to Gemini and returns the AI response.
  ///
  /// [message] - The user's latest message
  /// [language] - The target language being learned (e.g., "Spanish")
  /// [history] - Previous conversation messages for context
  Future<String> sendMessage({
    required String message,
    required String language,
    List<Content> history = const [],
  }) async {
    try {
      // System prompt to set up the tutor persona
      final systemPrompt = '''
You are a friendly and patient language tutor helping a student learn $language.
Respond primarily in $language, but provide English translations and explanations 
for grammar, vocabulary, and cultural context when helpful. Keep responses concise 
and encouraging. Gently correct any mistakes the student makes.
''';

      // Start chat with system prompt + history
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

      // Send the new user message
      final response = await chat.sendMessage(Content.text(message));
      return response.text ?? 'Sorry, I could not generate a response.';
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }
}
