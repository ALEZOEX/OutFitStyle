import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/skeleton.dart';
import '../../../ui/atoms/like_burst.dart';
import 'wardrobe_controller.dart';

class WardrobeGridItem extends ConsumerWidget {
  final WardrobeEntry entry;
  final VoidCallback? onFavorite;
  final VoidCallback? onArchive;
  final VoidCallback? onWorn;
  const WardrobeGridItem({
    super.key,
    required this.entry,
    this.onFavorite,
    this.onArchive,
    this.onWorn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(wardrobeControllerProvider.notifier);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          // Позже: детали с hero animation
        },
        child: Stack(
          children: [
            // Изображение или иконка
            Positioned.fill(
              child: entry.localImagePath != null
                  ? Image.file(
                      File(entry.localImagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Center(child: Text(entry.iconEmoji, style: const TextStyle(fontSize: 56))),
                      ),
                    )
                  : entry.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: entry.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Center(child: Text(entry.iconEmoji, style: const TextStyle(fontSize: 56))),
                          ),
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Center(child: Text(entry.iconEmoji, style: const TextStyle(fontSize: 56))),
                        ),
            ),

            // Угол с иконкой категории
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.iconEmoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            // Нижняя панель действий
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Row(
                children: [
                  _ActionPill(
                    icon: Icons.checkroom_rounded,
                    label: 'Надел',
                    onTap: () async {
                      Haptics.success();
                      await controller.markWorn(entry);
                      onWorn?.call();
                    },
                  ),
                  const Spacer(),
                  _IconAction(
                    icon: entry.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    active: entry.isFavorite,
                    onTap: () async {
                      Haptics.selection();
                      await controller.toggleFavorite(entry);
                      onFavorite?.call();
                    },
                  ),
                  const SizedBox(width: 8),
                  _IconAction(
                    icon: entry.isArchived ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    active: entry.isArchived,
                    onTap: () async {
                      Haptics.light();
                      await controller.toggleArchived(entry);
                      onArchive?.call();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionPill({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}

class _IconAction extends ConsumerWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _IconAction({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = active ? Colors.pinkAccent : Theme.of(context).colorScheme.onSurface;

    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Icon(icon, color: color),
        ),
      ),
    );
  }
}