import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wardrobe_item.freezed.dart';
part 'wardrobe_item.g.dart';

/// Категории гардероба
///
/// Обязательные категории для полного комплекта:
/// - [top] - верх (футболки, рубашки, свитера)
/// - [bottom] - низ (джинсы, брюки, шорты)
/// - [shoes] - обувь (кроссовки, ботинки, туфли)
///
/// Дополнительные категории:
/// - [outerwear] - верхняя одежда (куртки, пальто, пиджаки)
/// - [accessories] - аксессуары (сумки, ремни, очки)
/// - [headwear] - головные уборы (шапки, кепки)
class WardrobeCategories {
  static const String top = 'top';
  static const String bottom = 'bottom';
  static const String shoes = 'shoes';
  static const String outerwear = 'outerwear';
  static const String accessories = 'accessories';
  static const String headwear = 'headwear';

  /// Все категории
  static const List<String> all = [
    top,
    bottom,
    shoes,
    outerwear,
    accessories,
    headwear,
  ];

  /// Обязательные категории для полного комплекта
  static const List<String> required = [top, bottom, shoes];

  /// Получить иконку для категории
  static IconData getIcon(String category) {
    switch (category.toLowerCase()) {
      case top:
        return Icons.checkroom;
      case bottom:
        return Icons.checkroom_outlined;
      case shoes:
        return Icons.bolt;
      case outerwear:
        return Icons.sunny_snowing;
      case accessories:
        return Icons.shopping_bag;
      case headwear:
        return Icons.face;
      default:
        return Icons.category;
    }
  }

  /// Получить название категории на русском
  static String getNameRu(String category) {
    switch (category.toLowerCase()) {
      case top:
        return 'Верх';
      case bottom:
        return 'Низ';
      case shoes:
        return 'Обувь';
      case outerwear:
        return 'Верхняя одежда';
      case accessories:
        return 'Аксессуары';
      case headwear:
        return 'Головные уборы';
      default:
        return category;
    }
  }

  /// Проверить является ли категория обязательной
  static bool isRequired(String category) {
    return required.contains(category.toLowerCase());
  }
}

/// Подкатегории для более детальной классификации
class WardrobeSubcategories {
  // Верх
  static const String tshirt = 'tshirt'; // Футболка
  static const String shirt = 'shirt'; // Рубашка
  static const String blouse = 'blouse'; // Блузка
  static const String sweater = 'sweater'; // Свитер
  static const String hoodie = 'hoodie'; // Худи
  static const String polo = 'polo'; // Поло
  static const String tankTop = 'tank_top'; // Майка
  static const String longSleeve = 'long_sleeve'; // Лонгслив
  static const String turtleneck = 'turtleneck'; // Водолазка

  // Низ
  static const String jeans = 'jeans'; // Джинсы
  static const String trousers = 'trousers'; // Брюки
  static const String shorts = 'shorts'; // Шорты
  static const String skirt = 'skirt'; // Юбка
  static const String leggings = 'leggings'; // Леггинсы
  static const String joggers = 'joggers'; // Джоггеры
  static const String cargo = 'cargo'; // Карго
  static const String chinos = 'chinos'; // Чинос

  // Обувь
  static const String sneakers = 'sneakers'; // Кроссовки
  static const String shoes = 'shoes'; // Туфли
  static const String boots = 'boots'; // Ботинки
  static const String sandals = 'sandals'; // Сандали
  static const String loafers = 'loafers'; // Лоферы
  static const String sportShoes = 'sport_shoes'; // Спортивная обувь

  // Верхняя одежда
  static const String jacket = 'jacket'; // Куртка
  static const String coat = 'coat'; // Пальто
  static const String blazer = 'blazer'; // Пиджак
  static const String vest = 'vest'; // Жилет
  static const String windbreaker = 'windbreaker'; // Ветровка
  static const String raincoat = 'raincoat'; // Дождевик

  // Аксессуары
  static const String bag = 'bag'; // Сумка
  static const String belt = 'belt'; // Ремень
  static const String scarf = 'scarf'; // Шарф
  static const String gloves = 'gloves'; // Перчатки
  static const String glasses = 'glasses'; // Очки
  static const String watch = 'watch'; // Часы
  static const String jewelry = 'jewelry'; // Украшения

  // Головные уборы
  static const String hat = 'hat'; // Шапка
  static const String cap = 'cap'; // Кепка
  static const String beanie = 'beanie'; // Бини
  static const String bucketHat = 'bucket_hat'; // Панама
}

