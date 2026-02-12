import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OutfitDetailsScreen extends ConsumerWidget {
  final String outfitId;

  const OutfitDetailsScreen({super.key, required this.outfitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Details'),
      ),
      body: Center(
        child: Text('Outfit Details Screen for ID: $outfitId'),
      ),
    );
  }
}