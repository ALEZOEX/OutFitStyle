import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../app/onboarding/onboarding_providers.dart';
import '../../../ui/atoms/outfit_app_bar.dart';

final meProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(profileRepositoryProvider).getMe();
});

final isAdminProvider = FutureProvider.autoDispose<bool>((ref) async {
  try {
    final adminService = ref.read(adminServiceProvider);
    return await adminService.isAdmin();
  } catch (e) {
    // Если возникла ошибка при проверке, считаем, что пользователь не администратор
    return false;
  }
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: OutfitAppBar(
        title: 'Профиль',
        actions: [
          IconButton(
            tooltip: 'Выйти',
            onPressed: () async {
              await ref.read(sessionProvider.notifier).logout();
              await ref.read(onboardingStorageProvider).reset();
              ref.invalidate(onboardingDoneProvider);
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: me.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (data) {
          final user = (data['user'] as Map?)?.cast<String, dynamic>() ?? data;
          final name = (user['name'] ?? user['username'] ?? '—').toString();
          final email = (user['email'] ?? '—').toString();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                tileColor: Theme.of(context).colorScheme.surface,
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(email),
                leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
              ),
              const SizedBox(height: 14),

              // Кнопка административного интерфейса, если пользователь администратор
              isAdmin.when(
                loading: () => Container(),
                error: (e, _) => Container(),
                data: (isAdminUser) => isAdminUser ?
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    tileColor: Theme.of(context).colorScheme.surface,
                    leading: const Icon(Icons.admin_panel_settings_rounded),
                    title: const Text('Админ-панель'),
                    onTap: () {
                      context.push('/admin');
                    },
                  ) : Container(),
              ),

              const SizedBox(height: 10),

              // Здесь уже можно подключить achievements_screen и настройки
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                tileColor: Theme.of(context).colorScheme.surface,
                leading: const Icon(Icons.emoji_events_rounded),
                title: const Text('Достижения'),
                onTap: () {
                  // context.push('/achievements') если добавишь route
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                tileColor: Theme.of(context).colorScheme.surface,
                leading: const Icon(Icons.tune_rounded),
                title: const Text('Изменить предпочтения'),
                onTap: () {
                  // Можно открыть экран настроек/онбординга повторно
                },
              ),
            ],
          );
        },
      ),
    );
  }
}