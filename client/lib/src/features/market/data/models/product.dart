import 'package:equatable/equatable.dart';

/// Product model from market API
class Product extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String brand;
  final String category;
  final String? subcategory;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final List<String> sizes;
  final List<String> colors;
  final List<String> styleTags;
  final bool inStock;
  final int stockCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.brand,
    required this.category,
    this.subcategory,
    required this.price,
    this.currency = 'RUB',
    required this.imageUrls,
    required this.sizes,
    required this.colors,
    required this.styleTags,
    required this.inStock,
    required this.stockCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      brand: json['brand'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'RUB',
      imageUrls: (json['image_urls'] as List<dynamic>?)?.cast<String>() ?? [],
      sizes: (json['sizes'] as List<dynamic>?)?.cast<String>() ?? [],
      colors: (json['colors'] as List<dynamic>?)?.cast<String>() ?? [],
      styleTags: (json['style_tags'] as List<dynamic>?)?.cast<String>() ?? [],
      inStock: json['in_stock'] as bool? ?? true,
      stockCount: json['stock_count'] as int? ?? 0,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'brand': brand,
      'category': category,
      'subcategory': subcategory,
      'price': price,
      'currency': currency,
      'image_urls': imageUrls,
      'sizes': sizes,
      'colors': colors,
      'style_tags': styleTags,
      'in_stock': inStock,
      'stock_count': stockCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    brand,
    category,
    subcategory,
    price,
    currency,
    imageUrls,
    sizes,
    colors,
    styleTags,
    inStock,
    stockCount,
  ];

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? brand,
    String? category,
    String? subcategory,
    double? price,
    String? currency,
    List<String>? imageUrls,
    List<String>? sizes,
    List<String>? colors,
    List<String>? styleTags,
    bool? inStock,
    int? stockCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      imageUrls: imageUrls ?? this.imageUrls,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      styleTags: styleTags ?? this.styleTags,
      inStock: inStock ?? this.inStock,
      stockCount: stockCount ?? this.stockCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
