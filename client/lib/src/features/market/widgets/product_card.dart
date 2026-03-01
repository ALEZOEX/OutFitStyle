import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outfitstyle_client/src/features/market/data/models/product.dart';
import 'package:outfitstyle_client/src/features/market/data/models/cart.dart';
import 'package:outfitstyle_client/src/features/market/presentation/providers/cart_provider.dart';
import 'package:outfitstyle_client/src/features/market/presentation/providers/favorite_provider.dart';
import 'package:outfitstyle_client/src/theme/app_theme.dart';

/// Product card widget for grid display
class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteProvider).contains(product.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () => _navigateToDetail(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.imageUrls.firstOrNull ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),

                  // Out of stock overlay
                  if (!product.inStock)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Text(
                          'Нет в наличии',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                      color: isFavorite ? Colors.red : Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                      onPressed: () {
                        ref.read(favoriteProvider.notifier).toggleFavorite(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite ? 'Удалено из избранного' : 'Добавлено в избранное',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Product info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand
                  Text(
                    product.brand,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Name
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)} ₽',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),

                      // Add to cart button
                      if (product.inStock)
                        IconButton(
                          onPressed: () => _quickAddToCart(context, ref),
                          icon: const Icon(Icons.shopping_cart_outlined),
                          color: AppColors.primary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    // Navigate to product detail screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ProductDetailScreen(product: product),
    //   ),
    // );
  }

  Future<void> _quickAddToCart(BuildContext context, WidgetRef ref) async {
    // Если только один размер, добавляем сразу
    if (product.sizes.length == 1) {
      final request = AddToCartRequest(
        productId: product.id,
        quantity: 1,
        size: product.sizes.first,
        color: product.colors.firstOrNull,
      );
      
      try {
        await ref.read(cartProvider.notifier).addToCart(request);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Товар добавлен в корзину'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Показываем диалог выбора размера
      final selectedSize = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Выберите размер'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: product.sizes.map((size) {
              return ListTile(
                title: Text(size),
                onTap: () => Navigator.pop(context, size),
              );
            }).toList(),
          ),
        ),
      );

      if (selectedSize != null) {
        final request = AddToCartRequest(
          productId: product.id,
          quantity: 1,
          size: selectedSize,
          color: product.colors.firstOrNull,
        );

        try {
          await ref.read(cartProvider.notifier).addToCart(request);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Товар добавлен в корзину'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }
}
