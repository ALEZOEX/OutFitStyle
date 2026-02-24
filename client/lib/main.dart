import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/presentation/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase работает только на mobile (iOS/Android)
  // На web Firebase требует firebase_options.dart который нужно генерировать через flutterfire configure
  if (!kIsWeb) {
    // ErrorHandler.init() - требует Firebase
    debugPrint('📱 Mobile-версия: Firebase будет инициализирован в AuthService');
  } else {
    debugPrint('📝 Web-версия: Firebase отключён (требуется firebase_options.dart)');
  }

  runApp(
    ProviderScope(
      child: const OutfitStyleApp(),
    ),
  );
}
