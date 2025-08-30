// Create AppEnvironment to read dart-define variables at startup

class AppEnvironment {
  final String appName;
  final String openAIApiKey;
  final String openAIBaseUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String supabaseServiceRoleKey;
  final String supabaseEdgeBaseUrl;

  const AppEnvironment({
    required this.appName,
    required this.openAIApiKey,
    required this.openAIBaseUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.supabaseServiceRoleKey,
    required this.supabaseEdgeBaseUrl,
  });

  static AppEnvironment loadFromDartDefine() {
    String read(String name, {String? fallback}) {
      const env = String.fromEnvironment;
      final value = env(name);
      if (value.isEmpty) {
        if (fallback != null) return fallback;
        throw StateError('Missing required dart-define: ' + name);
      }
      return value;
    }

    return AppEnvironment(
      appName: read('APP_NAME', fallback: 'Lifeos'),
      openAIApiKey: read('OPENAI_API_KEY'),
      openAIBaseUrl: read(
        'OPENAI_BASE_URL',
        fallback: 'https://api.openai.com/v1',
      ),
      supabaseUrl: read('SUPABASE_URL'),
      supabaseAnonKey: read('SUPABASE_ANON_KEY'),
      supabaseServiceRoleKey: read('SUPABASE_SERVICE_ROLE_KEY', fallback: ''),
      supabaseEdgeBaseUrl: read('SUPABASE_EDGE_BASE_URL'),
    );
  }
}
