import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'providers/wardrobe_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/profile_provider.dart';
import 'services/wardrobe_service.dart';
import 'services/recommendation_service.dart';
import 'services/user_settings_service.dart';
import 'providers/theme_provider.dart';
import 'services/api_service.dart';
import 'services/shopping_service.dart';
import 'services/auth_storage.dart';
import 'services/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/navigation_screen.dart';
import 'screens/password_reset_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_gate_screen.dart';

// Import newly added services and providers
import 'services/weather_service.dart';
import 'providers/weather_provider.dart';
import 'services/geo_service.dart';
import 'screens/onboarding_wizard_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/body_measurements_screen.dart';

/// Берём API_BASE_URL из --dart-define, если он передан при сборке.
/// Например:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
const String _envApiBaseUrl = String.fromEnvironment('API_BASE_URL');

/// Унифицированное вычисление baseUrl для backend API.
///
/// Приоритет:
/// 1) Если передали через --dart-define=API_BASE_URL, используем его.
/// 2) Иначе используем AppConfig.apiBaseUrl (с автоматическим /api/v1).
String _resolveApiBaseUrl() {
  // 1. Явный override через --dart-define
  if (_envApiBaseUrl.isNotEmpty) {
    return _envApiBaseUrl;
  }

  // 2. AppConfig.apiBaseUrl
  final base = AppConfig.apiBaseUrl;

  if (base.endsWith('/api/v1')) {
    return base;
  }

  return '$base/api/v1';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final apiBaseUrl = _resolveApiBaseUrl();
  // ignore: avoid_print
  print('✅ API base URL: $apiBaseUrl');

  final authStorage = AuthStorage();
  final token = await authStorage.readAccessToken();

  runApp(
    MultiProvider(
      providers: [
        Provider<ShoppingService>(create: (_) => ShoppingService()),

        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),

        Provider<AuthStorage>.value(value: authStorage),

        Provider<ApiService>(
          create: (context) => ApiService(
            baseUrl: apiBaseUrl,
            authStorage: authStorage,
          ),
        ),

        Provider<AuthService>(
          create: (context) => AuthService(
            baseUrl: apiBaseUrl,
            authStorage: authStorage,
          ),
        ),

        Provider<UserSettingsService>(
          create: (context) => UserSettingsService(
            baseUrl: apiBaseUrl,
            authStorage: authStorage,
          ),
        ),

        Provider<WeatherService>(
          create: (context) => WeatherService(
            baseUrl: apiBaseUrl,
            authStorage: authStorage,
          ),
        ),
        ChangeNotifierProvider<WeatherProvider>(
          create: (context) => WeatherProvider(
            context.read<WeatherService>(),
          ),
        ),

        Provider<GeoService>(
          create: (context) => GeoService(
            baseUrl: apiBaseUrl,
            authStorage: authStorage,
          ),
        ),

        Provider<WardrobeService>(
          create: (context) => WardrobeService(
            baseUrl: apiBaseUrl,
            authStorage: authStorage,
          ),
        ),

        ChangeNotifierProvider<WardrobeProvider>(
          create: (context) => WardrobeProvider(
            context.read<WardrobeService>(),
          ),
        ),

        Provider<RecommendationService>(
          create: (context) => RecommendationService(
            baseUrl: apiBaseUrl,
            authStorage: authStorage,
          ),
        ),

        ChangeNotifierProvider<RecommendationProvider>(
          create: (context) => RecommendationProvider(
            context.read<RecommendationService>(),
          ),
        ),

        ChangeNotifierProvider<ProfileProvider>(
          create: (context) => ProfileProvider(
            context.read<UserSettingsService>(),
          ),
        ),

        Provider<CatalogService>(
          create: (context) => CatalogService(
            baseUrl: apiBaseUrl,
            authStorage: authStorage,
          ),
        ),
        ChangeNotifierProvider<CatalogProvider>(
          create: (context) => CatalogProvider(
            context.read<CatalogService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    SystemChrome.setSystemUIOverlayStyle(
      themeProvider.isDarkMode
          ? const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0F172A),
        systemNavigationBarIconBrightness: Brightness.light,
      )
          : const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF0F2F5),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'OutfitStyle',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF007bff),
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF007bff),
          secondary: Color(0xFF6c757d),
          error: Color(0xFFdc3545),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF007bff),
        scaffoldBackgroundColor: const Color(0xFF1a1a2e),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF007bff),
          secondary: Color(0xFF6c757d),
          error: Color(0xFFdc3545),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru'), // Русский
        Locale('en'),
      ],
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashGateScreen(),
        '/auth': (context) => const AuthScreen(),
        '/onboarding': (_) => const OnboardingWizardScreen(),
        '/home': (context) => const NavigationScreen(),
        '/password-reset': (context) => const PasswordResetScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/preferences': (context) => const PreferencesScreen(),
        '/body-measurements': (context) => const BodyMeasurementsScreen(),
      },
    );
  }
}