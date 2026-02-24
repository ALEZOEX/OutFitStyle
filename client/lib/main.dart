import 'package:firebase_core/firebase_core.dart';
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

  // Инициализация Firebase (безопасно, без сбоев если не настроен)
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase успешно инициализирован');
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('⚠️ Firebase не настроен: $e');
    debugPrint('📝 Запуск без Firebase (некоторые функции могут быть ограничены)');
  }

  // Инициализация обработчика ошибок (только если Firebase доступен)
  if (firebaseInitialized) {
    await ErrorHandler.init();
    debugPrint('✅ Crashlytics включён');
  } else {
    debugPrint('⚠️ Crashlytics отключён (Firebase недоступен)');
  }

  runApp(
    ProviderScope(
      child: const OutfitStyleApp(),
    ),
  );
}
