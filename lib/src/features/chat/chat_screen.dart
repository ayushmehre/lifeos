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
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final chat = context.read<ChatProvider>();
    await chat.sendMessage(text);
    _controller.clear();

    // Auto-scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      _send();
    }
  }

  void _clearConversation() {
    final chat = context.read<ChatProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear conversation?'),
        content: const Text('This will delete all messages in the current chat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              chat.clearConversation();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          if (chat.hasMessages)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearConversation,
              tooltip: 'Clear conversation',
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: chat.messages.isEmpty
                ? const Center(
                    child: Text(
                      'Start a conversation by typing a message below',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    itemCount: chat.messages.length,
                    itemBuilder: (ctx, i) {
                      final msgWithStatus = chat.messages[i];
                      final m = msgWithStatus.message;

                      // Handle typing indicator
                      if (msgWithStatus.status == MessageStatus.typing) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final alignment = m.role == ChatRole.user
                          ? Alignment.centerRight
                          : Alignment.centerLeft;

                      final color = m.role == ChatRole.user
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface;

                      final textColor = m.role == ChatRole.user
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface;

                      final borderColor = msgWithStatus.status == MessageStatus.error
                          ? Colors.red
                          : Theme.of(context).dividerColor.withOpacity(0.2);

                      return Align(
                        alignment: alignment,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.content,
                                style: TextStyle(color: textColor),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTime(m.timestamp),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textColor.withOpacity(0.8),
                                    ),
                                  ),
                                  if (msgWithStatus.status == MessageStatus.error)
                                    IconButton(
                                      icon: const Icon(Icons.refresh, size: 16),
                                      onPressed: () => context.read<ChatProvider>().retryLastMessage(),
                                      color: Colors.red,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (chat.isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                children: const [
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
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _handleSubmitted,
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: chat.isTyping ? null : _send,
                    icon: const Icon(Icons.send),
                    label: const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
