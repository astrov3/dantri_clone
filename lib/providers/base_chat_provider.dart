import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../services/base_chatbot_service.dart';

abstract class BaseChatProvider extends ChangeNotifier {
  final BaseChatbotService _chatbotService;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  BaseChatProvider({required BaseChatbotService chatbotService})
    : _chatbotService = chatbotService;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sessionId => _chatbotService.sessionId;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      text: message.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      sessionId: sessionId,
    );

    _messages.add(userMessage);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Send message to backend
      final response = await _chatbotService.sendMessage(message);
      print('Response: $response');

      // Add bot response
      final botMessage = ChatMessage(
        id: const Uuid().v4(),
        text: response['answer'] ?? 'Xin lỗi, tôi không hiểu câu hỏi của bạn.',
        isUser: false,
        timestamp: DateTime.now(),
        sessionId: sessionId,
      );

      _messages.add(botMessage);
    } catch (e) {
      _error = e.toString();

      // Add error message
      final errorMessage = ChatMessage(
        id: const Uuid().v4(),
        text: 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại.',
        isUser: false,
        timestamp: DateTime.now(),
        sessionId: sessionId,
      );

      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendWebhookMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      text: message.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      sessionId: sessionId,
    );

    _messages.add(userMessage);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Send message via webhook
      final response = await _chatbotService.sendWebhookMessage(message);
      print('Webhook Response: $response');

      // Add bot response
      final botMessage = ChatMessage(
        id: const Uuid().v4(),
        text:
            response['fulfillmentText'] ??
            'Xin lỗi, tôi không hiểu câu hỏi của bạn.',
        isUser: false,
        timestamp: DateTime.now(),
        sessionId: sessionId,
      );

      _messages.add(botMessage);
    } catch (e) {
      _error = e.toString();

      // Add error message
      final errorMessage = ChatMessage(
        id: const Uuid().v4(),
        text: 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại.',
        isUser: false,
        timestamp: DateTime.now(),
        sessionId: sessionId,
      );

      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
