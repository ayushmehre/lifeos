import 'package:flutter/material.dart';

import '../../../core/env/env.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/openai_service.dart';
import '../model/message.dart';

class ChatProvider extends ChangeNotifier {
  final AppEnvironment environment;

  late final OpenAIService _openAI = OpenAIService(
    env: environment,
    client: ApiClient.create(env: environment),
  );

  ChatProvider({required this.environment});

  final List<ChatMessage> _messages = <ChatMessage>[];
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  void addUserMessage(String content) {
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.user,
      content: content,
      timestamp: DateTime.now(),
    );
    _messages.add(msg);
    notifyListeners();
  }

  Future<void> simulateAssistantResponse(String prompt) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final reply = await _openAI.sendChatCompletion(
        messages: <Map<String, String>>[
          const {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': prompt},
        ],
      );
      _messages.add(
        ChatMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          role: ChatRole.assistant,
          content: reply,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      _messages.add(
        ChatMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          role: ChatRole.assistant,
          content: 'Failed to fetch AI response: $e',
          timestamp: DateTime.now(),
        ),
      );
    }
    _isLoading = false;
    notifyListeners();
  }
}
