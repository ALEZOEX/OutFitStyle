import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Модель плана подписки
class SubscriptionPlan {
  final String id;
  final String name;
  final String price;
  final String period;
  final String description;
  final List<String> features;
  final List<String> unavailableFeatures;
  final Color color;
  final bool isPopular;
  final bool isCurrent;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
    required this.unavailableFeatures,
    required this.color,
    this.isPopular = false,
    this.isCurrent = false,
  });
}

/// Планы подписок
class SubscriptionPlans {
  static const free = SubscriptionPlan(
    id: 'free',
    name: 'Free',
    price: '0',
    period: '',
    description: 'Базовые функции для начала',
    features: [
      'До 10 вещей в гардеробе',
      'Базовые погодные рекомендации',
      'Ограниченные стили',
    ],
    unavailableFeatures: [
      'ML рекомендации',
      'Безлимитный гардероб',
      'Приоритетная поддержка',
      'Эксклюзивные функции',
    ],
    color: Colors.grey,
  );

  static const premium = SubscriptionPlan(
    id: 'premium',
    name: 'Premium',
    price: '99',
    period: 'мес',
    description: 'Для ценителей стиля',
    features: [
      'Безлимитный гардероб',
      'ML рекомендации',
      'Расширенные стили',
      'Статистика и аналитика',
      'Без рекламы',
    ],
    unavailableFeatures: [
      'Приоритетная поддержка',
      'Эксклюзивные функции',
      'Ранний доступ к новинкам',
    ],
    color: Colors.blue,
    isPopular: true,
  );

  static const premiumPlus = SubscriptionPlan(
    id: 'premium_plus',
    name: 'Premium Plus',
    price: '199',
    period: 'мес',
    description: 'Максимальные возможности',
    features: [
      'Всё из Premium',
      'Приоритетная поддержка 24/7',
      'Эксклюзивные функции',
      'Ранний доступ к новинкам',
      'Персональный стилист (ИИ)',
      'VIP статус',
    ],
    unavailableFeatures: [],
    color: Colors.purple,
  );
}

final currentSubscriptionProvider = StateProvider<String?>((ref) => null);

/// Экран подписок
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentPlan = ref.watch(currentSubscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Подписка'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Заголовок
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.secondaryContainer,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Выберите план',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Разблокируйте все возможности OutfitStyle',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Планы
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildPlanCard(
                  context,
                  SubscriptionPlans.free,
                  currentPlan,
                  ref,
                ),
                const SizedBox(height: 16),
                _buildPlanCard(
                  context,
                  SubscriptionPlans.premium,
                  currentPlan,
                  ref,
                ),
                const SizedBox(height: 16),
                _buildPlanCard(
                  context,
                  SubscriptionPlans.premiumPlus,
                  currentPlan,
                  ref,
                ),
              ]),
            ),
          ),

          // Информация
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Divider(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    icon: Icons.security,
                    text: 'Безопасная оплата',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    icon: Icons.refresh,
                    text: 'Отмена в любое время',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    icon: Icons.receipt_long,
                    text: 'Чек на email',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Нажимая кнопку оплаты, вы принимаете условия\nпользовательского соглашения',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    SubscriptionPlan plan,
    String? currentPlan,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final isCurrent = currentPlan == plan.id;
    final isPopular = plan.isPopular;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            plan.color.withValues(alpha: 0.1),
            plan.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPopular
              ? plan.color.withValues(alpha: 0.5)
              : plan.color.withValues(alpha: 0.2),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: -12,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: plan.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Популярный',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок плана
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: plan.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isCurrent ? Icons.check_circle : Icons.star,
                        color: plan.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            plan.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Цена
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      plan.price,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: plan.color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (plan.period.isNotEmpty)
                      Text(
                        '₽/${plan.period}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Доступные функции
                ...plan.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 20,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
                // Недоступные функции
                if (plan.unavailableFeatures.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...plan.unavailableFeatures.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                const SizedBox(height: 16),
                // Кнопка
                SizedBox(
                  width: double.infinity,
                  child: isCurrent
                      ? OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Текущий план',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : FilledButton(
                          onPressed: () => _subscribe(context, plan),
                          style: FilledButton.styleFrom(
                            backgroundColor: plan.color,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            plan.id == 'free' ? 'Выбрать' : 'Оформить подписку',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _subscribe(BuildContext context, SubscriptionPlan plan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PaymentDialog(plan: plan),
    );
  }
}

/// Диалог оплаты подписки
class _PaymentDialog extends StatefulWidget {
  final SubscriptionPlan plan;

  const _PaymentDialog({required this.plan});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  bool _isLoading = false;
  String? _selectedPaymentMethod;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'card', 'name': 'Банковская карта', 'icon': Icons.credit_card},
    {'id': 'sbp', 'name': 'СБП', 'icon': Icons.qr_code_2},
    {'id': 'yandex', 'name': 'Yandex Pay', 'icon': Icons.wallet},
  ];

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    // Симуляция процесса оплаты
    // В продакшене здесь будет интеграция с платежным шлюзом
    await Future.delayed(const Duration(seconds: 2));

    // Симуляция успешной оплаты
    if (mounted) {
      Navigator.pop(context); // Закрыть диалог

      // Обновить текущую подписку через GlobalKey
      // В продакшене: использовать proper state management
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.plan.name} оформлен!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.plan.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payment,
              size: 40,
              color: widget.plan.color,
            ),
          ),
          const SizedBox(height: 12),
          Text('Оплата ${widget.plan.name}'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Сумма
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Сумма:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '${widget.plan.price}₽/${widget.plan.period}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.plan.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Метод оплаты
            Text(
              'Способ оплаты:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            // ignore: deprecated_member_use
            ..._paymentMethods.map((method) => RadioListTile<String>(
              value: method['id'] as String,
              // ignore: deprecated_member_use
              groupValue: _selectedPaymentMethod,
              // ignore: deprecated_member_use
              onChanged: _isLoading ? null : (value) {
                setState(() => _selectedPaymentMethod = value);
              },
              title: Row(
                children: [
                  Icon(method['icon'] as IconData, size: 20),
                  const SizedBox(width: 8),
                  Text(method['name'] as String),
                ],
              ),
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _isLoading || _selectedPaymentMethod == null
              ? null
              : _processPayment,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Оплатить'),
        ),
      ],
    );
  }
}
