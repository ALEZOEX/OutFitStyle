import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/presentation/app/app.dart';
import 'src/core/error/error_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase не используется на web — инициализация только для mobile
  // debugPrint('📝 Firebase отключён на web');
  // debugPrint('⚠️ Crashlytics отключён (Firebase недоступен)');

  runApp(
    ProviderScope(
      child: const OutfitStyleApp(),
    ),
  );
}
