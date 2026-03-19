import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../wardrobe/presentation/providers/wardrobe_provider.dart';
import '../recommendations/presentation/providers/recommendations_provider.dart';
import '../recommendations/presentation/providers/rating_provider.dart'
    show ratingApiServiceProvider;
import 'package:outfitstyle_client/src/presentation/providers/weather_provider.dart';
import 'package:outfitstyle_client/src/presentation/providers/user_location_provider.dart';
import 'package:outfitstyle_client/src/ui/widgets/weather_card.dart';
import 'package:outfitstyle_client/src/ui/widgets/empty_state.dart';
import 'package:outfitstyle_client/src/ui/widgets/city_selector_dialog.dart';
import 'package:outfitstyle_client/src/ui/widgets/max_width_container.dart';
import 'package:outfitstyle_client/src/domain/entities/outfit_recommendation.dart';

/// Главный экран: погода + персональные рекомендации + гардероб
///
/// Структура:
/// 1. Верхняя часть: погода, город с кнопкой изменения
/// 2. Основная часть: основной образ + альтернативные варианты
/// 3. Нижняя часть: статистика + кнопка "Сгенерировать еще"
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentAlternativeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userLocation = ref.watch(userLocationProvider);
    final weatherAsync = ref.watch(
      weatherProvider((
        lat: userLocation.latitude,
        lon: userLocation.longitude,
      )),
    );
    final wardrobeState = ref.watch(wardrobeProvider);
    final recommendationsState = ref.watch(recommendationsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(weatherProvider);
        ref.invalidate(wardrobeProvider);
        ref.invalidate(recommendationsProvider);
      },
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveMaxWidthContainer(
            maxWidth: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Погода и город
                _buildWeatherSection(context, weatherAsync, userLocation),

                const SizedBox(height: 20),

                // Основной образ на сегодня
                _buildMainOutfitSection(context, recommendationsState),

                const SizedBox(height: 20),

                // Альтернативные образы
                _buildAlternativeOutfitsSection(context, recommendationsState),

                const SizedBox(height: 20),

                // Статистика
                _buildStatsSection(
                  context,
                  wardrobeState,
                  recommendationsState,
                ),

                const SizedBox(height: 16),

                // Кнопка "Сгенерировать еще"
                _buildGenerateMoreButton(context, recommendationsState),

                const SizedBox(height: 100), // Отступ для bottom navigation
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Секция погоды с городом
  Widget _buildWeatherSection(
    BuildContext context,
    AsyncValue<dynamic> weatherAsync,
    UserLocation userLocation,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок с городом
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              userLocation.cityName ?? 'Город не выбран',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            // Кнопка изменения города
            TextButton.icon(
              onPressed: () => _showCitySelector(context),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Изменить'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Карточка погоды
        weatherAsync.when(
          data:
              (weather) => WeatherCard(
                weatherData: weather,
                forecast: [],
                onTap: () => ref.invalidate(weatherProvider),
                onRefresh: () => ref.invalidate(weatherProvider),
              ),
          loading: () => _buildLoadingCard(),
          error:
              (error, stack) => _buildErrorCard(
                message: 'Не удалось загрузить погоду',
                onRetry: () => ref.invalidate(weatherProvider),
              ),
        ),
      ],
    );
  }

  /// Секция основного образа
  Widget _buildMainOutfitSection(
    BuildContext context,
    RecommendationsState recommendationsState,
  ) {
    final recommendations = recommendationsState.recommendations;
    final hasRecommendations = recommendations.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Основной образ на сегодня',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (hasRecommendations)
              TextButton(
                onPressed: () => context.go('/home', extra: 2),
                child: const Text('Все'),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (!hasRecommendations ||
            recommendationsState.status == RecommendationsLoadStatus.loading)
          EmptyState(
            icon: Icons.checkroom_outlined,
            title: 'Нет рекомендаций',
            subtitle:
                'Получите персональные рекомендации на основе погоды и вашего гардероба',
            actionLabel: 'Получить рекомендацию',
            onAction: () => context.go('/home', extra: 2),
          )
        else
          _buildFullOutfitCard(context, recommendations.first),
      ],
    );
  }

  /// Карточка полного комплекта одежды
  Widget _buildFullOutfitCard(
    BuildContext context,
    OutfitRecommendation recommendation,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDarkMode
                    ? [
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      theme.colorScheme.secondaryContainer.withValues(
                        alpha: 0.2,
                      ),
                    ]
                    : [
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      theme.colorScheme.secondaryContainer.withValues(
                        alpha: 0.3,
                      ),
                    ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recommendation.title ?? 'Ваш образ',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Оценка погоды
                  if (recommendation.temperature != null)
                    Container(
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
                            Icons.thermostat,
                            size: 16,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${recommendation.temperature?.round() ?? 0}°C',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              if (recommendation.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(
                  recommendation.description ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 20),

              // Полный комплект одежды
              Text(
                'Комплект одежды',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Категории одежды
              _buildOutfitCategory(
                context,
                category: 'Верх',
                icon: Icons.checkroom,
                items: _getItemsByCategory(recommendation, 'top'),
                color: Colors.blue,
              ),
              const SizedBox(height: 12),

              _buildOutfitCategory(
                context,
                category: 'Низ',
                icon: Icons.checkroom_outlined,
                items: _getItemsByCategory(recommendation, 'bottom'),
                color: Colors.green,
              ),
              const SizedBox(height: 12),

              _buildOutfitCategory(
                context,
                category: 'Обувь',
                icon: Icons.bolt,
                items: _getItemsByCategory(recommendation, 'shoes'),
                color: Colors.orange,
              ),
              const SizedBox(height: 12),

              _buildOutfitCategory(
                context,
                category: 'Аксессуары',
                icon: Icons.shopping_bag,
                items: _getItemsByCategory(recommendation, 'accessories'),
                color: Colors.purple,
              ),

              // Кнопки действий
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDetails(context, recommendation),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Детали'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _planOutfit(context, recommendation),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Запланировать'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                Text(
                  category,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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

  /// Секция альтернативных образов
  Widget _buildAlternativeOutfitsSection(
    BuildContext context,
    RecommendationsState recommendationsState,
  ) {
    final recommendations = recommendationsState.recommendations;

    // Показываем альтернативы если есть больше 1 рекомендации
    if (recommendations.length < 2) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Альтернативные образы',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${_currentAlternativeIndex + 1} из ${recommendations.length - 1}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Горизонтальный список альтернатив
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recommendations.length - 1,
            itemBuilder: (context, index) {
              final outfit =
                  recommendations[index + 1]; // Пропускаем первый (основной)
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 280,
                  child: _buildAlternativeOutfitCard(context, outfit),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Карточка альтернативного образа
  Widget _buildAlternativeOutfitCard(
    BuildContext context,
    OutfitRecommendation outfit,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showDetails(context, outfit),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  isDarkMode
                      ? [
                        theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        theme.colorScheme.surface.withValues(alpha: 0.3),
                      ]
                      : [
                        theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        theme.colorScheme.surface,
                      ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Миниатюры одежды
                Expanded(child: _buildOutfitPreview(context, outfit)),

                const SizedBox(height: 12),

                // Название
                Text(
                  outfit.title ?? 'Образ',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Кнопки оценки
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => _rateOutfit(outfit, true),
                      icon: const Icon(Icons.thumb_up),
                      tooltip: 'Нравится',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green.withValues(alpha: 0.2),
                        foregroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () => _rateOutfit(outfit, false),
                      icon: const Icon(Icons.thumb_down),
                      tooltip: 'Не нравится',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.2),
                        foregroundColor: Colors.red,
                      ),
                    ),
                    const Spacer(),
                    IconButton.filledTonal(
                      onPressed: () => _planOutfit(context, outfit),
                      icon: const Icon(Icons.calendar_today),
                      tooltip: 'Запланировать',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Предварительный просмотр комплекта
  Widget _buildOutfitPreview(
    BuildContext context,
    OutfitRecommendation outfit,
  ) {
    final topItems = _getItemsByCategory(outfit, 'top');
    final bottomItems = _getItemsByCategory(outfit, 'bottom');
    final shoesItems = _getItemsByCategory(outfit, 'shoes');
    final accessoryItems = _getItemsByCategory(outfit, 'accessories');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPreviewRow(
          context,
          'Верх',
          topItems,
          Icons.checkroom,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildPreviewRow(
          context,
          'Низ',
          bottomItems,
          Icons.checkroom_outlined,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildPreviewRow(
          context,
          'Обувь',
          shoesItems,
          Icons.bolt,
          Colors.orange,
        ),
        if (accessoryItems.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildPreviewRow(
            context,
            'Аксессуары',
            accessoryItems,
            Icons.shopping_bag,
            Colors.purple,
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewRow(
    BuildContext context,
    String label,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            items.isNotEmpty ? items.first : '—',
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Секция статистики
  Widget _buildStatsSection(
    BuildContext context,
    WardrobeState wardrobeState,
    RecommendationsState recommendationsState,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final plannedOutfits = recommendationsState.getAllPlannedOutfits();

    // Статистика на сегодня
    final today = DateTime.now();
    final todayOutfits =
        plannedOutfits
            .where(
              (o) =>
                  o.date.year == today.year &&
                  o.date.month == today.month &&
                  o.date.day == today.day,
            )
            .length;

    // Статистика на неделю
    final weekOutfits =
        plannedOutfits.where((o) {
          final diff = o.date.difference(today).inDays;
          return diff >= 0 && diff < 7;
        }).length;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.today,
                  value: todayOutfits.toString(),
                  label: 'На сегодня',
                  color: Colors.blue,
                ),
                _buildStatDivider(),
                _buildStatItem(
                  context,
                  icon: Icons.calendar_month,
                  value: weekOutfits.toString(),
                  label: 'На неделю',
                  color: Colors.purple,
                ),
                _buildStatDivider(),
                _buildStatItem(
                  context,
                  icon: Icons.checkroom,
                  value: wardrobeState.totalCount.toString(),
                  label: 'В гардеробе',
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.3),
    );
  }

  /// Кнопка "Сгенерировать еще"
  Widget _buildGenerateMoreButton(
    BuildContext context,
    RecommendationsState recommendationsState,
  ) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed:
            recommendationsState.isGenerating
                ? null
                : () => _generateMoreRecommendations(context),
        icon:
            recommendationsState.isGenerating
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
                : const Icon(Icons.auto_awesome),
        label: Text(
          recommendationsState.isGenerating
              ? 'Генерация...'
              : 'Сгенерировать еще варианты',
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // ==================== Helper Methods ====================

  /// Получить предметы по категории
  List<String> _getItemsByCategory(
    OutfitRecommendation outfit,
    String category,
  ) {
    final items = outfit.recommendedItems ?? [];
    final result = <String>[];

    for (final item in items) {
      final itemLower = item.toLowerCase();

      // Определяем категорию по ключевым словам
      switch (category) {
        case 'top':
          if (itemLower.contains('футболк') ||
              itemLower.contains('рубашк') ||
              itemLower.contains('худи') ||
              itemLower.contains('свитер') ||
              itemLower.contains('кофт') ||
              itemLower.contains('топ') ||
              itemLower.contains('блуз')) {
            result.add(item);
          }
          break;
        case 'bottom':
          if (itemLower.contains('джинс') ||
              itemLower.contains('брюк') ||
              itemLower.contains('штан') ||
              itemLower.contains('шорт') ||
              itemLower.contains('юбк') ||
              itemLower.contains('леггинс')) {
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
              itemLower.contains('сапог')) {
            result.add(item);
          }
          break;
        case 'accessories':
          if (itemLower.contains('куртк') ||
              itemLower.contains('пальт') ||
              itemLower.contains('жакет') ||
              itemLower.contains('пиджак') ||
              itemLower.contains('шапк') ||
              itemLower.contains('шарф') ||
              itemLower.contains('перчатк') ||
              itemLower.contains('сумк') ||
              itemLower.contains('ремен') ||
              itemLower.contains('очк')) {
            result.add(item);
          }
          break;
      }
    }

    return result;
  }

  void _showCitySelector(BuildContext context) {
    showDialog<CityData>(
      context: context,
      builder:
          (context) => CitySelectorDialog(
            onCitySelected: (city) {
              ref.invalidate(userLocationProvider);
              ref.invalidate(weatherProvider);
            },
          ),
    );
  }

  void _showDetails(BuildContext context, OutfitRecommendation outfit) {
    // Навигация на экран деталей образа через GoRouter
    context.push('/outfit/${outfit.id}');
  }

  void _planOutfit(BuildContext context, OutfitRecommendation outfit) {
    final notifier = ref.read(recommendationsProvider.notifier);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Запланировать образ'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Образ: ${outfit.title}'),
                const SizedBox(height: 16),
                Text(
                  'Выберите дату:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                // Простой выбор даты - сегодня/завтра
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Сегодня'),
                      selected: true,
                      onSelected: (selected) {},
                    ),
                    ChoiceChip(
                      label: const Text('Завтра'),
                      selected: false,
                      onSelected: (selected) {},
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () {
                  notifier.planOutfit(
                    recommendationId: outfit.id ?? '',
                    date: DateTime.now(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Образ запланирован')),
                  );
                },
                child: const Text('Запланировать'),
              ),
            ],
          ),
    );
  }

  void _rateOutfit(OutfitRecommendation outfit, bool liked) {
    // Сохранение оценки пользователя через rating provider
    final ratingProvider = ref.read(ratingApiServiceProvider);
    ratingProvider.rateOutfit(
      recommendationId: outfit.id ?? '',
      rating: liked ? 5 : 1,
      outfitItems: null,
    );

    // Визуальная обратная связь
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(liked ? '✅ Образ понравился!' : '👎 Образ не понравился'),
        backgroundColor: liked ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _generateMoreRecommendations(BuildContext context) async {
    final notifier = ref.read(recommendationsProvider.notifier);

    final result = await notifier.generateRecommendation(
      temperature: 15,
      weatherCondition: 'sunny',
      occasion: 'casual',
    );

    if (context.mounted && result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Новая рекомендация сгенерирована!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
    }
  }

  /// Карточка загрузки
  Widget _buildLoadingCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text('Загрузка...', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  /// Карточка ошибки
  Widget _buildErrorCard({required String message, VoidCallback? onRetry}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
