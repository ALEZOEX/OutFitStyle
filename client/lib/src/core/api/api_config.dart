class ApiConfig {
  final String apiBase;
  final String apiKey;
  final Duration timeout;

  ApiConfig({
    required this.apiBase,
    required this.apiKey,
    this.timeout = const Duration(seconds: 30),
  });

  factory ApiConfig.dev() => ApiConfig(
        apiBase: 'https://api.outfitstyle.dev',
        apiKey: 'dev-key-not-for-production',
      );

  factory ApiConfig.prod() => ApiConfig(
        apiBase: 'https://api.outfitstyle.com',
        apiKey: 'prod-key-placeholder',
      );
}