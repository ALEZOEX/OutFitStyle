import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/domain_exports.dart';

class RecommendationFeedbackDialog extends ConsumerStatefulWidget {
  final Recommendation recommendation;
  final String userId;
  final Function(RecommendationFeedback feedback) onFeedbackSubmitted;

  const RecommendationFeedbackDialog({
    super.key,
    required this.recommendation,
    required this.userId,
    required this.onFeedbackSubmitted,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RecommendationFeedbackDialogState();
}

class _RecommendationFeedbackDialogState
    extends ConsumerState<RecommendationFeedbackDialog> {
  int _rating = 0;
  String _comment = '';
  final List<String> _likedItems = [];
  final List<String> _dislikedItems = [];
  bool _wouldReuse = false;
  bool _wouldRecommend = false;
  final List<String> _improvementSuggestions = [];
  FeedbackCategory _category = FeedbackCategory.general;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Оцените рекомендацию'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating
            const Text('Оценка:'),
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = index + 1),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Category selection
            const Text('Категория отзыва:'),
            DropdownButton<FeedbackCategory>(
              value: _category,
              onChanged: (FeedbackCategory? newValue) {
                if (newValue != null) {
                  setState(() {
                    _category = newValue;
                  });
                }
              },
              items: FeedbackCategory.values
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.displayName),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Comment
            TextField(
              decoration: const InputDecoration(
                labelText: 'Комментарий',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => _comment = value,
            ),
            const SizedBox(height: 16),

            // Would reuse
            CheckboxListTile(
              title: const Text('Хотели бы использовать снова'),
              value: _wouldReuse,
              onChanged: (bool? value) {
                setState(() {
                  _wouldReuse = value ?? false;
                });
              },
            ),

            // Would recommend
            CheckboxListTile(
              title: const Text('Порекомендовали бы другим'),
              value: _wouldRecommend,
              onChanged: (bool? value) {
                setState(() {
                  _wouldRecommend = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _submitFeedback,
          child: const Text('Отправить'),
        ),
      ],
    );
  }

  void _submitFeedback() {
    final feedback = RecommendationFeedback(
      userId: widget.userId,
      recommendationId: widget.recommendation.id?.toString() ?? '',
      rating: _rating,
      comment: _comment,
      likedItems: _likedItems,
      dislikedItems: _dislikedItems,
      wouldReuse: _wouldReuse,
      wouldRecommend: _wouldRecommend,
      improvementSuggestions: _improvementSuggestions,
      category: _category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onFeedbackSubmitted(feedback);
    Navigator.of(context).pop();
  }
}
