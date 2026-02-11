import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/presentation_providers_exports.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/recommendation_filter_sheet.dart';
import 'widgets/saved_recommendations_screen.dart';
import 'widgets/recommendation_history_screen.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider) ?? '';
    final weatherAsyncValue = ref.watch(weatherProvider);
    final recommendationState = ref.watch(recommendationStateNotifierProvider);

    // Load recommendations when weather data is available
    ref.listen(weatherProvider, (previous, next) {
      if (next != null && userId.isNotEmpty) {
        ref
            .read(recommendationStateNotifierProvider.notifier)
            .fetchRecommendations(
              userId: userId,
              latitude: next.latitude,
              longitude: next.longitude,
            );
      }
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
                if (userId.isNotEmpty && weatherAsyncValue != null) {
                  ref
                      .read(recommendationStateNotifierProvider.notifier)
                      .fetchRecommendations(
                        userId: userId,
                        latitude: weatherAsyncValue.latitude,
                        longitude: weatherAsyncValue.longitude,
                      );
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
                      if (userId.isNotEmpty && weatherAsyncValue != null) {
                        ref
                            .read(recommendationStateNotifierProvider.notifier)
                            .fetchRecommendations(
                              userId: userId,
                              latitude: weatherAsyncValue.latitude,
                              longitude: weatherAsyncValue.longitude,
                            );
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
            weatherAsyncValue == null
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
                                    ref
                                        .read(
                                            recommendationStateNotifierProvider
                                                .notifier)
                                        .fetchRecommendations(
                                          userId: userId,
                                          latitude: weatherAsyncValue.latitude,
                                          longitude:
                                              weatherAsyncValue.longitude,
                                        );
                                  },
                                  child: const Text('Повторить'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              ref
                                  .read(recommendationStateNotifierProvider
                                      .notifier)
                                  .fetchRecommendations(
                                    userId: userId,
                                    latitude: weatherAsyncValue.latitude,
                                    longitude: weatherAsyncValue.longitude,
                                  );
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount:
                                  recommendationState.recommendations.length,
                              itemBuilder: (context, index) {
                                final recommendation =
                                    recommendationState.recommendations[index];
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
