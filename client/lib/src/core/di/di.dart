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
final onboardingDoneProvider = StateNotifierProvider<OnboardingDoneNotifier, bool>((ref) {
  return OnboardingDoneNotifier();
});

class OnboardingDoneNotifier extends StateNotifier<bool> {
  OnboardingDoneNotifier() : super(false) {
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool('onboarding_done_v1') ?? false;
      state = done;
    } catch (_) {
      state = false;
    }
  }

  Future<void> setDone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done_v1', true);
      state = true;
    } catch (_) {
      // Игнорируем ошибку, но не меняем состояние
    }
  }

  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_done_v1');
      state = false;
    } catch (_) {
      // Игнорируем ошибку
    }
  }
}

// Провайдер для управления темой
final themeModeProvider = StateProvider((ref) => ThemeMode.system);