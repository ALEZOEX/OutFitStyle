import 'package:flutter/foundation.dart';
import 'lib/domain/entities/recommendation_entity.dart';
import 'lib/ui/atoms/haptics.dart';

void main() {
  // Создаем тестовый объект
  final testRec = RecommendationRow(
    id: 'test',
    origin: 'test',
    outfitDataJson: '{}',
    weatherDataJson: '{}',
    isFavorite: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    dirty: true,
  );

  // Условный вывод отладочной информации
  debugPrint('Test object created: ${testRec.id}');
  Haptics.selection();
}