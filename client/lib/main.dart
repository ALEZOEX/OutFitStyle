import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'services/user_settings_service.dart';
import 'providers/theme_provider.dart';
import 'services/api_service.dart';
import 'services/shopping_service.dart';
import 'services/auth_storage.dart';
import 'services/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/navigation_screen.dart';
import 'screens/profile_screen.dart';

// Можно переопределить при билде: --dart-define=API_BASE_URL=http://...
const String _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080/api/v1',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Стартовый стиль системы (потом в MyApp будет подстраиваться под тему)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final authStorage = AuthStorage();
  final token = await authStorage.readAccessToken();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<ShoppingService>(create: (_) => ShoppingService()),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        // Хранилище токена/ID пользователя
        Provider<AuthStorage>.value(value: authStorage),

        // Сервис аутентификации (login/register/verify/google)
        Provider<AuthService>(create: (_) => AuthService()),

        // Сервис пользовательских настроек (профиль)
        Provider<UserSettingsService>(
          create: (_) => UserSettingsService(
            baseUrl: _apiBaseUrl,
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

    // Подстраиваем цвет статусбара под текущую тему
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
