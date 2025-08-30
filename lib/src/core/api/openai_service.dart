import 'package:dio/dio.dart';

import '../env/env.dart';
import 'api_client.dart';

class OpenAIService {
  final AppEnvironment env;
  final ApiClient client;

  OpenAIService({required this.env, required this.client});

  Future<Response<dynamic>> sendChatCompletion({required List<Map<String, String>> messages}) async {
    final dio = client.dio;
    return dio.post(
      env.openAIBaseUrl + '/chat/completions',
      options: Options(
        headers: <String, String>{
          'Authorization': 'Bearer ' + env.openAIApiKey,
          'Content-Type': 'application/json',
        },
      ),
      data: <String, dynamic>{
        'model': 'gpt-4o-mini',
        'messages': messages,
      },
    );
  }
}
