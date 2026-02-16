import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/recommendation.dart';
import '../presentation/controllers/recommendation_state_notifier.dart';
import 'recommendation_feedback_dialog.dart';

class RecommendationCard extends ConsumerWidget {
  final Recommendation recommendation;
  final String userId;
  final VoidCallback? onDetailsPressed;
  final VoidCallback? onSharePressed;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.userId,
    this.onDetailsPressed,
    this.onSharePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: recommendation.isFavorite ? Colors.orange : Colors.transparent,
          width: recommendation.isFavorite ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with weather and confidence
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    recommendation.weather ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (recommendation.weather != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Погода: ${recommendation.weather}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[800],
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Confidence and rating row
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Доверие: ${recommendation.confidenceScore}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                if ((recommendation.rating ?? 0) > 0) ...[
                  ...List.generate(5, (index) {
                    return Icon(
                      index < (recommendation.rating ?? 0)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ],
                const Spacer(),
                if ((recommendation.usageCount ?? 0) > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Использовано: ${recommendation.usageCount ?? 0}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.purple[800],
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Outfit title and occasion/activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Рекомендуемый образ:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if ((recommendation.occasion?.isNotEmpty ?? false) ||
                    (recommendation.activity?.isNotEmpty ?? false))
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (recommendation.occasion?.isNotEmpty ?? false)
                          ? (recommendation.occasion ?? '')
                          : ((recommendation.activity?.isNotEmpty ?? false)
                              ? (recommendation.activity ?? '')
                              : ''),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.indigo[700],
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Outfit items
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (recommendation.outfit?.clothingItemIds ?? [])
                  .take(6) // Show up to 6 items
                  .map((itemId) => _buildOutfitItem(itemId.toString(), context))
                  .toList(),
            ),
            const SizedBox(height: 12),

            // Recommendation reason
            if (recommendation.recommendationReason?.isNotEmpty ?? false)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Причина: ${recommendation.recommendationReason ?? ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue[800],
                      ),
                ),
              ),
            if (!(recommendation.recommendationReason?.isNotEmpty ?? false))
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Совет: ${_getRecommendationTip(recommendation.outfit?.id?.toString() ?? '')}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green[800],
                      ),
                ),
              ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: (recommendation.isLiked ?? false)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: (recommendation.isLiked ?? false) ? Colors.red : null,
                  label: 'Нравится',
                  onPressed: () {
                    ref
                        .read(recommendationStateNotifierProvider.notifier)
                        .toggleLike(
                          recommendation.id?.toString() ?? '',
                        );
                  },
                ),
                _buildActionButton(
                  icon: Icons.feedback,
                  color: Colors.blue,
                  label: 'Отзыв',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => RecommendationFeedbackDialog(
                        recommendation: recommendation,
                        userId: userId,
                        onFeedbackSubmitted: (feedback) {
                          // recommendationNotifier.submitDetailedFeedback(
                          //   userId: userId,
                          //   recommendationId: recommendation.id?.toString() ?? '',
                          //   feedback: feedback,
                          // );
                        },
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.visibility,
                  color: Colors.green,
                  label: 'Детали',
                  onPressed: onDetailsPressed ?? () {},
                ),
                _buildActionButton(
                  icon: recommendation.isSaved
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                  color:
                      recommendation.isSaved ? Colors.orange : null,
                  label: 'Сохранить',
                  onPressed: () {
                    ref
                        .read(recommendationStateNotifierProvider.notifier)
                        .toggleSave(
                          recommendation.id?.toString() ?? '',
                        );
                  },
                ),
                _buildActionButton(
                  icon: Icons.share,
                  color: Colors.purple,
                  label: 'Поделиться',
                  onPressed: onSharePressed ?? () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color? color,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(label),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildOutfitItem(String itemId, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checkroom, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              'Эл. $itemId',
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getRecommendationTip(String? outfitId) {
    final tips = [
      'Добавьте легкую куртку на случай похолодания',
      'Выберите натуральные ткани для комфорта',
      'Не забудьте головной убор при ярком солнце',
      'Обувь должна быть удобной для долгой ходьбы',
      'Следите за уровнем влажности при выборе одежды',
      'Учитывайте ветер при выборе верхней одежды',
      'Выбирайте одежду по размеру для лучшего комфорта',
      'Создайте слои одежды для адаптации к температуре',
      'Выберите водонепроницаемую одежду при дожде',
      'Предпочитайте светлые тона в жаркую погоду',
    ];

    return tips[(outfitId ?? '').hashCode.abs() % tips.length];
  }
}
