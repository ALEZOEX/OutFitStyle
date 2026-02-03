import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/outfit_app_bar.dart';
import '../../../ui/atoms/skeleton.dart';
import 'wardrobe_controller.dart';

final wardrobeItemByIdProvider =
    StreamProvider.autoDispose.family<WardrobeEntry?, String>((ref, id) {
  final repo = ref.watch(wardrobeRepositoryProvider);
  return repo.watchById(id);
});

class WardrobeItemDetailScreen extends ConsumerWidget {
  final String itemId;
  const WardrobeItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(wardrobeItemByIdProvider(itemId));
    final controller = ref.read(wardrobeControllerProvider.notifier);

    return itemAsync.when(
      loading: () => Scaffold(
        appBar: OutfitAppBar(title: const Text('Вещь')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: OutfitAppBar(title: const Text('Вещь')),
        body: Center(child: Text('Ошибка: $e')),
      ),
      data: (item) {
        if (item == null) {
          return const Scaffold(
            body: Center(child: Text('Вещь не найдена')),
          );
        }

        return Scaffold(
          appBar: OutfitAppBar(
            title: 'Детали вещи',
            actions: [
              IconButton(
                onPressed: () async {
                  Haptics.selection();
                  await controller.toggleFavorite(item);
                },
                icon: Icon(
                  item.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: item.isFavorite ? Colors.pinkAccent : null,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Изображение вещи
              if (item.imageUrl != null || item.localImagePath != null)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: item.localImagePath != null
                        ? DecorationImage(
                            image: FileImage(File(item.localImagePath!)),
                            fit: BoxFit.cover,
                          )
                        : item.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(item.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: item.localImagePath == null && item.imageUrl == null
                      ? Center(
                          child: Text(item.iconEmoji,
                              style: const TextStyle(fontSize: 64)))
                      : null,
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                      child: Text(item.iconEmoji,
                          style: const TextStyle(fontSize: 64))),
                ),
              const SizedBox(height: 16),

              // Название и категория
              Text(
                item.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.iconEmoji}  ${item.category} • ${item.subcategory}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.65),
                    ),
              ),
              const SizedBox(height: 16),

              // Основная информация
              _InfoCard(
                title: 'Основная информация',
                children: [
                  _InfoRow(label: 'Стиль', value: item.style),
                  _InfoRow(label: 'Сезон', value: item.season),
                  _InfoRow(label: 'Пол', value: item.gender),
                  _InfoRow(label: 'Посадка', value: item.fit),
                  _InfoRow(label: 'Узор', value: item.pattern),
                ],
              ),
              const SizedBox(height: 16),

              // Температурные характеристики
              if (item.minTemp != null || item.maxTemp != null)
                _InfoCard(
                  title: 'Температурные характеристики',
                  children: [
                    if (item.minTemp != null)
                      _InfoRow(
                          label: 'Мин. температура',
                          value: '${item.minTemp}°C'),
                    if (item.maxTemp != null)
                      _InfoRow(
                          label: 'Макс. температура',
                          value: '${item.maxTemp}°C'),
                    if (item.warmthLevel != null)
                      _InfoRow(
                          label: 'Уровень теплоты',
                          value: '${item.warmthLevel}/10'),
                  ],
                ),
              const SizedBox(height: 16),

              // Погодные характеристики
              _InfoCard(
                title: 'Погодные характеристики',
                children: [
                  _InfoRow(
                      label: 'Подходит для дождя',
                      value: item.rainOk ? 'Да' : 'Нет'),
                  _InfoRow(
                      label: 'Подходит для снега',
                      value: item.snowOk ? 'Да' : 'Нет'),
                  _InfoRow(
                      label: 'Подходит для ветра',
                      value: item.windOk ? 'Да' : 'Нет'),
                ],
              ),
              const SizedBox(height: 16),

              // Назначение и материалы
              _InfoCard(
                title: 'Назначение и материалы',
                children: [
                  if (item.usage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Wrap(
                        spacing: 8,
                        children: item.usage
                            .map((u) => Chip(label: Text(_translateUsage(u))))
                            .toList(),
                      ),
                    ),
                  if (item.materials.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        children: item.materials
                            .map(
                                (m) => Chip(label: Text(_translateMaterial(m))))
                            .toList(),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Статистика использования
              _InfoCard(
                title: 'Статистика',
                children: [
                  _InfoRow(
                      label: 'Количество носок',
                      value: item.wearCount.toString()),
                  if (item.lastWornAt != null)
                    _InfoRow(
                        label: 'Последняя носка',
                        value: _formatDate(item.lastWornAt!)),
                ],
              ),
              const SizedBox(height: 16),

              // Погодные и температурные характеристики
              _InfoCard(
                title: 'Погодные и температурные характеристики',
                children: [
                  _InfoRow(
                      label: 'Подходит для дождя',
                      value: item.rainOk ? 'Да' : 'Нет'),
                  _InfoRow(
                      label: 'Подходит для снега',
                      value: item.snowOk ? 'Да' : 'Нет'),
                  _InfoRow(
                      label: 'Подходит для ветра',
                      value: item.windOk ? 'Да' : 'Нет'),
                  if (item.warmthLevel != null)
                    _InfoRow(
                        label: 'Уровень теплоты',
                        value: '${item.warmthLevel}/10'),
                  if (item.minTemp != null)
                    _InfoRow(
                        label: 'Мин. температура', value: '${item.minTemp}°C'),
                  if (item.maxTemp != null)
                    _InfoRow(
                        label: 'Макс. температура', value: '${item.maxTemp}°C'),
                ],
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Haptics.light();
                            await controller.toggleArchived(item);
                            if (context.mounted) {
                              context.pop();
                            }
                          },
                          icon: Icon(item.isArchived
                              ? Icons.unarchive_rounded
                              : Icons.archive_rounded),
                          label: Text(item.isArchived ? 'Вернуть' : 'В архив'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            Haptics.success();
                            await controller.markWorn(item);
                            // Обновляем экран
                            if (context.mounted) {
                              context.pop();
                              context.push('/home');
                            }
                          },
                          icon: const Icon(Icons.checkroom_rounded),
                          label: const Text('Надето'),
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
                        // Перейти к экрану создания рекомендации с этой вещью
                        context
                            .push('/wardrobe/${item.id}/use-in-recommendation');
                      },
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('Использовать в образе'),
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

  String _translateUsage(String usage) {
    switch (usage) {
      case 'work':
        return 'Работа';
      case 'casual':
        return 'Повседневное';
      case 'sports':
        return 'Спорт';
      case 'formal':
        return 'Формальное';
      case 'party':
        return 'Вечеринка';
      case 'travel':
        return 'Путешествие';
      default:
        return usage;
    }
  }

  String _translateMaterial(String material) {
    switch (material) {
      case 'cotton':
        return 'Хлопок';
      case 'wool':
        return 'Шерсть';
      case 'polyester':
        return 'Полиэстер';
      case 'silk':
        return 'Шелк';
      case 'denim':
        return 'Джинса';
      case 'leather':
        return 'Кожа';
      case 'linen':
        return 'Лен';
      default:
        return material;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.65),
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value.isEmpty ? '—' : value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
