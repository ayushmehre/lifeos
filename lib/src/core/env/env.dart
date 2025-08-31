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
    // Use const compile-time reads; provide safe defaults to avoid runtime crash
    const appName = String.fromEnvironment('APP_NAME', defaultValue: 'Lifeos');
    const openAIApiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    const openAIBaseUrl = String.fromEnvironment(
      'OPENAI_BASE_URL',
      defaultValue: 'https://api.openai.com/v1',
    );
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    const supabaseServiceRoleKey = String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY', defaultValue: '');
    const supabaseEdgeBaseUrl = String.fromEnvironment('SUPABASE_EDGE_BASE_URL', defaultValue: '');

    return AppEnvironment(
      appName: appName,
      openAIApiKey: openAIApiKey,
      openAIBaseUrl: openAIBaseUrl,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      supabaseServiceRoleKey: supabaseServiceRoleKey,
      supabaseEdgeBaseUrl: supabaseEdgeBaseUrl,
    );
  }
}
