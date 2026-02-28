/// Модель данных предпочтений пользователя из онбординга
class OnboardingData {
  final int? cityId;
  final String? cityName;
  final double? cityLat;
  final double? cityLon;
  final List<String> stylePreferences;
  final String? budgetRange;
  final String? favoriteBrands;

  const OnboardingData({
    this.cityId,
    this.cityName,
    this.cityLat,
    this.cityLon,
    this.stylePreferences = const [],
    this.budgetRange,
    this.favoriteBrands,
  });

  /// Проверка валидности данных
  bool get isValid {
    // Город обязателен
    if (cityId == null || cityName == null) return false;
    // Минимум 3 стиля
    if (stylePreferences.length < 3) return false;
    return true;
  }

  /// Конвертация в JSON для отправки на сервер
  Map<String, dynamic> toJson() {
    return {
      if (cityId != null) 'city_id': cityId,
      if (cityName != null) 'city_name': cityName,
      if (cityLat != null) 'city_lat': cityLat,
      if (cityLon != null) 'city_lon': cityLon,
      'style_preferences': stylePreferences,
      if (budgetRange != null) 'budget_range': budgetRange,
      if (favoriteBrands != null) 'favorite_brands': favoriteBrands,
    };
  }

  /// Конструктор из JSON
  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      cityId: json['city_id'] as int?,
      cityName: json['city_name'] as String?,
      cityLat: (json['city_lat'] as num?)?.toDouble(),
      cityLon: (json['city_lon'] as num?)?.toDouble(),
      stylePreferences: (json['style_preferences'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      budgetRange: json['budget_range'] as String?,
      favoriteBrands: json['favorite_brands'] as String?,
    );
  }

  /// Копирование с изменениями
  OnboardingData copyWith({
    int? cityId,
    String? cityName,
    double? cityLat,
    double? cityLon,
    List<String>? stylePreferences,
    String? budgetRange,
    String? favoriteBrands,
  }) {
    return OnboardingData(
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      cityLat: cityLat ?? this.cityLat,
      cityLon: cityLon ?? this.cityLon,
      stylePreferences: stylePreferences ?? this.stylePreferences,
      budgetRange: budgetRange ?? this.budgetRange,
      favoriteBrands: favoriteBrands ?? this.favoriteBrands,
    );
  }
}

/// Доступные диапазоны бюджета
enum BudgetRange {
  economy('economy', 'Эконом', 'до 5000₽'),
  medium('medium', 'Средний', '5000-15000₽'),
  premium('premium', 'Премиум', '15000₽+');

  final String value;
  final String displayName;
  final String description;

  const BudgetRange(this.value, this.displayName, this.description);

  static BudgetRange? fromValue(String? value) {
    for (final range in BudgetRange.values) {
      if (range.value == value) return range;
    }
    return null;
  }
}

/// Доступные стили одежды
enum StylePreference {
  casual('casual', 'Casual', 'Повседневный'),
  sport('sport', 'Sport', 'Спортивный'),
  classic('classic', 'Classic', 'Классический'),
  streetwear('streetwear', 'Streetwear', 'Уличный'),
  business('business', 'Business', 'Деловой'),
  minimalist('minimalist', 'Minimalist', 'Минимализм'),
  boho('boho', 'Boho', 'Бохо'),
  preppy('preppy', 'Preppy', 'Преппи');

  final String value;
  final String displayName;
  final String description;

  const StylePreference(this.value, this.displayName, this.description);

  static StylePreference? fromValue(String? value) {
    for (final style in StylePreference.values) {
      if (style.value == value) return style;
    }
    return null;
  }
}
