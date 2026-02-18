import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/presentation/app/app.dart';
import 'src/core/error/error_handler.dart';
import 'src/presentation/routing/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase (safely, without crashing if not configured)
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully');
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('⚠️ Firebase not configured: $e');
    debugPrint('📝 Running without Firebase (some features may be limited)');
  }

  // Initialize error handler (only if Firebase is available)
  if (firebaseInitialized) {
    await ErrorHandler.init();
    debugPrint('✅ Crashlytics enabled');
  } else {
    debugPrint('⚠️ Crashlytics disabled (Firebase not available)');
  }

  runApp(
    ProviderScope(
      // DI живёт через providers в lib/app/di.dart
      child: Consumer(
        builder: (context, ref, child) {
          // Инициализируем проверку авторизации при старте
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(authStateProvider.notifier).checkAuth();
          });
          return const OutfitStyleApp();
        },
      ),
    ),
  );
}
