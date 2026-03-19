import 'package:drift/drift.dart';

// Основная сущность рекомендации
class Recommendations extends Table {
  @override
  Set<Column> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get origin => text()();
  TextColumn get outfitDataJson => text()();
  TextColumn get weatherDataJson => text()();
  BoolColumn get isFavorite => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get dirty => boolean()();
  TextColumn get localImagePath => text().nullable()();
}

// Вспомогательные классы для работы с рекомендациями
/// Сущность строки рекомендации, содержащая информацию об outfits и соответствующих данных
class RecommendationRow {
  final String id;
  final String? serverId;
  final String origin;
  final String outfitDataJson;
  final String weatherDataJson;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool dirty;
  final String? localImagePath;

  RecommendationRow({
    required this.id,
    this.serverId,
    required this.origin,
    required this.outfitDataJson,
    required this.weatherDataJson,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    required this.dirty,
    this.localImagePath,
  });

  factory RecommendationRow.fromJson(Map<String, dynamic> json) {
    // Проверяем обязательные поля
    if (json['id'] == null) {
      throw ArgumentError('Field "id" is required but was null');
    }
    if (json['outfit_data_json'] == null) {
      throw ArgumentError('Field "outfit_data_json" is required but was null');
    }
    if (json['weather_data_json'] == null) {
      throw ArgumentError('Field "weather_data_json" is required but was null');
    }
    if (json['created_at'] == null) {
      throw ArgumentError('Field "created_at" is required but was null');
    }
    if (json['updated_at'] == null) {
      throw ArgumentError('Field "updated_at" is required but was null');
    }

    return RecommendationRow(
      id: json['id'] as String,
      serverId: json['server_id'] as String?,
      origin: json['origin'] as String? ?? 'local',
      outfitDataJson: json['outfit_data_json'] as String,
      weatherDataJson: json['weather_data_json'] as String,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastSyncedAt:
          json['last_synced_at'] != null
              ? DateTime.parse(json['last_synced_at'] as String)
              : null,
      dirty: json['dirty'] as bool? ?? true,
      localImagePath: json['local_image_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'server_id': serverId,
      'origin': origin,
      'outfit_data_json': outfitDataJson,
      'weather_data_json': weatherDataJson,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'dirty': dirty,
      'local_image_path': localImagePath,
    };
  }

  RecommendationRow copyWith({
    String? id,
    String? serverId,
    String? origin,
    String? outfitDataJson,
    String? weatherDataJson,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? dirty,
    String? localImagePath,
  }) {
    return RecommendationRow(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      origin: origin ?? this.origin,
      outfitDataJson: outfitDataJson ?? this.outfitDataJson,
      weatherDataJson: weatherDataJson ?? this.weatherDataJson,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      dirty: dirty ?? this.dirty,
      localImagePath: localImagePath ?? this.localImagePath,
    );
  }

  static RecommendationRow fromExternal(Map<String, dynamic> external) {
    return RecommendationRow(
      id: external['id'] ?? '',
      serverId: external['id'], // External ID becomes serverId
      origin: 'server', // Отметим, что это серверная рекомендация
      outfitDataJson: external['outfit_data_json'] ?? '{}',
      weatherDataJson: external['weather_data_json'] ?? '{}',
      isFavorite: external['is_favorite'] ?? false,
      createdAt: DateTime.parse(
        external['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        external['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      lastSyncedAt: DateTime.now(),
      dirty: false, // Сразу синхронизировано
      localImagePath: external['local_image_path'],
    );
  }

  static RecommendationRow fromDbEntity(dynamic dbEntity) {
    return RecommendationRow(
      id: dbEntity.id,
      serverId: dbEntity.serverId,
      origin: dbEntity.origin,
      outfitDataJson: dbEntity.outfitDataJson,
      weatherDataJson: dbEntity.weatherDataJson,
      isFavorite: dbEntity.isFavorite,
      createdAt: dbEntity.createdAt,
      updatedAt: dbEntity.updatedAt,
      lastSyncedAt: dbEntity.lastSyncedAt,
      dirty: dbEntity.dirty,
      localImagePath: dbEntity.localImagePath,
    );
  }
}
