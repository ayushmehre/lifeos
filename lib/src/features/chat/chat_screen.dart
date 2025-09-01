import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/ui_constants.dart';
import '../../shared/widgets/message_bubble.dart';
import '../../shared/widgets/chat_input.dart';
import 'model/message.dart';
import 'state/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  String? _editingMessageId;
  final TextEditingController _editController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _editController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    await chatProvider.sendMessage(text);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: UiConstants.scrollAnimationDuration,
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showMessageActions(ChatMessageWithStatus messageWithStatus) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MessageActionsSheet(
        messageWithStatus: messageWithStatus,
        onCopy: () {},
        onEdit: messageWithStatus.message.role == ChatRole.user
            ? () => _startEditing(messageWithStatus.message)
            : null,
        onDelete: () => _deleteMessage(messageWithStatus.message.id),
      ),
    );
  }

  void _startEditing(ChatMessage message) {
    setState(() {
      _editingMessageId = message.id;
      _editController.text = message.content;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingMessageId = null;
      _editController.clear();
    });
  }

  Future<void> _saveEdit() async {
    if (_editingMessageId == null) return;

    final newContent = _editController.text.trim();
    if (newContent.isEmpty) {
      _cancelEditing();
      return;
    }

    final chatProvider = context.read<ChatProvider>();
    await chatProvider.editMessage(_editingMessageId!, newContent);

    setState(() {
      _editingMessageId = null;
      _editController.clear();
    });
  }

  void _deleteMessage(String messageId) {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.deleteMessage(messageId);
  }

  void _clearConversation() {
    final chatProvider = context.read<ChatProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(UiStrings.clearConversationTitle),
        content: Text(UiStrings.clearConversationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(UiStrings.cancelButtonLabel),
          ),
          TextButton(
            onPressed: () {
              chatProvider.clearConversation();
              Navigator.of(context).pop();
            },
            child: Text(UiStrings.clearButtonLabel),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          if (chatProvider.hasMessages)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearConversation,
              tooltip: 'Clear conversation',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.messages.isEmpty
                ? const Center(
                    child: Text(
                      'Start a conversation by typing a message below',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final messageWithStatus = chatProvider.messages[index];

                      if (_editingMessageId == messageWithStatus.message.id) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _editController,
                                  maxLines: null,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Edit message...',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                  onSubmitted: (_) => _saveEdit(),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: _saveEdit,
                                      child: const Text('Save'),
                                    ),
                                    TextButton(
                                      onPressed: _cancelEditing,
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return MessageBubble(
                        messageWithStatus: messageWithStatus,
                        onLongPress: () =>
                            _showMessageActions(messageWithStatus),
                        onRetryTap:
                            messageWithStatus.status == MessageStatus.error
                            ? () => chatProvider.retryLastMessage()
                            : null,
                      );
                    },
                  ),
          ),
          if (chatProvider.isTyping)
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
          ChatInput(
            controller: _controller,
            focusNode: _focusNode,
            isTyping: chatProvider.isTyping,
            onSend: _sendMessage,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _sendMessage();
              }
            },
          ),
        ],
      ),
    );
  }
}
