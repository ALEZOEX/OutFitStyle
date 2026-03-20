import '../../../../domain/entities/wardrobe_item.dart';
import '../../../../domain/entities/weather_data.dart';
import '../../../../domain/entities/user_preference.dart';
import '../../../../domain/entities/outfit_recommendation.dart';

/// Сервис генерации рекомендаций на основе:
/// - текущей погоды
/// - вещей из гардероба
/// - предпочтений пользователя
class RecommendationService {
  /// Сгенерировать рекомендацию
  OutfitRecommendation generate({
    required WeatherData weather,
    required List<WardrobeItem> wardrobeItems,
    required UserPreference preferences,
    String? occasion,
  }) {
    // Фильтруем вещи по погоде
    final suitableItems = _filterByWeather(wardrobeItems, weather);

    // Применяем предпочтения пользователя
    final preferredItems = _applyPreferences(suitableItems, preferences);

    // Подбираем комплект по категориям
    final outfitItems = _selectOutfitItems(preferredItems, occasion);

    // Генерируем название и описание
    final title = _generateTitle(weather, preferences, occasion);
    final description = _generateDescription(weather, preferences, outfitItems);

    return OutfitRecommendation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      recommendedItems:
          outfitItems
              .map((item) => item.name ?? '')
              .where((name) => name.isNotEmpty)
              .toList(),
      temperature: weather.temperature,
      weatherCondition: weather.condition,
      createdAt: DateTime.now(),
    );
  }

  /// Сгенерировать несколько рекомендаций
  List<OutfitRecommendation> generateMultiple({
    required WeatherData weather,
    required List<WardrobeItem> wardrobeItems,
    required UserPreference preferences,
    int count = 3,
  }) {
    final recommendations = <OutfitRecommendation>[];
    final occasions = ['casual', 'classic', 'sport', 'outdoor'];

    for (int i = 0; i < count && i < occasions.length; i++) {
      final recommendation = generate(
        weather: weather,
        wardrobeItems: wardrobeItems,
        preferences: preferences,
        occasion: occasions[i],
      );
      recommendations.add(recommendation);
    }

    return recommendations;
  }

  /// Фильтрация вещей по погодным условиям
  List<WardrobeItem> _filterByWeather(
    List<WardrobeItem> items,
    WeatherData weather,
  ) {
    final temperature = weather.temperature ?? 20;
    final condition = weather.condition?.toLowerCase() ?? 'clear';

    return items.where((item) {
      // Проверка по температуре с дефолтными значениями по категории
      final minTemp = item.minTemp ?? _getDefaultMinTemp(item.category ?? '');
      final maxTemp = item.maxTemp ?? _getDefaultMaxTemp(item.category ?? '');

      if (temperature < minTemp || temperature > maxTemp) {
        return false;
      }

      // Проверка по осадкам
      if (condition == 'rainy' || condition == 'rain') {
        if (item.rainOk != true &&
            item.category != 'top' &&
            item.category != 'bottom') {
          // Для верхней одежды и обуви проверяем защиту от дождя
          if (item.category == 'shoes' || item.category == 'outerwear') {
            if (item.rainOk != true) return false;
          }
        }
      }

      if (condition == 'snowy' || condition == 'snow') {
        if (item.snowOk != true &&
            item.category != 'top' &&
            item.category != 'bottom') {
          if (item.category == 'shoes' || item.category == 'outerwear') {
            if (item.snowOk != true && (item.warmthLevel ?? 0) < 3) {
              return false;
            }
          }
        }
      }

      if (condition == 'windy' || condition == 'wind') {
        if (item.windOk != true && item.category == 'headwear') {
          // Для головных уборов проверяем защиту от ветра
          if (item.windOk != true) return false;
        }
      }

      return true;
    }).toList();
  }

  /// Дефолтная минимальная температура по категории
  int _getDefaultMinTemp(String category) {
    return switch (category) {
      'shorts' => 20, // Шорты только в тепло
      'tshirt' => 18, // Футболки от 18°C
      'shirt' => 15, // Рубашки от 15°C
      'jeans' => 10, // Джинсы от 10°C
      'dress' => 18, // Платья от 18°C
      'shoes' => 5, // Обувь от 5°C
      'outerwear' => -10, // Верхняя одежда от -10°C
      _ => -100, // По умолчанию без ограничений
    };
  }

  /// Дефолтная максимальная температура по категории
  int _getDefaultMaxTemp(String category) {
    return switch (category) {
      'shorts' => 40, // Шорты до 40°C
      'tshirt' => 35, // Футболки до 35°C
      'shirt' => 30, // Рубашки до 30°C
      'jeans' => 35, // Джинсы до 35°C
      'dress' => 35, // Платья до 35°C
      'shoes' => 40, // Обувь до 40°C
      'outerwear' => 15, // Верхняя одежда до 15°C
      _ => 100, // По умолчанию без ограничений
    };
  }

  /// Применение предпочтений пользователя
  List<WardrobeItem> _applyPreferences(
    List<WardrobeItem> items,
    UserPreference preferences,
  ) {
    var filtered = items;

    // Фильтр по стилям
    final preferredStyles = preferences.preferredStyles;
    if (preferredStyles.isNotEmpty) {
      final styleFiltered =
          filtered.where((item) {
            final itemStyle = item.style?.toLowerCase() ?? '';
            return preferredStyles.any(
              (style) =>
                  itemStyle.contains(style.toLowerCase()) ||
                  style.toLowerCase().contains(itemStyle),
            );
          }).toList();

      // Если есть подходящие по стилю — используем их, иначе — все
      if (styleFiltered.isNotEmpty) {
        filtered = styleFiltered;
      }
    }

    // Фильтр по цветам
    final preferredColors = preferences.preferredColors;
    if (preferredColors.isNotEmpty) {
      final colorFiltered =
          filtered.where((item) {
            final itemColor = item.color?.toLowerCase() ?? '';
            return preferredColors.any(
              (color) =>
                  itemColor.contains(color.toLowerCase()) ||
                  color.toLowerCase().contains(itemColor),
            );
          }).toList();

      // Если есть подходящие по цвету — используем их, иначе — все
      if (colorFiltered.isNotEmpty) {
        filtered = colorFiltered;
      }
    }

    // Фильтр по брендам
    final preferredBrands = preferences.preferredBrands;
    if (preferredBrands.isNotEmpty) {
      final brandFiltered =
          filtered.where((item) {
            final itemBrand = item.brand?.toLowerCase() ?? '';
            return preferredBrands.any(
              (brand) =>
                  itemBrand.contains(brand.toLowerCase()) ||
                  brand.toLowerCase().contains(itemBrand),
            );
          }).toList();

      // Если есть подходящие по бренду — используем их, иначе — все
      if (brandFiltered.isNotEmpty) {
        filtered = brandFiltered;
      }
    }

    // Исключённые items
    final excludedItems = preferences.excludedItems;
    if (excludedItems.isNotEmpty) {
      filtered =
          filtered.where((item) {
            final itemId = item.id ?? '';
            final itemName = item.name?.toLowerCase() ?? '';
            return !excludedItems.any(
              (excluded) =>
                  itemId == excluded ||
                  itemName.contains(excluded.toLowerCase()),
            );
          }).toList();
    }

    // Сортировка по избранным
    filtered.sort((a, b) {
      final aFavorite = a.isFavorite ?? false;
      final bFavorite = b.isFavorite ?? false;
      // Сортируем: избранные первыми
      if (aFavorite && !bFavorite) return -1;
      if (!aFavorite && bFavorite) return 1;
      return 0;
    });

    return filtered;
  }

  /// Подбор вещей по категориям для создания комплекта
  List<WardrobeItem> _selectOutfitItems(
    List<WardrobeItem> items,
    String? occasion,
  ) {
    final selected = <WardrobeItem>[];

    // Категории в порядке приоритета
    final categories = [
      'top',
      'bottom',
      'outerwear',
      'shoes',
      'headwear',
      'accessory',
    ];

    // Определяем приоритет стилей в зависимости от случая
    final stylePriority = _getStylePriorityForOccasion(occasion);

    for (final category in categories) {
      final categoryItems =
          items.where((item) => item.category == category).toList();

      if (categoryItems.isEmpty) continue;

      // Сортируем по приоритету стиля
      categoryItems.sort((a, b) {
        final aStyle = a.style?.toLowerCase() ?? '';
        final bStyle = b.style?.toLowerCase() ?? '';

        final aIndex = stylePriority.indexWhere((s) => aStyle.contains(s));
        final bIndex = stylePriority.indexWhere((s) => bStyle.contains(s));

        if (aIndex != -1 && bIndex != -1) return aIndex.compareTo(bIndex);
        if (aIndex != -1) return -1;
        if (bIndex != -1) return 1;

        return 0;
      });

      // Выбираем 1-2 предмета из категории
      final itemCount = category == 'top' || category == 'accessory' ? 2 : 1;
      selected.addAll(categoryItems.take(itemCount));
    }

    // Ограничиваем общее количество предметов (5-7 оптимально)
    if (selected.length > 7) {
      return selected.sublist(0, 7);
    }

    return selected;
  }

  /// Приоритет стилей для случая
  List<String> _getStylePriorityForOccasion(String? occasion) {
    switch (occasion?.toLowerCase()) {
      case 'classic':
      case 'business':
      case 'work':
        return ['classic', 'business', 'casual', 'sport', 'outdoor'];
      case 'sport':
      case 'gym':
      case 'workout':
        return ['sport', 'casual', 'outdoor', 'classic'];
      case 'outdoor':
      case 'hiking':
      case 'camping':
        return ['outdoor', 'sport', 'casual', 'classic'];
      case 'casual':
      default:
        return ['casual', 'sport', 'classic', 'outdoor'];
    }
  }

  /// Генерация заголовка рекомендации
  String _generateTitle(
    WeatherData weather,
    UserPreference preferences,
    String? occasion,
  ) {
    final temperature = weather.temperature ?? 20;
    final condition = weather.condition?.toLowerCase() ?? 'clear';

    // Определение типа погоды
    String weatherType;
    if (temperature < 0) {
      weatherType = 'морозной';
    } else if (temperature < 10) {
      weatherType = 'холодной';
    } else if (temperature < 20) {
      weatherType = 'прохладной';
    } else if (temperature < 28) {
      weatherType = 'комфортной';
    } else {
      weatherType = 'жаркой';
    }

    // Определение условия
    String conditionType = '';
    if (condition.contains('rain')) {
      conditionType = 'дождливой';
    } else if (condition.contains('snow')) {
      conditionType = 'снежной';
    } else if (condition.contains('cloud')) {
      conditionType = 'облачной';
    } else if (condition.contains('wind')) {
      conditionType = 'ветреной';
    } else {
      conditionType = 'солнечной';
    }

    // Случай
    String occasionType = '';
    switch (occasion?.toLowerCase()) {
      case 'classic':
      case 'business':
      case 'work':
        occasionType = 'деловой встречи';
        break;
      case 'sport':
      case 'gym':
      case 'workout':
        occasionType = 'тренировки';
        break;
      case 'outdoor':
      case 'hiking':
        occasionType = 'прогулки на природе';
        break;
      case 'casual':
      default:
        occasionType = 'повседневный';
    }

    // Формируем заголовок
    if (occasionType == 'повседневный') {
      return 'Образ для $weatherType погоды';
    } else {
      return 'Стильный образ для $occasionType в $conditionType погоду';
    }
  }

  /// Генерация описания рекомендации
  String _generateDescription(
    WeatherData weather,
    UserPreference preferences,
    List<WardrobeItem> outfitItems,
  ) {
    final temperature = weather.temperature ?? 20;
    final feelsLike = weather.feelsLike ?? temperature;

    final parts = <String>[];

    // Основная информация
    if (feelsLike < temperature - 3) {
      parts.add('Ощущается холоднее, чем показывает термометр');
    } else if (feelsLike > temperature + 3) {
      parts.add('Ощущается теплее, чем показывает термометр');
    }

    // Рекомендации по слоям
    final outerwear =
        outfitItems.where((item) => item.category == 'outerwear').toList();
    if (outerwear.isNotEmpty && temperature < 15) {
      parts.add('Верхняя одежда поможет сохранить тепло');
    }

    // Аксессуары
    final accessories =
        outfitItems
            .where(
              (item) =>
                  item.category == 'accessory' || item.category == 'headwear',
            )
            .toList();
    if (accessories.isNotEmpty) {
      parts.add('Аксессуары дополнят образ и защитят от погоды');
    }

    // Предпочтения по материалам
    if (preferences.prefersNaturalMaterials) {
      parts.add('В образе использованы натуральные материалы');
    }

    if (parts.isEmpty) {
      return 'Подобранный комплект идеально подходит для текущих погодных условий.';
    }

    return '${parts.join('. ')}. ';
  }
}
