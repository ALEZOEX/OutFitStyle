import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/outfit_app_bar.dart';
import '../../../ui/atoms/skeleton.dart';
import '../../../domain/entities/wardrobe_entity.dart';
import '../../../domain/entities/recommendation_entity.dart';
import '../wardrobe/wardrobe_controller.dart';
import '../recommendations/recommendations_controller.dart';

final wardrobeItemForRecommendationProvider =
    FutureProvider.autoDispose.family<WardrobeEntry?, String>((ref, id) async {
  final service = ref.watch(wardrobeDomainServiceProvider);
  return await service.getById(id);
});

class UseWardrobeItemInRecommendationScreen extends ConsumerWidget {
  final String itemId;
  const UseWardrobeItemInRecommendationScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(wardrobeItemForRecommendationProvider(itemId));
    final recService = ref.read(recommendationsDomainServiceProvider);

    return itemAsync.when(
      loading: () => Scaffold(
        appBar: OutfitAppBar(title: const Text('Использовать в образе')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: OutfitAppBar(title: const Text('Использовать в образе')),
        body: Center(child: Text('Ошибка: $e')),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: OutfitAppBar(title: const Text('Использовать в образе')),
            body: const Center(child: Text('Вещь не найдена')),
          );
        }
        return _UseWardrobeItemContent(item: item, service: recService);
      },
    );
  }
}

class _UseWardrobeItemContent extends ConsumerStatefulWidget {
  final WardrobeEntry item;
  final RecommendationsDomainService service;
  const _UseWardrobeItemContent({required this.item, required this.service});

  @override
  ConsumerState<_UseWardrobeItemContent> createState() => _UseWardrobeItemContentState();
}

class _UseWardrobeItemContentState extends ConsumerState<_UseWardrobeItemContent> {
  String _occasion = 'daily';
  bool _includeWeather = true;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return Scaffold(
      appBar: OutfitAppBar(
        title: 'Использовать в образе',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Карточка выбранной вещи
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(widget.item.iconEmoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.item.category} • ${widget.item.subcategory}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Выбор случая/повода
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Выберите повод',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Повседневное'),
                        selected: _occasion == 'daily',
                        onSelected: (_) => setState(() => _occasion = 'daily'),
                      ),
                      FilterChip(
                        label: const Text('Свидание'),
                        selected: _occasion == 'date',
                        onSelected: (_) => setState(() => _occasion = 'date'),
                      ),
                      FilterChip(
                        label: const Text('Офис'),
                        selected: _occasion == 'office',
                        onSelected: (_) => setState(() => _occasion = 'office'),
                      ),
                      FilterChip(
                        label: const Text('Прогулка'),
                        selected: _occasion == 'walk',
                        onSelected: (_) => setState(() => _occasion = 'walk'),
                      ),
                      FilterChip(
                        label: const Text('Спорт'),
                        selected: _occasion == 'sports',
                        onSelected: (_) => setState(() => _occasion = 'sports'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Опции
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Опции',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Учитывать погоду'),
                    value: _includeWeather,
                    onChanged: (value) => setState(() => _includeWeather = value),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: FilledButton.icon(
            onPressed: () async {
              Haptics.success();

              try {
                // Создаем рекомендацию с учетом выбранной вещи
                final recommendation = await service.generateRecommendationWithItem(
                  item: widget.item,
                  occasion: _occasion,
                  includeWeather: _includeWeather,
                );

                if (context.mounted) {
                  // Переходим к экрану деталей рекомендации
                  context.push('/recommendations/${recommendation.id}');

                  // Показываем сообщение
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Рекомендация создана с вашей вещью')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка: $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Создать рекомендацию'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }
}