import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/outfit_rating.dart';
import '../providers/rating_provider.dart';

/// Виджет рейтинга рекомендации со звёздами и статистикой качества
class OutfitRatingWidget extends ConsumerStatefulWidget {
  final String recommendationId;
  final VoidCallback? onRated;

  const OutfitRatingWidget({
    super.key,
    required this.recommendationId,
    this.onRated,
  });

  @override
  ConsumerState<OutfitRatingWidget> createState() => _OutfitRatingWidgetState();
}

class _OutfitRatingWidgetState extends ConsumerState<OutfitRatingWidget> {
  int? _tempRating;

  @override
  Widget build(BuildContext context) {
    final qualityAsync = ref.watch(
      recommendationQualityProvider(widget.recommendationId),
    );
    final userRatingAsync = ref.watch(
      userRatingProvider(widget.recommendationId),
    );
    final notifier = ref.read(ratingNotifierProvider.notifier);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Text(
              'Оцените этот образ',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Звёзды рейтинга
            userRatingAsync.when(
              data: (userRating) {
                final currentRating = _tempRating ?? userRating?.rating ?? 0;
                return _buildStarRating(currentRating, (rating) async {
                  setState(() {
                    _tempRating = rating;
                  });

                  try {
                    await notifier.rateOutfit(
                      recommendationId: widget.recommendationId,
                      rating: rating,
                      outfitItems: [], // Можно передать ID вещей
                    );
                    widget.onRated?.call();
                  } catch (e) {
                    setState(() {
                      _tempRating = userRating?.rating ?? 0;
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ошибка при оценке: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                });
              },
              loading: () => _buildStarRating(0, (_) {}),
              error: (_, _) => _buildStarRating(0, (_) {}),
            ),

            const SizedBox(height: 12),

            // Статистика качества
            qualityAsync.when(
              data: (quality) => _buildQualityStats(quality),
              loading: () => const CircularProgressIndicator.adaptive(),
              error:
                  (error, stack) => Text(
                    'Ошибка загрузки статистики',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Виджет звёздного рейтинга
  Widget _buildStarRating(int rating, Function(int) onRate) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= rating;

        return IconButton(
          icon: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: _getStarColor(starValue),
            size: 32,
          ),
          onPressed: () => onRate(starValue),
          tooltip: _getRatingTooltip(starValue),
        );
      }),
    );
  }

  /// Виджет статистики качества
  Widget _buildQualityStats(RecommendationQuality quality) {
    if (quality.ratingCount == 0) {
      return Text(
        'Пока нет оценок',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      );
    }

    final avgScore = quality.avgQualityScore.round();
    final scoreColor = _getScoreColor(avgScore);

    return Row(
      children: [
        // Средний quality_score
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scoreColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                avgScore > 0
                    ? Icons.trending_up
                    : (avgScore < 0 ? Icons.trending_down : Icons.remove),
                color: scoreColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                avgScore > 0 ? '+$avgScore' : '$avgScore',
                style: TextStyle(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Количество оценок
        Text(
          '${quality.ratingCount} ${_pluralize(quality.ratingCount, 'оценка', 'оценки', 'оценок')}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),

        const Spacer(),

        // Индикатор положительных/отрицательных
        if (quality.positiveCount > 0 || quality.negativeCount > 0) ...[
          _buildRatingDistribution(quality),
        ],
      ],
    );
  }

  /// Индикатор распределения оценок
  Widget _buildRatingDistribution(RecommendationQuality quality) {
    final total = quality.positiveCount + quality.negativeCount;
    if (total == 0) return const SizedBox.shrink();

    final positivePercent = quality.positiveCount / total;

    return SizedBox(
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: positivePercent,
            backgroundColor: Colors.red.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '👍 ${quality.positiveCount}',
                style: TextStyle(fontSize: 10, color: Colors.green.shade700),
              ),
              Text(
                '👎 ${quality.negativeCount}',
                style: TextStyle(fontSize: 10, color: Colors.red.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Цвет звезды в зависимости от значения
  Color _getStarColor(int starValue) {
    if (starValue <= 2) return Colors.red.shade400;
    if (starValue == 3) return Colors.orange.shade400;
    return Colors.amber;
  }

  /// Цвет quality_score
  Color _getScoreColor(int score) {
    if (score > 0) return Colors.green.shade600;
    if (score < 0) return Colors.red.shade600;
    return Colors.grey.shade600;
  }

  /// Подсказка для звёзд
  String _getRatingTooltip(int starValue) {
    switch (starValue) {
      case 1:
        return 'Ужасно (quality: -10)';
      case 2:
        return 'Плохо (quality: -5)';
      case 3:
        return 'Нормально (quality: 0)';
      case 4:
        return 'Хорошо (quality: +5)';
      case 5:
        return 'Отлично (quality: +10)';
      default:
        return '';
    }
  }

  /// Склонение слов
  String _pluralize(int number, String one, String few, String many) {
    final mod = number % 10;
    final mod100 = number % 100;

    if (mod100 >= 11 && mod100 <= 19) return many;
    if (mod == 1) return one;
    if (mod >= 2 && mod <= 4) return few;
    return many;
  }
}

/// Компактный виджет только со статистикой качества
class QualityScoreWidget extends ConsumerWidget {
  final String recommendationId;

  const QualityScoreWidget({super.key, required this.recommendationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qualityAsync = ref.watch(
      recommendationQualityProvider(recommendationId),
    );

    return qualityAsync.when(
      data: (quality) {
        if (quality.ratingCount == 0) {
          return const SizedBox.shrink();
        }

        final avgScore = quality.avgQualityScore.round();
        final scoreColor = _getScoreColor(avgScore);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scoreColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                avgScore > 0
                    ? Icons.trending_up
                    : (avgScore < 0 ? Icons.trending_down : Icons.remove),
                color: scoreColor,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                avgScore > 0 ? '+$avgScore' : '$avgScore',
                style: TextStyle(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
      loading:
          () => const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Color _getScoreColor(int score) {
    if (score > 0) return Colors.green.shade600;
    if (score < 0) return Colors.red.shade600;
    return Colors.grey.shade600;
  }
}

/// Bottom sheet для оценки рекомендации с дополнительной обратной связью
class RateOutfitBottomSheet extends StatefulWidget {
  final String recommendationId;
  final Function(int rating, String? feedback, ThermalFeedback? thermal)?
  onRated;

  const RateOutfitBottomSheet({
    super.key,
    required this.recommendationId,
    this.onRated,
  });

  @override
  State<RateOutfitBottomSheet> createState() => _RateOutfitBottomSheetState();
}

class _RateOutfitBottomSheetState extends State<RateOutfitBottomSheet> {
  int _rating = 0;
  String? _feedback;
  ThermalFeedback? _thermalFeedback;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Оцените этот образ',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Звёзды
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return IconButton(
                icon: Icon(
                  starValue <= _rating ? Icons.star : Icons.star_border,
                  color: _getStarColor(starValue),
                  size: 40,
                ),
                onPressed: () => setState(() => _rating = starValue),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Текстовое описание выбранного рейтинга
          if (_rating > 0)
            Text(
              _getRatingDescription(_rating),
              style: TextStyle(
                color: _getStarColor(_rating),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: 24),

          // Термальная обратная связь
          Text(
            'Как вам комфорт в этом образе?',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                ThermalFeedback.values.map((thermal) {
                  final isSelected = _thermalFeedback == thermal;
                  return ChoiceChip(
                    label: Text(thermal.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _thermalFeedback = selected ? thermal : null;
                      });
                    },
                  );
                }).toList(),
          ),

          const SizedBox(height: 16),

          // Текстовый отзыв
          TextField(
            controller: _feedbackController,
            decoration: const InputDecoration(
              labelText: 'Комментарий (необязательно)',
              hintText: 'Поделитесь своим мнением об этом образе...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            maxLines: 3,
            onChanged: (value) => _feedback = value.isEmpty ? null : value,
          ),

          const SizedBox(height: 24),

          // Кнопки
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed:
                      _rating > 0
                          ? () {
                            widget.onRated?.call(
                              _rating,
                              _feedback,
                              _thermalFeedback,
                            );
                            Navigator.pop(context);
                          }
                          : null,
                  child: const Text('Отправить'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Color _getStarColor(int starValue) {
    if (starValue <= 2) return Colors.red.shade400;
    if (starValue == 3) return Colors.orange.shade400;
    return Colors.amber;
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return 'Ужасно — качество: -10';
      case 2:
        return 'Плохо — качество: -5';
      case 3:
        return 'Нормально — качество: 0';
      case 4:
        return 'Хорошо — качество: +5';
      case 5:
        return 'Отлично — качество: +10';
      default:
        return '';
    }
  }
}

/// Показать bottom sheet для оценки
void showRateOutfitBottomSheet({
  required BuildContext context,
  required String recommendationId,
  Function(int rating, String? feedback, ThermalFeedback? thermal)? onRated,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => RateOutfitBottomSheet(
          recommendationId: recommendationId,
          onRated: onRated,
        ),
  );
}
