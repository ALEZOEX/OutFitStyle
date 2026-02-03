import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/outfit_app_bar.dart';
import '../../../ui/atoms/skeleton.dart';
import '../../../domain/entities/recommendation_entity.dart';
import '../../../domain/entities/wardrobe_entity.dart';
import '../recommendations_controller.dart';
import '../wardrobe/wardrobe_controller.dart';

class RecommendationWardrobeIntegrationScreen extends ConsumerWidget {
  final String recommendationId;
  const RecommendationWardrobeIntegrationScreen(
      {super.key, required this.recommendationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationAsync =
        ref.watch(recommendationByIdProvider(recommendationId));
    final wardrobeAsync = ref.watch(wardrobeStreamProvider);

    return recommendationAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: OutfitAppBar(title: const Text('Интеграция')),
        body: Center(child: Text('Ошибка: $e')),
      ),
      data: (recommendation) {
        return wardrobeAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: OutfitAppBar(title: const Text('Интеграция')),
            body: Center(child: Text('Ошибка гардероба: $e')),
          ),
          data: (wardrobe) {
            return _IntegrationContent(
              recommendation: recommendation,
              wardrobe: wardrobe,
            );
          },
        );
      },
    );
  }
}

class _IntegrationContent extends ConsumerStatefulWidget {
  final RecommendationRow recommendation;
  final List<WardrobeEntry> wardrobe;
  const _IntegrationContent(
      {required this.recommendation, required this.wardrobe});

  @override
  ConsumerState<_IntegrationContent> createState() =>
      _IntegrationContentState();
}

class _IntegrationContentState extends ConsumerState<_IntegrationContent> {
  final Map<String, WardrobeEntry?> _replacements = {};

