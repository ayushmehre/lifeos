import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/message.dart';
import 'state/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final chat = context.read<ChatProvider>();
    chat.addUserMessage(text);
    _controller.clear();
    await chat.simulateAssistantResponse(text);
    if (_scroll.hasClients) {
      await _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: chat.messages.length,
            itemBuilder: (ctx, i) {
              final m = chat.messages[i];
              final alignment = m.role == ChatRole.user ? Alignment.centerRight : Alignment.centerLeft;
              final color = m.role == ChatRole.user ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface;
              final textColor = m.role == ChatRole.user ? Colors.white : Theme.of(context).colorScheme.onSurface;
              return Align(
                alignment: alignment,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                  ),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.content, style: TextStyle(color: textColor)),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(m.timestamp),
                        style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (chat.isLoading)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: const [
                SizedBox(width: 12),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('AI is thinking...'),
              ],
            ),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Type your message here...'
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                  label: const Text('Send'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime date) {
    final hours = date.hour;
    final minutes = date.minute.toString().padLeft(2, '0');
    final ampm = hours >= 12 ? 'PM' : 'AM';
    final displayHours = (hours % 12 == 0) ? 12 : hours % 12;
    return displayHours.toString() + ':' + minutes + ' ' + ampm;
  }
}


