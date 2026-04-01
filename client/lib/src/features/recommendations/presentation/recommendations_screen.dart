import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/providers/recommendations_provider.dart';
import '../widgets/recommendation_card.dart';
import '../../../ui/widgets/city_selector_widget.dart';
import '../../../ui/widgets/max_width_container.dart';
import '../../../theme/app_theme.dart';
import '../../../presentation/providers/user_location_provider.dart';

/// Экран персональных рекомендаций
/// Без социальной функциональности — только персональные подборки
class RecommendationsScreen extends ConsumerStatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  ConsumerState<RecommendationsScreen> createState() =>
      _RecommendationsScreenState();
}

class _RecommendationsScreenState extends ConsumerState<RecommendationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recommendationsProvider);
    final stats = ref.watch(recommendationsStatsProvider);
    final selectedCity = ref.watch(selectedCityProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Заголовок
          SliverToBoxAdapter(
            child: ResponsiveMaxWidthContainer(
              maxWidth: 800,
              child: _buildHeader(context, state, stats),
            ),
          ),
          // Виджет выбора города для Web
          if (selectedCity == null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CitySelectorWidget(
                  onCitySelected: (city) {
                    // Перезагрузить рекомендации с новым городом
                    ref.invalidate(recommendationsProvider);
                  },
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Город: ${selectedCity.name}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            ref.read(selectedCityProvider.notifier).state =
                                null;
                            ref.invalidate(recommendationsProvider);
                          },
                          tooltip: 'Изменить город',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Быстрые действия
          SliverToBoxAdapter(
            child: ResponsiveMaxWidthContainer(
              maxWidth: 800,
              child: _buildQuickActions(context),
            ),
          ),
          // Кнопка генерации
          SliverToBoxAdapter(
            child: ResponsiveMaxWidthContainer(
              maxWidth: 800,
              child: _buildGenerateCard(context, state),
            ),
          ),
          // Список рекомендаций
          _buildRecommendationsList(context, state),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/recommendations/planner'),
        icon: const Icon(Icons.calendar_today),
        label: const Text('Планировщик'),
      ),
    );
  }

  /// Заголовок экрана
  Widget _buildHeader(
    BuildContext context,
    RecommendationsState state,
    Map<String, int> stats,
  ) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Рекомендации',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Персональные подборки outfit\'ов',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () =>
                      ref.read(recommendationsProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Обновить',
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Статистика
            _buildStatsRow(context, stats),
          ],
        ),
      ),
    );
  }

  /// Строка статистики
  Widget _buildStatsRow(BuildContext context, Map<String, int> stats) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.auto_awesome,
            label: 'Всего',
            value: stats['total']?.toString() ?? '0',
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.calendar_today,
            label: 'Запланировано',
            value: stats['planned']?.toString() ?? '0',
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.check_circle,
            label: 'Использовано',
            value: stats['used']?.toString() ?? '0',
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  /// Карточка статистики
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? color.withValues(alpha: 0.2)
            : color.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(
          color: isDarkMode
              ? color.withValues(alpha: 0.3)
              : color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: isDarkMode
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDarkMode
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Быстрые действия
  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: _QuickActionChip(
                icon: Icons.build,
                label: 'Конструктор',
                color: theme.colorScheme.primary,
                onTap: () => context.push('/recommendations/builder'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionChip(
                icon: Icons.calendar_today,
                label: 'Планировщик',
                color: theme.colorScheme.tertiary,
                onTap: () => context.push('/recommendations/planner'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Карточка генерации рекомендации
  Widget _buildGenerateCard(BuildContext context, RecommendationsState state) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: isDarkMode ? 6 : 3,
          shadowColor: theme.colorScheme.primary.withValues(
            alpha: isDarkMode ? 0.4 : 0.2,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
          child: InkWell(
            onTap: state.isGenerating
                ? null
                : () => _generateRecommendation(context),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          theme.colorScheme.primary.withValues(alpha: 0.95),
                          theme.colorScheme.secondary.withValues(alpha: 1.0),
                        ]
                      : [
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                          theme.colorScheme.secondary.withValues(alpha: 0.9),
                        ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isGenerating
                              ? 'Генерация...'
                              : 'Сгенерировать рекомендацию',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.isGenerating
                              ? 'Подбираем идеальный outfit...'
                              : 'На основе погоды и предпочтений',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimary.withValues(
                              alpha: 0.95,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary.withValues(
                        alpha: 0.25,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: isDarkMode
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: state.isGenerating
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : Icon(
                            Icons.auto_awesome,
                            color: theme.colorScheme.onPrimary,
                            size: 28,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Список рекомендаций
  Widget _buildRecommendationsList(
    BuildContext context,
    RecommendationsState state,
  ) {
    final theme = Theme.of(context);
    final notifier = ref.read(recommendationsProvider.notifier);

    if (state.status == RecommendationsLoadStatus.loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == RecommendationsLoadStatus.error) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                state.error ?? 'Ошибка загрузки',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notifier.refresh(),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.recommendations.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState(context));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final recommendation = state.recommendations[index];
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ResponsiveMaxWidthContainer(
              maxWidth: 800,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Dismissible(
                  key: ValueKey(recommendation.id ?? index),
                  background: _buildSwipeBackground(
                    context,
                    alignment: Alignment.centerLeft,
                    icon: Icons.favorite,
                    color: Colors.green,
                    label: 'Нравится',
                  ),
                  secondaryBackground: _buildSwipeBackground(
                    context,
                    alignment: Alignment.centerRight,
                    icon: Icons.skip_next,
                    color: Colors.orange,
                    label: 'Пропустить',
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      notifier.toggleLike(recommendation.id ?? '');
                      return false;
                    } else {
                      return true;
                    }
                  },
                  onDismissed: (_) {
                    notifier.removeRecommendation(recommendation.id ?? '');
                  },
                  child: RecommendationCard(
                    recommendation: recommendation,
                    onDetailsPressed: () =>
                        context.push('/recommendations/${recommendation.id}'),
                    onPlanPressed: () =>
                        _planRecommendation(context, recommendation.id),
                    onUsePressed: () =>
                        _useRecommendation(context, recommendation.id),
                  ),
                ),
              ),
            ),
          );
        }, childCount: state.recommendations.length),
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required Alignment alignment,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.radiusLg,
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Генерация рекомендации
  Future<void> _generateRecommendation(BuildContext context) async {
    final notifier = ref.read(recommendationsProvider.notifier);
    final userLocation = ref.read(userLocationProvider);

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final result = await notifier.generateRecommendation(
      latitude: userLocation.latitude,
      longitude: userLocation.longitude,
      occasion: 'casual',
    );

    if (!context.mounted) return;

    if (result != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 12),
              Text('Рекомендация сгенерирована!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      final errorMsg =
          ref.read(recommendationsProvider).error ?? 'Что-то пошло не так';
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(errorMsg)),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Повторить',
            textColor: Colors.white,
            onPressed: () => _generateRecommendation(context),
          ),
        ),
      );
    }
  }

  /// Запланировать рекомендацию
  void _planRecommendation(BuildContext context, String? id) {
    if (id == null) return;
    context.push('/recommendations/planner', extra: id);
  }

  /// Использовать рекомендацию
  void _useRecommendation(BuildContext context, String? id) {
    if (id == null) return;
    final notifier = ref.read(recommendationsProvider.notifier);
    notifier.markAsUsed(id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Рекомендация отмечена как использованная'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  /// Пустое состояние
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Нет рекомендаций',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Сгенерируйте персональную рекомендацию\nна основе погоды и вашего гардероба',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _generateRecommendation(context),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Сгенерировать'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Элемент быстрого действия
class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusLg,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
