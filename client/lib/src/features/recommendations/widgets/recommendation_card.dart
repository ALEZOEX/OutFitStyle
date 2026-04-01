import 'package:flutter/material.dart';
import '../../../domain/entities/outfit_recommendation.dart';
import '../../../theme/app_theme.dart';

/// Карточка персональной рекомендации с полным комплектом одежды
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

    final topItems = _getItemsByCategory('top');
    final bottomItems = _getItemsByCategory('bottom');
    final shoesItems = _getItemsByCategory('shoes');
    final accessoryItems = _getItemsByCategory('accessories');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLg,
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    recommendation.title ?? 'Рекомендация',
                    style: AppTypography.headlineSmall(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (recommendation.weatherCondition != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.thermostat,
                          size: 14,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${recommendation.temperature?.round() ?? 0}°C',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Описание
            if (recommendation.description != null &&
                recommendation.description!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(
                    alpha: isDarkMode ? 0.15 : 0.08,
                  ),
                  border: Border.all(
                    color: AppColors.success.withValues(
                      alpha: isDarkMode ? 0.3 : 0.2,
                    ),
                  ),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Text(
                  recommendation.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode
                        ? AppColors.success.withValues(alpha: 0.9)
                        : AppColors.success,
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.lg),

            // Комплект одежды
            Text('Комплект одежды', style: AppTypography.labelLarge(context)),
            const SizedBox(height: AppSpacing.md),

            _buildOutfitCategory(
              context,
              category: 'Верх',
              icon: Icons.checkroom,
              items: topItems,
              color: AppColors.info,
              required: true,
            ),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xs),

            _buildOutfitCategory(
              context,
              category: 'Низ',
              icon: Icons.checkroom_outlined,
              items: bottomItems,
              color: AppColors.success,
              required: true,
            ),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xs),

            _buildOutfitCategory(
              context,
              category: 'Обувь',
              icon: Icons.bolt,
              items: shoesItems,
              color: AppColors.warning,
              required: true,
            ),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xs),

            if (accessoryItems.isNotEmpty)
              _buildOutfitCategory(
                context,
                category: 'Аксессуары',
                icon: Icons.shopping_bag,
                items: accessoryItems,
                color: AppColors.primary,
                required: false,
              ),

            const SizedBox(height: AppSpacing.lg),

            // Кнопки действий
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDislikePressed,
                    icon: const Icon(Icons.thumb_down, size: 18),
                    label: const Text('Не нравится'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onLikePressed,
                    icon: const Icon(Icons.thumb_up, size: 18),
                    label: const Text('Нравится'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      foregroundColor: AppColors.success,
                      side: BorderSide(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onPlanPressed,
                    icon: Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    label: const Text('Запланировать'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onUsePressed,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Использовать'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDarkMode ? 0.15 : 0.08),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(
          color: color.withValues(alpha: isDarkMode ? 0.3 : 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(category, style: AppTypography.labelMedium(context)),
                    if (required)
                      Container(
                        margin: const EdgeInsets.only(left: AppSpacing.xs + 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs + 2,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          'обязательно',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.error,
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
                    style: AppTypography.bodyMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                else if (required)
                  Text(
                    '⚠️ Требуется предмет',
                    style: AppTypography.bodyMedium(context).copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    'Не выбрано',
                    style: AppTypography.bodyMedium(context).copyWith(
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
      }
    }

    return result;
  }
}
