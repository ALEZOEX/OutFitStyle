class ItemTranslator {
  static const Map<String, String> _categoryTranslations = {
    // Англоязычные названия -> Русские
    'outerwear': 'Верхняя одежда',
    'upper': 'Верх',
    'lower': 'Низ',
    'footwear': 'Обувь',
    'accessory': 'Аксессуар',
    'underwear': 'Нижнее бельё',
    'dress': 'Платье',
    'tops': 'Топы',
    'bottoms': 'Низ',
    'shoes': 'Обувь',
    'bags': 'Сумки',
    'jewellery': 'Ювелирные изделия',
    'watches': 'Часы',
    'sunglasses': 'Солнцезащитные очки',
    'hats': 'Головные уборы',
    'scarves': 'Шарфы',
    'belts': 'Ремни',
    'socks': 'Носки',
    'stockings': 'Колготки',
    'nightwear': 'Ночная одежда',
    'swimwear': 'Пляжная одежда',
    'activewear': 'Спортивная одежда',
    'topwear': 'Верхняя одежда',
    'bottomwear': 'Низ',
    'apparel': 'Одежда',
    'personal care': 'Уход за собой',

    // Русскоязычные названия (для унификации)
    'верхняя одежда': 'Верхняя одежда',
    'верх': 'Верх',
    'низ': 'Низ',
    'обувь': 'Обувь',
    'аксессуар': 'Аксессуар',
    'нижнее бельё': 'Нижнее бельё',
    'платье': 'Платье',
    'топы': 'Топы',
    'сумки': 'Сумки',
    'часы': 'Часы',
    'очки': 'Солнцезащитные очки',
    'головные уборы': 'Головные уборы',
    'шарфы': 'Шарфы',
    'ремни': 'Ремни',
    'носки': 'Носки',
    'колготки': 'Колготки',
    'ночная одежда': 'Ночная одежда',
    'пляжная одежда': 'Пляжная одежда',
    'спортивная одежда': 'Спортивная одежда',
    'верхняя_одежда': 'Верхняя одежда',
    'одежда': 'Одежда',
  };

  static const Map<String, String> _genderTranslations = {
    'Men': 'Мужской',
    'Women': 'Женский',
    'Unisex': 'Унисекс',
    'Boys': 'Для мальчиков',
    'Girls': 'Для девочек',
    'men': 'Мужской',
    'women': 'Женский',
    'unisex': 'Унисекс',
    'boys': 'Для мальчиков',
    'girls': 'Для девочек'
  };

  static const Map<String, String> _seasonTranslations = {
    'Spring': 'Весна',
    'Summer': 'Лето',
    'Fall': 'Осень', 
    'Winter': 'Зима',
    'All Seasons': 'Все сезоны',
    'All Season': 'Все сезоны',
    'spring': 'Весна',
    'summer': 'Лето',
    'fall': 'Осень',
    'winter': 'Зима',
    'all seasons': 'Все сезоны',
    'all season': 'Все сезоны'
  };

  static const Map<String, String> _usageTranslations = {
    'Casual': 'Повседневный',
    'Formal': 'Формальный',
    'Ethnic': 'Этнический',
    'Sports': 'Спорт',
    'Smart': 'Смарт',
    'Party': 'Вечеринка',
    'Business': 'Бизнес',
    'Travel': 'Путешествие',
    'Home': 'Дом',
    'Work': 'Работа',
    'Outdoors': 'На улице',
    'Beach': 'Пляж',
    'Swimming': 'Плавание',
    'Workout': 'Тренировка',
    'casual': 'Повседневный',
    'formal': 'Формальный',
    'ethnic': 'Этнический',
    'sports': 'Спорт',
    'smart': 'Смарт',
    'party': 'Вечеринка',
    'business': 'Бизнес',
    'travel': 'Путешествие',
    'home': 'Дом',
    'work': 'Работа',
    'outdoors': 'На улице',
    'beach': 'Пляж',
    'swimming': 'Плавание',
    'workout': 'Тренировка'
  };

  static const Map<String, String> _masterCategoryTranslations = {
    'Apparel': 'Одежда',
    'Accessories': 'Аксессуары',
    'Footwear': 'Обувь',
    'Personal Care': 'Уход за собой',
    'apparel': 'Одежда',
    'accessories': 'Аксессуары',
    'footwear': 'Обувь',
    'personal care': 'Уход за собой'
  };

  static String translateCategory(String category) {
    return _categoryTranslations[category] ?? category;
  }

  static String translateGender(String gender) {
    return _genderTranslations[gender] ?? gender;
  }

  static String translateSeason(String season) {
    return _seasonTranslations[season] ?? season;
  }

  static String translateUsage(String usage) {
    return _usageTranslations[usage] ?? usage;
  }

  static String translateMasterCategory(String masterCategory) {
    return _masterCategoryTranslations[masterCategory] ?? masterCategory;
  }

  static String translateAnyField(String field, String fieldName) {
    switch(fieldName.toLowerCase()) {
      case 'category':
      case 'subcategory':
        return translateCategory(field);
      case 'gender':
        return translateGender(field);
      case 'season':
        return translateSeason(field);
      case 'usage':
        return translateUsage(field);
      case 'mastercategory':
        return translateMasterCategory(field);
      default:
        return field;
    }
  }
}