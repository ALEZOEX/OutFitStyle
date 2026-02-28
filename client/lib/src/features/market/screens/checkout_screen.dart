import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/src/features/market/presentation/providers/cart_provider.dart';
import 'package:outfitstyle_client/src/features/market/presentation/providers/market_provider.dart';
import 'package:outfitstyle_client/src/features/market/data/models/order.dart';
import 'package:outfitstyle_client/src/theme/app_theme.dart';

/// Checkout screen - order creation
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  String _paymentMethod = 'card';

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Оформление заказа'),
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart.isEmpty) {
            return const Center(
              child: Text('Корзина пуста'),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Delivery address section
                _buildSectionTitle('Адрес доставки'),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'Город',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите город';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Улица, дом, квартира',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите адрес';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Почтовый индекс',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.mail),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Payment method section
                _buildSectionTitle('Способ оплаты'),
                const SizedBox(height: 16),

                RadioListTile<String>(
                  title: const Text('Банковская карта'),
                  subtitle: const Text('Visa, Mastercard, МИР'),
                  value: 'card',
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                  },
                ),

                RadioListTile<String>(
                  title: const Text('YooKassa'),
                  subtitle: const Text('Онлайн платеж'),
                  value: 'yookassa',
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                  },
                ),

                RadioListTile<String>(
                  title: const Text('При получении'),
                  subtitle: const Text('Наличными или картой'),
                  value: 'cash',
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Order summary
                _buildSectionTitle('Заказ'),
                const SizedBox(height: 16),

                ...cart.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.productName ?? 'Товар'} x${item.quantity}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${item.total.toStringAsFixed(0)} ₽',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),

                const Divider(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Итого:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${cart.totalAmount.toStringAsFixed(0)} ₽',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Place order button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _placeOrder(cart),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Разместить заказ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Ошибка: $error'),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> _placeOrder(dynamic cart) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final request = CreateOrderRequest(
        shippingAddress: {
          'city': _cityController.text,
          'address': _addressController.text,
          'postal_code': _postalCodeController.text,
        },
        paymentMethod: _paymentMethod,
      );

      final order = await ref.read(marketRepositoryProvider).createOrder(request);

      if (mounted) {
        // Clear cart
        await ref.read(cartProvider.notifier).clear();

        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Заказ #${order.id.substring(0, 8)} создан!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back or to order details
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка создания заказа: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
