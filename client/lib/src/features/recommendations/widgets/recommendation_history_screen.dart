import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/domain_exports.dart';
import '../../../presentation/providers/presentation_providers_exports.dart';
import '../presentation/controllers/recommendation_state_notifier.dart';

class RecommendationHistoryScreen extends ConsumerWidget {
  const RecommendationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider) ?? '';

    // Load history when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(recommendationStateNotifierProvider.notifier)
          .loadRecommendationHistory(userId: userId);
    });

    final historyState = ref.watch(recommendationStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('История рекомендаций')),
      body:
          historyState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : historyState.errorMessage != null
              ? Center(child: Text('Ошибка: ${historyState.errorMessage}'))
              : historyState.historyRecommendations.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'История рекомендаций пуста',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: historyState.historyRecommendations.length,
                itemBuilder: (context, index) {
                  final recommendation =
                      historyState.historyRecommendations[index];
                  return _buildHistoryItem(context, recommendation);
                },
              ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    Recommendation recommendation,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Рекомендация от ${recommendation.createdAt?.day}.${recommendation.createdAt?.month}.${recommendation.createdAt?.year}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if ((recommendation.rating ?? 0) > 0)
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (recommendation.rating ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Доверие модели: ${recommendation.confidenceScore}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Повод: ${(recommendation.occasion?.isNotEmpty ?? false) ? recommendation.occasion : 'Общий'}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Активность: ${(recommendation.activity?.isNotEmpty ?? false) ? recommendation.activity : 'Общая'}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  (recommendation.outfit?.clothingItemIds ?? [])
                      .take(4) // Show only first 4 items
                      .map(
                        (itemId) =>
                            _buildOutfitItem(itemId.toString(), context),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (recommendation.isUsed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Использовано',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                const SizedBox(width: 8),
                if (recommendation.isFavorite)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Избранное',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitItem(String itemId, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checkroom, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text('Элемент $itemId', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
