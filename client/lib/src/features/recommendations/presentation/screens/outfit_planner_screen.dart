import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/recommendations_provider.dart';

/// Экран планирования образов на дату
/// Позволяет запланировать рекомендацию на конкретную дату
/// и просмотреть запланированные образы на неделю/месяц
class OutfitPlannerScreen extends ConsumerStatefulWidget {
  final String? initialRecommendationId;

  const OutfitPlannerScreen({super.key, this.initialRecommendationId});

  @override
  ConsumerState<OutfitPlannerScreen> createState() =>
      _OutfitPlannerScreenState();
}

class _OutfitPlannerScreenState extends ConsumerState<OutfitPlannerScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedRecommendationId;
  final _dateFormat = DateFormat('dd MMMM yyyy', 'ru_RU');
  final _dayFormat = DateFormat('EEEE', 'ru_RU');

  @override
  void initState() {
    super.initState();
    _selectedRecommendationId = widget.initialRecommendationId;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Планировщик образов'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Просмотр месяца',
            onPressed: () => _showMonthView(context, state),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Выбор даты
            _buildDateSelector(context),
            const SizedBox(height: 24),

            // Информация о выбранной дате
            _buildDateInfo(context),
            const SizedBox(height: 24),

            // Запланированный образ на дату
            _buildPlannedOutfit(context, state),
            const SizedBox(height: 24),

            // Выбор рекомендации для планирования
            _buildRecommendationSelector(context, state),
            const SizedBox(height: 24),

            // Список на неделю
            _buildWeekPlan(context, state),
          ],
        ),
      ),
    );
  }

  /// Селектор даты
  Widget _buildDateSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите дату',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(
                        const Duration(days: 1),
                      );
                    });
                  },
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 30),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        locale: const Locale('ru', 'RU'),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _dateFormat.format(_selectedDate),
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(
                        const Duration(days: 1),
                      );
                    });
                  },
                ),
              ],
            ),
            // Быстрый выбор
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickDateChip(
                  label: 'Сегодня',
                  date: DateTime.now(),
                  isSelected: _isSameDay(_selectedDate, DateTime.now()),
                  onTap: () => setState(() => _selectedDate = DateTime.now()),
                ),
                _QuickDateChip(
                  label: 'Завтра',
                  date: DateTime.now().add(const Duration(days: 1)),
                  isSelected: _isSameDay(
                    _selectedDate,
                    DateTime.now().add(const Duration(days: 1)),
                  ),
                  onTap:
                      () => setState(
                        () =>
                            _selectedDate = DateTime.now().add(
                              const Duration(days: 1),
                            ),
                      ),
                ),
                _QuickDateChip(
                  label: 'Выходные',
                  date: _getNextWeekend(),
                  isSelected: _isSameDay(_selectedDate, _getNextWeekend()),
                  onTap:
                      () => setState(() => _selectedDate = _getNextWeekend()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Информация о дате
  Widget _buildDateInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    final isPast = _selectedDate.isBefore(DateTime.now()) && !isToday;

    return Row(
      children: [
        Icon(
          isToday
              ? Icons.today
              : isPast
              ? Icons.history
              : Icons.event,
          color:
              isToday
                  ? theme.colorScheme.primary
                  : isPast
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.tertiary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dayFormat.format(_selectedDate),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      isToday
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                ),
              ),
              Text(
                isToday
                    ? 'Сегодня'
                    : isPast
                    ? 'Прошедшая дата'
                    : 'Планирование на будущее',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      isToday
                          ? theme.colorScheme.primary
                          : isPast
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Запланированный образ на дату
  Widget _buildPlannedOutfit(BuildContext context, RecommendationsState state) {
    final theme = Theme.of(context);
    final plannedOutfit = state.getPlannedOutfit(_selectedDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Запланированный образ',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (plannedOutfit != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Отменить планирование',
                    onPressed: () => _confirmCancelPlanning(context, state),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (plannedOutfit != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plannedOutfit.title ?? 'Образ',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (plannedOutfit.description != null &&
                        plannedOutfit.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        plannedOutfit.description!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (plannedOutfit.items != null &&
                        plannedOutfit.items!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children:
                            plannedOutfit.items!
                                .take(3)
                                .map(
                                  (item) => Chip(
                                    label: Text(
                                      item,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Нет запланированного образа',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Выберите рекомендацию ниже',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Выбор рекомендации для планирования
  Widget _buildRecommendationSelector(
    BuildContext context,
    RecommendationsState state,
  ) {
    final theme = Theme.of(context);
    final recommendations = state.recommendations;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите рекомендацию',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (recommendations.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Нет доступных рекомендаций',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recommendations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final recommendation = recommendations[index];
                  final isSelected =
                      _selectedRecommendationId == recommendation.id;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedRecommendationId = recommendation.id;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? theme.colorScheme.primaryContainer.withValues(
                                  alpha: 0.3,
                                )
                                : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline.withValues(
                                    alpha: 0.3,
                                  ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recommendation.title ?? 'Рекомендация',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (recommendation.recommendedItems != null &&
                                    recommendation
                                        .recommendedItems!
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    recommendation.recommendedItems!
                                        .take(2)
                                        .join(', '),
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _selectedRecommendationId != null
                        ? () => _planOutfit(context, state)
                        : null,
                icon: const Icon(Icons.add_task),
                label: const Text('Запланировать образ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// План на неделю
  Widget _buildWeekPlan(BuildContext context, RecommendationsState state) {
    final theme = Theme.of(context);
    final weekPlan = state.getPlannedForWeek(_selectedDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'План на неделю',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${weekPlan.length} образов',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (weekPlan.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Нет запланированных образов на эту неделю',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: weekPlan.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final outfit = weekPlan[index];
                  final isToday = _isSameDay(outfit.date, DateTime.now());
                  final isPast =
                      outfit.date.isBefore(DateTime.now()) && !isToday;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            isToday
                                ? theme.colorScheme.primaryContainer
                                : isPast
                                ? theme.colorScheme.surfaceContainerHighest
                                : theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          outfit.date.day.toString(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                isToday
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      outfit.title ?? 'Образ',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: isPast ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      _dayFormat.format(outfit.date),
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing:
                        isPast
                            ? Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                            )
                            : null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Показать просмотр месяца
  void _showMonthView(BuildContext context, RecommendationsState state) {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ru', 'RU'),
      selectableDayPredicate: (date) {
        final outfit = state.getPlannedOutfit(date);
        return outfit == null; // Можно выбрать только дни без образа
      },
    ).then((picked) {
      if (picked != null) {
        setState(() {
          _selectedDate = picked;
        });
      }
    });
  }

  /// Запланировать образ
  void _planOutfit(BuildContext context, RecommendationsState state) {
    if (_selectedRecommendationId == null) return;

    final notifier = ref.read(recommendationsProvider.notifier);
    notifier.planOutfit(
      recommendationId: _selectedRecommendationId!,
      date: _selectedDate,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700]),
            const SizedBox(width: 12),
            Text('Образ запланирован на ${_dateFormat.format(_selectedDate)}'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Подтверждение отмены планирования
  void _confirmCancelPlanning(
    BuildContext context,
    RecommendationsState state,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Отменить планирование'),
            content: const Text(
              'Вы уверены, что хотите отменить запланированный образ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  final notifier = ref.read(recommendationsProvider.notifier);
                  notifier.cancelPlannedOutfit(_selectedDate);

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Планирование отменено'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  );
                },
                child: const Text('Отменить'),
              ),
            ],
          ),
    );
  }

  /// Проверка на одинаковый день
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Получить следующие выходные
  DateTime _getNextWeekend() {
    final now = DateTime.now();
    int daysUntilSaturday = 6 - now.weekday;
    if (daysUntilSaturday < 0) daysUntilSaturday += 7;
    if (daysUntilSaturday == 0)
      daysUntilSaturday = 1; // Если сегодня суббота, показать воскресенье
    return DateTime(now.year, now.month, now.day + daysUntilSaturday);
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
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
