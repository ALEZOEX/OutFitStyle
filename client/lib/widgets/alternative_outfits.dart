import'package:flutter/material.dart';
import '../models/outfit.dart';
import '../theme/app_theme.dart';

class AlternativeOutfits extends StatefulWidget {
  final List<OutfitSet> alternatives;
  final bool isDark;
  final Function(OutfitSet)? onSelect;

  const AlternativeOutfits({
    Key? key,
 required this.alternatives,
    required this.isDark,
    this.onSelect,
  }) : super(key: key);

  @override
  State<AlternativeOutfits> createState() => _AlternativeOutfitsState();
}

class _AlternativeOutfitsState extends State<AlternativeOutfits> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent:_controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AlternativeOutfits oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark!= widget.isDark) {
      if (widget.isDark) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alternatives.isEmpty) return const SizedBox.shrink();

    final displayAlternatives= widget.alternatives.take(3).toList();

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
                  gradient: widget.isDark
                      ? AppTheme.primaryGradient
                      : const LinearGradient(
                          colors: [Color(0xFF007bff), Color(0xFF0056b3)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (widget.isDark ? AppTheme.primary : const Color(0xFF007bff))
                              .withOpacity(0.3),
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
                      'Альтернативныеварианты',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? AppTheme.textPrimary : Colors.black87,
                      ),
                    ),
                    Text(
                      'Другие подходящие комплекты',
                      style: TextStyle(
fontSize:12,
                        color:
                            widget.isDark ? AppTheme.textSecondary : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Используем LayoutBuilder с Wrap для адаптивности
       LayoutBuilder(
          builder: (context, constraints) {
            // Вычисляем ширину для 3 колонок, но не меньше минимальной
            final itemWidth = (constraints.maxWidth > 700)
                ? (constraints.maxWidth - 32) / 3
                :(constraints.maxWidth > 460
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth > 230
                        ? constraints.maxWidth - 16
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
                    isDark:widget.isDark,
                    index: index,
                    onTap: widget.onSelect != null ? () => widget.onSelect!(outfit) : null,
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

// ===== ВНУТРЕННИЙ ВИДЖЕТ КАРТОЧКИ =====
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

class _AlternativeCardState extends State<_AlternativeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

@override
 void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
void dispose() {
   _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AlternativeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark) {
      if (widget.isDark) {
        _controller.forward();
      }else {
_controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context){
    final confidence = (widget.outfit.confidence * 100).toInt();
    final gradients = [
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
      [const Color(0xFF10B981), const Color(0xFF3B82F6)],
    ];
    final gradient = gradients[widget.index %gradients.length];

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDark
                ? [AppTheme.cardDark, AppTheme.cardDark.withOpacity(0.8)]
                : [Colors.white, const Color(0xFFFAFBFC)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: gradient[0].withOpacity(0.4), width: 2),
          boxShadow: [
           BoxShadow(
              color: gradient[0].withOpacity(0.2),
              blurRadius:15,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.08),
              blurRadius: 15,
              offset: const Offset(0,5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
_buildHeader(gradient, confidence),

              // Вместо Expanded используем Flexible для решенияпроблемы с рендербоксом
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(18),
                  child: _buildContent(gradient),
                ),
              ),

              // Button
              if (widget.onTap != null) _buildButton(gradient),
            ],
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
              color: gradient[0].withOpacity(0.3),
              blurRadius: 10,
              offset:const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
             border:
                  Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
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
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
      crossAxisAlignment:CrossAxisAlignment.start,
      children: [
        ...widget.outfit.items.take(3).map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                 decoration: BoxDecoration(
                    gradient: LinearGradient(colors:[
                      gradient[0].withOpacity(0.2),
                      gradient[1].withOpacity(0.1)
                    ]),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: gradient[0].withOpacity(0.3)),
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
                            color:widget.isDark
                                ? AppTheme.textPrimary
                                : Colors.black87),
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
                                : Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        if (widget.outfit.items.length > 3)
          Container(
            margin: const EdgeInsets.only(top: 4, bottom:8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: gradient[0].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(
              '+${widget.outfit.items.length -3} еще',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: gradient[0]),
            ),
          ),
        const SizedBox(height: 8),
        Container(
padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.isDark
                ? AppTheme.backgroundDark
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: gradient[0].withOpacity(0.2)),
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
                          :Colors.black54,
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
                color: gradient[0].withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Material(
          color: Colors.transparent,
          type: MaterialType.transparency,
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
}
