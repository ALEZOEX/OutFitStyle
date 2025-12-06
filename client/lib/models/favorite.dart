class FavoriteOutfit {
  final int favoriteId;
  final String savedAt;
  final String location;
  final double temperature;
  final String weather;
  final List<Map<String, dynamic>> items;

  FavoriteOutfit({
    required this.favoriteId,
    required this.savedAt,
    required this.location,
    required this.temperature,
    required this.weather,
    required this.items,
  });

  factory FavoriteOutfit.fromJson(Map<String, dynamic> json) {
    return FavoriteOutfit(
      // Поддерживаем и старый формат (favorite_id, saved_at), и текущий (id, created_at)
      favoriteId: json['favorite_id'] ?? json['id'] ?? 0,
      savedAt: (json['saved_at'] ?? json['created_at'] ?? '') as String,
      // Эти поля сейчас, скорее всего, не приходят — оставляем фолбэки
      location: json['location'] ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      weather: json['weather'] ?? '',
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
    );
  }
}