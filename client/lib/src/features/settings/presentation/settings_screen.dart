import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/theme_controller.dart';

/// Экран настроек приложения
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeController = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Секция темы
          _buildSection(
            context,
            title: 'Внешний вид',
            children: [
              _buildThemeSelector(context, themeMode, themeController),
            ],
          ),
          const SizedBox(height: 16),
          // Секция уведомлений (заглушка для будущей реализации)
          _buildSection(
            context,
            title: 'Уведомления',
            children: [
              _buildListTile(
                icon: Icons.notifications_outlined,
                title: 'Уведомления',
                subtitle: 'Будет доступно в следующей версии',
                enabled: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Секция локации (заглушка для будущей реализации)
          _buildSection(
            context,
            title: 'Местоположение',
            children: [
              _buildListTile(
                icon: Icons.location_on_outlined,
                title: 'Геолокация',
                subtitle: 'Будет доступно в следующей версии',
                enabled: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Построение секции настроек
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  /// Переключатель темы
  Widget _buildThemeSelector(
    BuildContext context,
    ThemeMode themeMode,
    ThemeModeController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Тема оформления',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text('Светлая'),
                icon: Icon(Icons.light_mode, color: Color(0xFFFFC107)),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text('Тёмная'),
                icon: Icon(Icons.dark_mode, color: Color(0xFF9FA8DA)),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text('Системная'),
                icon: Icon(Icons.phone_android, color: Color(0xFF4A6CF7)),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (Set<ThemeMode> selected) {
              if (selected.isNotEmpty) {
                controller.setMode(selected.first);
              }
            },
            showSelectedIcon: false,
          ),
          const SizedBox(height: 8),
          Text(
            _getThemeDescription(themeMode),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  /// Описание выбранной темы
  String _getThemeDescription(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => 'Светлая тема всегда активна',
      ThemeMode.dark => 'Тёмная тема всегда активна',
      ThemeMode.system => 'Тема зависит от настроек системы',
    };
  }

  /// Элемент списка настроек
  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: enabled ? null : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? null : Colors.grey,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: enabled ? null : Colors.grey,
                fontSize: 12,
              ),
            )
          : null,
      trailing: enabled
          ? Icon(
              Icons.chevron_right,
              color: enabled ? null : Colors.grey,
            )
          : null,
      enabled: enabled,
      onTap: onTap,
    );
  }
}
