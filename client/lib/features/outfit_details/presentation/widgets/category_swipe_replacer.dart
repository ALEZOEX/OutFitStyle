import 'package:flutter/material.dart';
import '../../../../domain/entities/wardrobe_entity.dart' as domain;
import '../../../../ui/atoms/haptics.dart';

class CategorySwipeReplacer extends StatefulWidget {
  final String category;
  final Map<String, dynamic> original;
  final List<domain.WardrobeEntry> alternatives;

  final domain.WardrobeEntry? selected;
  final void Function(domain.WardrobeEntry? picked) onSelected;

  const CategorySwipeReplacer({
    super.key,
    required this.category,
    required this.original,
    required this.alternatives,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<CategorySwipeReplacer> createState() => _CategorySwipeReplacerState();
}

class _CategorySwipeReplacerState extends State<CategorySwipeReplacer> {
  late final PageController _pc;

  @override
  void initState() {
    super.initState();
    _pc = PageController(viewportFraction: 0.86);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <_PickPage>[
      _PickPage.original(
        icon: (widget.original['icon_emoji'] ?? '👕').toString(),
        name: (widget.original['name'] ?? 'Оригинал').toString(),
      ),
      ...widget.alternatives.map((w) => _PickPage.alt(w)),
    ];

    // если выбран replacement — подсветим (не обязательно прыгать по странице)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.category,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 112,
          child: PageView.builder(
            controller: _pc,
            itemCount: pages.length,
            onPageChanged: (i) {
              Haptics.selection();
              final p = pages[i];
              widget.onSelected(p.alt);
            },
            itemBuilder: (context, i) {
              final p = pages[i];
              final isSelected =
                  (p.alt?.id != null && widget.selected?.id == p.alt!.id) ||
                      (p.alt == null && widget.selected == null);

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Text(p.icon, style: const TextStyle(fontSize: 30)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        p.alt == null ? 'ORIG' : 'ALT',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.8)
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PickPage {
  final String icon;
  final String name;
  final domain.WardrobeEntry? alt;

  _PickPage._(this.icon, this.name, this.alt);

  factory _PickPage.original({required String icon, required String name}) =>
      _PickPage._(icon, name, null);

  factory _PickPage.alt(domain.WardrobeEntry w) => _PickPage._(w.iconEmoji, w.name, w);
}
