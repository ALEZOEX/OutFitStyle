import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для состояния аутентификации
final authStateProvider = StateProvider<bool>((ref) => false);

// Провайдер для ID пользователя
final userIdProvider = StateProvider<String?>((ref) => null);
