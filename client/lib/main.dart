import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'src/config/app_config.dart';
import 'src/theme/app_theme.dart';
import 'src/navigation/app_navigation.dart';
import 'src/auth/session_manager.dart';
import 'src/core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: AppConfig.firebaseApiKey,
      appId: AppConfig.firebaseAppId,
      messagingSenderId: AppConfig.firebaseMessagingSenderId,
      projectId: AppConfig.firebaseProjectId,
    ),
  );

  // Инициализация SharedPreferences
  await SharedPreferences.getInstance();

  // Установка обработчиков ошибок
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Установка ориентации портрета
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Инициализация сервиса уведомлений
  await FirebaseNotificationService().initialize();

  // Запуск приложения с Riverpod
  runApp(
    const ProviderScope(
      child: OutfitStyleApp(),
    ),
  );
}

class OutfitStyleApp extends ConsumerWidget {
  const OutfitStyleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<SessionManager>(
      future: _initSessionManager(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        }

        final sessionManager = snapshot.data!;
        final appNavigation = AppNavigation(sessionManager);

        return MaterialApp.router(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system, // Используем системную тему по умолчанию
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('ru'), // Russian
          ],
          routerConfig: appNavigation.router,
          builder: (context, child) {
            // Добавляем глобальные обработчики ошибок
            ErrorWidget.builder = (FlutterErrorDetails details) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(AppLocalizations.of(context)?.error ?? 'Error'),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)?.somethingWentWrong ??
                            'Something went wrong',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(details.exceptionAsString()),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                            AppLocalizations.of(context)?.retry ?? 'Retry'),
                      ),
                    ],
                  ),
                ),
              );
            };

            return child!;
          },
        );
      },
    );
  }

  Future<SessionManager> _initSessionManager() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return SessionManager(FirebaseAuth.instance, sharedPreferences);
  }
}
