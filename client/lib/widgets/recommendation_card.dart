import 'package:flutter/material.dart';

import '../models/recommendation_models.dart';
import '../utils/preferences_constants.dart';

class RecommendationCard extends StatelessWidget {
  final RecommendationRecord rec;
  final bool showActions;
  final VoidCallback? onRegenerate;

  const RecommendationCard({super.key, required this.rec, this.showActions = false, this.onRegenerate});

  @override
  Widget build(BuildContext context) {
    final lines = rec.outfitLines();
    final dateStr = rec.createdAt.toLocal().toString().split(' ')[0]; // Только дата YYYY-MM-DD
    final weather = rec.weatherData['weather_main'] ?? 'Clear';
    final temp = rec.weatherData['temperature'] ?? 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Дата + Погода + Избранное
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Образ на $dateStr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('$weather, ${temp.round()}°C', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                IconButton(
                  icon: Icon(rec.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                  onPressed: () {
                    // TODO: Реализовать toggleFavorite в провайдере и вызывать тут
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Items List
            ...lines.map((l) => _buildItemRow(context, l)),

            // Footer Actions (только для свежей)
            if (showActions) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRegenerate,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Пересобрать полностью'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, Map<String, dynamic> line) {
    final cat = translateCategory(line['category'] ?? ''); // Используем наш переводчик
    final item = line['item'] ?? {};
    final name = item['name'] ?? 'Вещь';
    final emoji = item['icon_emoji'] ?? '👕';
    final alts = (line['alternatives'] as List?) ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (showActions && alts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: Colors.blue),
              tooltip: 'Посмотреть альтернативы',
              onPressed: () => _showAlternatives(context, cat, alts),
            ),
        ],
      ),
    );
  }

  void _showAlternatives(BuildContext context, String title, List alts) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Альтернативы для: $title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            if (alts.isEmpty) const Text('Нет альтернатив :('),
            ...alts.map((a) {
              // В реальном API 'a' может содержать только ID и score. 
              // Чтобы показать имя, нужно либо иметь полные данные в alternatives, 
              // либо мы показываем "Альтернатива #N (score: ...)"
              // В Модуле 21 мы сохраняли только ID/score. 
              // Для MVP покажем score, но в идеале нужно расширить бэкенд (вернуть name).
              return ListTile(
                title: Text('Вариант (ID: ${a['id'].toString().substring(0, 4)}...)'), 
                subtitle: Text('Подходит на ${(a['score'] * 100).round()}%'),
                trailing: const Icon(Icons.check_circle_outline),
                onTap: () {
                  // TODO: Тут можно вызвать метод "заменить вещь в рекомендации" (сложно для MVP)
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}