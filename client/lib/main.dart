import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'src/presentation/app/app.dart';
import 'src/core/config/build_stamp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Выводим build stamp
  BuildStamp.printStamp();

  // Инициализируем Firebase на web и mobile
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('📝 Web-версия: Firebase инициализирован');
  } else {
    // Mobile будет инициализирован в AuthService
    debugPrint('📱 Mobile-версия: Firebase будет инициализирован в AuthService');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      child: const OutfitStyleApp(),
    ),
  );
}
