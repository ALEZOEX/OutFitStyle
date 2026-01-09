import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/local/app_database.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/skeleton.dart';
import '../../../ui/atoms/like_burst.dart';
import '../../../ui/atoms/outfit_app_bar.dart';
import '../../outfit_details/presentation/outfit_details_screen.dart';
import 'generator_controller.dart';
import 'widgets/tinder_swipe_card.dart';
import 'widgets/tinder_deck.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({super.key});

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen> {
  late final LikeBurstController _burst;
  final _topKey = GlobalKey<TinderSwipeCardState>();

  @override
  void initState() {
    super.initState();
    _burst = LikeBurstController();
    // Вызываем bootstrap асинхронно, чтобы не блокировать инициализацию
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Run bootstrap without awaiting to not block initialization
      ref.read(generatorControllerProvider.notifier).bootstrap();
    });
  }

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generatorControllerProvider);
    final ctl = ref.read(generatorControllerProvider.notifier);
    final deck = ref.watch(generatorDeckProvider);

    return Scaffold(
      appBar: OutfitAppBar(
        title: 'Подбор',
        actions: [
          IconButton(
            onPressed: () {
              Haptics.selection();
              ctl.resetDeck();
            },
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Сбросить колоду',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _OccasionChips(
            value: state.occasion,
            onChanged: (v) {
              Haptics.selection();
              ctl.setOccasion(v);
            },
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: _InlineError(text: state.error!),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: deck.isEmpty
                  ? Center(
                      child: state.isGenerating
                          ? const SkeletonBox(width: double.infinity, height: double.infinity)
                          : FilledButton.icon(
                              onPressed: () {
                                Haptics.light();
                                ctl.generate();
                              },
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: const Text('Сгенерировать образ'),
                            ),
                    )
                  : Stack(
                      children: [
                        TinderDeck(
                          cards: deck,
                          topCardKey: _topKey,
                          onDecision: (row, decision) async {
                            if (decision == SwipeDecision.like) {
                              Haptics.success();
                              _burst.play();
                              await ctl.like(row);
                            } else {
                              Haptics.light();
                              ctl.dislike(row);
                            }
                          },
                          cardBuilder: (row) => _OutfitCard(
                            row: row,
                            onOpen: () => context.push('/outfit/${row.id}'),
                            heroTag: 'outfit_${row.id}',
                          ),
                        ),
                        // салют поверх
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: LikeBurst(controller: _burst.controller),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // One-thumb bottom controls
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: deck.isEmpty ? null : () {
                        Haptics.light();
                        _topKey.currentState?.swipeLeft();
                      },
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Не то'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: deck.isEmpty ? () { Haptics.light(); ctl.generate(); } : () {
                        Haptics.success();
                        _burst.play();
                        _topKey.currentState?.swipeRight();
                      },
                      icon: Icon(deck.isEmpty ? Icons.auto_awesome_rounded : Icons.favorite_rounded),
                      label: Text(deck.isEmpty ? 'Ещё' : 'В избранное'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: state.isGenerating
                        ? null
                        : () {
                            Haptics.selection();
                            ctl.generate();
                          },
                    icon: state.isGenerating
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.shuffle_rounded),
                    tooltip: 'Сгенерировать новую',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OccasionChips extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;

  const _OccasionChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('daily', 'На каждый день'),
      ('date', 'Для свидания'),
      ('office', 'В офис'),
      ('walk', 'Прогулка'),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final (id, label) = items[i];
          final selected = id == value;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => onChanged(id),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          );
        },
      ),
    );
  }
}

class _OutfitCard extends StatelessWidget {
  final RecommendationRow row;
  final VoidCallback onOpen;
  final String heroTag;

  const _OutfitCard({required this.row, required this.onOpen, required this.heroTag});

  Map<String, dynamic> _outfit() {
    try {
      return (jsonDecode(row.outfitDataJson) as Map).cast<String, dynamic>();
    } catch (_) {
      return {};
    }
  }

  Map<String, dynamic> _weather() {
    try {
      return (jsonDecode(row.weatherDataJson) as Map).cast<String, dynamic>();
    } catch (_) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final outfit = _outfit();
    final weather = _weather();

    final lines = (outfit['outfit'] is List)
        ? (outfit['outfit'] as List).whereType<Map>().map((e) => e.cast<String, dynamic>()).toList()
        : <Map<String, dynamic>>[];

    final temp = (weather['temp'] ?? weather['temperature'] ?? '').toString();
    final cond = (weather['condition'] ?? weather['description'] ?? weather['weather'] ?? '').toString();

    return Hero(
      tag: heroTag,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Образ',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Icon(
                      row.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: row.isFavorite ? Colors.pinkAccent : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (temp.isNotEmpty) Text('$temp°', style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cond.isEmpty ? 'Погода' : cond,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: _SimpleCollage(lines: lines),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onOpen,
                  child: const Text('Открыть детали'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SimpleCollage extends StatelessWidget {
  final List<Map<String, dynamic>> lines;
  const _SimpleCollage({required this.lines});

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return Center(
        child: Text(
          'Нет данных образа',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    final show = lines.take(5).toList();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: show.map((e) {
        final icon = (e['icon_emoji'] ?? '👕').toString();
        final name = (e['name'] ?? '').toString();
        final cat = (e['category'] ?? '').toString();

        return Container(
          width: 150,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(cat, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String text;
  const _InlineError({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text),
    );
  }
}