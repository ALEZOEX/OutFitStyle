import 'package:flutter/material.dart';
import '../services/wildberries_service.dart';
import '../theme/app_theme.dart';

class WildberriesProductCard extends StatelessWidget {
  final WildberriesProduct product;
  final bool isDark;
  final VoidCallback? onTap;

  const WildberriesProductCard({
    super.key,
    required this.product,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppTheme.primary.withValues(alpha: 0.3)
                : const Color(0xFF007bff).withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                image: product.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color:
                    isDark ? const Color(0xFF121212) : const Color(0xFFf8f9fa),
              ),
              child: product.imageUrl.isEmpty
                  ? Icon(
                      Icons.checkroom,
                      size: 50,
                      color: isDark ? AppTheme.textSecondary : Colors.grey,
                    )
                  : null,
            ),

            // Productinfo
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand
                  if (product.brand.isNotEmpty)
                    Text(
                      product.brand,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? AppTheme.primary : const Color(0xFF007bff),
                      ),
                    ),

                  if (product.brand.isNotEmpty) const SizedBox(height: 4),

                  // Product name
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppTheme.textPrimary : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Price and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.salePrice < product.price &&
                              product.salePrice > 0) ...[
                            Text(
                              '${product.salePrice ~/ 100} ₽',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.textPrimary
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              '${product.price ~/ 100} ₽',
                              style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                                color: isDark
                                    ? AppTheme.textSecondary
                                    : Colors.grey,
                              ),
                            ),
                          ] else ...[
                            Text(
                              '${product.price ~/ 100} ₽',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.textPrimary
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Rating
                      if (product.rating > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppTheme.textSecondary
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  if (product.feedbackCount > 0)
                    Text(
                      '${product.feedbackCount} отзывов',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.textSecondary : Colors.grey,
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
