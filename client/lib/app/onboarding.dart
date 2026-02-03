import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingDoneProvider = StateProvider<bool>((ref) {
  // В реальном приложении здесь будет проверка, завершен ли онбординг
  // Пока возвращаем фиктивное значение
  return true; // Предполагаем, что онбординг всегда завершен для демонстрации
});
