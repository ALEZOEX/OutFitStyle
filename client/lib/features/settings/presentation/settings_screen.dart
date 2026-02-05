import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart' hide onboardingStorageProvider, onboardingDoneProvider;
import '../../../app/onboarding/onboarding_providers.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/outfit_app_bar.dart';
import '../../../ui/design_system/outfit_style_components.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: OutfitAppBar(
        title: 'Настройки',
      ),
      body: ListView(
        padding: OutfitStyleComponents.paddingMedium,
        children: [
          // Тема
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
                    'Тема оформления',
                    style: OutfitStyleComponents.titleMedium(context)
                        .copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                          value: ThemeMode.system, label: Text('Системная')),
                      ButtonSegment(
                          value: ThemeMode.light, label: Text('Светлая')),
                      ButtonSegment(
                          value: ThemeMode.dark, label: Text('Тёмная')),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (s) => themeNotifier.state = s.first,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Профиль
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: OutfitStyleComponents.radiusXLarge,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_rounded),
                  title: const Text('Профиль'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Haptics.selection();
                    context.push('/profile');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.emoji_events_rounded),
                  title: const Text('Достижения'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Haptics.selection();
                    // context.push('/achievements') если добавите route
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.tune_rounded),
                  title: const Text('Изменить предпочтения'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Haptics.selection();
                    // Можно открыть экран онбординга повторно
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Конфиденциальность
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: OutfitStyleComponents.radiusXLarge,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_rounded),
                  title: const Text('Конфиденциальность'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Haptics.selection();
                    // context.push('/privacy') если добавите route
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_rounded),
                  title: const Text('О приложении'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Haptics.selection();
                    // context.push('/about') если добавите route
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Выход
          FilledButton.icon(
            onPressed: () async {
              Haptics.selection();
              await ref.read(sessionProvider.notifier).logout();
              await ref.read(onboardingStorageProvider).reset();
              ref.invalidate(onboardingDoneProvider);
              // Возвращаем на экран аутентификации
              if (context.mounted) {
                context.go('/auth');
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Выйти из аккаунта'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}
