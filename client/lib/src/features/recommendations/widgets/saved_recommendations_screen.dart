import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/domain_exports.dart';
import '../../../presentation/providers/presentation_providers_exports.dart';
import '../presentation/controllers/recommendation_state_notifier.dart';

class SavedRecommendationsScreen extends ConsumerWidget {
  const SavedRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider) ?? '';

    // Load saved recommendations when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(recommendationStateNotifierProvider.notifier)
          .loadSavedRecommendations(userId: userId);
    });

    final recommendationState = ref.watch(recommendationStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Сохраненные рекомендации')),
      body:
          recommendationState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : recommendationState.errorMessage != null
              ? Center(
                child: Text('Ошибка: ${recommendationState.errorMessage}'),
              )
              : recommendationState.savedRecommendations.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Нет сохраненных рекомендаций',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: recommendationState.savedRecommendations.length,
                itemBuilder: (context, index) {
                  final recommendation =
                      recommendationState.savedRecommendations[index];
                  return _buildSavedRecommendationCard(context, recommendation);
                },
              ),
    );
  }

  Widget _buildSavedRecommendationCard(
    BuildContext context,
    Recommendation recommendation,
  ) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    (recommendation.outfit?.clothingItemIds ?? [])
                        .take(6) // Show first 6 items
                        .map(
                          (itemId) =>
                              _buildOutfitItem(itemId.toString(), context),
                        )
                        .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Доверие: ${recommendation.confidenceScore}%',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                if (recommendation.occasion?.isNotEmpty ?? false)
                  Text(
                    'Повод: ${recommendation.occasion}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (recommendation.isLiked ?? false)
                      const Icon(Icons.favorite, color: Colors.red, size: 16),
                    if (recommendation.isLiked ?? false)
                      const SizedBox(width: 4),
                    if ((recommendation.rating ?? 0) > 0) ...[
                      ...List.generate(5, (index) {
                        return Icon(
                          index < (recommendation.rating ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        );
                      }),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitItem(String itemId, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        'Эл. $itemId',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
      ),
    );
  }
}
