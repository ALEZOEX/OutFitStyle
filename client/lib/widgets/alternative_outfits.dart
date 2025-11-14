import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../theme/app_theme.dart';

class AlternativeOutfits extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (alternatives.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(
                Icons.grid_view,
                color: isDark ? AppTheme.primary : const Color(0xFF007bff),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Альтернативные варианты',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textPrimary : Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '${alternatives.length} варианта',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.textSecondary : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: alternatives.length,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _AlternativeCard(
                  outfit: alternatives[index],
                  isDark: isDark,
                  index: index,
                  onTap: onSelect != null
                      ? () => onSelect!(alternatives[index])
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AlternativeCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final confidence = (outfit.confidence * 100).toInt();
    
    // Различные цвета для каждой альтернативы
    final colors = [
      const Color(0xFF6366F1), // Индиго
      const Color(0xFF8B5CF6), // Фиолетовый
      const Color(0xFFEC4899), // Розовый
    ];
    final accentColor = colors[index % colors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? accentColor.withOpacity(0.3)
                : accentColor.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: accentColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '№${index + 2}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF28a745),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$confidence%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Items preview
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main items (first 3)
                    ...outfit.items.take(3).map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              item.iconEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppTheme.textPrimary
                                      : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    // More indicator
                    if (outfit.items.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+${outfit.items.length - 3} еще',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppTheme.textSecondary
                                : Colors.grey[600],
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Reason
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.backgroundDark
                            : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        outfit.reason,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppTheme.textSecondary
                              : Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Select button
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentColor,
                      side: BorderSide(color: accentColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Выбрать',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}