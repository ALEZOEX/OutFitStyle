/// Product entity for domain layer
class ProductEntity {
  final String id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final bool inStock;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.inStock,
  });
}
