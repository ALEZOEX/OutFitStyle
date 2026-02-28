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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'OutfitStyle'**
  String get appName;

  /// Welcome message displayed to the user
  ///
  /// In en, this message translates to:
  /// **'Welcome to OutfitStyle!'**
  String get welcomeMessage;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error text
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Recommendations tab title
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// Saved recommendations tab title
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// History tab title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Weather related text
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// Outfit related text
  ///
  /// In en, this message translates to:
  /// **'Outfit'**
  String get outfit;

  /// Profile related text
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings related text
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Google sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Message displayed when no internet connection
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Preferences screen title
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Clothing size section title
  ///
  /// In en, this message translates to:
  /// **'Clothing Size'**
  String get clothingSize;

  /// Preferred styles section title
  ///
  /// In en, this message translates to:
  /// **'Preferred Styles'**
  String get preferredStyles;

  /// Favorite brands section title
  ///
  /// In en, this message translates to:
  /// **'Favorite Brands'**
  String get favoriteBrands;

  /// Color preferences section title
  ///
  /// In en, this message translates to:
  /// **'Color Preferences'**
  String get colorPreferences;

  /// Budget section title
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// Save preferences button text
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get savePreferences;

  /// Onboarding: Welcome title
  ///
  /// In en, this message translates to:
  /// **'Welcome to OutfitStyle!'**
  String get onboardingWelcomeTitle;

  /// Onboarding: Welcome subtitle
  ///
  /// In en, this message translates to:
  /// **'Your personal style assistant'**
  String get onboardingWelcomeSubtitle;

  /// Onboarding: Welcome description
  ///
  /// In en, this message translates to:
  /// **'Get personalized outfit recommendations based on weather and your preferences'**
  String get onboardingWelcomeDescription;

  /// Onboarding: City selection title
  ///
  /// In en, this message translates to:
  /// **'Select your city'**
  String get onboardingCityTitle;

  /// Onboarding: City selection description
  ///
  /// In en, this message translates to:
  /// **'For accurate weather-based recommendations'**
  String get onboardingCityDescription;

  /// Onboarding: City search hint
  ///
  /// In en, this message translates to:
  /// **'Enter city name...'**
  String get onboardingCitySearchHint;

  /// Onboarding: City detect by IP
  ///
  /// In en, this message translates to:
  /// **'Detect automatically'**
  String get onboardingCityDetectByIp;

  /// Onboarding: City required error
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get onboardingCityRequired;

  /// Onboarding: Styles title
  ///
  /// In en, this message translates to:
  /// **'What styles do you like?'**
  String get onboardingStylesTitle;

  /// Onboarding: Styles description
  ///
  /// In en, this message translates to:
  /// **'Choose at least 3 styles'**
  String get onboardingStylesDescription;

  /// Onboarding: Styles minimum error
  ///
  /// In en, this message translates to:
  /// **'Select at least 3 styles'**
  String get onboardingStylesMinimum;

  /// Onboarding: Preferences title
  ///
  /// In en, this message translates to:
  /// **'Your preferences'**
  String get onboardingPreferencesTitle;

  /// Onboarding: Preferences description
  ///
  /// In en, this message translates to:
  /// **'Help us tailor recommendations for you'**
  String get onboardingPreferencesDescription;

  /// Onboarding: Budget label
  ///
  /// In en, this message translates to:
  /// **'Budget range'**
  String get onboardingBudgetLabel;

  /// Onboarding: Brands label
  ///
  /// In en, this message translates to:
  /// **'Favorite brands (optional)'**
  String get onboardingBrandsLabel;

  /// Onboarding: Brands hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Zara, H&M, Nike...'**
  String get onboardingBrandsHint;

  /// Onboarding: Complete title
  ///
  /// In en, this message translates to:
  /// **'Ready!'**
  String get onboardingCompleteTitle;

  /// Onboarding: Complete description
  ///
  /// In en, this message translates to:
  /// **'We've prepared your first recommendations'**
  String get onboardingCompleteDescription;

  /// Onboarding: Start button
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStartButton;

  /// Onboarding: Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNextButton;

  /// Onboarding: Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBackButton;

  /// Onboarding: Skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkipButton;

  /// Onboarding: Finish button
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinishButton;

  /// Onboarding: Style Casual
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get styleCasual;

  /// Onboarding: Style Sport
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get styleSport;

  /// Onboarding: Style Classic
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get styleClassic;

  /// Onboarding: Style Streetwear
  ///
  /// In en, this message translates to:
  /// **'Streetwear'**
  String get styleStreetwear;

  /// Onboarding: Style Business
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get styleBusiness;

  /// Onboarding: Style Minimalist
  ///
  /// In en, this message translates to:
  /// **'Minimalist'**
  String get styleMinimalist;

  /// Onboarding: Style Boho
  ///
  /// In en, this message translates to:
  /// **'Boho'**
  String get styleBoho;

  /// Onboarding: Style Preppy
  ///
  /// In en, this message translates to:
  /// **'Preppy'**
  String get stylePreppy;

  /// Onboarding: Budget Economy
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get budgetEconomy;

  /// Onboarding: Budget Medium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get budgetMedium;

  /// Onboarding: Budget Premium
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get budgetPremium;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
