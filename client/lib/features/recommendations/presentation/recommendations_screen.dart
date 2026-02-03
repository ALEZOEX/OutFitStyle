import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/outfit_app_bar.dart';
import '../../../ui/atoms/skeleton.dart';
import 'recommendations_controller.dart';
import 'widgets/recommendation_card.dart';

class RecommendationsScreen extends ConsumerStatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  ConsumerState<RecommendationsScreen> createState() =>
      _RecommendationsScreenState();
}

class _RecommendationsScreenState extends ConsumerState<RecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(recommendationsControllerProvider.notifier).sync();
      // Загружаем изображения для кэширования
      // ignore: discarded_futures
      ref.read(recommendationsControllerProvider.notifier).prefetchImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(recommendationsStreamProvider);
    final controller = ref.read(recommendationsControllerProvider.notifier);

    return Scaffold(
      appBar: OutfitAppBar(
        title: 'Рекомендации',
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
      body: recommendationsAsync.when(
        loading: () => const _RecommendationsSkeleton(),
        error: (e, _) => _RecommendationsError(error: e.toString()),
        data: (recommendations) {
          if (recommendations.isEmpty) {
            return const Center(
              child: Text('Пока нет рекомендаций'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final rec = recommendations[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RecommendationCard(
                  recommendation: rec,
                  onTap: () {
                    Haptics.selection();
                    context.push('/recommendations/${rec.id}');
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Haptics.selection();
          await controller.generateRecommendation(occasion: 'daily');
        },
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text('Сгенерировать'),
      ),
    );
  }
}

class _RecommendationsSkeleton extends StatelessWidget {
  const _RecommendationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      itemCount: 5,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: SkeletonBox(width: double.infinity, height: 180),
      ),
    );
  }
}

class _RecommendationsError extends StatelessWidget {
  final String error;
  const _RecommendationsError({required this.error});

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
