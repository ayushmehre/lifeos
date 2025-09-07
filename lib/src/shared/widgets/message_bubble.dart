import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/chat/model/message.dart';
import '../../features/chat/state/chat_provider.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessageWithStatus messageWithStatus;
  final VoidCallback? onLongPress;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onRetryTap;

  const MessageBubble({
    super.key,
    required this.messageWithStatus,
    this.onLongPress,
    this.onEditTap,
    this.onDeleteTap,
    this.onRetryTap,
  });

  @override
  Widget build(BuildContext context) {
    final message = messageWithStatus.message;

    if (messageWithStatus.status == MessageStatus.typing) {
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

    final alignment = message.role == ChatRole.user
        ? Alignment.centerRight
        : Alignment.centerLeft;

    final color = message.role == ChatRole.user
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surface;

    final textColor = message.role == ChatRole.user
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    final borderColor = messageWithStatus.status == MessageStatus.error
        ? Colors.red
        : Theme.of(context).dividerColor.withOpacity(0.2);

    return Align(
      alignment: alignment,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              Text(message.content, style: TextStyle(color: textColor)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                  if (messageWithStatus.status == MessageStatus.error &&
                      onRetryTap != null)
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 16),
                      onPressed: onRetryTap,
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hours = date.hour;
    final minutes = date.minute.toString().padLeft(2, '0');
    final ampm = hours >= 12 ? 'PM' : 'AM';
    final displayHours = (hours % 12 == 0) ? 12 : hours % 12;
    return '$displayHours:$minutes $ampm';
  }
}

class MessageActionsSheet extends StatelessWidget {
  final ChatMessageWithStatus messageWithStatus;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MessageActionsSheet({
    super.key,
    required this.messageWithStatus,
    this.onCopy,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final message = messageWithStatus.message;
    final canEdit =
        message.role == ChatRole.user &&
        messageWithStatus.status != MessageStatus.typing;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy message'),
            onTap: () async {
              if (onCopy != null) {
                await Clipboard.setData(ClipboardData(text: message.content));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message copied to clipboard'),
                    ),
                  );
                }
              }
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          if (canEdit && onEdit != null)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit message'),
              onTap: () {
                onEdit!();
                Navigator.of(context).pop();
              },
            ),
          if (onDelete != null)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete message',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                onDelete!();
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
