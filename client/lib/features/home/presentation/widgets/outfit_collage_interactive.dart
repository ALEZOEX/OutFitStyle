import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di.dart';
import '../../../../domain/entities/wardrobe_entity.dart' as domain;
import '../../../../ui/atoms/haptics.dart';

class OutfitCollageInteractive extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> lines; // outfitData['outfit']
  const OutfitCollageInteractive({super.key, required this.lines});

  @override
  ConsumerState<OutfitCollageInteractive> createState() =>
      _OutfitCollageInteractiveState();
}

class _OutfitCollageInteractiveState
    extends ConsumerState<OutfitCollageInteractive> {
  final Map<String, int> _idxByCategory =
      {}; // 0 = original, 1.. = alternatives

  @override
  Widget build(BuildContext context) {
    final wardrobe = ref.watch(wardrobeStreamProvider).valueOrNull ??
        const <domain.WardrobeEntry>[];

    final byCat = <String, List<domain.WardrobeEntry>>{};
    for (final w in wardrobe.where((w) => !w.isArchived)) {
      byCat.putIfAbsent(w.category, () => []).add(w);
    }

    final show = widget.lines.take(5).toList();

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;

        final positions = <Offset>[
          Offset(w * 0.08, h * 0.10),
          Offset(w * 0.42, h * 0.14),
          Offset(w * 0.18, h * 0.45),
          Offset(w * 0.52, h * 0.50),
          Offset(w * 0.30, h * 0.30),
        ];

        final rotations = [-0.06, 0.05, 0.03, -0.04, 0.02];

        return Stack(
          children: [
            for (var i = 0; i < show.length; i++)
              Positioned(
                left: positions[i].dx,
                top: positions[i].dy,
                child: Transform.rotate(
                  angle: rotations[i],
                  child: _SwipeCycleCard(
                    category: (show[i]['category'] ?? '').toString(),
                    original: show[i],
                    alternatives:
                        byCat[(show[i]['category'] ?? '').toString()] ??
                            const <domain.WardrobeEntry>[],
                    idx: _idxByCategory[
                            (show[i]['category'] ?? '').toString()] ??
                        0,
                    onIdxChanged: (cat, nextIdx) {
                      setState(() => _idxByCategory[cat] = nextIdx);
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SwipeCycleCard extends StatelessWidget {
  final String category;
  final Map<String, dynamic> original;
  final List<domain.WardrobeEntry> alternatives;

  final int idx;
  final void Function(String category, int idx) onIdxChanged;

  const _SwipeCycleCard({
    required this.category,
    required this.original,
    required this.alternatives,
    required this.idx,
    required this.onIdxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final choices = <_Choice>[
      _Choice.original(original),
      ...alternatives.map(_Choice.alt),
    ];

    final safeIdx = choices.isEmpty ? 0 : idx.clamp(0, choices.length - 1);
    final current =
        choices.isEmpty ? _Choice.original(original) : choices[safeIdx];

    // свайпы влево/вправо циклят варианты (локально, без API)
    return GestureDetector(
      onHorizontalDragEnd: (d) {
        if (choices.length <= 1) return;

        final v = d.primaryVelocity ?? 0;
        final next = v < -50
            ? _nextIdx(safeIdx, choices.length)
            : (v > 50 ? _prevIdx(safeIdx, choices.length) : safeIdx);
        if (next != safeIdx) {
          Haptics.selection();
          onIdxChanged(category, next);
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) {
          final slide = Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(anim);
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: _ChoiceCard(
          key: ValueKey(current.key),
          choice: current,
          hasAlts: choices.length > 1,
          category: category,
        ),
      ),
    );
  }

  int _nextIdx(int i, int len) => (i + 1) % len;
  int _prevIdx(int i, int len) => (i - 1 + len) % len;
}

class _ChoiceCard extends StatelessWidget {
  final _Choice choice;
  final bool hasAlts;
  final String category;

  const _ChoiceCard({
    super.key,
    required this.choice,
    required this.hasAlts,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChoiceMedia(choice: choice),
          const SizedBox(height: 8),
          Text(
            choice.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          if (hasAlts) ...[
            const SizedBox(height: 10),
            Text(
              'Свайп ⇄ заменить',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChoiceMedia extends StatelessWidget {
  final _Choice choice;
  const _ChoiceMedia({required this.choice});

  @override
  Widget build(BuildContext context) {
    // 1) локальный файл
    if (!kIsWeb && choice.localPath != null) {
      final f = File(choice.localPath!);
      if (f.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(f,
              height: 74, width: double.infinity, fit: BoxFit.cover),
        );
      }
    }

    // 2) иначе emoji (для исходных outfit lines обычно так)
    return Container(
      height: 74,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(choice.iconEmoji, style: const TextStyle(fontSize: 34)),
      ),
    );
  }
}

class _Choice {
  final String key;
  final String name;
  final String iconEmoji;
  final String? localPath;

  _Choice._({
    required this.key,
    required this.name,
    required this.iconEmoji,
    required this.localPath,
  });

  factory _Choice.original(Map<String, dynamic> m) => _Choice._(
        key: 'orig:${(m['category'] ?? '').toString()}',
        name: (m['name'] ?? 'Вещь').toString(),
        iconEmoji: (m['icon_emoji'] ?? '👕').toString(),
        localPath: null,
      );

  factory _Choice.alt(domain.WardrobeEntry w) => _Choice._(
        key: 'alt:${w.id}',
        name: w.name,
        iconEmoji: w.iconEmoji,
        localPath: w.localImagePath,
      );
}
