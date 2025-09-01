import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechProvider extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  String _statusText = 'Tap the microphone to start listening';

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  String get statusText => _statusText;
  bool get isAvailable => _speechToText.isAvailable;

  Future<bool> initialize() async {
    final available = await _speechToText.initialize(
      onStatus: _onStatus,
      onError: (error) => _onError(error.errorMsg),
      debugLogging: false,
    );
    notifyListeners();
    return available;
  }

  void _onStatus(String status) {
    _isListening = _speechToText.isListening;
    _statusText = status;
    notifyListeners();
  }

  void _onError(String error) {
    _statusText = 'Error: $error';
    _isListening = false;
    notifyListeners();
  }

  Future<void> startListening({required Function(String) onResult}) async {
    if (!_speechToText.isAvailable) {
      _statusText = 'Speech recognition not available';
      notifyListeners();
      return;
    }

    _lastWords = '';
    _isListening = true;
    _statusText = 'Listening...';
    notifyListeners();

    await _speechToText.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        if (result.finalResult) {
          onResult(_lastWords);
          stopListening();
        }
        notifyListeners();
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    _statusText = 'Stopped listening';
    notifyListeners();
  }

  void reset() {
    _lastWords = '';
    _statusText = 'Tap the microphone to start listening';
    notifyListeners();
  }
}
