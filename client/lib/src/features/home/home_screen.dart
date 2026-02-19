import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../wardrobe/presentation/providers/wardrobe_provider.dart';
import '../recommendations/presentation/providers/recommendations_provider.dart';
import '../../presentation/providers/weather_provider.dart';
import '../../presentation/providers/user_preferences_provider.dart';
import '../../ui/widgets/weather_card.dart';
import '../../ui/widgets/empty_state.dart';

/// Главный экран: погода + персональные рекомендации + гардероб
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Координаты по умолчанию (Москва)
  static const _defaultLocation = (lat: 55.7558, lon: 37.6173);

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherProvider(_defaultLocation));
    final wardrobeState = ref.watch(wardrobeProvider);
    final recommendationsState = ref.watch(recommendationsProvider);
    final userPreferences = ref.watch(userPreferencesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(weatherProvider);
        ref.invalidate(wardrobeProvider);
        ref.invalidate(recommendationsProvider);
      },
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Приветствие
              _buildHeader(context, userPreferences),

              const SizedBox(height: 20),

              // Карточка погоды
              _buildWeatherSection(context, weatherAsync),

              const SizedBox(height: 20),

              // Образ на сегодня
              _buildDailyOutfitSection(context, recommendationsState),

              const SizedBox(height: 20),

              // Гардероб
              _buildWardrobeSection(context, wardrobeState),

              const SizedBox(height: 20),

              // Быстрые действия
              _buildQuickActions(context),

              const SizedBox(height: 100), // Отступ для bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  /// Заголовок с приветствием
  Widget _buildHeader(BuildContext context, userPreferences) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Доброе утро'
        : hour < 18
            ? 'Добрый день'
            : 'Добрый вечер';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Создайте свой идеальный образ сегодня',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  /// Секция погоды
  Widget _buildWeatherSection(
    BuildContext context,
    AsyncValue<dynamic> weatherAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        weatherAsync.when(
          data: (weather) => WeatherCard(
            weatherData: weather,
            forecast: [], // Можно добавить прогноз через weatherForecastProvider
            onTap: () => ref.invalidate(weatherProvider),
            onRefresh: () => ref.invalidate(weatherProvider),
          ),
          loading: () => _buildLoadingCard(),
          error: (error, stack) => _buildErrorCard(
            message: 'Не удалось загрузить погоду',
            onRetry: () => ref.invalidate(weatherProvider),
          ),
        ),
      ],
    );
  }

  /// Секция образа на сегодня
  Widget _buildDailyOutfitSection(
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
              'Ваш образ на сегодня',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (hasRecommendations)
              TextButton(
                onPressed: () {
                  // Переключаем на вкладку рекомендаций через HomeShellWrapper
                  GoRouter.of(context).go('/home', extra: 2); // 2 - индекс рекомендаций
                },
                child: const Text('Все'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!hasRecommendations || recommendationsState.status == RecommendationsLoadStatus.loading)
          EmptyState(
            icon: Icons.checkroom_outlined,
            title: 'Нет рекомендаций',
            subtitle: 'Получите персональные рекомендации на основе погоды и вашего гардероба',
            actionLabel: 'Получить рекомендацию',
            onAction: () => GoRouter.of(context).go('/home', extra: 2),
          )
        else
          _buildRecommendationCard(context, recommendations.first),
      ],
    );
  }

  /// Карточка рекомендации
  Widget _buildRecommendationCard(BuildContext context, recommendation) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => GoRouter.of(context).go('/home', extra: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recommendation.outfitImageUrls?.isNotEmpty == true)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  recommendation.outfitImageUrls!.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    height: 150,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.checkroom,
                      size: 64,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 150,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.checkroom,
                  size: 64,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.title ?? 'Рекомендация',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (recommendation.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      recommendation.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (recommendation.recommendedItems?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recommendation.recommendedItems!
                          .take(3)
                          .map<Widget>((item) => Chip(
                                label: Text(
                                  item,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Секция гардероба
  Widget _buildWardrobeSection(
    BuildContext context,
    WardrobeState wardrobeState,
  ) {
    final totalCount = wardrobeState.totalCount;
    final categoryCounts = wardrobeState.categoryCounts;
    final favoritesCount = wardrobeState.favoritesCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Гардероб',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => context.push('/wardrobe'),
              child: const Text('Все'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (totalCount == 0)
          EmptyState(
            icon: Icons.checkroom_outlined,
            title: 'Гардероб пуст',
            subtitle: 'Добавьте свои вещи, чтобы получать персональные рекомендации',
            actionLabel: 'Добавить вещь',
            onAction: () => context.push('/wardrobe/add'),
          )
        else
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Общая статистика
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        icon: Icons.checkroom,
                        value: totalCount.toString(),
                        label: 'Всего вещей',
                      ),
                      _buildDivider(),
                      _buildStatItem(
                        context,
                        icon: Icons.favorite,
                        value: favoritesCount.toString(),
                        label: 'Избранное',
                      ),
                      _buildDivider(),
                      _buildStatItem(
                        context,
                        icon: Icons.category,
                        value: categoryCounts.length.toString(),
                        label: 'Категорий',
                      ),
                    ],
                  ),
                  // Категории
                  if (categoryCounts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categoryCounts.entries.map((entry) {
                        return Chip(
                          avatar: Icon(
                            _getCategoryIcon(entry.key),
                            size: 18,
                          ),
                          label: Text(
                            '${_getCategoryName(entry.key)}: ${entry.value}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Элемент статистики
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  /// Быстрые действия
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (
        icon: Icons.add,
        label: 'Добавить',
        color: Colors.blue,
        route: '/wardrobe/add',
      ),
      (
        icon: Icons.auto_awesome,
        label: 'Рекомендации',
        color: Colors.purple,
        route: '/recommendations',
      ),
      (
        icon: Icons.checkroom,
        label: 'Гардероб',
        color: Colors.green,
        route: '/wardrobe',
      ),
      (
        icon: Icons.person,
        label: 'Профиль',
        color: Colors.pink,
        route: '/profile',
      ),
    ].toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Быстрые действия',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100, // Увеличили высоту для предотвращения overflow
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 5), // Добавили padding
            itemCount: actions.length,
            // ignore: unnecessary_underscores
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final action = actions[index];
              return _QuickActionItem(
                icon: action.icon,
                label: action.label,
                color: action.color,
                onTap: () => context.push(action.route),
              );
            },
          ),
        ),
      ],
    );
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
              Text(
                'Загрузка...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Карточка ошибки
  Widget _buildErrorCard({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
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

  /// Иконка для категории
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'top':
        return Icons.checkroom;
      case 'bottom':
        return Icons.checkroom_outlined;
      case 'shoes':
        return Icons.bolt;
      case 'outerwear':
        return Icons.sunny_snowing;
      case 'headwear':
        return Icons.face;
      case 'accessory':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }

  /// Название категории
  String _getCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'top':
        return 'Верх';
      case 'bottom':
        return 'Низ';
      case 'shoes':
        return 'Обувь';
      case 'outerwear':
        return 'Верхняя одежда';
      case 'headwear':
        return 'Головные уборы';
      case 'accessory':
        return 'Аксессуары';
      default:
        return category;
    }
  }
}

/// Элемент быстрого действия
class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
