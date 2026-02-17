// Web-specific main entry point
// Firebase web packages are incompatible with current Flutter version
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

  // Firebase web is temporarily disabled due to compatibility issues
  debugPrint('🌐 Web: Running without Firebase (compatibility mode)');
  debugPrint('📝 Some features may be limited');

  // Initialize error handler
  await ErrorHandler.init();

  runApp(
    ProviderScope(
      child: const OutfitStyleApp(),
    ),
  );
}
