import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WardrobeItemDetailScreen extends ConsumerWidget {
  final String itemId;

  const WardrobeItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wardrobe Item Detail')),
      body: Center(child: Text('Wardrobe Item Detail Screen for ID: $itemId')),
    );
  }
}
