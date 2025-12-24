import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/atoms/skeleton.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/outfit_app_bar.dart';
import 'wardrobe_controller.dart';
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
    // При первом входе: показываем кэш мгновенно (если есть), и сразу синкаем.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(wardrobeControllerProvider.notifier).sync();
      // потом "докачка" картинок для метро
      // ignore: discarded_futures
      ref.read(wardrobeControllerProvider.notifier).prefetchImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stream = ref.watch(wardrobeStreamProvider);
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

      // One-thumb: основные действия снизу
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Haptics.light();
                    // позже: Magic Import камера
                  },
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('Magic Import'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: () {
                  Haptics.selection();
                  // позже: ручное добавление
                },
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Добавить вручную',
              ),
            ],
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: controller.sync,
        child: stream.when(
          loading: () => _WardrobeSkeleton(),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Ошибка: $e'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: controller.sync,
                child: const Text('Повторить'),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('Пока пусто. Добавь первую вещь.')),
                ],
              );
            }

            // Pinterest-like: 2 колонки, карточки, большие радиусы.
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
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
      ),
    );
  }
}

class _WardrobeSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: 10,
      itemBuilder: (_, __) => const SkeletonBox(width: double.infinity, height: double.infinity),
    );
  }
}