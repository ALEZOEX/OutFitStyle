import 'package:flutter/material.dart';
import '../../../domain/entities/outfit_recommendation.dart';

/// Карточка персональной рекомендации с полным комплектом одежды
///
/// Обязательные элементы:
/// - Верх (top): футболка, рубашка, худи, свитер и т.д.
/// - Низ (bottom): штаны, джинсы, брюки, шорты
/// - Обувь (shoes): кроссовки, ботинки, туфли
/// - Аксессуары (accessories): куртка, пальто, шапка, шарф (опционально)
class RecommendationCard extends StatelessWidget {
  final OutfitRecommendation recommendation;
  final VoidCallback? onDetailsPressed;
  final VoidCallback? onPlanPressed;
  final VoidCallback? onUsePressed;
  final VoidCallback? onLikePressed;
  final VoidCallback? onDislikePressed;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onDetailsPressed,
    this.onPlanPressed,
    this.onUsePressed,
    this.onLikePressed,
    this.onDislikePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Получаем предметы по категориям
    final topItems = _getItemsByCategory('top');
    final bottomItems = _getItemsByCategory('bottom');
    final shoesItems = _getItemsByCategory('shoes');
    final accessoryItems = _getItemsByCategory('accessories');

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with weather and title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    recommendation.title ?? 'Рекомендация',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
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
                      color:
                          isDarkMode
                              ? theme.colorScheme.primaryContainer
                              : Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.thermostat,
                          size: 14,
                          color:
                              isDarkMode
                                  ? theme.colorScheme.onPrimaryContainer
                                  : Colors.blue[800],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recommendation.temperature?.round() ?? 0}°C',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                isDarkMode
                                    ? theme.colorScheme.onPrimaryContainer
                                    : Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Описание
            if (recommendation.description != null &&
                recommendation.description!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? theme.colorScheme.secondaryContainer.withOpacity(
                            0.3,
                          )
                          : Colors.green[50],
                  border: Border.all(
                    color:
                        isDarkMode
                            ? theme.colorScheme.secondaryContainer
                            : Colors.green[200]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  recommendation.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        isDarkMode
                            ? theme.colorScheme.onSecondaryContainer
                            : Colors.green[800],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Полный комплект одежды
            Text(
              'Комплект одежды',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Верх
            _buildOutfitCategory(
              context,
              category: 'Верх',
              icon: Icons.checkroom,
              items: topItems,
              color: Colors.blue,
              required: true,
            ),
            const SizedBox(height: 10),

            // Низ
            _buildOutfitCategory(
              context,
              category: 'Низ',
              icon: Icons.checkroom_outlined,
              items: bottomItems,
              color: Colors.green,
              required: true,
            ),
            const SizedBox(height: 10),

            // Обувь
            _buildOutfitCategory(
              context,
              category: 'Обувь',
              icon: Icons.bolt,
              items: shoesItems,
              color: Colors.orange,
              required: true,
            ),
            const SizedBox(height: 10),

            // Аксессуары (опционально)
            if (accessoryItems.isNotEmpty)
              _buildOutfitCategory(
                context,
                category: 'Аксессуары',
                icon: Icons.shopping_bag,
                items: accessoryItems,
                color: Colors.purple,
                required: false,
              ),

            const SizedBox(height: 16),

            // Кнопки действий
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Дизлайк
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDislikePressed,
                    icon: const Icon(Icons.thumb_down, color: Colors.red),
                    label: const Text('Не нравится'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Лайк
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onLikePressed,
                    icon: const Icon(Icons.thumb_up, color: Colors.green),
                    label: const Text('Нравится'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      foregroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Запланировать
                Expanded(
                  child: TextButton.icon(
                    onPressed: onPlanPressed,
                    icon: Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.primary,
                    ),
                    label: const Text('Запланировать'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Использовать
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onUsePressed,
                    icon: const Icon(Icons.check),
                    label: const Text('Использовать'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Категория одежды в комплекте
  Widget _buildOutfitCategory(
    BuildContext context, {
    required String category,
    required IconData icon,
    required List<String> items,
    required Color color,
    required bool required,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? color.withValues(alpha: 0.15)
                : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDarkMode
                  ? color.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      category,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (required)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'обязательно',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (items.isNotEmpty)
                  Text(
                    items.join(', '),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                else if (required)
                  Text(
                    '⚠️ Требуется предмет',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    'Не выбрано',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Получить предметы по категории
  List<String> _getItemsByCategory(String category) {
    final items = recommendation.recommendedItems ?? [];
    final result = <String>[];

    for (final item in items) {
      final itemLower = item.toLowerCase();

      switch (category) {
        case 'top':
          if (itemLower.contains('футболк') ||
              itemLower.contains('рубашк') ||
              itemLower.contains('худи') ||
              itemLower.contains('свитер') ||
              itemLower.contains('кофт') ||
              itemLower.contains('топ') ||
              itemLower.contains('блуз') ||
              itemLower.contains('лонгслив') ||
              itemLower.contains('водолазк') ||
              itemLower.contains('майк') ||
              itemLower.contains('поло')) {
            result.add(item);
          }
          break;
        case 'bottom':
          if (itemLower.contains('джинс') ||
              itemLower.contains('брюк') ||
              itemLower.contains('штан') ||
              itemLower.contains('шорт') ||
              itemLower.contains('юбк') ||
              itemLower.contains('леггинс') ||
              itemLower.contains('карго') ||
              itemLower.contains('чинос')) {
            result.add(item);
          }
          break;
        case 'shoes':
          if (itemLower.contains('кроссовк') ||
              itemLower.contains('ботинк') ||
              itemLower.contains('туфел') ||
              itemLower.contains('сандали') ||
              itemLower.contains('обув') ||
              itemLower.contains('кед') ||
              itemLower.contains('сапог') ||
              itemLower.contains('полуботинк') ||
              itemLower.contains('мокасин') ||
              itemLower.contains('лофер')) {
            result.add(item);
          }
          break;
        case 'accessories':
          if (itemLower.contains('куртк') ||
              itemLower.contains('пальт') ||
              itemLower.contains('жакет') ||
              itemLower.contains('пиджак') ||
              itemLower.contains('ветровк') ||
              itemLower.contains('дождевик') ||
              itemLower.contains('жилет') ||
              itemLower.contains('шапк') ||
              itemLower.contains('шарф') ||
              itemLower.contains('перчатк') ||
              itemLower.contains('сумк') ||
              itemLower.contains('ремен') ||
              itemLower.contains('очк') ||
              itemLower.contains('кепк') ||
              itemLower.contains('сноуд') ||
              itemLower.contains('капюшон')) {
            result.add(item);
          }
          break;
      }
    }

    return result;
  }
}
