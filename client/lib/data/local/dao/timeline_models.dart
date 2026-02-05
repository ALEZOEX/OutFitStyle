import '../../../domain/entities/recommendation_entity.dart';

// Вспомогательный класс для DAO
class TimelineDayRow {
  final DateTime date;
  final int outfitCount;
  final RecommendationRow? recommendation;

  const TimelineDayRow({
    required this.date,
    required this.outfitCount,
    this.recommendation,
  });
}
