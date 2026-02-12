import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecommendationDetailScreen extends ConsumerWidget {
  final String recommendationId;

  const RecommendationDetailScreen({super.key, required this.recommendationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendation Detail'),
      ),
      body: Center(
        child: Text('Recommendation Detail Screen for ID: $recommendationId'),
      ),
    );
  }
}