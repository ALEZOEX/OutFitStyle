import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/domain_exports.dart';
import '../../../presentation/providers/presentation_providers_exports.dart';
import '../presentation/controllers/recommendation_state_notifier.dart';

class RecommendationHistoryScreen extends StatefulWidget {
  const RecommendationHistoryScreen({super.key});

  @override
  State<RecommendationHistoryScreen> createState() => _RecommendationHistoryScreenState();
}

class _RecommendationHistoryScreenState extends State<RecommendationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final ref = ProviderScope.containerOf(context, listen: false);
        final userId = ref.read(userIdProvider) ?? '';
        ref.read(recommendationStateNotifierProvider.notifier).loadRecommendationHistory(userId: userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final historyState = ref.watch(recommendationStateNotifierProvider);

        return Scaffold(
          appBar: AppBar(title: const Text('История рекомендаций')),
          body: historyState.isLoading
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
                  final recommendation = historyState.historyRecommendations[index];
                  return _buildHistoryItem(context, recommendation);
                },
              ),
        );
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, Recommendation recommendation) {
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
                    'Рекомендация от ${recommendation.createdAt?.day ?? '—'}.${recommendation.createdAt?.month ?? '—'}.${recommendation.createdAt?.year ?? '—'}',
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
            Text('Доверие: ${recommendation.confidenceScore}%'),
            if (recommendation.occasion?.isNotEmpty ?? false)
              Text('Повод: ${recommendation.occasion}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: (recommendation.outfit?.clothingItemIds ?? [])
                  .take(6)
                  .map((id) => _buildOutfitItem(id.toString(), context))
                  .toList(),
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
