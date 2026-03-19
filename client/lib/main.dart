import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'src/presentation/app/app.dart';
import 'src/core/config/build_stamp.dart';

// Service Worker auto-update fix deployed - v1.0.1
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Выводим build stamp
  BuildStamp.printStamp();

  // Инициализируем Firebase ПЕРЕД ProviderScope
  if (kIsWeb) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('📝 Web-версия: Firebase инициализирован');
    } catch (e) {
      debugPrint('❌ Ошибка инициализации Firebase: $e');
    }
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(ProviderScope(child: const OutfitStyleApp()));
}
