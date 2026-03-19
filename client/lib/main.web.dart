// Web-версия main entry point
// Firebase web пакеты несовместимы с текущей версией Flutter
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

  // Firebase web временно отключён из-за проблем совместимости
  debugPrint('🌐 Web: Запуск без Firebase (режим совместимости)');
  debugPrint('📝 Некоторые функции могут быть ограничены');

  // Инициализация обработчика ошибок
  await ErrorHandler.init();

  runApp(ProviderScope(child: const OutfitStyleApp()));
}
