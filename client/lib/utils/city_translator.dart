class CityTranslator {
  // Популярные города: Русский -> Английский
  static const Map<String, String> _cityMap = {
    // Россия
    'москва': 'Moscow',
    'санкт-петербург': 'Saint Petersburg',
    'петербург': 'Saint Petersburg',
    'спб': 'Saint Petersburg',
    'новосибирск': 'Novosibirsk',
    'екатеринбург': 'Yekaterinburg',
    'казань': 'Kazan',
    'нижний новгород': 'Nizhny Novgorod',
    'челябинск': 'Chelyabinsk',
    'самара': 'Samara',
    'омск': 'Omsk',
    'ростов-на-дону': 'Rostov-on-Don',
    'уфа': 'Ufa',
    'красноярск': 'Krasnoyarsk',
    'воронеж': 'Voronezh',
    'пермь': 'Perm',
    'волгоград': 'Volgograd',
    'краснодар': 'Krasnodar',
    'сочи': 'Sochi',
    'владивосток': 'Vladivostok',
    'иркутск': 'Irkutsk',
    'тюмень': 'Tyumen',
    'томск': 'Tomsk',

    // США
    'нью-йорк': 'New York',
    'нью йорк': 'New York',
    'лос-анджелес': 'Los Angeles',
    'чикаго': 'Chicago',
    'хьюстон': 'Houston',
    'майами': 'Miami',
    'сан-франциско': 'San Francisco',
    'лас-вегас': 'Las Vegas',
    'вашингтон': 'Washington',
    'бостон': 'Boston',

    // Европа
    'лондон': 'London',
    'париж': 'Paris',
    'берлин': 'Berlin',
    'мадрид': 'Madrid',
    'рим': 'Rome',
    'вена': 'Vienna',
    'прага': 'Prague',
    'амстердам': 'Amsterdam',
    'брюссель': 'Brussels',
    'стокгольм': 'Stockholm',
    'копенгаген': 'Copenhagen',
    'хельсинки': 'Helsinki',
    'варшава': 'Warsaw',
    'будапешт': 'Budapest',
    'афины': 'Athens',
    'лиссабон': 'Lisbon',
    'дублин': 'Dublin',
    'осло': 'Oslo',

    // Азия
    'токио': 'Tokyo',
    'пекин': 'Beijing',
    'шанхай': 'Shanghai',
    'сеул': 'Seoul',
    'бангкок': 'Bangkok',
    'сингапур': 'Singapore',
    'дели': 'Delhi',
    'мумбаи': 'Mumbai',
    'стамбул': 'Istanbul',
    'дубай': 'Dubai',
    'тель-авив': 'Tel Aviv',
    'иерусалим': 'Jerusalem',

    // Другие
    'сидней': 'Sydney',
    'мельбурн': 'Melbourne',
    'торонто': 'Toronto',
    'ванкувер': 'Vancouver',
    'монреаль': 'Montreal',
    'буэнос-айрес': 'Buenos Aires',
    'рио-де-жанейро': 'Rio de Janeiro',
    'каир': 'Cairo',
    'кейптаун': 'Cape Town',
  };

  /// Переводит город с русского на английский или возвращает как есть
  static String translate(String city) {
    if (city.isEmpty) return city;

    final normalized = city.toLowerCase().trim();

    // Проверяем прямое совпадение
    if (_cityMap.containsKey(normalized)) {
      return _cityMap[normalized]!;
    }

    // Проверяем частичное совпадение
    for (var entry in _cityMap.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return entry.value;
      }
    }

    // Если не нашли - возвращаем оригинал (может быть уже на английском)
    return city;
  }

  /// Проверяет, является ли строка кириллицей
  static bool isCyrillic(String text) {
    if (text.isEmpty) return false;
    final cyrillicPattern = RegExp(r'[а-яА-ЯёЁ]');
    return cyrillicPattern.hasMatch(text);
  }

  /// Получает список популярных городов для автодополнения
  static List<String> getSuggestions(String query) {
    if (query.isEmpty) return [];

    final normalized = query.toLowerCase().trim();
    final suggestions = <String>[];

    // Поиск по русским названиям
    for (var entry in _cityMap.entries) {
      if (entry.key.startsWith(normalized)) {
        suggestions.add('${_capitalize(entry.key)} (${entry.value})');
      }
    }

    // Поиск по английским названиям
    for (var entry in _cityMap.entries) {
      if (entry.value.toLowerCase().startsWith(normalized)) {
        suggestions.add(entry.value);
      }
    }

    return suggestions.take(5).toList();
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Форматирует отображаемое имя города
  static String getDisplayName(String city) {
    final normalized = city.toLowerCase().trim();

    // Если это русское название - возвращаем с английским вариантом
    if (_cityMap.containsKey(normalized)) {
      return '${_capitalize(normalized)} (${_cityMap[normalized]})';
    }

    // Если английское - возвращаем как есть
    return city;
  }
}
