import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isTyping;
  final String? hintText;
  final VoidCallback? onSend;
  final Function(String)? onSubmitted;

  const ChatInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.isTyping = false,
    this.hintText,
    this.onSend,
    this.onSubmitted,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Speech recognition error: $error')),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _speechToText?.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (_speechToText == null || !_speechToText!.isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
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
          widget.controller.text = result.recognizedWords;
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

  void _handleSubmitted(String value) {
    if (value.trim().isNotEmpty && widget.onSubmitted != null) {
      widget.onSubmitted!(value);
    }
  }

  void _handleSend() {
    if (widget.controller.text.trim().isNotEmpty && widget.onSend != null) {
      widget.onSend!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: _isListening
                      ? 'Listening...'
                      : (widget.hintText ?? 'Type your message...'),
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
                    tooltip: _isListening
                        ? 'Stop listening'
                        : 'Start voice input',
                  ),
                ),
                onSubmitted: _handleSubmitted,
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed:
                  (widget.isTyping || widget.controller.text.trim().isEmpty)
                  ? null
                  : _handleSend,
              icon: const Icon(Icons.send),
              label: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
