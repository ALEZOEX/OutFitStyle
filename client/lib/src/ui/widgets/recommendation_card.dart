import 'package:flutter/material.dart';

import '../../features/domain/entities/outfit_recommendation.dart';

/// Карточка рекомендации outfit'а
class RecommendationCard extends StatelessWidget {
  final OutfitRecommendation recommendation;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final bool isLiked;
  final bool isSaved;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
    this.onLike,
    this.onSave,
    this.isLiked = false,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение
            AspectRatio(aspectRatio: 4 / 3, child: _buildPlaceholder(context)),
            // Информация
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recommendation.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Теги
                  if (recommendation.recommendedItems.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                          recommendation.recommendedItems
                              .take(3)
                              .map((item) => _buildTag(item, context))
                              .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          size: 64,
          color: Theme.of(
            context,
          ).colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildTag(String tag, BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Пустое состояние для списка рекомендаций
class EmptyRecommendationsState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRefresh;
  final VoidCallback? onGenerate;

  const EmptyRecommendationsState({
    super.key,
    this.message,
    this.onRefresh,
    this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              message ?? 'Нет рекомендаций',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Сгенерируйте персональную рекомендацию\nна основе погоды и ваших предпочтений',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (onGenerate != null)
              ElevatedButton.icon(
                onPressed: onGenerate,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Сгенерировать'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
