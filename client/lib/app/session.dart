import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SessionStatus { unknown, authed }

final sessionProvider = StateProvider<SessionStatus>((ref) {
  // В реальном приложении здесь будет проверка аутентификации пользователя
  // Пока возвращаем фиктивное значение
  return SessionStatus.authed; // Предполагаем, что пользователь всегда аутентифицирован для демонстрации
});