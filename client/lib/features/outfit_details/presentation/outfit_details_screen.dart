import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../data/local/app_database.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/outfit_app_bar.dart';
import '../../../domain/outfit/outfit_builder.dart';
import '../wardrobe/presentation/wardrobe_controller.dart';
import 'widgets/category_swipe_replacer.dart';
import '../share/presentation/outfit_share_screen.dart';

final outfitByIdProvider =
    StreamProvider.autoDispose.family<RecommendationRow?, String>((ref, id) {
  final repo = ref.watch(recommendationsRepositoryProvider);
  return repo.watchById(id);
});

class OutfitDetailsScreen extends ConsumerStatefulWidget {
  final String outfitId;
  const OutfitDetailsScreen({super.key, required this.outfitId});

  @override
  ConsumerState<OutfitDetailsScreen> createState() =>
      _OutfitDetailsScreenState();
}

class _OutfitDetailsScreenState extends ConsumerState<OutfitDetailsScreen> {
  final _shareKey = GlobalKey();

  // локальные замены (не сохраняем на сервер)
  final Map<String, WardrobeEntry> _overrideByCategory = {};

  @override
  Widget build(BuildContext context) {
    final asyncRow = ref.watch(outfitByIdProvider(widget.outfitId));
    final repo = ref.read(recommendationsRepositoryProvider);

    return asyncRow.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Образ')),
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
            title: 'Образ',
            actions: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      Haptics.selection();
                      // Navigate to the new share preview screen
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OutfitShareScreen(
                            outfitId: widget.outfitId,
                            outfitDataJson: row.outfitDataJson,
                            weatherDataJson: row.weatherDataJson,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.ios_share_rounded),
                    tooltip: 'Поделиться',
                  ),
                  IconButton(
                    onPressed: () async {
                      Haptics.selection();
                      await repo.toggleFavorite(row);
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
              RepaintBoundary(
                key: _shareKey,
                child: Column(
                  children: [
                    Hero(
                      tag: 'outfit_${row.id}',
                      child: _HeaderCard(
                        weather: weather,
                        isFavorite: row.isFavorite,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ТВОЙ "идеал": свайп замены по категориям (локальный перебор)
                    wardrobeAsync.when(
                      loading: () => const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator())),
                      error: (e, _) => Text('Wardrobe error: $e'),
                      data: (wardrobe) {
                        final byCat = <String, List<WardrobeEntry>>{};
                        for (final w in wardrobe.where((w) => !w.isArchived)) {
                          byCat.putIfAbsent(w.category, () => []).add(w);
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Заменить вещи',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 10),
                            for (final cat in categories)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: CategorySwipeReplacer(
                                  category: cat,
                                  original: lines.firstWhere(
                                      (e) =>
                                          (e['category'] ?? '').toString() ==
                                          cat,
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
              ),

              const SizedBox(height: 14),
              Text(
                'Итоговый состав',
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
              child: Row(
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

                        final finalLines = OutfitBuilder.buildFinalLines(
                          originalLines: lines,
                          overridesByCategory: _overrideByCategory,
                        );

                        final finalOutfit =
                            OutfitBuilder.buildOutfitData(lines: finalLines);

                        final newId = await repo.saveLocalOutfit(
                          outfitData: finalOutfit,
                          weatherData: weather,
                          favorite: true,
                        );

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Сохранено в избранное (локально)')),
                        );

                        // опционально: сразу открыть сохранённый локальный образ
                        // ignore: use_build_context_synchronously
                        context.go('/outfit/$newId');
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
