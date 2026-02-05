import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/outfit_app_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);
    final isAdminAsync = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: OutfitAppBar(
        title: 'Профиль',
        actions: [
          IconButton(
            onPressed: () {
              Haptics.selection();
              context.push('/settings');
            },
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Настройки',
          ),
        ],
      ),
      body: meAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (me) {
          if (me == null) {
            return const Center(child: Text('Пользователь не найден'));
          }

          final name = (me['display_name'] ?? me['username'] ?? '').toString();
          final email = (me['email'] ?? '').toString();
          final avatar = (me['avatar_url'] ?? '').toString();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Карточка пользователя
              Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage:
                            avatar.isNotEmpty ? NetworkImage(avatar) : null,
                        child: avatar.isEmpty
                            ? const Icon(Icons.person_rounded, size: 36)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? '—' : name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email.isEmpty ? '—' : email,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.65),
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

              // Админ-панель (если пользователь администратор)
              isAdminAsync.when(
                loading: () => Container(),
                error: (e, _) => Container(),
                data: (isAdminUser) => isAdminUser
                    ? Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          leading:
                              const Icon(Icons.admin_panel_settings_rounded),
                          title: const Text('Админ-панель'),
                          onTap: () {
                            Haptics.selection();
                            context.push('/admin');
                          },
                        ),
                      )
                    : Container(),
              ),
              const SizedBox(height: 10),

              // Достижения
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  leading: const Icon(Icons.emoji_events_rounded),
                  title: const Text('Достижения'),
                  onTap: () {
                    Haptics.selection();
                    // context.push('/achievements') если добавите route
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Изменить предпочтения
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  leading: const Icon(Icons.tune_rounded),
                  title: const Text('Изменить предпочтения'),
                  onTap: () {
                    Haptics.selection();
                    // Можно открыть экран настроек/онбординга повторно
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
