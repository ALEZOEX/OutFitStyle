// Классы для создания и обновления элементов гардероба
class WardrobeItemCreateRequest {
  final String name;
  final String category;
  final String subcategory;
  final String style;
  final String iconEmoji;
  final String? imageUrl;
  final String? blurHash;
  final int? minTemp;
  final int? maxTemp;
  final int? warmthLevel;
  final bool rainOk;
  final bool snowOk;
  final bool windOk;
  final String? usage;
  final String? materials;
  final bool isFavorite;
  final bool isArchived;
  final String? season;
  final String? gender;
  final String? fit;
  final String? pattern;
  final String? localImagePath;

  WardrobeItemCreateRequest({
    required this.name,
    required this.category,
    required this.subcategory,
    required this.style,
    required this.iconEmoji,
    this.imageUrl,
    this.blurHash,
    this.minTemp,
    this.maxTemp,
    this.warmthLevel,
    required this.rainOk,
    required this.snowOk,
    required this.windOk,
    this.usage,
    this.materials,
    required this.isFavorite,
    required this.isArchived,
    this.season,
    this.gender,
    this.fit,
    this.pattern,
    this.localImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'style': style,
      'icon_emoji': iconEmoji,
      'image_url': imageUrl,
      'blur_hash': blurHash,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'warmth_level': warmthLevel,
      'rain_ok': rainOk,
      'snow_ok': snowOk,
      'wind_ok': windOk,
      'usage': usage,
      'materials': materials,
      'is_favorite': isFavorite,
      'is_archived': isArchived,
      'season': season,
      'gender': gender,
      'fit': fit,
      'pattern': pattern,
      'local_image_path': localImagePath,
    };
  }
}

class WardrobeItemUpdateRequest {
  final String? name;
  final String? category;
  final String? subcategory;
  final String? style;
  final String? iconEmoji;
  final String? imageUrl;
  final String? blurHash;
  final int? minTemp;
  final int? maxTemp;
  final int? warmthLevel;
  final bool? rainOk;
  final bool? snowOk;
  final bool? windOk;
  final String? usage;
  final String? materials;
  final bool? isFavorite;
  final bool? isArchived;
  final String? season;
  final String? gender;
  final String? fit;
  final String? pattern;
  final String? localImagePath;

  WardrobeItemUpdateRequest({
    this.name,
    this.category,
    this.subcategory,
    this.style,
    this.iconEmoji,
    this.imageUrl,
    this.blurHash,
    this.minTemp,
    this.maxTemp,
    this.warmthLevel,
    this.rainOk,
    this.snowOk,
    this.windOk,
    this.usage,
    this.materials,
    this.isFavorite,
    this.isArchived,
    this.season,
    this.gender,
    this.fit,
    this.pattern,
    this.localImagePath,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) json['name'] = name;
    if (category != null) json['category'] = category;
    if (subcategory != null) json['subcategory'] = subcategory;
    if (style != null) json['style'] = style;
    if (iconEmoji != null) json['icon_emoji'] = iconEmoji;
    if (imageUrl != null) json['image_url'] = imageUrl;
    if (blurHash != null) json['blur_hash'] = blurHash;
    if (minTemp != null) json['min_temp'] = minTemp;
    if (maxTemp != null) json['max_temp'] = maxTemp;
    if (warmthLevel != null) json['warmth_level'] = warmthLevel;
    if (rainOk != null) json['rain_ok'] = rainOk;
    if (snowOk != null) json['snow_ok'] = snowOk;
    if (windOk != null) json['wind_ok'] = windOk;
    if (usage != null) json['usage'] = usage;
    if (materials != null) json['materials'] = materials;
    if (isFavorite != null) json['is_favorite'] = isFavorite;
    if (isArchived != null) json['is_archived'] = isArchived;
    if (season != null) json['season'] = season;
    if (gender != null) json['gender'] = gender;
    if (fit != null) json['fit'] = fit;
    if (pattern != null) json['pattern'] = pattern;
    if (localImagePath != null) json['local_image_path'] = localImagePath;
    return json;
  }
}
