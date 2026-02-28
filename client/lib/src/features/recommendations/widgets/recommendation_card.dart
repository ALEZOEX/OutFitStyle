import 'package:flutter/material.dart';
import '../../../domain/entities/outfit_recommendation.dart';

/// Карточка персональной рекомендации
/// Без социальной функциональности (лайки, комментарии, лента)
class RecommendationCard extends StatelessWidget {
  final OutfitRecommendation recommendation;
  final VoidCallback? onDetailsPressed;
  final VoidCallback? onPlanPressed;
  final VoidCallback? onUsePressed;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onDetailsPressed,
    this.onPlanPressed,
    this.onUsePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with weather
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    recommendation.title ?? 'Рекомендация',
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (recommendation.weatherCondition != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? theme.colorScheme.primaryContainer 
                          : Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recommendation.weatherCondition!,
                      style: theme.textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? theme.colorScheme.onPrimaryContainer
                                : Colors.blue[800],
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Outfit items
            if (recommendation.recommendedItems != null &&
                recommendation.recommendedItems!.isNotEmpty) ...[
              Text(
                'Рекомендуемые вещи:',
                style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recommendation.recommendedItems!
                    .take(6)
                    .map((item) => _buildOutfitItem(item, context))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Description
            if (recommendation.description != null &&
                recommendation.description!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? theme.colorScheme.secondaryContainer.withOpacity(0.3)
                      : Colors.green[50],
                  border: Border.all(
                    color: isDarkMode
                        ? theme.colorScheme.secondaryContainer
                        : Colors.green[200]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  recommendation.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? theme.colorScheme.onSecondaryContainer
                            : Colors.green[800],
                      ),
                ),
              ),
            if (recommendation.description == null ||
                recommendation.description!.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                      : Colors.blue[50],
                  border: Border.all(
                    color: isDarkMode
                        ? theme.colorScheme.primaryContainer
                        : Colors.blue[200]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Совет: ${_getRecommendationTip(recommendation.id ?? '')}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? theme.colorScheme.onPrimaryContainer
                            : Colors.blue[800],
                      ),
                ),
              ),
            const SizedBox(height: 12),

            // Action buttons - персональные действия
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.calendar_today,
                  color: isDarkMode ? theme.colorScheme.primary : Colors.blue,
                  label: 'Запланировать',
                  onPressed: onPlanPressed,
                ),
                _buildActionButton(
                  icon: Icons.visibility,
                  color: isDarkMode ? theme.colorScheme.secondary : Colors.green,
                  label: 'Детали',
                  onPressed: onDetailsPressed ?? () {},
                ),
                _buildActionButton(
                  icon: Icons.check,
                  color: isDarkMode ? theme.colorScheme.tertiary : Colors.orange,
                  label: 'Использовать',
                  onPressed: onUsePressed,
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

  Widget _buildOutfitItem(String item, BuildContext context) {
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
              item,
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
