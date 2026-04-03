import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:outfitstyle_client/src/theme/app_theme.dart';
import 'package:outfitstyle_client/src/ui/containers/glass_components.dart';
import 'package:outfitstyle_client/src/domain/entities/saved_outfit.dart';
import 'package:outfitstyle_client/src/features/wardrobe/presentation/providers/wardrobe_provider.dart';
import 'package:outfitstyle_client/src/features/builder/presentation/providers/outfit_provider.dart';

/// Экран планировщика образов
///
/// Загружает сохранённые образы из API и позволяет
/// планировать их на конкретные даты.
class OutfitPlannerScreen extends ConsumerStatefulWidget {
  const OutfitPlannerScreen({super.key});

  @override
  ConsumerState<OutfitPlannerScreen> createState() =>
      _OutfitPlannerScreenState();
}

class _OutfitPlannerScreenState extends ConsumerState<OutfitPlannerScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  // Локальный кэш запланированных образов (дата -> outfitId)
  // В будущем можно заменить на API endpoint планирования
  final Map<DateTime, List<String>> _plannedOutfitIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final outfitState = ref.watch(outfitProvider);
    final wardrobeState = ref.watch(wardrobeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            _buildAppBar(context),

            // Индикаторы загрузки
            if (outfitState.status == OutfitLoadStatus.loading ||
                wardrobeState.status == WardrobeLoadStatus.loading)
              const LinearProgressIndicator()
            else if (outfitState.status == OutfitLoadStatus.error)
              _buildErrorBanner(
                context,
                outfitState.error ?? 'Ошибка загрузки образов',
              ),

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
                    _buildPlannedOutfits(context, isDark, outfitState.outfits),
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

  Widget _buildErrorBanner(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onErrorContainer,
          fontSize: 12,
        ),
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
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
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
                  _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month - 1,
                  );
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
                  _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month + 1,
                  );
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
                .map(
                  (day) => SizedBox(
                    width: 40,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
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
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    );
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
          final date = DateTime(
            _focusedMonth.year,
            _focusedMonth.month,
            dayCounter,
          );
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, DateTime.now());
          final hasOutfit = _hasPlannedOutfits(date);

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

  Widget _buildPlannedOutfits(
    BuildContext context,
    bool isDark,
    List<SavedOutfit> allOutfits,
  ) {
    final outfitIds = _plannedOutfitIds[_normalizeDate(_selectedDate)] ?? [];
    final outfitsForDate = outfitIds
        .map((id) => allOutfits.firstWhere(
              (o) => o.id == id,
              orElse: () => SavedOutfit(
                id: id,
                userId: '',
                name: 'Удалённый образ',
                items: [],
                createdAt: DateTime.now(),
              ),
            ))
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
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.2),
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: Icon(
                        Icons.checkroom,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            outfit.name,
                            style: AppTypography.headlineSmall(context)
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${outfit.items.length} предметов',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deletePlannedOutfit(outfit.id),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
                if (outfit.description != null &&
                    outfit.description!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    outfit.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _addPlannedOutfit() {
    final outfitState = ref.read(outfitProvider);

    if (outfitState.outfits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала создайте образ в конструкторе'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddOutfitSheet(
        selectedDate: _selectedDate,
        availableOutfits: outfitState.outfits,
        onAdded: (outfitId) {
          setState(() {
            final normalizedDate = _normalizeDate(_selectedDate);
            if (!_plannedOutfitIds.containsKey(normalizedDate)) {
              _plannedOutfitIds[normalizedDate] = [];
            }
            _plannedOutfitIds[normalizedDate]!.add(outfitId);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deletePlannedOutfit(String outfitId) {
    setState(() {
      final normalizedDate = _normalizeDate(_selectedDate);
      _plannedOutfitIds[normalizedDate]?.remove(outfitId);
      if (_plannedOutfitIds[normalizedDate]?.isEmpty ?? false) {
        _plannedOutfitIds.remove(normalizedDate);
      }
    });
  }

  bool _hasPlannedOutfits(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final ids = _plannedOutfitIds[normalizedDate];
    return ids != null && ids.isNotEmpty;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Нормализует дату до начала дня (без времени) для использования как ключ
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class _AddOutfitSheet extends StatefulWidget {
  final DateTime selectedDate;
  final List<SavedOutfit> availableOutfits;
  final Function(String outfitId) onAdded;

  const _AddOutfitSheet({
    required this.selectedDate,
    required this.availableOutfits,
    required this.onAdded,
  });

  @override
  State<_AddOutfitSheet> createState() => _AddOutfitSheetState();
}

class _AddOutfitSheetState extends State<_AddOutfitSheet> {
  String? _selectedOutfitId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
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
            'Добавить образ на ${DateFormat('d MMMM', 'ru_RU').format(widget.selectedDate)}',
            style: AppTypography.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Список доступных образов
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: widget.availableOutfits.length,
              itemBuilder: (context, index) {
                final outfit = widget.availableOutfits[index];
                final isSelected = _selectedOutfitId == outfit.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: InkWell(
                    onTap: () => setState(() => _selectedOutfitId = outfit.id),
                    borderRadius: AppRadius.radiusMd,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1)
                            : isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  outfit.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                ),
                                Text(
                                  '${outfit.items.length} предметов',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          GlassButton(
            label: 'Добавить',
            icon: Icons.check,
            onPressed: _selectedOutfitId != null
                ? () => widget.onAdded(_selectedOutfitId!)
                : () {},
            isLoading: false,
          ),
        ],
      ),
    );
  }
}
