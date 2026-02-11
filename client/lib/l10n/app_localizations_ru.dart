// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'OutfitStyle';

  @override
  String get welcomeMessage => 'Добро пожаловать в OutfitStyle!';

  @override
  String get loading => 'Загрузка...';

  @override
  String get error => 'Ошибка';

  @override
  String get retry => 'Повторить';

  @override
  String get recommendations => 'Рекомендации';

  @override
  String get saved => 'Сохраненные';

  @override
  String get history => 'История';

  @override
  String get weather => 'Погода';

  @override
  String get outfit => 'Настрой';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get login => 'Вход';

  @override
  String get logout => 'Выход';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get signInWithGoogle => 'Войти через Google';

  @override
  String get noInternetConnection => 'Нет подключения к интернету';

  @override
  String get somethingWentWrong => 'Что-то пошло не так';
}
