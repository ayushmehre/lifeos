import 'package:dio/dio.dart';

import '../env/env.dart';
import 'api_client.dart';

class OpenAIService {
  final AppEnvironment env;
  final ApiClient client;

  OpenAIService({required this.env, required this.client});

  /// Sends a non-streaming chat completion request.
  /// [messages] should be a list like: [{'role': 'user', 'content': '...'}, ...]
  Future<String> sendChatCompletion({
    required List<Map<String, String>> messages,
    String model = 'gpt-4o-mini',
    double temperature = 0.7,
  }) async {
    final dio = client.dio;
    final Response<dynamic> res = await dio.post(
      '${env.openAIBaseUrl}/chat/completions',
      options: Options(
        headers: <String, String>{
          'Authorization': 'Bearer ${env.openAIApiKey}',
          'Content-Type': 'application/json',
        },
      ),
      data: <String, dynamic>{
        'model': model,
        'temperature': temperature,
        'messages': messages,
      },
    );

    // OpenAI returns: { choices: [ { message: { role, content } } ] }
    final dynamic choices = res.data['choices'];
    if (choices is List && choices.isNotEmpty) {
      final dynamic message = choices.first['message'];
      if (message is Map && message['content'] is String) {
        return message['content'] as String;
      }
    }
    throw StateError('Unexpected OpenAI response format');
  }
}
