import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:outfitstyle_client/src/theme/app_theme.dart';
import 'package:outfitstyle_client/src/ui/containers/glass_components.dart';

/// Экран планировщика образов
class OutfitPlannerScreen extends StatefulWidget {
  const OutfitPlannerScreen({super.key});

  @override
  State<OutfitPlannerScreen> createState() => _OutfitPlannerScreenState();
}

class _OutfitPlannerScreenState extends State<OutfitPlannerScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  final List<_PlannedOutfit> _plannedOutfits = [
    _PlannedOutfit(
      date: DateTime.now(),
      title: 'Деловая встреча',
      outfit: 'Деловой костюм',
      weather: '+18°C, ясно',
      weatherIcon: Icons.wb_sunny_rounded,
      eventType: 'work',
    ),
    _PlannedOutfit(
      date: DateTime.now().add(const Duration(days: 1)),
      title: 'Прогулка в парке',
      outfit: 'Casual outfit',
      weather: '+15°C, облачно',
      weatherIcon: Icons.cloud_rounded,
      eventType: 'casual',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            _buildAppBar(context),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Календарь
                    _buildCalendar(context, isDark),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Запланированные образы
                    Text(
                      'Запланировано на ${DateFormat('d MMMM', 'ru_RU').format(_selectedDate)}',
                      style: AppTypography.labelLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildPlannedOutfits(context, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPlannedOutfit,
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Планировщик',
              style: AppTypography.headlineSmall(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, bool isDark) {
    return GlassCard(
      child: Column(
        children: [
          // Навигация по месяцам
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                }),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('MMMM yyyy', 'ru_RU').format(_focusedMonth),
                style: AppTypography.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                }),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Дни недели
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                .map((day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Дни месяца
          _buildCalendarDays(context, isDark),
        ],
      ),
    );
  }

  Widget _buildCalendarDays(BuildContext context, bool isDark) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    
    final List<Widget> weeks = [];
    int dayCounter = 1;
    
    for (int week = 0; week < 6; week++) {
      final List<Widget> days = [];
      
      for (int weekday = 0; weekday < 7; weekday++) {
        if (week == 0 && weekday < firstWeekday - 1) {
          days.add(const SizedBox(width: 40, child: SizedBox.shrink()));
        } else if (dayCounter > daysInMonth) {
          days.add(const SizedBox(width: 40, child: SizedBox.shrink()));
        } else {
          final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayCounter);
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, DateTime.now());
          final hasOutfit = _plannedOutfits.any((o) => _isSameDay(o.date, date));
          
          days.add(
            SizedBox(
              width: 40,
              child: InkWell(
                onTap: () => setState(() => _selectedDate = date),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : isToday
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$dayCounter',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (hasOutfit)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
          dayCounter++;
        }
      }
      
      weeks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days,
          ),
        ),
      );
      
      if (dayCounter > daysInMonth) break;
    }
    
    return Column(children: weeks);
  }

  Widget _buildPlannedOutfits(BuildContext context, bool isDark) {
    final outfitsForDate = _plannedOutfits
        .where((o) => _isSameDay(o.date, _selectedDate))
        .toList();

    if (outfitsForDate.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Нет запланированных образов',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassButton(
                label: 'Добавить образ',
                icon: Icons.add,
                onPressed: _addPlannedOutfit,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: outfitsForDate.length,
      itemBuilder: (context, index) {
        final outfit = outfitsForDate[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getEventColor(outfit.eventType).withValues(alpha: 0.2),
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: Icon(
                        _getEventIcon(outfit.eventType),
                        size: 20,
                        color: _getEventColor(outfit.eventType),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            outfit.title,
                            style: AppTypography.headlineSmall(context).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            outfit.outfit,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteOutfit(outfit),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                    borderRadius: AppRadius.radiusPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        outfit.weatherIcon,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        outfit.weather,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addPlannedOutfit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddOutfitSheet(
        selectedDate: _selectedDate,
        onAdded: () {
          setState(() {
            _plannedOutfits.add(_PlannedOutfit(
              date: _selectedDate,
              title: 'Новое событие',
              outfit: 'Casual outfit',
              weather: '+16°C, облачно',
              weatherIcon: Icons.cloud_rounded,
              eventType: 'casual',
            ));
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteOutfit(_PlannedOutfit outfit) {
    setState(() {
      _plannedOutfits.remove(outfit);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'work':
        return Colors.blue;
      case 'casual':
        return Colors.green;
      case 'party':
        return Colors.purple;
      case 'sport':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case 'work':
        return Icons.work_outline;
      case 'casual':
        return Icons.coffee_outlined;
      case 'party':
        return Icons.celebration_outlined;
      case 'sport':
        return Icons.fitness_center_outlined;
      default:
        return Icons.event_outlined;
    }
  }
}

class _PlannedOutfit {
  final DateTime date;
  final String title;
  final String outfit;
  final String weather;
  final IconData weatherIcon;
  final String eventType;

  const _PlannedOutfit({
    required this.date,
    required this.title,
    required this.outfit,
    required this.weather,
    required this.weatherIcon,
    required this.eventType,
  });
}

class _AddOutfitSheet extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onAdded;

  const _AddOutfitSheet({
    required this.selectedDate,
    required this.onAdded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: AppRadius.radiusPill,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Добавить образ на ${DateFormat('d MMMM', 'ru_RU').format(selectedDate)}',
            style: AppTypography.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassButton(
            label: 'Добавить',
            icon: Icons.check,
            onPressed: onAdded,
          ),
        ],
      ),
    );
  }
}
