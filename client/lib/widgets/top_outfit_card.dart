import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../models/recommendation.dart';
import '../theme/app_theme.dart';

class TopOutfitCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final confidence = (outfit.confidence * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.cardDark,
                  AppTheme.cardDark.withOpacity(0.8),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppTheme.primary.withOpacity(0.5)
              : const Color(0xFF007bff).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF007bff).withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppTheme.primaryGradient
                  : const LinearGradient(
                      colors: [Color(0xFF007bff), Color(0xFF0056b3)],
                    ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.stars,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOP РЕКОМЕНДАЦИЯ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Лучший выбор для вас',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 16,
                        color:
                            isDark ? AppTheme.primary : const Color(0xFF007bff),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$confidence%',
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.primary
                              : const Color(0xFF007bff),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main outfit items
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reason
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.primary.withOpacity(0.1)
                        : const Color(0xFF007bff).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color:
                            isDark ? AppTheme.primary : const Color(0xFF007bff),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          outfit.reason,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                isDark ? AppTheme.textPrimary : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Outfit items grid
                _buildOutfitItemsGrid(),

                const SizedBox(height: 24),

                // Select button
                if (onSelect != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? AppTheme.primary : const Color(0xFF007bff),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: isDark ? 0 : 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Выбрать этот комплект',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitItemsGrid() {
    // Порядок категорий для отображения
    final categoryOrder = [
      'outerwear',
      'upper',
      'lower',
      'footwear',
      'accessories'
    ];

    final displayItems = <ClothingItem>[];
    for (var category in categoryOrder) {
      final item = outfit.getItemByCategory(category);
      if (item != null) {
        displayItems.add(item);
      }
    }

    return Column(
      children: displayItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == displayItems.length - 1;

        return Column(
          children: [
            _buildOutfitItemRow(item),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(width: 32),
                    Container(
                      width: 2,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                              ? [
                                  AppTheme.primary.withOpacity(0.3),
                                  AppTheme.primary.withOpacity(0.1),
                                ]
                              : [
                                  const Color(0xFF007bff).withOpacity(0.3),
                                  const Color(0xFF007bff).withOpacity(0.1),
                                ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildOutfitItemRow(ClothingItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.primary.withOpacity(0.2) : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.primary.withOpacity(0.1)
                  : const Color(0xFF007bff).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item.iconEmoji,
                style: const TextStyle(fontSize: 32),
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
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textPrimary : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCategoryName(item.category),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.textSecondary : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // ML Score
          if (item.mlScore != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF28a745), Color(0xFF20883b)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(item.mlScore! * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
        ],
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
