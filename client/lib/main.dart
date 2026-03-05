import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'src/presentation/app/app.dart';
import 'src/core/config/build_stamp.dart';

/// Provider для инициализации Firebase
final firebaseInitProvider = FutureProvider<void>((ref) async {
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('📝 Web-версия: Firebase инициализирован');
  }
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Выводим build stamp
  BuildStamp.printStamp();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      child: const _FirebaseInitWrapper(
        child: OutfitStyleApp(),
      ),
    ),
  );
}

/// Виджет для инициализации Firebase внутри ProviderScope
class _FirebaseInitWrapper extends ConsumerWidget {
  final Widget child;

  const _FirebaseInitWrapper({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Инициализируем Firebase асинхронно
    ref.watch(firebaseInitProvider);
    return child;
  }
}
