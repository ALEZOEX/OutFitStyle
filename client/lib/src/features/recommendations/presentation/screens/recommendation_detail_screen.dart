import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/outfit_recommendation.dart';
import '../providers/recommendations_provider.dart';

/// Экран деталей рекомендации
/// Без социальной функциональности — только персональные действия
class RecommendationDetailScreen extends ConsumerStatefulWidget {
  final String recommendationId;

  const RecommendationDetailScreen({super.key, required this.recommendationId});

  @override
  ConsumerState<RecommendationDetailScreen> createState() => _RecommendationDetailScreenState();
}

class _RecommendationDetailScreenState extends ConsumerState<RecommendationDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
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
    final recommendation = state.recommendations
        .firstWhere((r) => r.id == widget.recommendationId, orElse: () => _createPlaceholder());

    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar с прозрачным фоном
          SliverAppBar(
            expandedHeight: 350,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                onPressed: () => _showPlanDialog(context, recommendation),
                tooltip: 'Запланировать',
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImagePlaceholder(context),
                  // Градиент overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Контент
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок и описание
                      _buildHeader(context, recommendation),
                      const SizedBox(height: 24),

                      // Информация о погоде
                      _buildWeatherInfo(context, recommendation),
                      const SizedBox(height: 24),

                      // Рекомендуемые вещи
                      _buildRecommendedItems(context, recommendation),
                      const SizedBox(height: 24),

                      // Действия
                      _buildActions(context, recommendation),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
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
          size: 80,
          color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    OutfitRecommendation recommendation,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.title ?? 'Рекомендация',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(recommendation.createdAt ?? DateTime.now()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recommendation.description != null && recommendation.description!.isNotEmpty)
          Text(
            recommendation.description!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
      ],
    );
  }

  Widget _buildWeatherInfo(
    BuildContext context,
    OutfitRecommendation recommendation,
  ) {
    final theme = Theme.of(context);
    final temperature = recommendation.temperature;
    final weatherCondition = recommendation.weatherCondition ?? 'sunny';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Погодные условия',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherStat(
                context,
                icon: Icons.thermostat,
                value: temperature != null ? '${temperature.round()}°C' : '—',
                label: 'Температура',
              ),
              _buildDivider(),
              _buildWeatherStat(
                context,
                icon: _getWeatherIcon(weatherCondition),
                value: _getWeatherName(weatherCondition),
                label: 'Условия',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 28,
          ),
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
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 60,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.3),
    );
  }

  Widget _buildRecommendedItems(
    BuildContext context,
    OutfitRecommendation recommendation,
  ) {
    final theme = Theme.of(context);
    final items = recommendation.recommendedItems ?? [];

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.checkroom,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Рекомендуемые вещи',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[index],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    OutfitRecommendation recommendation,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Основные действия
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showPlanDialog(context, recommendation),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Запланировать'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  if (recommendation.id != null) {
                    final notifier = ref.read(recommendationsProvider.notifier);
                    notifier.markAsUsed(recommendation.id!);
                  }
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Рекомендация использована'),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Использовать'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Вторичные действия
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  // Переход в конструктор с предзаполненными вещами
                  context.push('/recommendations/builder');
                },
                icon: const Icon(Icons.build),
                label: const Text('Конструктор'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                      title: const Text('Удалить рекомендацию?'),
                      content: const Text(
                        'Это действие нельзя отменить',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Отмена'),
                        ),
                        FilledButton(
                          onPressed: () {
                            if (recommendation.id != null) {
                              final notifier = ref.read(recommendationsProvider.notifier);
                              notifier.removeRecommendation(recommendation.id!);
                            }
                            Navigator.pop(context);
                            context.pop();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Удалить'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Удалить'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Диалог планирования
  void _showPlanDialog(BuildContext context, OutfitRecommendation recommendation) {
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.tertiary,
              size: 32,
            ),
          ),
          title: const Text('Запланировать образ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                recommendation.title ?? 'Образ',
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('ru', 'RU'),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd MMMM yyyy', 'ru_RU').format(selectedDate),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Быстрый выбор
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickDateChip(
                    label: 'Сегодня',
                    date: DateTime.now(),
                    isSelected: _isSameDay(selectedDate, DateTime.now()),
                    onTap: () => setState(() => selectedDate = DateTime.now()),
                  ),
                  _QuickDateChip(
                    label: 'Завтра',
                    date: DateTime.now().add(const Duration(days: 1)),
                    isSelected: _isSameDay(selectedDate, DateTime.now().add(const Duration(days: 1))),
                    onTap: () => setState(() => selectedDate = DateTime.now().add(const Duration(days: 1))),
                  ),
                  _QuickDateChip(
                    label: 'Выходные',
                    date: _getNextWeekend(),
                    isSelected: _isSameDay(selectedDate, _getNextWeekend()),
                    onTap: () => setState(() => selectedDate = _getNextWeekend()),
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
            FilledButton.icon(
              onPressed: () {
                if (recommendation.id == null) return;
                final notifier = ref.read(recommendationsProvider.notifier);
                notifier.planOutfit(
                  recommendationId: recommendation.id!,
                  date: selectedDate,
                );
                Navigator.pop(context);
                
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 12),
                        Text('Образ запланирован на ${DateFormat("dd MMMM", "ru_RU").format(selectedDate)}'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Запланировать'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Сегодня';
    } else if (difference == 1) {
      return 'Вчера';
    } else if (difference < 7) {
      return '$difference дн. назад';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  IconData _getWeatherIcon(String condition) {
    return switch (condition.toLowerCase()) {
      'sunny' || 'ясно' => Icons.wb_sunny,
      'cloudy' || 'облачно' => Icons.cloud,
      'rainy' || 'дождь' => Icons.grain,
      'snowy' || 'снег' => Icons.ac_unit,
      'partly_cloudy' || 'переменная облачность' => Icons.cloud_queue,
      _ => Icons.wb_sunny,
    };
  }

  String _getWeatherName(String condition) {
    return switch (condition.toLowerCase()) {
      'sunny' => 'Ясно',
      'cloudy' => 'Облачно',
      'rainy' => 'Дождь',
      'snowy' => 'Снег',
      'partly_cloudy' => 'Переменная облачность',
      _ => 'Ясно',
    };
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _getNextWeekend() {
    final now = DateTime.now();
    int daysUntilSaturday = 6 - now.weekday;
    if (daysUntilSaturday < 0) daysUntilSaturday += 7;
    if (daysUntilSaturday == 0) daysUntilSaturday = 1;
    return DateTime(now.year, now.month, now.day + daysUntilSaturday);
  }

  OutfitRecommendation _createPlaceholder() {
    return OutfitRecommendation(
      id: widget.recommendationId,
      title: 'Рекомендация',
      description: '',
      recommendedItems: [],
      temperature: null,
      weatherCondition: null,
      createdAt: DateTime.now(),
    );
  }
}

/// Быстрый выбор даты
class _QuickDateChip extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickDateChip({
    required this.label,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onTap(),
      label: Text(label),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
