import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import '../routing/router.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';

/// Виджет для инициализации состояния авторизации
class AuthInitializer extends ConsumerStatefulWidget {
  final Widget child;

  const AuthInitializer({super.key, required this.child});

  @override
  ConsumerState<AuthInitializer> createState() => _AuthInitializerState();
}

class _AuthInitializerState extends ConsumerState<AuthInitializer> {
  @override
  void initState() {
    super.initState();
    // Инициализируем состояние авторизации при запуске
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authStateNotifier = ref.read(authStateProvider.notifier);
      authStateNotifier.checkAuth();

      // Инициализируем загрузку уведомлений и запускаем polling
      final notificationsNotifier = ref.read(notificationsProvider.notifier);
      notificationsNotifier.loadNotifications(refresh: true);
      notificationsNotifier.startPolling();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class OutfitStyleApp extends ConsumerWidget {
  const OutfitStyleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

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

    return AuthInitializer(
      child: MaterialApp.router(
        title: 'OutfitStyle',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
        locale: const Locale('ru'), // Принудительно русский язык
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
  }
}
