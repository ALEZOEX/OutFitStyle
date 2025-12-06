import'package:flutter/material.dart';
import '../models/outfit.dart';
import '../theme/app_theme.dart';

class TopOutfitCard extends StatelessWidget {
  final OutfitSet outfit;
  final bool isDark;
  final Function(OutfitSet)? onSelect;

  const TopOutfitCard({
    super.key,
    required this.outfit,
    required this.isDark,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? AppTheme.primaryGradientDark // Используем dark-градиент для темной темы
                        : AppTheme.primaryGradientLight, // Используем light-градиент для светлой темы
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark
                                ? AppTheme.primary
                                :AppTheme.primary)
                            .withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                 ),
                  child: const Icon(Icons.checkroom,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Основной комплект',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.textPrimary : Colors.black87,
                        ),
                      ),
                      Text(
                        'Рекомендован AI с уверенностью ${outfit.confidence * 100}%',
                        style: TextStyle(
fontSize: 12,
                          color: isDark
                              ? AppTheme.textSecondary
                              : Colors.grey[600],
),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Items
            ...outfit.items.map((item){
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                     width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? AppTheme.cardGradientDark // Используем dark-градиент для элементов в темной теме
                            : AppTheme.cardGradient, // Используем light-градиент для элементов в светлой теме
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3)),
                     ),
                      child: Center(
                          child: Text(item.iconEmoji,
                              style: const TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
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
                              fontSize: 12,
                              color: isDark
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

            const SizedBox(height: 20),

            // Reason
            Container(
              padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
                color:
                    isDark ? AppTheme.backgroundDark : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
             ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                   child: Text(
                      outfit.reason,
                      style: TextStyle(
                          fontSize: 12,
                          color:
                             isDark ? AppTheme.textSecondary : Colors.black54,
                          fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
],
              ),
            ),

            if (onSelect!= null) ...[
              const SizedBox(height: 20),
ElevatedButton.icon(
                onPressed: () => onSelect!(outfit),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Выбрать'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
         ],
        ),
      ),
    );
  }

  //Исправлена опечатка: Stringcategory -> Stringcategory
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