@freezed
abstract class WardrobeItem with _$WardrobeItem {
  // ignore: invalid_annotation_target
  const factory WardrobeItem({
    /// Уникальный идентификатор
    String? id,

    /// Название предмета (например, "Белая футболка Basic")
    String? name,

    /// Категория: top, bottom, shoes, outerwear, accessories, headwear
    // ignore: invalid_annotation_target
    @JsonKey(name: 'category') String? category,

    /// Подкатегория: tshirt, jeans, sneakers и т.д.
    // ignore: invalid_annotation_target
    @JsonKey(name: 'subcategory') String? subcategory,

    /// Бренд
    String? brand,

    /// Цвет
    String? color,

    /// Размер (S, M, L, XL, 42, 44 и т.д.)
    String? size,

    /// URL изображения
    String? imageUrl,

    /// Emoji иконка для предмета
    String? iconEmoji,

    /// BlurHash для плейсхолдера изображения
    String? blurHash,

    /// Минимальная температура для носки (°C)
    // ignore: invalid_annotation_target
    @JsonKey(name: 'min_temp') double? minTemp,

    /// Максимальная температура для носки (°C)
    // ignore: invalid_annotation_target
    @JsonKey(name: 'max_temp') double? maxTemp,

    /// Уровень теплоты (1-5, где 5 - самый теплый)
    // ignore: invalid_annotation_target
    @JsonKey(name: 'warmth_level') int? warmthLevel,

    /// Подходит для дождя
    // ignore: invalid_annotation_target
    @JsonKey(name: 'rain_ok') bool? rainOk,

    /// Подходит для снега
    // ignore: invalid_annotation_target
    @JsonKey(name: 'snow_ok') bool? snowOk,

    /// Подходит для ветреной погоды
    // ignore: invalid_annotation_target
    @JsonKey(name: 'wind_ok') bool? windOk,

    /// Количество использований
    int? usage,

    /// Материалы (например, ["cotton", "polyester"])
    List<String>? materials,

    /// Пол: unisex, male, female
    String? gender,

    /// Крой: slim, regular, loose, oversized
    String? fit,

    /// Узор: solid, striped, checked, printed
    String? pattern,

    /// Локальный путь к изображению
    String? localImagePath,

    /// Стиль: casual, formal, sport, streetwear
    String? style,

    /// Избранное
    // ignore: invalid_annotation_target
    @JsonKey(name: 'is_favorite') bool? isFavorite,

    /// Архивировано
    // ignore: invalid_annotation_target
    @JsonKey(name: 'is_archived') bool? isArchived,

    /// Сезон: all_season, spring, summer, autumn, winter
    String? season,

    /// ID на сервере
    // ignore: invalid_annotation_target
    @JsonKey(name: 'server_id') String? serverId,

    /// Есть ли несохраненные изменения
    bool? dirty,

    /// Дата последней синхронизации
    // ignore: invalid_annotation_target
    @JsonKey(name: 'last_synced_at') DateTime? lastSyncedAt,
  }) = _WardrobeItem;

  factory WardrobeItem.fromJson(Map<String, dynamic> json) =>
      _$WardrobeItemFromJson(json);
}

/// Расширения для удобной работы с WardrobeItem
extension WardrobeItemExtension on WardrobeItem {
  /// Проверить является ли предмет обязательной категории
  bool get isRequiredCategory {
    return WardrobeCategories.isRequired(category ?? '');
  }

  /// Получить иконку категории
  IconData get categoryIcon {
    return WardrobeCategories.getIcon(category ?? '');
  }

  /// Получить название категории на русском
  String get categoryNameRu {
    return WardrobeCategories.getNameRu(category ?? '');
  }

  /// Проверить подходит ли предмет для текущей температуры
  bool isSuitableForTemperature(double temperature) {
    final min = minTemp;
    final max = maxTemp;

    if (min == null && max == null) return true;
    if (min != null && temperature < min) return false;
    if (max != null && temperature > max) return false;

    return true;
  }

  /// Проверить подходит ли предмет для погоды
  bool isSuitableForWeather({bool? isRain, bool? isSnow, bool? isWindy}) {
    if (isRain == true && (rainOk != true)) return false;
    if (isSnow == true && (snowOk != true)) return false;
    if (isWindy == true && (windOk != true)) return false;

    return true;
  }

  /// Получить emoji или иконку по умолчанию
  String get emojiOrPlaceholder {
    return iconEmoji ?? _getDefaultEmoji();
  }

  /// Получить emoji по умолчанию на основе категории
  String _getDefaultEmoji() {
    switch (category?.toLowerCase()) {
      case 'top':
        return '👕';
      case 'bottom':
        return '👖';
      case 'shoes':
        return '👟';
      case 'outerwear':
        return '🧥';
      case 'accessories':
        return '👜';
      case 'headwear':
        return '🧢';
      default:
        return '🏷️';
    }
  }
}
