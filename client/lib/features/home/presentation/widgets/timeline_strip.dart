import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/haptics.dart';

final timelineDaysProvider =
    StreamProvider.autoDispose<List<TimelineDay>>((ref) {
  final repo = ref.watch(recommendationsRepositoryProvider);
  return repo.watchTimeline(limit: 7); // 7 дней
});

class TimelineStrip extends ConsumerWidget {
  final void Function(DateTime day)? onSelect;
  const TimelineStrip({super.key, this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysAsync = ref.watch(timelineDaysProvider);

    return daysAsync.when(
      loading: () => const _TimelineSkeleton(),
      error: (e, _) => Text('Timeline error: $e'),
      data: (days) => SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: days.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final day = days[i];
            final isToday = _isSameDay(day.date, DateTime.now());
            final isSelected = _isSameDay(day.date, selectedDay);

            return TimelineDayCard(
              day: day,
              isToday: isToday,
              isSelected: isSelected,
              onTap: () {
                Haptics.selection();
                onSelect?.call(day.date);
              },
            );
          },
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class TimelineDayCard extends StatelessWidget {
  final TimelineDay day;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;
  const TimelineDayCard({
    super.key,
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEE\ndd MMM', 'ru');
    final dayStr = formatter.format(day.date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : isToday
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              dayStr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : isToday
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            if (day.outfitCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  day.outfitCount.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineSkeleton extends StatelessWidget {
  const _TimelineSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => Container(
          width: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
