import 'package:drift/drift.dart';

// Основная сущность элемента гардероба
class WardrobeEntries extends Table {
  @override
  Set<Column> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get subcategory => text()();
  TextColumn get style => text()();
  TextColumn get iconEmoji => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get blurHash => text().nullable()();
  IntColumn get minTemp => integer().nullable()();
  IntColumn get maxTemp => integer().nullable()();
  IntColumn get warmthLevel => integer().nullable()();
  BoolColumn get rainOk => boolean()();
  BoolColumn get snowOk => boolean()();
  BoolColumn get windOk => boolean()();
  TextColumn get usage => text().nullable()();
  TextColumn get materials => text().nullable()();
  IntColumn get wearCount => integer()();
  DateTimeColumn get lastWornAt => dateTime().nullable()();
  BoolColumn get isFavorite => boolean()();
  BoolColumn get isArchived => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get dirty => boolean()();
  TextColumn get season => text().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get fit => text().nullable()();
  TextColumn get pattern => text().nullable()();
  TextColumn get localImagePath => text().nullable()();
}

class WardrobeEntry {
  final String id;
  final String? serverId;
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
  final int wearCount;
  final DateTime? lastWornAt;
  final bool isFavorite;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool dirty;
  final String? season;
  final String? gender;
  final String? fit;
  final String? pattern;
  final String? localImagePath;

  WardrobeEntry({
    required this.id,
    this.serverId,
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
    required this.wearCount,
    this.lastWornAt,
    required this.isFavorite,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    required this.dirty,
    this.season,
    this.gender,
    this.fit,
    this.pattern,
    this.localImagePath,
  });

