import 'package:flutter/material.dart';

import '../../../core/env/env.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/openai_service.dart';
import '../model/message.dart';

enum MessageStatus { sending, sent, error, typing }

class ChatMessageWithStatus {
  final ChatMessage message;
  final MessageStatus status;

  const ChatMessageWithStatus({
    required this.message,
    this.status = MessageStatus.sent,
  });

  ChatMessageWithStatus copyWith({
    ChatMessage? message,
    MessageStatus? status,
  }) {
    return ChatMessageWithStatus(
      message: message ?? this.message,
      status: status ?? this.status,
    );
  }
}

class ChatProvider extends ChangeNotifier {
  final AppEnvironment environment;

  late final OpenAIService _openAI = OpenAIService(
    env: environment,
    client: ApiClient.create(env: environment),
  );

  ChatProvider({required this.environment}) {
    _addInitialMessage();
  }

  final List<ChatMessageWithStatus> _messages = <ChatMessageWithStatus>[];
  bool _isTyping = false;
  String? _lastError;

  List<ChatMessageWithStatus> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  String? get lastError => _lastError;
  bool get hasMessages => _messages.isNotEmpty;

  void _addInitialMessage() {
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessageWithStatus(
          message: ChatMessage(
            id: 'welcome',
            role: ChatRole.assistant,
            content: 'Hello! I\'m your AI assistant. How can I help you today?',
            timestamp: DateTime.now(),
          ),
        ),
      );
      notifyListeners();
    }
  }

  void addUserMessage(String content) {
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.user,
      content: content.trim(),
      timestamp: DateTime.now(),
    );

    _messages.add(ChatMessageWithStatus(message: msg, status: MessageStatus.sent));
    _lastError = null;
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isTyping) return;

    addUserMessage(content);

    _isTyping = true;
    _lastError = null;
    notifyListeners();

    // Add typing indicator
    _messages.add(
      ChatMessageWithStatus(
        message: ChatMessage(
          id: 'typing_${DateTime.now().millisecondsSinceEpoch}',
          role: ChatRole.assistant,
          content: '',
          timestamp: DateTime.now(),
        ),
        status: MessageStatus.typing,
      ),
    );
    notifyListeners();

    try {
      // Build conversation history for API
      final conversationMessages = _buildConversationHistory();

      final reply = await _openAI.sendChatCompletion(
        messages: conversationMessages,
        temperature: 0.7,
      );

      // Remove typing indicator and add real response
      _messages.removeWhere((msg) => msg.status == MessageStatus.typing);

      final assistantMsg = ChatMessage(
        id: 'assistant_${DateTime.now().millisecondsSinceEpoch}',
        role: ChatRole.assistant,
        content: reply,
        timestamp: DateTime.now(),
      );

      _messages.add(ChatMessageWithStatus(message: assistantMsg));
    } catch (e) {
      // Remove typing indicator and add error message
      _messages.removeWhere((msg) => msg.status == MessageStatus.typing);

      final errorMsg = ChatMessage(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        role: ChatRole.assistant,
        content: 'Sorry, I encountered an error: ${e.toString()}. Please try again.',
        timestamp: DateTime.now(),
      );

      _messages.add(ChatMessageWithStatus(message: errorMsg, status: MessageStatus.error));
      _lastError = e.toString();
    }

    _isTyping = false;
    notifyListeners();
  }

  List<Map<String, String>> _buildConversationHistory() {
    final history = <Map<String, String>>[];

    // Add system message
    history.add(const {
      'role': 'system',
      'content': 'You are LifeOS, a helpful AI assistant. Provide clear, concise, and accurate responses. You have access to information and can help with various tasks.',
    });

    // Add conversation history (excluding typing indicators and errors)
    for (final msg in _messages) {
      if (msg.status != MessageStatus.typing && msg.status != MessageStatus.error) {
        history.add({
          'role': msg.message.role == ChatRole.user ? 'user' : 'assistant',
          'content': msg.message.content,
        });
      }
    }

    return history;
  }

  void clearConversation() {
    _messages.clear();
    _lastError = null;
    _isTyping = false;
    _addInitialMessage();
  }

  void retryLastMessage() {
    if (_messages.isEmpty || !_messages.last.message.content.contains('error')) return;

    // Find the last user message and retry
    final lastUserMsg = _messages.lastWhere(
      (msg) => msg.message.role == ChatRole.user,
      orElse: () => _messages.first,
    );

    if (lastUserMsg.message.role == ChatRole.user) {
      sendMessage(lastUserMsg.message.content);
    }
  }
}
