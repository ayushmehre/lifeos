import 'package:flutter/material.dart';

import '../../../core/env/env.dart';
import '../model/message.dart';

class ChatProvider extends ChangeNotifier {
  final AppEnvironment environment;

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
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _messages.add(ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      role: ChatRole.assistant,
      content: 'I received your message: "' + prompt + '". This is a simulated response. API wiring is ready.',
      timestamp: DateTime.now(),
    ));
    _isLoading = false;
    notifyListeners();
  }
}