  factory WardrobeEntry.fromJson(Map<String, dynamic> json) {
    // Проверяем обязательные поля
    if (json['id'] == null) {
      throw ArgumentError('Field "id" is required but was null');
    }
    if (json['name'] == null) {
      throw ArgumentError('Field "name" is required but was null');
    }
    if (json['category'] == null) {
      throw ArgumentError('Field "category" is required but was null');
    }
    if (json['subcategory'] == null) {
      throw ArgumentError('Field "subcategory" is required but was null');
    }
    if (json['style'] == null) {
      throw ArgumentError('Field "style" is required but was null');
    }
    if (json['icon_emoji'] == null) {
      throw ArgumentError('Field "icon_emoji" is required but was null');
    }
    if (json['created_at'] == null) {
      throw ArgumentError('Field "created_at" is required but was null');
    }
    if (json['updated_at'] == null) {
      throw ArgumentError('Field "updated_at" is required but was null');
    }

    return WardrobeEntry(
      id: json['id'] as String,
      serverId: json['server_id'] as String?,
      name: json['name'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      style: json['style'] as String,
      iconEmoji: json['icon_emoji'] as String,
      imageUrl: json['image_url'] as String?,
      blurHash: json['blur_hash'] as String?,
      minTemp: json['min_temp'] as int?,
      maxTemp: json['max_temp'] as int?,
      warmthLevel: json['warmth_level'] as int?,
      rainOk: json['rain_ok'] as bool? ?? false,
      snowOk: json['snow_ok'] as bool? ?? false,
      windOk: json['wind_ok'] as bool? ?? false,
      usage: json['usage'] as String?,
      materials: json['materials'] as String?,
      wearCount: json['wear_count'] as int? ?? 0,
      lastWornAt: json['last_worn_at'] != null ? DateTime.parse(json['last_worn_at'] as String) : null,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastSyncedAt: json['last_synced_at'] != null ? DateTime.parse(json['last_synced_at'] as String) : null,
      dirty: json['dirty'] as bool? ?? false,
      season: json['season'] as String?,
      gender: json['gender'] as String?,
      fit: json['fit'] as String?,
      pattern: json['pattern'] as String?,
      localImagePath: json['local_image_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'server_id': serverId,
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
      'wear_count': wearCount,
      'last_worn_at': lastWornAt?.toIso8601String(),
      'is_favorite': isFavorite,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'dirty': dirty,
      'season': season,
      'gender': gender,
      'fit': fit,
      'pattern': pattern,
      'local_image_path': localImagePath,
    };
  }

  WardrobeEntry copyWith({
    String? id,
    String? serverId,
    String? name,
    String? category,
    String? subcategory,
    String? style,
    String? iconEmoji,
    String? imageUrl,
    String? blurHash,
    int? minTemp,
    int? maxTemp,
    int? warmthLevel,
    bool? rainOk,
    bool? snowOk,
    bool? windOk,
    String? usage,
    String? materials,
    int? wearCount,
    DateTime? lastWornAt,
    bool? isFavorite,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? dirty,
    String? season,
    String? gender,
    String? fit,
    String? pattern,
    String? localImagePath,
  }) {
    return WardrobeEntry(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      style: style ?? this.style,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      imageUrl: imageUrl ?? this.imageUrl,
      blurHash: blurHash ?? this.blurHash,
      minTemp: minTemp ?? this.minTemp,
      maxTemp: maxTemp ?? this.maxTemp,
      warmthLevel: warmthLevel ?? this.warmthLevel,
      rainOk: rainOk ?? this.rainOk,
      snowOk: snowOk ?? this.snowOk,
      windOk: windOk ?? this.windOk,
      usage: usage ?? this.usage,
      materials: materials ?? this.materials,
      wearCount: wearCount ?? this.wearCount,
      lastWornAt: lastWornAt ?? this.lastWornAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      dirty: dirty ?? this.dirty,
      season: season ?? this.season,
      gender: gender ?? this.gender,
      fit: fit ?? this.fit,
      pattern: pattern ?? this.pattern,
      localImagePath: localImagePath ?? this.localImagePath,
    );
  }

  static WardrobeEntry fromExternal(Map<String, dynamic> external) {
    return WardrobeEntry(
      id: external['id'] ?? '', // Keep empty if not provided, should be handled by caller
      serverId: external['id'], // External ID becomes serverId
      name: external['name'] ?? '',
      category: external['category'] ?? '',
      subcategory: external['subcategory'] ?? '',
      style: external['style'] ?? '',
      iconEmoji: external['icon_emoji'] ?? '',
      imageUrl: external['image_url'],
      blurHash: external['blur_hash'],
      minTemp: external['min_temp'],
      maxTemp: external['max_temp'],
      warmthLevel: external['warmth_level'],
      rainOk: external['rain_ok'] ?? false,
      snowOk: external['snow_ok'] ?? false,
      windOk: external['wind_ok'] ?? false,
      usage: external['usage'],
      materials: external['materials'],
      wearCount: external['wear_count'] ?? 0,
      lastWornAt: external['last_worn_at'] != null ? DateTime.parse(external['last_worn_at']) : null,
      isFavorite: external['is_favorite'] ?? false,
      isArchived: external['is_archived'] ?? false,
      createdAt: DateTime.parse(external['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(external['updated_at'] ?? DateTime.now().toIso8601String()),
      lastSyncedAt: DateTime.now(),
      dirty: false, // Сразу синхронизировано
      season: external['season'],
      gender: external['gender'],
      fit: external['fit'],
      pattern: external['pattern'],
      localImagePath: external['local_image_path'],
    );
  }

  static WardrobeEntry fromDbEntity(dynamic dbEntity) {
    return WardrobeEntry(
      id: dbEntity.id,
      serverId: dbEntity.serverId,
      name: dbEntity.name,
      category: dbEntity.category,
      subcategory: dbEntity.subcategory,
      style: dbEntity.style,
      iconEmoji: dbEntity.iconEmoji,
      imageUrl: dbEntity.imageUrl,
      blurHash: dbEntity.blurHash,
      minTemp: dbEntity.minTemp,
      maxTemp: dbEntity.maxTemp,
      warmthLevel: dbEntity.warmthLevel,
      rainOk: dbEntity.rainOk,
      snowOk: dbEntity.snowOk,
      windOk: dbEntity.windOk,
      usage: dbEntity.usage,
      materials: dbEntity.materials,
      wearCount: dbEntity.wearCount,
      lastWornAt: dbEntity.lastWornAt,
      isFavorite: dbEntity.isFavorite,
      isArchived: dbEntity.isArchived,
      createdAt: dbEntity.createdAt,
      updatedAt: dbEntity.updatedAt,
      lastSyncedAt: dbEntity.lastSyncedAt,
      dirty: dbEntity.dirty,
      season: dbEntity.season,
      gender: dbEntity.gender,
      fit: dbEntity.fit,
      pattern: dbEntity.pattern,
      localImagePath: dbEntity.localImagePath,
    );
  }
}