  @override
  Widget build(BuildContext context) {
    final recommendation = widget.recommendation;
    final wardrobe = widget.wardrobe;

    // Группируем вещи из рекомендации по категориям
    final outfitLines = _parseOutfitLines(recommendation.outfitDataJson);
    final byCategory = <String, List<Map<String, dynamic>>>{};
    for (final line in outfitLines) {
      final category = (line['category'] ?? '').toString();
      if (category.isNotEmpty) {
        byCategory.putIfAbsent(category, () => []).add(line);
      }
    }

    // Группируем вещи из гардероба по категориям
    final wardrobeByCategory = <String, List<WardrobeEntry>>{};
    for (final item in wardrobe.where((w) => !w.isArchived)) {
      wardrobeByCategory.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      appBar: OutfitAppBar(
        title: 'Интеграция с гардеробом',
        actions: [
          IconButton(
            onPressed: () async {
              Haptics.selection();
              // Сохраняем комбинированный образ
              await _saveCombinedOutfit();
            },
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Оригинальная рекомендация
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Оригинальная рекомендация',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  _OutfitPreview(lines: outfitLines),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Возможность замены
          Text(
            'Замените вещи из рекомендации на свои из гардероба',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),

          for (final entry in byCategory.entries)
            _CategoryReplacementSection(
              category: entry.key,
              originalItems: entry.value,
              wardrobeItems: wardrobeByCategory[entry.key] ?? [],
              onReplace: (replacement) {
                setState(() {
                  if (replacement == null) {
                    _replacements.remove(entry.key);
                  } else {
                    _replacements[entry.key] = replacement;
                  }
                });
              },
            ),

          const SizedBox(height: 16),

          // Предварительный просмотр результата
          if (_replacements.isNotEmpty) ...[
            Text(
              'Предварительный просмотр результата',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _CombinedOutfitPreview(
                  originalLines: outfitLines,
                  replacements: _replacements,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _parseOutfitLines(String outfitDataJson) {
    try {
      final outfit =
          (jsonDecode(outfitDataJson) as Map).cast<String, dynamic>();
      final lines = (outfit['outfit'] is List)
          ? (outfit['outfit'] as List)
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList()
          : <Map<String, dynamic>>[];
      return lines;
    } catch (e) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _saveCombinedOutfit() async {
    final service = ref.read(recommendationsDomainServiceProvider);

    // Создаем объединенный образ
    final originalLines =
        _parseOutfitLines(widget.recommendation.outfitDataJson);
    final finalLines = <Map<String, dynamic>>[];

    for (final line in originalLines) {
      final category = (line['category'] ?? '').toString();
      final replacement = _replacements[category];

      if (replacement != null) {
        // Используем вещь из гардероба
        finalLines.add({
          'id': replacement.id,
          'name': replacement.name,
          'category': replacement.category,
          'subcategory': replacement.subcategory,
          'icon_emoji': replacement.iconEmoji,
          'source': 'wardrobe',
          'is_owned': true,
          'image_url': replacement.imageUrl,
        });
      } else {
        // Используем оригинальную рекомендацию
        finalLines.add(Map<String, dynamic>.from(line));
      }
    }

    final finalOutfitData = {
      'outfit': finalLines,
    };

    // Сохраняем как новый локальный образ
    await service.saveLocalOutfit(
      outfitData: finalOutfitData,
      weatherData: jsonDecode(widget.recommendation.weatherDataJson),
      favorite: true,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Образ сохранен в гардероб')),
      );
      Navigator.of(context).pop(); // Возвращаемся назад
    }
  }
}

class _OutfitPreview extends StatelessWidget {
  final List<Map<String, dynamic>> lines;
  const _OutfitPreview({required this.lines});

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const Text('Нет данных об образе');
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: lines.map((line) {
        final icon = (line['icon_emoji'] ?? '👕').toString();
        final name = (line['name'] ?? 'Вещь').toString();
        final category = (line['category'] ?? 'Категория').toString();

        return Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              SizedBox(
                width: 80,
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryReplacementSection extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> originalItems;
  final List<WardrobeEntry> wardrobeItems;
  final void Function(WardrobeEntry? replacement) onReplace;
  const _CategoryReplacementSection({
    required this.category,
    required this.originalItems,
    required this.wardrobeItems,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),

            // Оригинальная вещь из рекомендации
            Text('Рекомендованная вещь:',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: originalItems.map((item) {
                final icon = (item['icon_emoji'] ?? '👕').toString();
                final name = (item['name'] ?? 'Вещь').toString();
                return _WardrobeItemChip(
                  icon: icon,
                  name: name,
                  isOriginal: true,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Варианты из гардероба
            Text('Ваши вещи:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            if (wardrobeItems.isEmpty)
              Text(
                'Нет подходящих вещей в этой категории',
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.65)),
              )
            else
              Wrap(
                spacing: 8,
                children: [
                  _WardrobeItemChip(
                    icon: '🔄',
                    name: 'Оставить оригинальной',
                    isSelected: true, // По умолчанию оригинальная
                    onTap: () => onReplace(null),
                  ),
                  ...wardrobeItems.map((item) => _WardrobeItemChip(
                        icon: item.iconEmoji,
                        name: item.name,
                        isSelected: false,
                        onTap: () => onReplace(item),
                      )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _WardrobeItemChip extends StatelessWidget {
  final String icon;
  final String name;
  final bool isOriginal;
  final bool isSelected;
  final VoidCallback? onTap;
  const _WardrobeItemChip({
    required this.icon,
    required this.name,
    this.isOriginal = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) {
        if (onTap != null) {
          Haptics.selection();
          onTap!();
        }
      },
      showCheckmark: false,
    );
  }
}

class _CombinedOutfitPreview extends ConsumerWidget {
  final List<Map<String, dynamic>> originalLines;
  final Map<String, WardrobeEntry?> replacements;
  const _CombinedOutfitPreview(
      {required this.originalLines, required this.replacements});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = <Map<String, dynamic>>[];

    for (final line in originalLines) {
      final category = (line['category'] ?? '').toString();
      final replacement = replacements[category];

      if (replacement != null) {
        lines.add({
          'id': replacement.id,
          'name': replacement.name,
          'category': replacement.category,
          'subcategory': replacement.subcategory,
          'icon_emoji': replacement.iconEmoji,
          'source': 'wardrobe',
          'is_owned': true,
        });
      } else {
        lines.add(Map<String, dynamic>.from(line));
      }
    }

    return _OutfitPreview(lines: lines);
  }
}
