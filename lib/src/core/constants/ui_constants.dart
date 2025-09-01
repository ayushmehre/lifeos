class UiConstants {
  static const double messageMaxWidthRatio = 0.8;
  static const double messageBorderRadius = 14;
  static const double messagePaddingHorizontal = 12;
  static const double messagePaddingVertical = 10;
  static const double messageMarginVertical = 6;
  static const double messageTimestampFontSize = 11;
  static const double inputBorderRadius = 20;
  static const double inputPaddingHorizontal = 16;
  static const double inputPaddingVertical = 12;
  static const double typingIndicatorSize = 20;
  static const double typingIndicatorStrokeWidth = 2;
  static const int inputMaxLines = 4;
  static const Duration scrollAnimationDuration = Duration(milliseconds: 250);
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration speechListenDuration = Duration(seconds: 30);
  static const Duration speechPauseDuration = Duration(seconds: 3);
}

class UiStrings {
  static const String welcomeMessage = 'Hello! I\'m your AI assistant. How can I help you today?';
  static const String aiThinkingMessage = 'AI is thinking...';
  static const String listeningHint = 'Listening...';
  static const String typeMessageHint = 'Type your message...';
  static const String stopListeningTooltip = 'Stop listening';
  static const String startVoiceInputTooltip = 'Start voice input';
  static const String sendButtonLabel = 'Send';
  static const String clearConversationTitle = 'Clear conversation?';
  static const String clearConversationMessage = 'This will delete all messages in the current chat.';
  static const String cancelButtonLabel = 'Cancel';
  static const String clearButtonLabel = 'Clear';
  static const String copyActionLabel = 'Copy message';
  static const String editActionLabel = 'Edit message';
  static const String deleteActionLabel = 'Delete message';
  static const String editMessageHint = 'Edit message...';
  static const String saveButtonLabel = 'Save';
  static const String speechNotAvailableMessage = 'Speech recognition not available';
  static const String speechErrorMessage = 'Speech recognition error: ';
  static const String messageCopiedMessage = 'Message copied to clipboard';
  static const String apiErrorPrefix = 'Sorry, I encountered an error: ';
  static const String retryMessageSuffix = '. Please try again.';
}
