import 'package:flutter/material.dart';
import '../../../../domain/entities/recommendation.dart';

class RecommendationHistoryItem extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback? onTap;

  const RecommendationHistoryItem({
    Key? key,
    required this.recommendation,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          'Рекомендация ${recommendation.createdAt?.day}.${recommendation.createdAt?.month}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          recommendation.tags.isNotEmpty
              ? recommendation.tags.join(', ')
              : 'Стильный образ',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          recommendation.isLiked ? Icons.favorite : Icons.favorite_border,
          color: recommendation.isLiked ? Colors.red : null,
        ),
        onTap: onTap,
      ),
    );
  }
}
