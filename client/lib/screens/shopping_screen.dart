import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_item.dart';
import '../services/shopping_service.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  late Future<List<ShoppingItem>> _wishlistFuture;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final shoppingService =
        Provider.of<ShoppingService>(context, listen: false);
    try {
      setState(() {
        _wishlistFuture = shoppingService.getShoppingWishlist(userId: 1);
      });
      await _wishlistFuture;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки списка покупок: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    // final theme = Theme.of(context); // Получаем текущую тему

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('ШОПИНГ'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadWishlist,
        child: FutureBuilder<List<ShoppingItem>>(
          future: _wishlistFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final items = snapshot.data!;
            return ListView(
              children: [
                // Shopping list
                _buildShoppingList(items),
                const SizedBox(height: 16),
                // Size information
                _buildSizeInfo(),
                const SizedBox(height: 16),
                // Wardrobe cost analysis
                _buildCostAnalysis(items),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShoppingList(List<ShoppingItem> items) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, size: 20),
                const SizedBox(width: 8),
                const Text('Список покупок',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${items.length} вещей',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          ...items
              .map((item) => _buildShoppingItem(item)),
        ],
      ),
    );
  }

  Widget _buildShoppingItem(ShoppingItem item) {
    // Исправлено имя метода
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image, color: Colors.white),
      ),
      title: Text(item.name),
      subtitle: item.brand != null ? Text(item.brand!) : null,
      trailing: Text(
        item.price != null ? '${item.price?.toStringAsFixed(0)} ₽' : '',
        style:
            const TextStyle(fontWeight: FontWeight.bold), // Исправлена опечатка
      ),
      onTap: () => _editItem(item),
    );
  }

  Widget _buildSizeInfo() {
    return const Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.straighten, size: 20),
                SizedBox(width: 8),
                Text('Размеры', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Text('Запишите, чтобы использовать при покупках',
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Размеры одежды')),
                Icon(Icons.chevron_right, size: 20)
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Тип фигуры')),
                Icon(Icons.chevron_right, size: 20)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostAnalysis(List<ShoppingItem> items) {
    final totalCost = items.fold(0.0, (sum, item) => sum + (item.price ?? 0));
    final averagePrice = items.isNotEmpty ? totalCost / items.length : 0;
    final mostExpensive = items.isNotEmpty
        ? items.reduce((a, b) => (a.price ?? 0) > (b.price ?? 0) ? a : b)
        : null;
    final cheapest = items.isNotEmpty
        ? items.reduce((a, b) => (a.price ?? 0) < (b.price ?? 0) ? a : b)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, size: 20),
                const SizedBox(width: 8),
                const Text('Анализ стоимости',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('Настройка валюты'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Общая стоимость: ${totalCost.toStringAsFixed(0)} ₽',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Средняя цена: ${averagePrice.toStringAsFixed(0)} ₽',
              style: const TextStyle(fontSize: 16),
            ),
            if (mostExpensive != null)
              Text(
                'Самый дорогой: ${mostExpensive.name} (${mostExpensive.price?.toStringAsFixed(0)} ₽)',
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
            if (cheapest != null)
              Text(
                'Самый дешевый: ${cheapest.name} (${cheapest.price?.toStringAsFixed(0)} ₽)',
                style: const TextStyle(fontSize: 14, color: Colors.green),
              ),
            const SizedBox(height: 8),
            const Text('Распределение по ценовым категориям:',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            _buildPriceDistributionChart(items),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDistributionChart(List<ShoppingItem> items) {
    final priceRanges = {
      'До 1000 ₽': 0,
      '1000-3000 ₽': 0,
      '3000-5000 ₽': 0,
      '5000-10000 ₽': 0,
      'Более 10000 ₽': 0,
    };

    for (final item in items) {
      final price = item.price ?? 0;
      if (price < 1000) {
        priceRanges['До 1000 ₽'] = (priceRanges['До 1000 ₽'] ?? 0) + 1;
      } else if (price < 3000) {
        priceRanges['1000-3000 ₽'] = (priceRanges['1000-3000 ₽'] ?? 0) + 1;
      } else if (price < 5000) {
        priceRanges['3000-5000 ₽'] = (priceRanges['3000-5000 ₽'] ?? 0) + 1;
      } else if (price < 10000) {
        priceRanges['5000-10000 ₽'] = (priceRanges['5000-10000 ₽'] ?? 0) + 1;
      } else {
        priceRanges['Более 10000 ₽'] = (priceRanges['Более 10000 ₽'] ?? 0) + 1;
      }
    }

    return Column(
      children: priceRanges.entries.map((entry) {
        final count = entry.value;
        final percentage = items.isNotEmpty ? (count / items.length * 100) : 0;

        Color getBarColor() {
          switch (entry.key) {
            case 'До 1000 ₽':
              return Colors.green;
            case '1000-3000 ₽':
              return Colors.blue;
            case '3000-5000 ₽':
              return Colors.yellow;
            case '5000-10000 ₽':
              return Colors.orange;
            default:
              return Colors.red;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(entry.key, style: const TextStyle(fontSize: 12)),
              ),
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width *
                          0.3 *
                          (percentage / 100),
                      decoration: BoxDecoration(
                        color: getBarColor(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text('$count шт', style: const TextStyle(fontSize: 12)),
              ),
              Expanded(
                flex: 1,
                child: Text('${percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Список покупок пуст',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Добавляйте одежду со статусом «В списке покупок»',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _addItem() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция добавления товара в разработке')),
    );
  }

  void _editItem(ShoppingItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Редактирование ${item.name} в разработке')),
    );
  }
}
