/// Build stamp — генерируется при сборке
/// Заполняется через --dart-define при flutter build web
class BuildStamp {
  /// Commit SHA (из git)
  static const String commitSha = String.fromEnvironment(
    'COMMIT_SHA',
    defaultValue: 'unknown',
  );

  /// Дата сборки
  static const String buildDate = String.fromEnvironment(
    'BUILD_DATE',
    defaultValue: 'unknown',
  );

  /// Версия приложения
  static const String version = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  /// Получить полную информацию о сборке
  static String get info {
    return 'v$version | $commitSha | $buildDate';
  }

  /// Вывести информацию о сборке в консоль
  static void printStamp() {
    print('🏗️  Build: $info');
  }
}
