import 'package:flutter/material.dart';

// --- STYLES ---

const List<String> kStyles = [
  'casual',
  'street',
  'classic',
  'sport',
  'business',
  'smart_casual',
  'outdoor',
];

const Map<String, String> kStyleNamesRu = {
  'casual': 'Кэжуал',
  'street': 'Уличный',
  'classic': 'Классика',
  'sport': 'Спорт',
  'business': 'Деловой',
  'smart_casual': 'Смарт кэжуал',
  'outdoor': 'Активный отдых',
};

// --- COLORS ---

const List<String> kColors = [
  'black',
  'white',
  'gray',
  'navy',
  'beige',
  'brown',
  'green',
  'blue',
  'red',
  'pink',
  'yellow',
  'orange',
  'purple',
];

const Map<String, String> kColorNamesRu = {
  'black': 'Чёрный',
  'white': 'Белый',
  'gray': 'Серый',
  'navy': 'Тёмно-синий',
  'beige': 'Бежевый',
  'brown': 'Коричневый',
  'green': 'Зелёный',
  'blue': 'Синий',
  'red': 'Красный',
  'pink': 'Розовый',
  'yellow': 'Жёлтый',
  'orange': 'Оранжевый',
  'purple': 'Фиолетовый',
};

const Map<String, Color> kColorSwatches = {
  'black': Colors.black,
  'white': Colors.white,
  'gray': Colors.grey,
  'navy': Color(0xFF001F3F),
  'beige': Color(0xFFF5F5DC),
  'brown': Colors.brown,
  'green': Colors.green,
  'blue': Colors.blue,
  'red': Colors.red,
  'pink': Colors.pink,
  'yellow': Colors.yellow,
  'orange': Colors.orange,
  'purple': Colors.purple,
};

// --- CATEGORIES ---

const Map<String, String> kCategoryNamesRu = {
  'outerwear': 'Верхняя одежда',
  'upper': 'Верх',
  'lower': 'Низ',
  'footwear': 'Обувь',
  'accessory': 'Аксессуары',
};

const Map<String, String> kSubcategoryNamesRu = {
  'coat': 'Пальто',
  'raincoat': 'Дождевик',
  'jacket': 'Куртка',
  'tshirt': 'Футболка',
  'hoodie': 'Худи',
  'shirt': 'Рубашка',
  'sweater': 'Свитер',
  'jeans': 'Джинсы',
  'pants': 'Брюки',
  'shorts': 'Шорты',
  'skirt': 'Юбка',
  'sneakers': 'Кроссовки',
  'boots': 'Ботинки',
  'shoes': 'Туфли',
  'hat': 'Шапка',
  'scarf': 'Шарф',
  'gloves': 'Перчатки',
  'bag': 'Сумка',
  'umbrella': 'Зонт',
};

String translateCategory(String cat) => kCategoryNamesRu[cat] ?? cat;
String translateSubcategory(String sub) => kSubcategoryNamesRu[sub] ?? sub;
String translateStyle(String style) => kStyleNamesRu[style] ?? style;
String translateColor(String color) => kColorNamesRu[color] ?? color;