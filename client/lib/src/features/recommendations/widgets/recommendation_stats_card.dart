// ignore_for_file: dead_null_aware_expression
import 'package:flutter/material.dart';

class RecommendationStatsCard extends StatelessWidget {
  const RecommendationStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder stats
    const totalRecommendations = 0;
    const likedCount = 0;
    const savedCount = 0;
    const avgConfidence = 0;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Статистика рекомендаций',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Всего',
                  totalRecommendations.toString(),
                  Icons.list,
                ),
                _buildStatItem(
                  'Нравится',
                  likedCount.toString(),
                  Icons.favorite,
                ),
                _buildStatItem(
                  'Сохранено',
                  savedCount.toString(),
                  Icons.bookmark,
                ),
                _buildStatItem('Доверие', '$avgConfidence%', Icons.trending_up),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
