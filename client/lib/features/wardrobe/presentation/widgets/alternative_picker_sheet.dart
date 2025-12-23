import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/app_database.dart';
import '../../../../domain/entities/alt_pick.dart';
import '../../../wardrobe/presentation/wardrobe_controller.dart';

class AlternativePickerSheet extends ConsumerWidget {
  final String category;
  const AlternativePickerSheet({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardrobeStream = ref.watch(wardrobeStreamProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Заменить ($category)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: wardrobeStream.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Ошибка: $e')),
                data: (items) {
                  final filtered = items.where((e) => e.category == category && !e.isArchived).toList();
                  if (filtered.isEmpty) {
                    return const Center(child: Text('Нет альтернатив в гардеробе'));
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final e = filtered[i];
                      return ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        tileColor: Theme.of(context).colorScheme.surface,
                        leading: Text(e.iconEmoji, style: const TextStyle(fontSize: 26)),
                        title: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('Wear: ${e.wearCount}'),
                        onTap: () => Navigator.pop(context, AltPick(e.id, e.name)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}