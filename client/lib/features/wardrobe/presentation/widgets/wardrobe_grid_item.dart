import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../../../data/local/app_database.dart';
import '../../../../ui/atoms/skeleton.dart';

class WardrobeGridItem extends StatefulWidget {
  final WardrobeEntry entry;
  final VoidCallback onFavorite;
  final VoidCallback onArchive;
  final VoidCallback onWorn;

  const WardrobeGridItem({
    super.key,
    required this.entry,
    required this.onFavorite,
    required this.onArchive,
    required this.onWorn,
  });

  @override
  State<WardrobeGridItem> createState() => _WardrobeGridItemState();
}

class _WardrobeGridItemState extends State<WardrobeGridItem> with SingleTickerProviderStateMixin {
  late final AnimationController _likeCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 220));

  @override
  void dispose() {
    _likeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // позже: details с hero animation
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _ImageBlock(entry: e)),

                  // One-thumb-ish: действия внизу карточки
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Row(
                      children: [
                        _ActionPill(
                          icon: Icons.checkroom_rounded,
                          label: 'Надел',
                          onTap: widget.onWorn,
                        ),
                        const Spacer(),
                        _IconAction(
                          icon: e.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          active: e.isFavorite,
                          onTap: () async {
                            await _likeCtrl.forward(from: 0);
                            widget.onFavorite();
                          },
                          controller: _likeCtrl,
                        ),
                        const SizedBox(width: 8),
                        _IconAction(
                          icon: Icons.archive_outlined,
                          active: e.isArchived,
                          onTap: widget.onArchive,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${e.iconEmoji}  ${e.category}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Wear count: ${e.wearCount}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
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

class _ImageBlock extends StatelessWidget {
  final WardrobeEntry entry;
  const _ImageBlock({required this.entry});

  @override
  Widget build(BuildContext context) {
    final localPath = entry.localImagePath;

    if (!kIsWeb && localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    final url = entry.imageUrl;
    if (url == null || url.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Text(entry.iconEmoji, style: const TextStyle(fontSize: 56)),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) {
        final bh = entry.blurHash;
        if (bh != null && bh.isNotEmpty) {
          return BlurHash(hash: bh);
        }
        return const SkeletonBox(width: double.infinity, height: double.infinity);
      },
      errorWidget: (_, __, ___) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.broken_image_outlined)),
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
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final AnimationController? controller;

  const _IconAction({
    required this.icon,
    required this.active,
    required this.onTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.pinkAccent : Theme.of(context).colorScheme.onSurface;

    Widget child = Icon(icon, color: color);

    if (controller != null) {
      child = AnimatedBuilder(
        animation: controller!,
        builder: (_, __) {
          final t = controller!.value;
          final scale = 1.0 + (0.18 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0));
          return Transform.scale(scale: scale, child: child);
        },
      );
    }

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
        child: Center(child: child),
      ),
    );
  }
}