///Model for a shopping wishlist item
class ShoppingItem {
  final int id;
  final String name;
  final String? brand;
  final double? price;
  final String? category;
  final String? subcategory;
  final String? imageUrl;
  final DateTime? createdAt;

  ShoppingItem({
    required this.id,
    required this.name,
    this.brand,
    this.price,
    this.category,
    this.subcategory,
    this.imageUrl,
    this.createdAt,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'],
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : null,
      category: json['category'],
      subcategory: json['subcategory'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
