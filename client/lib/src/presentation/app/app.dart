import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import '../routing/router.dart';
import 'auth_gate.dart';
import '../../features/settings/presentation/screens/language_screen.dart';

class OutfitStyleApp extends StatefulWidget {
  const OutfitStyleApp({super.key});

  @override
  State<OutfitStyleApp> createState() => _OutfitStyleAppState();
}

class _OutfitStyleAppState extends State<OutfitStyleApp> {
  @override
  Widget build(BuildContext context) {
    // Используем Consumer внутри build для доступа к providers
    return Consumer(
      builder: (context, ref, child) {
        final router = ref.watch(appRouterProvider);
        final themeMode = ref.watch(themeModeProvider);
        final languageCode = ref.watch(currentLanguageProvider);

        // Определяем актуальную тему для настройки статус-бара
        final isDarkMode = themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                    Brightness.dark);

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDarkMode ? Brightness.light : Brightness.dark,
            statusBarBrightness:
                isDarkMode ? Brightness.dark : Brightness.light,
          ),
        );

        // AuthGate контролирует startup flow:
        // 1. Refresh при старте (1 раз)
        // 2. Запуск polling только при авторизованном пользователе
        // 3. Нет 401-спама при старте
        return AuthGate(
          child: MaterialApp.router(
            title: 'OutfitStyle',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeMode,
            routerConfig: router,
            locale: Locale(languageCode),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ru'), // Русский
              Locale('en'), // Английский
            ],
          ),
        );
      },
    );
  }
}
