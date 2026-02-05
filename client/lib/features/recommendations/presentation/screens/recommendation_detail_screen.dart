import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:outfitstyle_client/app/di.dart';
import 'package:outfitstyle_client/ui/atoms/haptics.dart';
import 'package:outfitstyle_client/ui/atoms/outfit_app_bar.dart';
import 'package:outfitstyle_client/domain/entities/recommendation_entity.dart';
import 'package:outfitstyle_client/domain/entities/wardrobe_entity.dart' as domain;

final recommendationByIdProvider =
    StreamProvider.autoDispose.family<RecommendationRow?, String>((ref, id) {
  final service = ref.watch(recommendationsDomainServiceProvider);
  return service.watchById(id);
});

class RecommendationDetailScreen extends ConsumerStatefulWidget {
  final String recommendationId;
  const RecommendationDetailScreen({super.key, required this.recommendationId});

  @override
  ConsumerState<RecommendationDetailScreen> createState() =>
      _RecommendationDetailScreenState();
}

class _RecommendationDetailScreenState
    extends ConsumerState<RecommendationDetailScreen> {
  // локальные замены (не сохраняем на сервер)
  final Map<String, domain.WardrobeEntry> _overrideByCategory = {};

  @override
  Widget build(BuildContext context) {
    final asyncRow =
        ref.watch(recommendationByIdProvider(widget.recommendationId));
    final service = ref.read(recommendationsDomainServiceProvider);

    return asyncRow.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: OutfitAppBar(title: 'Рекомендация'),
        body: Center(child: Text('Ошибка: $e')),
      ),
      data: (row) {
        if (row == null) {
          return const Scaffold(
            body: Center(child: Text('Не найдено')),
          );
        }

        final outfit = _decode(row.outfitDataJson);
        final weather = _decode(row.weatherDataJson);

        final lines = (outfit['outfit'] is List)
            ? (outfit['outfit'] as List)
                .whereType<Map>()
                .map((e) => e.cast<String, dynamic>())
                .toList()
            : <Map<String, dynamic>>[];

        final categories = lines
            .map((e) => (e['category'] ?? '').toString())
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList();

        final wardrobeAsync = ref.watch(wardrobeStreamProvider);

        return Scaffold(
          appBar: OutfitAppBar(
            title: 'Рекомендация',
            actions: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      Haptics.selection();
                      // Поделиться рекомендацией
                    },
                    icon: const Icon(Icons.ios_share_rounded),
                    tooltip: 'Поделиться',
                  ),
                  IconButton(
                    onPressed: () async {
                      Haptics.selection();
                      await service.toggleFavorite(row);
                    },
                    icon: Icon(
                      row.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: row.isFavorite ? Colors.pinkAccent : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              Column(
                children: [
                  _HeaderCard(
                    weather: weather,
                    isFavorite: row.isFavorite,
                  ),
                  const SizedBox(height: 12),

                  // Возможность заменить вещи из рекомендации на вещи из гардероба
                  wardrobeAsync.when(
                    loading: () => const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => Text('Ошибка гардероба: $e'),
                    data: (wardrobe) {
                      final byCat = <String, List<domain.WardrobeEntry>>{};
                      for (final w in wardrobe.where((w) => !w.isArchived)) {
                        byCat.putIfAbsent(w.category, () => []).add(w);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Заменить вещи из рекомендации',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          for (final cat in categories)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: CategoryReplacementWidget(
                                category: cat,
                                original: lines.firstWhere(
                                    (e) =>
                                        (e['category'] ?? '').toString() == cat,
                                    orElse: () => {}),
                                alternatives: byCat[cat] ?? const [],
                                selected: _overrideByCategory[cat],
                                onSelected: (picked) {
                                  setState(() {
                                    if (picked == null) {
                                      _overrideByCategory.remove(cat);
                                    } else {
                                      _overrideByCategory[cat] = picked;
                                    }
                                  });
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Text(
                'Состав рекомендации',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),

              // Показываем итог: оригинал + overrides
              ...categories.map((cat) {
                final picked = _overrideByCategory[cat];
                if (picked != null) {
                  return _LineTile(
                    icon: picked.iconEmoji,
                    title: picked.name,
                    subtitle: 'Замена • $cat',
                  );
                }
                final original = lines.firstWhere(
                    (e) => (e['category'] ?? '') == cat,
                    orElse: () => {});
                return _LineTile(
                  icon: (original['icon_emoji'] ?? '👕').toString(),
                  title: (original['name'] ?? 'Вещь').toString(),
                  subtitle: cat,
                );
              }),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _overrideByCategory.isEmpty
                              ? null
                              : () {
                                  Haptics.selection();
                                  setState(() => _overrideByCategory.clear());
                                },
                          icon: const Icon(Icons.undo_rounded),
                          label: const Text('Сбросить замены'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            Haptics.success();

                            final finalLines = _buildFinalLines(
                              originalLines: lines,
                              overridesByCategory: _overrideByCategory,
                            );

                            final finalOutfit =
                                _buildOutfitData(lines: finalLines);

                            final newId = await service.saveLocalOutfit(
                              outfitData: finalOutfit,
                              weatherData: weather,
                              favorite: true,
                            );

                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Сохранено как новый образ')),
                            );

                            // перейти к сохраненному образу
                            if (context.mounted) {
                              context.go('/outfit/$newId');
                            }
                          },
                          icon: const Icon(Icons.bookmark_add_rounded),
                          label: const Text('Сохранить как новый'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Haptics.selection();
                        // Перейти к экрану интеграции с гардеробом
                        context.push('/recommendations/${row.id}/integrate');
                      },
                      icon: const Icon(Icons.compare_arrows_rounded),
                      label: const Text('Интегрировать с гардеробом'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _decode(String jsonStr) {
    try {
      return (jsonDecode(jsonStr) as Map).cast<String, dynamic>();
    } catch (_) {
      return {};
    }
  }

  List<Map<String, dynamic>> _buildFinalLines({
    required List<Map<String, dynamic>> originalLines,
    required Map<String, domain.WardrobeEntry> overridesByCategory,
  }) {
    final out = <Map<String, dynamic>>[];

    for (final line in originalLines) {
      final cat = (line['category'] ?? '').toString();
      final override = overridesByCategory[cat];

      if (override != null) {
        out.add(_mapWardrobeEntryToOutfitLine(override));
      } else {
        out.add(Map<String, dynamic>.from(line));
      }
    }

    // Если вдруг override есть по категории, которой не было в оригинале — добавим в конец
    for (final kv in overridesByCategory.entries) {
      final cat = kv.key;
      final exists = out.any((e) => (e['category'] ?? '').toString() == cat);
      if (!exists) out.add(_mapWardrobeEntryToOutfitLine(kv.value));
    }

    return out;
  }

  Map<String, dynamic> _buildOutfitData({
    required List<Map<String, dynamic>> lines,
  }) {
    return <String, dynamic>{
      'outfit': lines,
    };
  }

  Map<String, dynamic> _mapWardrobeEntryToOutfitLine(domain.WardrobeEntry w) {
    return <String, dynamic>{
      'id': w.id,
      'name': w.name,
      'category': w.category,
      'subcategory': w.subcategory,
      'icon_emoji': w.iconEmoji,
      'source': 'wardrobe',
      'is_owned': true,
      // можно расширять позже:
      'image_url': w.imageUrl,
    };
  }
}

class _HeaderCard extends StatelessWidget {
  final Map<String, dynamic> weather;
  final bool isFavorite;
  const _HeaderCard({required this.weather, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    final temp = (weather['temp'] ?? weather['temperature'] ?? '').toString();
    final cond = (weather['condition'] ??
            weather['description'] ??
            weather['weather'] ??
            '')
        .toString();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Погода',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(cond.isEmpty ? '—' : cond),
                  ]),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  temp.isEmpty ? '—' : '$temp°',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(isFavorite ? 'В избранном' : 'Не сохранён'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _LineTile(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        tileColor: Theme.of(context).colorScheme.surface,
        leading: Text(icon, style: const TextStyle(fontSize: 26)),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class CategoryReplacementWidget extends StatefulWidget {
  final String category;
  final Map<String, dynamic> original;
  final List<domain.WardrobeEntry> alternatives;
  final domain.WardrobeEntry? selected;
  final void Function(domain.WardrobeEntry? picked) onSelected;

  const CategoryReplacementWidget({
    super.key,
    required this.category,
    required this.original,
    required this.alternatives,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<CategoryReplacementWidget> createState() =>
      _CategoryReplacementWidgetState();
}

class _CategoryReplacementWidgetState extends State<CategoryReplacementWidget> {
  late final PageController _pc;

  @override
  void initState() {
    super.initState();
    _pc = PageController(viewportFraction: 0.86);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <_PickPage>[
      _PickPage.original(
        icon: (widget.original['icon_emoji'] ?? '👕').toString(),
        name: (widget.original['name'] ?? 'Оригинал').toString(),
      ),
      ...widget.alternatives.map((w) => _PickPage.alt(w)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.category,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 112,
          child: PageView.builder(
            controller: _pc,
            itemCount: pages.length,
            onPageChanged: (i) {
              Haptics.selection();
              final p = pages[i];
              widget.onSelected(p.alt);
            },
            itemBuilder: (context, i) {
              final p = pages[i];
              final isSelected =
                  (p.alt?.id != null && widget.selected?.id == p.alt!.id) ||
                      (p.alt == null && widget.selected == null);

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Text(p.icon, style: const TextStyle(fontSize: 30)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        p.alt == null ? 'ОР' : 'ЗАМ',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.8)
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PickPage {
  final String icon;
  final String name;
  final domain.WardrobeEntry? alt;

  _PickPage._(this.icon, this.name, this.alt);

  factory _PickPage.original({required String icon, required String name}) =>
      _PickPage._(icon, name, null);

  factory _PickPage.alt(domain.WardrobeEntry w) => _PickPage._(w.iconEmoji, w.name, w);
}
