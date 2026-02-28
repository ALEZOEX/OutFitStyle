import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// Название приложения
  ///
  /// In ru, this message translates to:
  /// **'OutfitStyle'**
  String get appName;

  /// Приветственное сообщение, отображаемое пользователю
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать в OutfitStyle!'**
  String get welcomeMessage;

  /// Текст индикатора загрузки
  ///
  /// In ru, this message translates to:
  /// **'Загрузка...'**
  String get loading;

  /// Общий текст ошибки
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get error;

  /// Текст кнопки повтора
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// Заголовок вкладки рекомендаций
  ///
  /// In ru, this message translates to:
  /// **'Рекомендации'**
  String get recommendations;

  /// Заголовок вкладки сохраненных рекомендаций
  ///
  /// In ru, this message translates to:
  /// **'Сохраненные'**
  String get saved;

  /// Заголовок вкладки истории
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get history;

  /// Текст, связанный с погодой
  ///
  /// In ru, this message translates to:
  /// **'Погода'**
  String get weather;

  /// Текст, связанный с нарядом
  ///
  /// In ru, this message translates to:
  /// **'Настрой'**
  String get outfit;

  /// Текст, связанный с профилем
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profile;

  /// Текст, связанный с настройками
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// Текст кнопки входа
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get login;

  /// Текст кнопки выхода
  ///
  /// In ru, this message translates to:
  /// **'Выход'**
  String get logout;

  /// Метка поля электронной почты
  ///
  /// In ru, this message translates to:
  /// **'Электронная почта'**
  String get email;

  /// Метка поля пароля
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// Текст кнопки входа через Google
  ///
  /// In ru, this message translates to:
  /// **'Войти через Google'**
  String get signInWithGoogle;

  /// Сообщение, отображаемое при отсутствии подключения к интернету
  ///
  /// In ru, this message translates to:
  /// **'Нет подключения к интернету'**
  String get noInternetConnection;

  /// Общее сообщение об ошибке
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так'**
  String get somethingWentWrong;

  /// Заголовок экрана предпочтений
  ///
  /// In ru, this message translates to:
  /// **'Предпочтения'**
  String get preferences;

  /// Текст кнопки сохранения
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// Заголовок секции размера одежды
  ///
  /// In ru, this message translates to:
  /// **'Размер одежды'**
  String get clothingSize;

  /// Заголовок секции предпочитаемых стилей
  ///
  /// In ru, this message translates to:
  /// **'Предпочитаемые стили'**
  String get preferredStyles;

  /// Заголовок секции любимых брендов
  ///
  /// In ru, this message translates to:
  /// **'Любимые бренды'**
  String get favoriteBrands;

  /// Заголовок секции цветовых предпочтений
  ///
  /// In ru, this message translates to:
  /// **'Цветовые предпочтения'**
  String get colorPreferences;

  /// Заголовок секции бюджета
  ///
  /// In ru, this message translates to:
  /// **'Бюджет'**
  String get budget;

  /// Текст кнопки сохранения предпочтений
  ///
  /// In ru, this message translates to:
  /// **'Сохранить предпочтения'**
  String get savePreferences;

  /// Заголовок экрана заполнения профиля
  ///
  /// In ru, this message translates to:
  /// **'Заполните профиль'**
  String get completeProfileTitle;

  /// Приветствие на экране заполнения профиля
  ///
  /// In ru, this message translates to:
  /// **'Давайте познакомимся!'**
  String get letsGetAcquainted;

  /// Подзаголовок экрана заполнения профиля
  ///
  /// In ru, this message translates to:
  /// **'Заполните информацию о себе для персонализированных рекомендаций'**
  String get fillProfileForPersonalized;

  /// Текст кнопки добавления фото
  ///
  /// In ru, this message translates to:
  /// **'Добавить фото'**
  String get addPhoto;

  /// Текст кнопки выбора фото из галереи
  ///
  /// In ru, this message translates to:
  /// **'Выбрать из галереи'**
  String get selectFromGallery;

  /// Метка поля имени
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get name;

  /// Сообщение об ошибке, если имя не заполнено
  ///
  /// In ru, this message translates to:
  /// **'Введите имя'**
  String get nameRequired;

  /// Сообщение об ошибке, если имя слишком короткое
  ///
  /// In ru, this message translates to:
  /// **'Минимум 2 символа'**
  String get nameMinLength;

  /// Подсказка к полю имени
  ///
  /// In ru, this message translates to:
  /// **'Как к вам обращаться?'**
  String get howToAddressYou;

  /// Текст кнопки сохранения профиля
  ///
  /// In ru, this message translates to:
  /// **'Сохранить и продолжить'**
  String get saveAndContinue;

  /// Текст кнопки при сохранении
  ///
  /// In ru, this message translates to:
  /// **'Сохранение...'**
  String get saving;

  /// Подсказка о возможности изменения данных
  ///
  /// In ru, this message translates to:
  /// **'Вы сможете изменить эти данные в настройках профиля'**
  String get youCanChangeLater;

  /// Сообщение об ошибке сохранения
  ///
  /// In ru, this message translates to:
  /// **'Ошибка при сохранении: '**
  String get errorSaving;

  /// Сообщение об ошибке выбора фото
  ///
  /// In ru, this message translates to:
  /// **'Ошибка при выборе фото: '**
  String get errorSelectingPhoto;

  /// Сообщение об успешном обновлении профиля
  ///
  /// In ru, this message translates to:
  /// **'Профиль успешно обновлен'**
  String get profileUpdated;

  /// Сообщение об успешном обновлении аватара
  ///
  /// In ru, this message translates to:
  /// **'Аватар успешно обновлен'**
  String get avatarUpdated;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
