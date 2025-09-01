import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

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

  // Editing state
  String? _editingMessageId;
  final TextEditingController _editController = TextEditingController();

  // Speech recognition
  SpeechToText? _speechToText;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    _speechToText = SpeechToText();
    await _speechToText!.initialize(
      onStatus: (status) {
        setState(() {
          _isListening = status == 'listening';
        });
      },
      onError: (error) {
        setState(() {
          _isListening = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech recognition error: $error')),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _focusNode.dispose();
    _editController.dispose();
    _speechToText?.stop();
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
        content: const Text(
          'This will delete all messages in the current chat.',
        ),
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

  void _showMessageActions(ChatMessageWithStatus msgWithStatus) {
    final message = msgWithStatus.message;
    final canEdit = message.role == ChatRole.user && msgWithStatus.status != MessageStatus.typing;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy message'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied to clipboard')),
                );
              },
            ),
            if (canEdit)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit message'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _startEditing(message);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete message', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(ctx).pop();
                _deleteMessage(message.id);
              },
            ),
          ],
        ),
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

    final chat = context.read<ChatProvider>();
    await chat.editMessage(_editingMessageId!, newContent);

    setState(() {
      _editingMessageId = null;
      _editController.clear();
    });
  }

  void _deleteMessage(String messageId) {
    final chat = context.read<ChatProvider>();
    chat.deleteMessage(messageId);
  }

  Future<void> _startListening() async {
    if (_speechToText == null || !_speechToText!.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    if (_isListening) {
      await _speechToText!.stop();
      setState(() {
        _isListening = false;
      });
      return;
    }

    setState(() {
      _isListening = true;
    });

    await _speechToText!.listen(
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
          if (result.finalResult) {
            _isListening = false;
          }
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
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

                      final isEditing = _editingMessageId == m.id;

                      final alignment = m.role == ChatRole.user
                          ? Alignment.centerRight
                          : Alignment.centerLeft;

                      final color = m.role == ChatRole.user
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface;

                      final textColor = m.role == ChatRole.user
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface;

                      final borderColor =
                          msgWithStatus.status == MessageStatus.error
                            ? Colors.red
                            : Theme.of(context).dividerColor.withOpacity(0.2);

                      return Align(
                        alignment: alignment,
                        child: GestureDetector(
                          onLongPress: () => _showMessageActions(msgWithStatus),
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
                                if (isEditing)
                                  Column(
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
                                        style: TextStyle(color: textColor),
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
                                  )
                                else
                                  Column(
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
                                          if (msgWithStatus.status ==
                                              MessageStatus.error)
                                            IconButton(
                                              icon: const Icon(Icons.refresh, size: 16),
                                              onPressed: () => context
                                                  .read<ChatProvider>()
                                                  .retryLastMessage(),
                                              color: Colors.red,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                              ],
                            ),
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
                        hintText: _isListening ? 'Listening...' : 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic_off : Icons.mic,
                            color: _isListening ? Colors.red : null,
                          ),
                          onPressed: _startListening,
                          tooltip: _isListening ? 'Stop listening' : 'Start voice input',
                        ),
                      ),
                      onSubmitted: _handleSubmitted,
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: (chat.isTyping || _controller.text.trim().isEmpty) ? null : _send,
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
