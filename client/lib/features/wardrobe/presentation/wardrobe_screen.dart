import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/outfit_app_bar.dart';
import '../../../ui/atoms/skeleton.dart';
import 'widgets/wardrobe_grid_item.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(wardrobeControllerProvider.notifier).sync();

      // Загружаем изображения для кэширования
      // Получаем список элементов гардероба и передаем его в prefetchImages
      // ignore: discarded_futures
      final items = await ref.read(wardrobeRepositoryProvider).getAll();
      ref.read(wardrobeControllerProvider.notifier).prefetchImages(items);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wardrobeAsync = ref.watch(wardrobeStreamProvider);
    final controller = ref.read(wardrobeControllerProvider.notifier);

    return Scaffold(
      appBar: OutfitAppBar(
        title: 'Шкаф',
        actions: [
          IconButton(
            onPressed: () async {
              Haptics.selection();
              await controller.sync();
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Обновить',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Haptics.selection();
          context.push('/wardrobe/add');
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Добавить'),
      ),
      body: wardrobeAsync.when(
        loading: () => const _WardrobeSkeleton(),
        error: (e, _) => _WardrobeError(error: e.toString()),
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 80),
                const Center(child: Text('Шкаф пуст. Добавь первую вещь.')),
                const SizedBox(height: 20),
                Center(
                  child: FilledButton.icon(
                    onPressed: () => context.push('/wardrobe/add'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Добавить вещь'),
                  ),
                ),
              ],
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final e = items[index];
              return WardrobeGridItem(
                entry: e,
                onFavorite: () async {
                  Haptics.selection();
                  await controller.toggleFavorite(e);
                },
                onArchive: () async {
                  Haptics.light();
                  await controller.toggleArchived(e);
                },
                onWorn: () async {
                  Haptics.success();
                  await controller.markWorn(e);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _WardrobeSkeleton extends StatelessWidget {
  const _WardrobeSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: 10,
      itemBuilder: (_, __) =>
          const SkeletonBox(width: double.infinity, height: double.infinity),
    );
  }
}

class _WardrobeError extends StatelessWidget {
  final String error;
  const _WardrobeError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Ошибка: $error'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              // Повторная попытка загрузки
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}
