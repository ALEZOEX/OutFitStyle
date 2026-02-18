import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: theme.colorScheme.primary.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: _buildImage(context),
                ),
                // Градиент overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Бейдж погоды
                if (recommendation.weatherCondition != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getWeatherIcon(recommendation.weatherCondition!),
                            size: 14,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${recommendation.temperature?.round()}°C',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Кнопки действий
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      _buildActionButton(
                        context,
                        icon: isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                        onTap: onLike,
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? theme.colorScheme.primary : null,
                        onTap: onSave,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Информация
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.title ?? 'Рекомендация',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recommendation.description ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Теги
                  if (recommendation.recommendedItems != null &&
                      recommendation.recommendedItems!.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: recommendation.recommendedItems!
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

  Widget _buildImage(BuildContext context) {
    if (recommendation.imageUrl != null &&
        recommendation.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: recommendation.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      );
    }
    return _buildPlaceholder(context);
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
          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? Colors.white).withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: color ?? Colors.black87,
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

  IconData _getWeatherIcon(String condition) {
    return switch (condition.toLowerCase()) {
      'sunny' || 'ясно' => Icons.wb_sunny,
      'cloudy' || 'облачно' => Icons.cloud,
      'rainy' || 'дождь' => Icons.grain,
      'snowy' || 'снег' => Icons.ac_unit,
      'partly_cloudy' || 'переменная облачность' => Icons.cloud,
      _ => Icons.wb_sunny,
    };
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
                    theme.colorScheme.primaryContainer.withOpacity(0.5),
                    theme.colorScheme.secondaryContainer.withOpacity(0.5),
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
