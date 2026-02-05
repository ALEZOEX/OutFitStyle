/// Сущность наряда
class OutfitEntity {
  final String id;
  final String name;
  final String description;
  final List<String> items;
  final bool isFavorite;
  final String? imageUrl;

  OutfitEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.items,
    this.isFavorite = false,
    this.imageUrl,
  });

  /// Создает экземпляр [OutfitEntity] из JSON-объекта
  factory OutfitEntity.fromJson(Map<String, dynamic> json) {
    return OutfitEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      items: (json['items'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isFavorite: json['is_favorite'] ?? false,
      imageUrl: json['image_url'],
    );
  }

  /// Преобразует экземпляр [OutfitEntity] в JSON-объект
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'items': items,
      'is_favorite': isFavorite,
      'image_url': imageUrl,
    };
  }
}