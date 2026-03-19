class AppConfig {
  final bool enableAnalytics;
  final bool enableCrashlytics;
  final bool enableRemoteConfig;
  final String version;
  final String buildNumber;

  AppConfig({
    this.enableAnalytics = true,
    this.enableCrashlytics = true,
    this.enableRemoteConfig = true,
    this.version = '1.0.0',
    this.buildNumber = '1',
  });
}
