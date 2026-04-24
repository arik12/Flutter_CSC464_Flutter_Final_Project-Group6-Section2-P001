import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/gemini_service.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final ChatService _chatService = ChatService();

  List<MessageModel> _messages = [];
  String? _currentLanguage;
  String? _currentChatId;
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<MessageModel>>? _messagesSubscription;

  List<MessageModel> get messages => List.unmodifiable(_messages);
  String? get currentLanguage => _currentLanguage;
  String? get currentChatId => _currentChatId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> startNewChat(String language) async {
    _currentLanguage = language;
    _messages = [];
    _error = null;
    _isLoading = false;
    notifyListeners();

    await _messagesSubscription?.cancel();

    _currentChatId = await _chatService.createChat(language);

    _messagesSubscription =
        _chatService.getMessagesStream(_currentChatId!).listen((messages) {
      _messages = messages;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String userMessage) async {
    if (_currentLanguage == null || _currentChatId == null) return;
    if (userMessage.trim().isEmpty) return;

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
      // History build
      final geminiHistory = <Map<String, dynamic>>[];
      for (final msg in _messages) {
        geminiHistory.add({
          'role': msg.isUser ? 'user' : 'model',
          'parts': [
            {'text': msg.message}
          ]
        });
      }

      final aiResponse = await _geminiService.sendMessage(
        message: userMessage,
        language: _currentLanguage!,
        history: geminiHistory,
      );

      final aiMsg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: 'ai',
        message: aiResponse,
        timestamp: DateTime.now(),
      );
      await _chatService.saveMessage(aiMsg, _currentChatId!);
    } catch (e) {
      _error = 'Error: $e';

      final errorMsg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: 'ai',
        message: '⚠️ Error: $e',
        timestamp: DateTime.now(),
      );
      await _chatService.saveMessage(errorMsg, _currentChatId!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
