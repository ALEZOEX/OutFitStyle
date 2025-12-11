import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../theme/app_theme.dart';
import '../utils/item_translator.dart';

class AlternativeOutfits extends StatelessWidget {
  final List<OutfitSet> alternatives;
  final bool isDark;
  final void Function(OutfitSet)? onSelect;

  const AlternativeOutfits({
    super.key,
    required this.alternatives,
    required this.isDark,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (alternatives.isEmpty) return const SizedBox.shrink();

    final displayAlternatives = alternatives.take(3).toList();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок секции
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppTheme.primaryGradientDark
                      : AppTheme.primaryGradientLight,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppTheme.primary : AppTheme.primary)
                          .withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Альтернативные варианты',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Другие подходящие комплекты',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Адаптивная сетка с карточками
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final itemWidth = maxWidth > 700
                ? (maxWidth - 32) / 3
                : maxWidth > 480
                ? (maxWidth - 16) / 2
                : maxWidth;

            return Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: displayAlternatives.asMap().entries.map((entry) {
                final index = entry.key;
                final outfit = entry.value;
                return SizedBox(
                  width: itemWidth,
                  child: _AlternativeCard(
                    outfit: outfit,
                    isDark: isDark,
                    index: index,
                    onTap: onSelect != null ? () => onSelect!(outfit) : null,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _AlternativeCard extends StatefulWidget {
  final OutfitSet outfit;
  final bool isDark;
  final int index;
  final VoidCallback? onTap;

  const _AlternativeCard({
    required this.outfit,
    required this.isDark,
    required this.index,
    this.onTap,
  });

  @override
  State<_AlternativeCard> createState() => _AlternativeCardState();
}

class _AlternativeCardState extends State<_AlternativeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'outerwear':
        return 'Верхняя одежда';
      case 'upper':
        return 'Верх';
      case 'lower':
        return 'Низ';
      case 'footwear':
        return 'Обувь';
      case 'accessories':
        return 'Аксессуары';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidence = (widget.outfit.confidence * 100).toInt();
    final gradients = [
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
      [const Color(0xFF10B981), const Color(0xFF3B82F6)],
    ];
    final gradient = gradients[widget.index % gradients.length];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: _isHovered ? 1.03 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isDark
                    ? [AppTheme.cardDark, AppTheme.cardDark.withOpacity(0.8)]
                    : [Colors.white, const Color(0xFFFAFBFC)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: gradient[0].withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.2),
                  blurRadius: _isHovered ? 25 : 15,
                  offset: Offset(0, _isHovered ? 10 : 6),
                  spreadRadius: _isHovered ? 2 : 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(
                    widget.isDark ? 0.2 : 0.05,
                  ),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(theme, gradient, confidence),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: _buildContent(theme, gradient),
                  ),
                  if (widget.onTap != null) _buildButton(gradient),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      ThemeData theme, List<Color> gradient, int confidence) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Text(
              '№${widget.index + 2}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology, size: 14, color: gradient[0]),
                const SizedBox(width: 4),
                Text(
                  '$confidence%',
                  style: TextStyle(
                    color: gradient[0],
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, List<Color> gradient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...widget.outfit.items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradient[0].withOpacity(0.2),
                        gradient[1].withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: gradient[0].withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.iconEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              ItemTranslator.translateAnyField(item.category, 'category'),
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Color(int.parse(item.getTagColor().substring(1), radix: 16) + 0xFF000000),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.getSourceDisplayText().length > 3
                                ? '${item.getSourceDisplayText().substring(0, 3)}..'
                                : item.getSourceDisplayText(),
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF121212)
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: gradient[0].withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: gradient[0]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.outfit.reason,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton(List<Color> gradient) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Выбрать',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}