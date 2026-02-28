import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/market_provider.dart';
import '../data/market_api_client.dart';
import '../data/models/product.dart';

/// Market screen - products catalog
class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  String? _selectedCategory;
  String? _searchQuery;
  final _searchController = TextEditingController();
  final _importUrlController = TextEditingController();
  final _marketApiClient = MarketApiClient(baseUrl: 'http://localhost:8001');

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    ref.read(productsProvider.notifier).loadProducts(
      category: _selectedCategory,
      search: _searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _importUrlController.dispose();
    super.dispose();
  }

  /// Show import product dialog
  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download_outlined),
            SizedBox(width: 8),
            Text('Импорт товара'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Вставьте ссылку на товар с Wildberries или Ozon:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _importUrlController,
              decoration: InputDecoration(
                labelText: 'Ссылка на WB/Ozon',
                hintText: 'https://www.wildberries.ru/... или https://www.ozon.ru/...',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Импортировать',
                  onPressed: () => _importProduct(_importUrlController.text),
                ),
              ),
              maxLines: 2,
              minLines: 1,
            ),
            const SizedBox(height: 8),
            const Text(
              'Поддерживаются ссылки вида:\n'
              '• https://www.wildberries.ru/catalog/...\n'
              '• https://www.ozon.ru/product/...\n'
              '• wb/12345678\n'
              '• oz/12345678',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton.icon(
            onPressed: () => _importProduct(_importUrlController.text),
            icon: const Icon(Icons.download),
            label: const Text('Импортировать'),
          ),
        ],
      ),
    );
  }

  /// Import product from URL
  Future<void> _importProduct(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите URL товара')),
      );
      return;
    }

    // Close keyboard
    Navigator.pop(context);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await _marketApiClient.importProductFromUrl(url);
      
      // Close loading
      if (mounted) Navigator.pop(context);

      final status = result['status'] as String;
      final message = result['message'] as String;
      final remainingImports = result['remaining_imports'] as int?;

      if (status == 'success' && result['product'] != null) {
        final productData = result['product'] as Map<String, dynamic>;
        final product = Product.fromJson(productData);

        // Show success dialog with product preview
        if (mounted) {
          _showImportSuccessDialog(product, remainingImports);
          // Reload products
          _loadProducts();
        }
      } else {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка импорта: $message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show import success dialog
  void _showImportSuccessDialog(Product product, int? remainingImports) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Успешно!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Товар "${product.name}" успешно импортирован!'),
            const SizedBox(height: 16),
            if (product.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrls.first,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text('Бренд: ${product.brand}'),
            Text('Цена: ${product.price} ${product.currency}'),
            if (remainingImports != null) ...[
              const SizedBox(height: 8),
              Text(
                'Осталось импортов сегодня: $remainingImports',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showImportDialog();
            },
            child: const Text('Ещё'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Магазин'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Импортировать товар',
            onPressed: _showImportDialog,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // Navigate to cart
              // Navigator.pushNamed(context, '/market/cart');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск товаров...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = null;
                          });
                          _loadProducts();
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value.isEmpty ? null : value;
                });
                _loadProducts();
              },
            ),
          ),

          // Categories
          categoriesAsync.when(
            data: (categories) => SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // All category
                  FilterChip(
                    label: const Text('Все'),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = null;
                      });
                      _loadProducts();
                    },
                  ),
                  const SizedBox(width: 8),
                  ...categories.map((category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category['label'] ?? ''),
                      selected: _selectedCategory == category['value'],
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category['value'] : null;
                        });
                        _loadProducts();
                      },
                    ),
                  )),
                ],
              ),
            ),
            loading: () => const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox(),
          ),

          const SizedBox(height: 16),

          // Products grid
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Text('Товары не найдены'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Ошибка загрузки: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProducts,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
