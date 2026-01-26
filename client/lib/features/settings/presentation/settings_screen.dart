import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../app/onboarding/onboarding_providers.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/theme/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Тема оформления', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, label: Text('Системная')),
                      ButtonSegment(value: ThemeMode.light, label: Text('Светлая')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Тёмная')),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (s) => themeNotifier.setMode(s.first),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Профиль', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.emoji_events_rounded),
                    title: const Text('Достижения'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Haptics.selection();
                      // Navigate to achievements screen
                      // Will be implemented when achievements feature is ready
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.auto_mode_rounded),
                    title: const Text('Предпочтения'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Haptics.selection();
                      // Navigate to preferences screen
                      // Will be implemented when preferences feature is ready
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          OutlinedButton.icon(
            onPressed: () async {
              Haptics.selection();
              await ref.read(sessionProvider.notifier).logout();
              await ref.read(onboardingStorageProvider).reset();
              ref.invalidate(onboardingDoneProvider);
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Выйти'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}