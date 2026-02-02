import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/outfit_app_bar.dart';
import '../../../ui/design_system/outfit_style_components.dart';

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
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (stats) => ListView(
          padding: OutfitStyleComponents.paddingMedium,
          children: [
            // Статистика
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: OutfitStyleComponents.radiusXLarge,
              ),
              child: Padding(
                padding: OutfitStyleComponents.paddingMedium,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Статистика',
                      style: OutfitStyleComponents.titleMedium(context).copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 16),
                    _StatItem(
                      label: 'Всего пользователей',
                      value: stats['users_total']?.toString() ?? '0',
                    ),
                    const SizedBox(height: 8),
                    _StatItem(
                      label: 'Всего рекомендаций',
                      value: stats['recommendations_total']?.toString() ?? '0',
                    ),
                    const SizedBox(height: 8),
                    _StatItem(
                      label: 'Всего вещей в гардеробах',
                      value: stats['wardrobe_total']?.toString() ?? '0',
                    ),
                    const SizedBox(height: 8),
                    _StatItem(
                      label: 'Активных подписок',
                      value: stats['active_subscriptions']?.toString() ?? '0',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Пользователи
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: OutfitStyleComponents.radiusXLarge,
              ),
              child: Padding(
                padding: OutfitStyleComponents.paddingMedium,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Последние пользователи',
                      style: OutfitStyleComponents.titleMedium(context).copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    usersAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text('Ошибка: $e'),
                      data: (users) => Column(
                        children: [
                          for (final user in users.take(5)) // показываем первых 5
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: Text(
                                  user['email'] ?? 'Без email',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(user['display_name'] ?? 'Без имени'),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () {
                                  Haptics.selection();
                                  // context.push('/admin/users/${user['id']}') если добавите route
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Управление
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: OutfitStyleComponents.radiusXLarge,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.cached_rounded),
                    title: const Text('Очистить кэш'),
                    onTap: () {
                      Haptics.selection();
                      // Добавить логику очистки кэша
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.backup_rounded),
                    title: const Text('Резервное копирование'),
                    onTap: () {
                      Haptics.selection();
                      // Добавить логику бэкапа
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.analytics_rounded),
                    title: const Text('Аналитика'),
                    onTap: () {
                      Haptics.selection();
                      // Добавить логику аналитики
                    },
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}