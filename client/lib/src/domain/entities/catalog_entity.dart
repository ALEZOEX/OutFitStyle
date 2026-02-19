// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_entity.freezed.dart';
part 'catalog_entity.g.dart';

/// Сущность элемента каталога одежды
/// 
/// Соответствует доменной модели ClothingItem на сервере (Go)
/// Используется для отображения базового каталога вещей
@freezed
abstract class CatalogEntity with _$CatalogEntity {
  const factory CatalogEntity({
    /// Уникальный идентификатор элемента одежды
    required String id,

    /// Название элемента одежды
    required String name,

    /// Описание элемента одежды (опционально)
    String? description,

    /// Категория одежды (например, "outerwear", "upper", "lower", "footwear", "accessory")
    required String category,

    /// Подкатегория одежды (например, "t-shirt", "jeans", "coat")
    required String subcategory,

    /// Минимальная температура комфорта (в градусах Цельсия)
    @JsonKey(name: 'min_temp') int? minTemp,

    /// Максимальная температура комфорта (в градусах Цельсия)
    @JsonKey(name: 'max_temp') int? maxTemp,

    /// Уровень теплоты (1-10, где 1 - летняя одежда, 10 - зимняя)
    @JsonKey(name: 'warmth_level') int? warmthLevel,

    /// Подходит ли для дождливой погоды
    @JsonKey(name: 'rain_ok') @Default(true) bool rainOk,

    /// Подходит ли для снежной погоды
    @JsonKey(name: 'snow_ok') @Default(true) bool snowOk,

    /// Подходит ли для ветреной погоды
    @JsonKey(name: 'wind_ok') @Default(true) bool windOk,

    /// Стиль одежды (например, "casual", "business", "sport", "street", "classic", "smart_casual", "outdoor")
    required String style,

    /// Уровень формальности (1-5, где 1 - максимально неформально, 5 - максимально формально)
    @JsonKey(name: 'formality_level') int? formalityLevel,

    /// Базовый цвет одежды
    @JsonKey(name: 'base_colour') String? baseColour,

    /// Узор/рисунок (например, "solid", "striped", "checked", "printed", "camo")
    required String pattern,

    /// Посадка/фасон (например, "slim", "regular", "relaxed", "oversized")
    String? fit,

    /// Пол (например, "unisex")
    @Default('unisex') String gender,

    /// Сезон (например, "winter", "spring", "summer", "autumn", "all")
    required String season,

    /// Назначение использования (например, ["daily", "work", "formal", "sport", "outdoor", "travel", "party"])
    @Default([]) List<String> usage,

    /// Материалы (например, ["cotton", "wool", "polyester"])
    @Default([]) List<String> materials,

    /// Бренд одежды (опционально)
    String? brand,

    /// URL полноразмерного изображения
    @JsonKey(name: 'image_url') String? imageUrl,

    /// URL миниатюры изображения
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,

    /// Эмодзи-иконка для отображения
    @JsonKey(name: 'icon_emoji') String? iconEmoji,

    /// Источник одежды: synthetic|user|partner|manual
    @Default('synthetic') String source,

    /// Активен ли элемент
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _CatalogEntity;

  factory CatalogEntity.fromJson(Map<String, dynamic> json) =>
      _$CatalogEntityFromJson(json);
}

/// Расширение для удобного отображения категорий
extension CatalogEntityCategoryExtension on CatalogEntity {
  /// Отображаемое название категории
  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'outerwear':
        return 'Верхняя одежда';
      case 'upper':
        return 'Верх';
      case 'lower':
        return 'Низ';
      case 'footwear':
        return 'Обувь';
      case 'accessory':
        return 'Аксессуар';
      default:
        return category;
    }
  }

  /// Эмодзи для категории
  String get categoryEmoji {
    switch (category.toLowerCase()) {
      case 'outerwear':
        return '🧥';
      case 'upper':
        return '👕';
      case 'lower':
        return '👖';
      case 'footwear':
        return '👟';
      case 'accessory':
        return '🧣';
      default:
        return '👔';
    }
  }

  /// Отображаемое название сезона
  String get seasonDisplayName {
    switch (season.toLowerCase()) {
      case 'winter':
        return 'Зима';
      case 'spring':
        return 'Весна';
      case 'summer':
        return 'Лето';
      case 'autumn':
        return 'Осень';
      case 'all':
        return 'Все сезоны';
      default:
        return season;
    }
  }

  /// Отображаемое название стиля
  String get styleDisplayName {
    switch (style.toLowerCase()) {
      case 'casual':
        return 'Повседневный';
      case 'business':
        return 'Деловой';
      case 'sport':
        return 'Спортивный';
      case 'street':
        return 'Уличный';
      case 'classic':
        return 'Классический';
      case 'smart_casual':
        return 'Смарт-кэжуал';
      case 'outdoor':
        return 'Для активного отдыха';
      default:
        return style;
    }
  }

  /// Температурный диапазон для отображения
  String? get temperatureRange {
    if (minTemp != null && maxTemp != null) {
      return 'от $minTemp° до $maxTemp°';
    } else if (minTemp != null) {
      return 'от $minTemp°';
    } else if (maxTemp != null) {
      return 'до $maxTemp°';
    }
    return null;
  }
}
