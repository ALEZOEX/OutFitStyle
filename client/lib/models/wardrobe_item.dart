class WardrobeListItem {
  final int id;
  final String name;
  final String iconEmoji;
  final double mlScore;
  final String customName;
  final String customIcon;

  WardrobeListItem({
    required this.id,
    required this.name,
    required this.iconEmoji,
    required this.mlScore,
    required this.customName,
    required this.customIcon,
  });

  factory WardrobeListItem.fromJson(Map<String, dynamic> json) {
    return WardrobeListItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Без названия',
      iconEmoji: json['icon_emoji'] ?? '👕',
      mlScore: (json['ml_score'] ?? 0.0).toDouble(),
      customName: json['custom_name'] ?? '',
      customIcon: json['custom_icon'] ?? '',
    );
  }
}