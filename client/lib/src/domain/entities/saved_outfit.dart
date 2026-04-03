/// Сущность сохранённого образа (SavedOutfit)
///
/// Соответствует серверной модели domain.SavedOutfit
class SavedOutfit {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final List<dynamic> items;
  final List<String> occasions;
  final List<String> seasons;
  final int? minTemp;
  final int? maxTemp;
  final String? thumbnailUrl;
  final bool isFavorite;
  final int timesWorn;
  final DateTime? lastWornAt;
  final DateTime createdAt;

  const SavedOutfit({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.items,
    this.occasions = const [],
    this.seasons = const [],
    this.minTemp,
    this.maxTemp,
    this.thumbnailUrl,
    this.isFavorite = false,
    this.timesWorn = 0,
    this.lastWornAt,
    required this.createdAt,
  });

  factory SavedOutfit.fromJson(Map<String, dynamic> json) {
    final outfitData = json['outfit'] as Map<String, dynamic>? ?? json;

    return SavedOutfit(
      id: outfitData['id']?.toString() ?? '',
      userId: outfitData['user_id']?.toString() ?? '',
      name: outfitData['name'] as String? ?? '',
      description: outfitData['description'] as String?,
      items: outfitData['items'] is List
          ? outfitData['items'] as List<dynamic>
          : [],
      occasions: outfitData['occasions'] is List
          ? (outfitData['occasions'] as List<dynamic>)
              .map((e) => e.toString())
              .toList()
          : [],
      seasons: outfitData['seasons'] is List
          ? (outfitData['seasons'] as List<dynamic>)
              .map((e) => e.toString())
              .toList()
          : [],
      minTemp: outfitData['min_temp'] as int?,
      maxTemp: outfitData['max_temp'] as int?,
      thumbnailUrl: outfitData['thumbnail_url'] as String?,
      isFavorite: outfitData['is_favorite'] as bool? ?? false,
      timesWorn: outfitData['times_worn'] as int? ?? 0,
      lastWornAt: outfitData['last_worn_at'] != null
          ? DateTime.parse(outfitData['last_worn_at'] as String)
          : null,
      createdAt: outfitData['created_at'] != null
          ? DateTime.parse(outfitData['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'items': items,
      'occasions': occasions,
      'seasons': seasons,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'thumbnail_url': thumbnailUrl,
      'is_favorite': isFavorite,
      'times_worn': timesWorn,
      'last_worn_at': lastWornAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  SavedOutfit copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<dynamic>? items,
    List<String>? occasions,
    List<String>? seasons,
    int? minTemp,
    int? maxTemp,
    String? thumbnailUrl,
    bool? isFavorite,
    int? timesWorn,
    DateTime? lastWornAt,
    DateTime? createdAt,
  }) {
    return SavedOutfit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
      occasions: occasions ?? this.occasions,
      seasons: seasons ?? this.seasons,
      minTemp: minTemp ?? this.minTemp,
      maxTemp: maxTemp ?? this.maxTemp,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      timesWorn: timesWorn ?? this.timesWorn,
      lastWornAt: lastWornAt ?? this.lastWornAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Запрос на создание сохранённого образа
///
/// Соответствует серверной модели domain.SavedOutfitCreateRequest
class SavedOutfitCreateRequest {
  final String name;
  final List<Map<String, dynamic>> items;
  final List<String>? occasions;
  final List<String>? seasons;
  final String? description;

  const SavedOutfitCreateRequest({
    required this.name,
    required this.items,
    this.occasions,
    this.seasons,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'items': items,
    };
    final occ = occasions;
    if (occ != null && occ.isNotEmpty) {
      json['occasions'] = occ;
    }
    final seas = seasons;
    if (seas != null && seas.isNotEmpty) {
      json['seasons'] = seas;
    }
    final desc = description;
    if (desc != null && desc.isNotEmpty) {
      json['description'] = desc;
    }
    return json;
  }
}

/// Запрос на обновление сохранённого образа
///
/// Соответствует серверной модели domain.SavedOutfitUpdateRequest
class SavedOutfitUpdateRequest {
  final String? name;
  final List<Map<String, dynamic>>? items;
  final List<String>? occasions;
  final List<String>? seasons;
  final String? description;
  final bool? isFavorite;

  const SavedOutfitUpdateRequest({
    this.name,
    this.items,
    this.occasions,
    this.seasons,
    this.description,
    this.isFavorite,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (items != null) json['items'] = items;
    final occ = occasions;
    if (occ != null && occ.isNotEmpty) json['occasions'] = occ;
    final seas = seasons;
    if (seas != null && seas.isNotEmpty) json['seasons'] = seas;
    final desc = description;
    if (desc != null && desc.isNotEmpty) json['description'] = desc;
    if (isFavorite != null) json['is_favorite'] = isFavorite;
    return json;
  }
}

/// Ответ API со списком образов
class SavedOutfitListResponse {
  final List<SavedOutfit> outfits;
  final int total;
  final int page;
  final int limit;

  const SavedOutfitListResponse({
    required this.outfits,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory SavedOutfitListResponse.fromJson(Map<String, dynamic> json) {
    final outfitsData = json['outfits'] as List<dynamic>? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>?;

    return SavedOutfitListResponse(
      outfits: outfitsData
          .map((e) => SavedOutfit.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: pagination?['total'] as int? ?? outfitsData.length,
      page: pagination?['page'] as int? ?? 1,
      limit: pagination?['limit'] as int? ?? outfitsData.length,
    );
  }
}
