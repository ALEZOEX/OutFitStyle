import 'recommendation.dart';

class OutfitSet {
  final List<ClothingItem> items;
  final double confidence;
  final String reason;
  final Map<String, ClothingItem> itemsByCategory;

  OutfitSet({
    required this.items,
    required this.confidence,
    required this.reason,
  }) : itemsByCategory = _groupByCategory(items);

  static Map<String, ClothingItem> _groupByCategory(List<ClothingItem> items) {
    final Map<String, ClothingItem> grouped = {};
    for (var item in items) {
      grouped[item.category] = item;
    }
    return grouped;
  }

  ClothingItem? getItemByCategory(String category) {
    return itemsByCategory[category];
  }

  List<String> get categories => itemsByCategory.keys.toList();
}

class OutfitRecommendations {
  final OutfitSet topChoice;
  final List<OutfitSet> alternatives;
  final String weatherSummary;

  OutfitRecommendations({
    required this.topChoice,
    required this.alternatives,
    required this.weatherSummary,
  });

  factory OutfitRecommendations.fromItems(
    List<ClothingItem> allItems,
    double temperature,
    String weather,
  ) {
    // Сортируем по ML score
    final sortedItems = List<ClothingItem>.from(allItems)
      ..sort((a, b) => (b.mlScore ?? 0).compareTo(a.mlScore ?? 0));

    // Группируем по категориям
    final Map<String, List<ClothingItem>> byCategory = {};
    for (var item in sortedItems) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }

    // Создаем TOP комплект (лучший из каждой категории)
    final topItems = <ClothingItem>[];
    for (var category in byCategory.keys) {
      if (byCategory[category]!.isNotEmpty) {
        topItems.add(byCategory[category]!.first);
      }
    }

    final topConfidence = topItems.isEmpty
        ? 0.0
        : topItems.map((e) => e.mlScore ?? 0).reduce((a, b) => a + b) /
            topItems.length;

    final topChoice = OutfitSet(
      items: topItems,
      confidence: topConfidence,
      reason: _getRecommendationReason(temperature, weather, topConfidence),
    );

    // Создаем альтернативные комплекты
    final alternatives = <OutfitSet>[];

    // Альтернатива 1: Второй по рейтингу из каждой категории
    final alt1Items = <ClothingItem>[];
    for (var category in byCategory.keys) {
      if (byCategory[category]!.length > 1) {
        alt1Items.add(byCategory[category]![1]);
      }
    }
    if (alt1Items.length >= 2) {
      alternatives.add(OutfitSet(
        items: alt1Items,
        confidence: alt1Items.map((e) => e.mlScore ?? 0).reduce((a, b) => a + b) /
            alt1Items.length,
        reason: 'Альтернативный комфортный выбор',
      ));
    }

    // Альтернатива 2: Третий вариант
    final alt2Items = <ClothingItem>[];
    for (var category in byCategory.keys) {
      if (byCategory[category]!.length > 2) {
        alt2Items.add(byCategory[category]![2]);
      }
    }
    if (alt2Items.length >= 2) {
      alternatives.add(OutfitSet(
        items: alt2Items,
        confidence: alt2Items.map((e) => e.mlScore ?? 0).reduce((a, b) => a + b) /
            alt2Items.length,
        reason: 'Стильная альтернатива',
      ));
    }

    // Альтернатива 3: Микс (лучшие + вторые варианты)
    final alt3Items = <ClothingItem>[];
    var index = 0;
    for (var category in byCategory.keys) {
      final items = byCategory[category]!;
      if (items.isNotEmpty) {
        alt3Items.add(items[index % items.length]);
        index++;
      }
    }
    if (alt3Items.length >= 2 && alternatives.length < 3) {
      alternatives.add(OutfitSet(
        items: alt3Items,
        confidence: alt3Items.map((e) => e.mlScore ?? 0).reduce((a, b) => a + b) /
            alt3Items.length,
        reason: 'Сбалансированный вариант',
      ));
    }

    return OutfitRecommendations(
      topChoice: topChoice,
      alternatives: alternatives.take(3).toList(),
      weatherSummary: _getWeatherSummary(temperature, weather),
    );
  }

  static String _getRecommendationReason(
    double temp,
    String weather,
    double confidence,
  ) {
    if (confidence >= 0.9) {
      return 'Идеальный выбор для текущей погоды';
    } else if (confidence >= 0.8) {
      return 'Отличный вариант с высоким комфортом';
    } else if (confidence >= 0.7) {
      return 'Хороший выбор для таких условий';
    } else {
      return 'Подходящий вариант одежды';
    }
  }

  static String _getWeatherSummary(double temp, String weather) {
    if (temp < -10) {
      return 'Экстремальный холод';
    } else if (temp < 0) {
      return 'Морозная погода';
    } else if (temp < 10) {
      return 'Прохладно';
    } else if (temp < 20) {
      return 'Умеренная температура';
    } else if (temp < 28) {
      return 'Тепло';
    } else {
      return 'Жарко';
    }
  }
}