import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';

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
  TextColumn get imageUrl => text().nullable()();
  TextColumn get localImagePath => text().nullable()();
}

// Вспомогательные классы для работы с рекомендациями
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
  final String? imageUrl;
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
    this.imageUrl,
    this.localImagePath,
  });

  factory RecommendationRow.fromJson(Map<String, dynamic> json) {
    return RecommendationRow(
      id: json['id'],
      serverId: json['server_id'],
      origin: json['origin'] ?? 'local',
      outfitDataJson: json['outfit_data_json'],
      weatherDataJson: json['weather_data_json'],
      isFavorite: json['is_favorite'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastSyncedAt: json['last_synced_at'] != null ? DateTime.parse(json['last_synced_at']) : null,
      dirty: json['dirty'] ?? true,
      imageUrl: json['image_url'],
      localImagePath: json['local_image_path'],
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
      'image_url': imageUrl,
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
    String? imageUrl,
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
      imageUrl: imageUrl ?? this.imageUrl,
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
      createdAt: DateTime.parse(external['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(external['updated_at'] ?? DateTime.now().toIso8601String()),
      lastSyncedAt: DateTime.now(),
      dirty: false, // Сразу синхронизировано
      imageUrl: external['image_url'],
      localImagePath: external['local_image_path'],
    );
  }
}