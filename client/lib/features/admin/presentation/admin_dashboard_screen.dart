import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/outfit_app_bar.dart';

final adminStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final adminService = ref.read(adminServiceProvider);
  return adminService.getAdminStats();
});

final adminUsersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final adminService = ref.read(adminServiceProvider);
  return adminService.getUsers(1, 10); // первые 10 пользователей
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: OutfitAppBar(
        title: 'Админ-панель',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статистика
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Ошибка загрузки статистики: $e')),
              data: (stats) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Статистика приложения',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildStatItem('Всего пользователей', stats['users_total']?.toString() ?? '0'),
                      _buildStatItem('Всего рекомендаций', stats['recommendations_total']?.toString() ?? '0'),
                      _buildStatItem('Всего вещей в гардеробах', stats['wardrobe_total']?.toString() ?? '0'),
                      _buildStatItem('Всего платежей', stats['payments_total']?.toString() ?? '0'),
                      _buildStatItem('Доход', '\$${stats['payments_revenue_completed']?.toStringAsFixed(2) ?? '0.00'}'),
                      _buildStatItem('Активных подписок', stats['active_subscriptions']?.toString() ?? '0'),
                      _buildStatItem('Всего уведомлений', stats['notifications_total']?.toString() ?? '0'),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Список пользователей
            const Text(
              'Последние пользователи',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Ошибка загрузки пользователей: $e')),
              data: (users) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (final user in users.take(5)) // показываем первых 5
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['email'] ?? 'Без email',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      user['display_name'] ?? 'Без имени',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}