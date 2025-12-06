import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'services/user_settings_service.dart';
import 'providers/theme_provider.dart';
import 'services/api_service.dart';
import 'services/shopping_service.dart';
import 'services/auth_storage.dart';
import 'services/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/navigation_screen.dart';
import 'screens/profile_screen.dart';

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
        // Теперь ApiService тоже получает baseUrl
        Provider<ApiService>(
          create: (_) => ApiService(baseUrl: apiBaseUrl),
        ),

        Provider<ShoppingService>(create: (_) => ShoppingService()),

        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),

        Provider<AuthStorage>.value(value: authStorage),

        Provider<AuthService>(
          create: (_) => AuthService(baseUrl: apiBaseUrl),
        ),

        Provider<UserSettingsService>(
          create: (_) => UserSettingsService(
            baseUrl: apiBaseUrl,
            authStorage: authStorage,
          ),
        ),
      ],
      child: MyApp(
        initialRoute: token != null ? '/home' : '/auth',
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

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
      initialRoute: initialRoute,
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const NavigationScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}