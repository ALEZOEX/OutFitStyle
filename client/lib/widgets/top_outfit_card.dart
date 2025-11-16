import'package:flutter/material.dart';
import '../models/outfit.dart';
import '../theme/app_theme.dart';
// ... existing code ...
import '../models/recommendation.dart';

class TopOutfitCard extends StatefulWidget {
  final OutfitSet outfit;
  final bool isDark;
  final VoidCallback? onSelect;

  const TopOutfitCard({
    Key? key,
    required this.outfit,
    required this.isDark,
    this.onSelect,
  }) : super(key: key);

@override
  State<TopOutfitCard> createState() => _TopOutfitCardState();
}

class _TopOutfitCardState extends State<TopOutfitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
 }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confidence = (widget.outfit.confidence * 100).toInt();

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
     onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onSelect,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: widget.isDark
? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.cardDark,
                      Color.fromRGBO(15, 23, 42, 0.6),
                      AppTheme.primary.withOpacity(0.1),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                   end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFFF8F9FA),
                      Color.fromRGBO(0, 123, 255, 0.05),
                    ],
                  ),
            boxShadow: [
              BoxShadow(
                color: widget.isDark
                    ?Color.fromRGBO(99, 102, 241, 0.3)
                    : Color.fromRGBO(0, 123, 255, 0.2),
                blurRadius: 30,
                offset: const Offset(0, 12),
                spreadRadius: -5,
              ),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, widget.isDark ? 0.3 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.isDark
                            ? Color.fromRGBO(99, 102, 241, 0.1)
                            : Color.fromRGBO(0, 123, 255, 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with crown
                  _buildHeader(confidence),

                  // Main outfit items
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reason with icon
                        _buildReasonBadge(),

                        const SizedBox(height: 24),

                        // Outfit items
                       _buildOutfitItemsList(),

                        const SizedBox(height: 24),

                        // Confidence visualization
                        _buildConfidenceBar(confidence),

                        const SizedBox(height: 24),

                        // Select button
                        if (widget.onSelect != null) _buildSelectButton(),
                      ],
                    ),
                  ),
               ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int confidence) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: widget.isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary,
                  AppTheme.secondary,
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF007bff),
                  const Color(0xFF0056b3),
                  const Color(0xFF6366F1),
                ],
              ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isDark
                ? Color.fromRGBO(99, 102, 241, 0.3)
                : Color.fromRGBO(0, 123, 255, 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Crown iconwith glow
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius:15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          // Text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOP ВЫБОР',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height:3),
                Text(
                  'Идеально подобрано для вас',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // AI Badge with animation
         TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 18,
                        color: widget.isDark? AppTheme.primary
                            : const Color(0xFF007bff),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$confidence%',
                        style: TextStyle(
                          color: widget.isDark
                              ? AppTheme.primary
                              : const Color(0xFF007bff),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReasonBadge() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
color: widget.isDark
            ? AppTheme.primary.withOpacity(0.12)
            : const Color(0xFF007bff).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isDark
              ? Color.fromRGBO(99, 102, 241, 0.3)
              : Color.fromRGBO(0, 123, 255, 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
             color: widget.isDark
                  ? Color.fromRGBO(99, 102, 241, 0.2)
                  : const Color(0xFF007bff).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lightbulb,
              size: 18,
color: widget.isDark
                  ? AppTheme.primary
                  : const Color(0xFF007bff),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.outfit.reason,
              style: TextStyle(
                fontSize: 14,
               color: widget.isDark
                    ? AppTheme.textPrimary
                    : Colors.black87,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitItemsList() {
    final categoryOrder= [
      'outerwear',
      'upper',
      'lower',
      'footwear',
      'accessories'
    ];

    final displayItems = <ClothingItem>[];
    for (var category in categoryOrder) {
      final item = widget.outfit.getItemByCategory(category);
      if (item !=null) {
        displayItems.add(item);
      }
    }

    return Column(
      children: displayItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == displayItems.length - 1;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
             offset: Offset(20 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: Column(
                  children: [
                    _buildOutfitItemRow(item, index),
                    if (!isLast) _buildConnector(),
                  ],
                ),
              ),
            );
         },
        );
      }).toList(),
    );
  }

  Widget _buildOutfitItemRow(ClothingItem item, int index) {
    final categoryColor = _getCategoryColor(item.category);
    final mlScore = item.mlScore ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: widget.isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.backgroundDark,
                  AppTheme.backgroundDark.withOpacity(0.5),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFAFBFC),
                  Colors.white,
                ],
              ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon with category color
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  categoryColor.withOpacity(0.2),
                  categoryColor.withOpacity(0.1),
                ],
              ),
borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: categoryColor.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                item.iconEmoji,
                style: const TextStyle(fontSize: 34),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: widget.isDark
                        ? AppTheme.textPrimary
                        : Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: categoryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getCategoryName(item.category),
                    style: TextStyle(
                      fontSize: 12,
                      color: categoryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ML Score with circular progress
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: mlScore),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 5,
                      backgroundColor: widget.isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(mlScore),
                      ),
                    );
                 },
                ),
                // Percentage text
                Text(
                  '${(mlScore * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(mlScore),
                  ),
                ),
              ],
            ),
          ),
        ],
),
    );
  }

  Widget _buildConnector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 30),
          Container(
            width: 3,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: widget.isDark
                    ? [
                        AppTheme.primary.withOpacity(0.5),
                        AppTheme.primary.withOpacity(0.1),
                      ]
                    : [
                        const Color(0xFF007bff).withOpacity(0.4),
                        Color.fromRGBO(0, 123, 255, 0.1),
                      ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isDark
                      ? [
                          Color.fromRGBO(99, 102, 241, 0.3),
                          Colors.transparent,
                        ]
                      : [
                          Color.fromRGBO(0, 123, 255, 0.2),
                          Colors.transparent,
                        ],
),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar(int confidence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AI Уверенность',
style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.isDark
                    ? AppTheme.textSecondary
                    : Colors.grey[700],
              ),
            ),
            Text(
              _getConfidenceLabel(confidence),
              style: TextStyle(
fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(confidence / 100),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
           children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: confidence / 100),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getScoreColor(confidence / 100),
                            _getScoreColor(confidence / 100).withOpacity(0.7),
                          ],
                        ),
                       borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _getScoreColor(confidence / 100)
                                .withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                   ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.isDark
            ? AppTheme.primaryGradient
            : const LinearGradient(
                colors: [Color(0xFF007bff), Color(0xFF0056b3)],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.isDark
                ? AppTheme.primary.withOpacity(0.4)
                : Color.fromRGBO(0, 123, 255, 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onSelect,
          borderRadius: BorderRadius.circular(16),
          child:Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  'Выбрать этот комплект',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
switch (category.toLowerCase()) {
      case 'outerwear':
        return const Color(0xFF6366F1); // Индиго
      case 'upper':
        return const Color(0xFF8B5CF6); // Фиолетовый
      case 'lower':
        return const Color(0xFF10B981); // Зеленый
      case 'footwear':
        return const Color(0xFFF59E0B); // Оранжевый
      case 'accessories':
        return const Color(0xFFEC4899); // Розовый
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 0.9) return const Color(0xFF10B981); // Зеленый
    if (score >= 0.8) return const Color(0xFF3B82F6); // Синий
    if (score >= 0.7) return const Color(0xFFF59E0B); // Оранжевый
    return const Color(0xFFEF4444); // Красный
  }

  String _getConfidenceLabel(int confidence) {
    if (confidence >= 90) return 'Превосходно';
    if (confidence >= 80) return 'Отлично';
    if (confidence >= 70) return 'Хорошо';
    return 'Приемлемо';
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