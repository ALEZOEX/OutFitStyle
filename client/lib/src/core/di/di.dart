import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

// Minimal DI setup to avoid circular dependencies and missing files
// Core
final loggerProvider = Provider((ref) => Logger());

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

// Session provider (using the existing session file)
enum SessionStatus { unknown, authed }

final sessionProvider = StateProvider<SessionStatus>((ref) {
  // В реальном приложении здесь будет проверка аутентификации пользователя
  // Пока возвращаем фиктивное значение
  return SessionStatus
      .authed; // Предполагаем, что пользователь всегда аутентифицирован для демонстрации
});

// Providers for onboarding
final onboardingDoneProvider = StateProvider<bool>((ref) {
  // В реальном приложении здесь будет проверка, завершен ли онбординг
  // Пока возвращаем фиктивное значение
  return true; // Предполагаем, что онбординг всегда завершен для демонстрации
});

// Провайдер для управления темой
final themeModeProvider = StateProvider((ref) => ThemeMode.system);