import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../theme/app_theme.dart';

class AlternativeOutfits extends StatelessWidget {
  final List<OutfitSet> alternatives;
  final bool isDark;
  final Function(OutfitSet)? onSelect;

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
                      ? AppTheme.primaryGradient
                      : const LinearGradient(
                          colors: [Color(0xFF007bff), Color(0xFF0056b3)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isDark ? AppTheme.primary : const Color(0xFF007bff))
                              .withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.grid_view_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Альтернативные варианты',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textPrimary : Colors.black87,
                      ),
                    ),
                    Text(
                      'Другие подходящие комплекты',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark ? AppTheme.textSecondary : Colors.grey[600],
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
            final itemWidth = (constraints.maxWidth > 700)
                ? (constraints.maxWidth - 32) / 3
                : (constraints.maxWidth > 480
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth);

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDark
                  ? [
                      AppTheme.cardDark,
                      AppTheme.cardDark.withValues(alpha: 0.8)
                    ]
                  : [Colors.white, const Color(0xFFFAFBFC)],
            ),
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: gradient[0].withValues(alpha: 0.4), width: 2),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: 0.2),
                blurRadius: _isHovered ? 25 : 15,
                offset: Offset(0, _isHovered ? 10 : 6),
                spreadRadius: _isHovered ? 2 : 0,
              ),
              BoxShadow(
                color:
                    Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.05),
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
                _buildHeader(gradient, confidence),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: _buildContent(gradient),
                ),
                if (widget.onTap != null) _buildButton(gradient),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<Color> gradient, int confidence) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient),
        boxShadow: [
          BoxShadow(
              color: gradient[0].withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Text(
              '№${widget.index + 2}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2))
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
                      fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<Color> gradient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Важно!
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
                    gradient: LinearGradient(colors: [
                      gradient[0].withValues(alpha: 0.2),
                      gradient[1].withValues(alpha: 0.1)
                    ]),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: gradient[0].withValues(alpha: 0.3)),
                  ),
                  child: Center(
                      child: Text(item.iconEmoji,
                          style: const TextStyle(fontSize: 20))),
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
                          color: widget.isDark
                              ? AppTheme.textPrimary
                              : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getCategoryName(item.category),
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.isDark
                              ? AppTheme.textSecondary
                              : Colors.grey[600],
                        ),
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
            border: Border.all(color: gradient[0].withValues(alpha: 0.2)),
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
                      color: widget.isDark
                          ? AppTheme.textSecondary
                          : Colors.black54,
                      fontWeight: FontWeight.w500),
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
                color: gradient[0].withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4))
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
                  Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Выбрать',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5),
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
