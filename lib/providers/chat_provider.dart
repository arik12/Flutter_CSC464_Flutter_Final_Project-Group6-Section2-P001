import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/message_model.dart';
import '../services/gemini_service.dart';
import '../services/chat_service.dart';

/// The main Provider for chat state management.
///
/// Messages are now stored in Firestore via [ChatService].
/// A real-time stream listener keeps the UI in sync automatically.
///
/// Handles:
/// - Starting new chat sessions (creates Firestore chat document)
/// - Sending user messages (saved to Firestore)
/// - Getting AI responses from Gemini (saved to Firestore)
/// - Real-time message sync via Firestore stream
/// - Loading state while waiting for AI
class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final ChatService _chatService = ChatService();

  // Messages synced from Firestore in real-time
  List<MessageModel> _messages = [];

  String? _currentLanguage;
  String? _currentChatId;
  bool _isLoading = false;
  String? _error;

  // Firestore stream subscription
  StreamSubscription<List<MessageModel>>? _messagesSubscription;

  // Public getters
  List<MessageModel> get messages => List.unmodifiable(_messages);
  String? get currentLanguage => _currentLanguage;
  String? get currentChatId => _currentChatId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Starts a new chat session for the given language.
  /// Creates a new chat document in Firestore and begins listening
  /// to its messages subcollection.
  Future<void> startNewChat(String language) async {
    _currentLanguage = language;
    _messages = [];
    _error = null;
    _isLoading = false;
    notifyListeners();

    // Cancel any previous stream subscription
    await _messagesSubscription?.cancel();

    // Create a new chat document in Firestore
    _currentChatId = await _chatService.createChat(language);

    // Listen to real-time messages from Firestore
    _messagesSubscription = _chatService
        .getMessagesStream(_currentChatId!)
        .listen((messages) {
      _messages = messages;
      notifyListeners();
    });
  }

  /// Sends a user message, saves it to Firestore,
  /// gets the AI response, and saves that too.
  Future<void> sendMessage(String userMessage) async {
    if (_currentLanguage == null || _currentChatId == null) return;
    if (userMessage.trim().isEmpty) return;

    // 1. Build and save user message to Firestore
    final userMsg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'user',
      message: userMessage,
      timestamp: DateTime.now(),
    );
    await _chatService.saveMessage(userMsg, _currentChatId!);

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 2. Build conversation history for Gemini context
      final geminiHistory = <Content>[];
      for (final msg in _messages) {
        if (msg.isUser) {
          geminiHistory.add(Content.text(msg.message));
        } else {
          geminiHistory.add(Content.model([TextPart(msg.message)]));
        }
      }

      // 3. Get AI response from Gemini API
      final aiResponse = await _geminiService.sendMessage(
        message: userMessage,
        language: _currentLanguage!,
        history: geminiHistory,
      );

      // 4. Save AI response to Firestore
      final aiMsg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: 'ai',
        message: aiResponse,
        timestamp: DateTime.now(),
      );
      await _chatService.saveMessage(aiMsg, _currentChatId!);
    } catch (e) {
      _error = 'Error: \$e';

      // Save error message to Firestore so it appears in chat
      final errorMsg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: 'ai',
        message:
            '⚠️ Sorry, I had trouble responding. Please check your API key and try again.',
        timestamp: DateTime.now(),
      );
      await _chatService.saveMessage(errorMsg, _currentChatId!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resets state and cancels the Firestore stream subscription.
  Future<void> reset() async {
    await _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _currentLanguage = null;
    _currentChatId = null;
    _messages = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
