import 'recommendation_entity.dart';

/// Сущность дня в таймлайне, содержащая информацию о рекомендациях и количестве образов на день
class TimelineDay {
  final DateTime date;
  final int outfitCount;
  final RecommendationRow? recommendation;

  TimelineDay({
    required this.date,
    required this.outfitCount,
    this.recommendation,
  });

  factory TimelineDay.fromJson(Map<String, dynamic> json) {
    // Проверяем обязательные поля
    if (json['date'] == null) {
      throw ArgumentError('Field "date" is required but was null');
    }
    if (json['outfit_count'] == null) {
      throw ArgumentError('Field "outfit_count" is required but was null');
    }

    return TimelineDay(
      date: DateTime.parse(json['date'] as String),
      outfitCount: json['outfit_count'] as int,
      recommendation:
          json['recommendation'] != null
              ? RecommendationRow.fromJson(
                json['recommendation'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'outfit_count': outfitCount,
      'recommendation': recommendation?.toJson(),
    };
  }

  TimelineDay copyWith({
    DateTime? date,
    int? outfitCount,
    RecommendationRow? recommendation,
  }) {
    return TimelineDay(
      date: date ?? this.date,
      outfitCount: outfitCount ?? this.outfitCount,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  static TimelineDay fromExternal(Map<String, dynamic> external) {
    return TimelineDay(
      date: DateTime.parse(
        external['date'] ?? DateTime.now().toIso8601String(),
      ),
      outfitCount: external['outfit_count'] ?? 0,
      recommendation:
          external['recommendation'] != null
              ? RecommendationRow.fromExternal(
                external['recommendation'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  static TimelineDay fromDbEntity(dynamic dbEntity) {
    return TimelineDay(
      date: dbEntity.date,
      outfitCount: dbEntity.outfitCount,
      recommendation:
          dbEntity.recommendation != null
              ? RecommendationRow.fromDbEntity(dbEntity.recommendation)
              : null,
    );
  }

  @override
  String toString() {
    return 'TimelineDay(date: $date, outfitCount: $outfitCount, recommendation: $recommendation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TimelineDay &&
        other.date == date &&
        other.outfitCount == outfitCount &&
        other.recommendation == recommendation;
  }

  @override
  int get hashCode {
    return date.hashCode ^ outfitCount.hashCode ^ recommendation.hashCode;
  }
}
