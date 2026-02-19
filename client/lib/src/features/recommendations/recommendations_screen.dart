import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/presentation_providers_exports.dart';
import 'presentation/controllers/recommendation_state_notifier.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/recommendation_filter_sheet.dart';
import 'widgets/saved_recommendations_screen.dart';
import 'widgets/recommendation_history_screen.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider) ?? '';
    final weatherAsyncValue = ref.watch(weatherProvider((lat: 55.75, lon: 37.61)));
    final recommendationState = ref.watch(recommendationStateNotifierProvider);

    // Load recommendations when weather data is available
    ref.listen(weatherProvider((lat: 55.75, lon: 37.61)), (previous, next) {
      next.whenData((weather) {
        if (userId.isNotEmpty) {
          final latitude = weather.latitude ?? 55.75;
          final longitude = weather.longitude ?? 37.61;
          ref
              .read(recommendationStateNotifierProvider.notifier)
              .fetchRecommendations(
                userId: userId,
                latitude: latitude,
                longitude: longitude,
              );
        }
      });
    });

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Рекомендации'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (userId.isNotEmpty && weatherAsyncValue.value != null) {
                  final latitude = weatherAsyncValue.value?.latitude;
                  final longitude = weatherAsyncValue.value?.longitude;
                  if (latitude != null && longitude != null) {
                    ref
                        .read(recommendationStateNotifierProvider.notifier)
                        .fetchRecommendations(
                          userId: userId,
                          latitude: latitude,
                          longitude: longitude,
                        );
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => RecommendationFilterSheet(
                    onApply: (options) {
                      // Apply filter logic here
                      // For now, just refresh the recommendations
                      if (userId.isNotEmpty && weatherAsyncValue.value != null) {
                        final latitude = weatherAsyncValue.value?.latitude;
                        final longitude = weatherAsyncValue.value?.longitude;
                        if (latitude != null && longitude != null) {
                          ref
                              .read(recommendationStateNotifierProvider.notifier)
                              .fetchRecommendations(
                                userId: userId,
                                latitude: latitude,
                                longitude: longitude,
                              );
                        }
                      }
                    },
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (String result) {
                switch (result) {
                  case 'saved':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SavedRecommendationsScreen(),
                      ),
                    );
                    break;
                  case 'history':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const RecommendationHistoryScreen(),
                      ),
                    );
                    break;
                  case 'preferences':
                    // Navigate to user preferences
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'saved',
                  child: Text('Сохраненные рекомендации'),
                ),
                const PopupMenuItem<String>(
                  value: 'history',
                  child: Text('История рекомендаций'),
                ),
                const PopupMenuItem<String>(
                  value: 'preferences',
                  child: Text('Мои предпочтения'),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Рекомендации'),
              Tab(text: 'Сохраненные'),
              Tab(text: 'История'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Main recommendations tab
            weatherAsyncValue.value == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Погода недоступна'),
                      ],
                    ),
                  )
                : recommendationState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : recommendationState.errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error,
                                    size: 64, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(
                                    'Ошибка: ${recommendationState.errorMessage}'),
                                ElevatedButton(
                                  onPressed: () {
                                    final latitude = weatherAsyncValue.value?.latitude;
                                    final longitude = weatherAsyncValue.value?.longitude;
                                    if (latitude != null && longitude != null) {
                                      ref
                                          .read(
                                              recommendationStateNotifierProvider
                                                  .notifier)
                                          .fetchRecommendations(
                                            userId: userId,
                                            latitude: latitude,
                                            longitude: longitude,
                                          );
                                    }
                                  },
                                  child: const Text('Повторить'),
                                ),
                              ],
                            ),
                          )
                        : recommendationState.recommendations.when(
                            data: (recommendations) {
                              return RefreshIndicator(
                                onRefresh: () async {
                                  final latitude = weatherAsyncValue.value?.latitude;
                                  final longitude = weatherAsyncValue.value?.longitude;
                                  if (latitude != null && longitude != null) {
                                    await ref
                                        .read(recommendationStateNotifierProvider
                                            .notifier)
                                        .fetchRecommendations(
                                          userId: userId,
                                          latitude: latitude,
                                          longitude: longitude,
                                        );
                                  }
                                },
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: recommendations.length,
                                  itemBuilder: (context, index) {
                                    final recommendation = recommendations[index];
                                    return RecommendationCard(
                                      recommendation: recommendation,
                                      userId: userId,
                                      onDetailsPressed: () {
                                        context.push('/recommendations/detail',
                                            extra: recommendation);
                                      },
                                      onSharePressed: () {
                                        // Share functionality would go here
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Функция поделиться скоро будет доступна')),
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, stack) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error, size: 64, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text('Ошибка: $error'),
                                  ElevatedButton(
                                    onPressed: () {
                                      final latitude = weatherAsyncValue.value?.latitude;
                                      final longitude = weatherAsyncValue.value?.longitude;
                                      if (latitude != null && longitude != null) {
                                        ref
                                            .read(recommendationStateNotifierProvider.notifier)
                                            .fetchRecommendations(
                                              userId: userId,
                                              latitude: latitude,
                                              longitude: longitude,
                                            );
                                      }
                                    },
                                    child: const Text('Повторить'),
                                  ),
                                ],
                              ),
                            ),
                          ),
            // Saved recommendations tab
            const SavedRecommendationsScreen(),
            // History tab
            const RecommendationHistoryScreen(),
          ],
        ),
      ),
    );
  }
}
