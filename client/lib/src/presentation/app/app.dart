import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import '../routing/router.dart';
import 'auth_gate.dart';
import '../../features/settings/providers/language_provider.dart';
import '../../ui/widgets/service_worker_update_banner.dart';

class OutfitStyleApp extends ConsumerWidget {
  const OutfitStyleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final languageCode = ref.watch(currentLanguageProvider);

    return MaterialApp.router(
      title: 'OutfitStyle',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      locale: Locale(languageCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final brightness = MediaQuery.platformBrightnessOf(context);
        final isDark =
            themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system && brightness == Brightness.dark);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
          child: ServiceWorkerUpdateBanner(child: AuthGate(child: child!)),
        );
      },
    );
  }
}
