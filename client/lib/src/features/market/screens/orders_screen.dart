import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:outfitstyle_client/src/features/market/data/models/order.dart';
import 'package:outfitstyle_client/src/features/market/presentation/providers/market_provider.dart';
import 'package:outfitstyle_client/src/features/market/widgets/order_card.dart';
import 'package:outfitstyle_client/src/theme/app_theme.dart';

/// Orders history screen
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String? _selectedStatus;
  AsyncValue<List<Order>> _orders = const AsyncValue.loading();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    setState(() {
      _orders = const AsyncValue.loading();
    });

    try {
      final repository = ref.read(marketRepositoryProvider);
      final ordersList = await repository.getOrders(status: _selectedStatus);
      setState(() {
        _orders = AsyncValue.data(ordersList);
      });
    } catch (e, stack) {
      setState(() {
        _orders = AsyncValue.error(e, stack);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заказы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Все'),
                  selected: _selectedStatus == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = null;
                    });
                    _loadOrders();
                  },
                ),
                ...OrderStatus.values.map((status) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(status.displayName),
                    selected: _selectedStatus == status.name,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? status.name : null;
                      });
                      _loadOrders();
                    },
                  ),
                )),
              ],
            ),
          ),

          // Orders list
          Expanded(
            child: _orders.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return _buildEmptyOrders(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return OrderCard(
                      order: orders[index],
                      onTap: () => _navigateToOrderDetails(orders[index]),
                      onCancel: orders[index].status == OrderStatus.pending
                          ? () => _cancelOrder(orders[index])
                          : null,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Ошибка загрузки: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadOrders,
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

  Widget _buildEmptyOrders(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Нет заказов',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Ваши заказы появятся здесь',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to market
              context.go('/market');
            },
            child: const Text('Перейти в каталог'),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderDetails(Order order) {
    // Навигация на экран деталей заказа через GoRouter
    context.push('/order/${order.id}');
  }

  Future<void> _cancelOrder(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить заказ?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Отменить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Отмена заказа через repository
      final repository = ref.read(marketRepositoryProvider);
      await repository.cancelOrder(order.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заказ отменен'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrders(); // Refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка отмены: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
