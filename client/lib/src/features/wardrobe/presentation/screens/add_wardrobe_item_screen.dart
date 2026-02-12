import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddWardrobeItemScreen extends ConsumerWidget {
  const AddWardrobeItemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Wardrobe Item'),
      ),
      body: const Center(
        child: Text('Add Wardrobe Item Screen'),
      ),
    );
  }
}