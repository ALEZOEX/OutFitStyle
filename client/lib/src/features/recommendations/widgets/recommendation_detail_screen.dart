// ignore_for_file: dead_null_aware_expression
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/recommendation.dart';

class RecommendationDetailScreen extends ConsumerWidget {
  final Recommendation recommendation;

  const RecommendationDetailScreen({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали рекомендации'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Погодные условия',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (recommendation.weather != null)
                      _buildWeatherInfoFromObject(
                          'Погода', recommendation.weather),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Outfit section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Рекомендуемый наряд',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      (recommendation.outfit?.name?.isNotEmpty ?? false)
                          ? (recommendation.outfit?.name ?? '')
                          : 'Наряд #${(recommendation.outfit?.id?.toString() ?? '').length > 8 ? (recommendation.outfit?.id?.toString() ?? '').substring(0, 8) : (recommendation.outfit?.id?.toString() ?? '')}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recommendation.outfit?.description ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Outfit items
                    Text(
                      'Элементы наряда:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (recommendation.outfit?.clothingItemIds ?? [])
                          .map((itemId) => Chip(
                                label: Text('Элемент $itemId'),
                                avatar: const Icon(Icons.checkroom, size: 16),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Recommendation details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Детали рекомендации',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Тип рекомендации',
                        (recommendation.type?.displayName ?? '')),
                    _buildDetailRow(
                        'Источник', (recommendation.source?.displayName ?? '')),
                    _buildDetailRow(
                        'Доверие модели', '${recommendation.confidenceScore}%'),
                    _buildDetailRow('Дата создания',
                        recommendation.createdAt != null ? recommendation.createdAt.toString() : 'N/A'),
                    _buildDetailRow(
                        'Теги', (recommendation.tags ?? []).join(', ')),
                    _buildDetailRow(
                        'Случаи',
                        (recommendation.outfit != null ? (recommendation.outfit!.occasions ?? []) : [])
                            .map((o) => o.displayName)
                            .join(', ')),
                    _buildDetailRow(
                        'Погодные условия',
                        (recommendation.outfit != null ? (recommendation.outfit!.weatherConditions ?? []) : [])
                            .map((w) => w.displayName)
                            .join(', ')),
                    _buildDetailRow(
                        'Сезоны',
                        (recommendation.outfit?.seasons ?? [])
                            .map((s) => s.displayName)
                            .join(', ')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfoFromObject(String label, Object? weatherObj) {
    String weatherStr = weatherObj?.toString() ?? 'N/A';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(weatherStr),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(value, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
