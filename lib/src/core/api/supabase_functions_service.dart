import 'package:dio/dio.dart';

import '../env/env.dart';
import 'api_client.dart';

class SupabaseFunctionsService {
  final AppEnvironment env;
  final ApiClient client;

  SupabaseFunctionsService({required this.env, required this.client});

  /// Generic invoke for a function name.
  Future<Response<dynamic>> invoke(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    final dio = client.dio;
    final url = '${env.supabaseEdgeBaseUrl}/$functionName';

    return dio.post(
      url,
      options: Options(
        headers: <String, String>{
          'Authorization': 'Bearer ${env.supabaseAnonKey}',
          'Content-Type': 'application/json',
        },
      ),
      data: body ?? const <String, dynamic>{},
    );
  }

  /// Example specific endpoints you might have:
  Future<Response<dynamic>> logEvent({required String name, Map<String, dynamic>? payload}) {
    return invoke('log-event', body: <String, dynamic>{'name': name, 'payload': payload ?? <String, dynamic>{}});
  }

  Future<Response<dynamic>> search({required String query}) {
    return invoke('search', body: <String, dynamic>{'q': query});
  }
}
