import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Экран настроек конфиденциальности
class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  // Состояния переключателей
  bool _allowAnalytics = true;
  bool _allowPersonalizedAds = false;
  bool _showActivityStatus = true;
  bool _allowDataSync = true;
  bool _incognitoMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Загрузить настройки из SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allowAnalytics = prefs.getBool('allow_analytics') ?? true;
      _allowPersonalizedAds = prefs.getBool('allow_personalized_ads') ?? false;
      _showActivityStatus = prefs.getBool('show_activity_status') ?? true;
      _allowDataSync = prefs.getBool('allow_data_sync') ?? true;
      _incognitoMode = prefs.getBool('incognito_mode') ?? false;
    });
  }

  /// Сохранить настройку
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Конфиденциальность'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Информация
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ваши данные под защитой',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Управляйте настройками приватности',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Сбор данных
          SliverToBoxAdapter(
            child: _buildSectionHeader(context, 'Сбор данных'),
          ),
          SliverToBoxAdapter(
            child: _buildSettingsCard(
              context,
              items: [
                _buildToggleSetting(
                  context,
                  icon: Icons.analytics_outlined,
                  title: 'Аналитика',
                  subtitle: 'Разрешить сбор анонимных данных об использовании',
                  value: _allowAnalytics,
                  onChanged: (value) {
                    setState(() => _allowAnalytics = value);
                    _saveSetting('allow_analytics', value);
                  },
                ),
                _buildToggleSetting(
                  context,
                  icon: Icons.ad_units_outlined,
                  title: 'Персонализированная реклама',
                  subtitle: 'Показывать рекламу на основе ваших интересов',
                  value: _allowPersonalizedAds,
                  onChanged: (value) {
                    setState(() => _allowPersonalizedAds = value);
                    _saveSetting('allow_personalized_ads', value);
                  },
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Видимость
          SliverToBoxAdapter(
            child: _buildSectionHeader(context, 'Видимость'),
          ),
          SliverToBoxAdapter(
            child: _buildSettingsCard(
              context,
              items: [
                _buildToggleSetting(
                  context,
                  icon: Icons.visibility_outlined,
                  title: 'Показывать статус активности',
                  subtitle: 'Другие пользователи видят, когда вы онлайн',
                  value: _showActivityStatus,
                  onChanged: (value) {
                    setState(() => _showActivityStatus = value);
                    _saveSetting('show_activity_status', value);
                  },
                ),
                _buildToggleSetting(
                  context,
                  icon: Icons.sync_outlined,
                  title: 'Синхронизация данных',
                  subtitle: 'Автоматическая синхронизация с облаком',
                  value: _allowDataSync,
                  onChanged: (value) {
                    setState(() => _allowDataSync = value);
                    _saveSetting('allow_data_sync', value);
                  },
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Режим инкогнито
          SliverToBoxAdapter(
            child: _buildSectionHeader(context, 'Режим приватности'),
          ),
          SliverToBoxAdapter(
            child: _buildSettingsCard(
              context,
              items: [
                _buildToggleSetting(
                  context,
                  icon: Icons.person_off_outlined,
                  title: 'Режим инкогнито',
                  subtitle: 'Не сохранять историю просмотров и действий',
                  value: _incognitoMode,
                  onChanged: (value) {
                    setState(() => _incognitoMode = value);
                    _saveSetting('incognito_mode', value);

                    if (value && mounted) {
                      _showIncognitoWarning(context);
                    }
                  },
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Управление данными
          SliverToBoxAdapter(
            child: _buildSectionHeader(context, 'Управление данными'),
          ),
          SliverToBoxAdapter(
            child: _buildSettingsCard(
              context,
              items: [
                _buildActionTile(
                  context,
                  icon: Icons.download_outlined,
                  title: 'Экспорт данных',
                  subtitle: 'Скачать все ваши данные в формате JSON',
                  onTap: () => _exportData(context),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.delete_outline,
                  title: 'Удалить все данные',
                  subtitle: 'Полностью очистить локальные данные приложения',
                  isDestructive: true,
                  onTap: () => _deleteData(context),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Политика конфиденциальности
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Настройки применяются немедленно. '
                'Подробнее о том, как мы обрабатываем данные, '
                'читайте в политике конфиденциальности.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> items,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildToggleSetting(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
        activeThumbColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color.withValues(alpha: 0.8), size: 22),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: isDestructive ? theme.colorScheme.error : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: theme.colorScheme.onSurfaceVariant,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showIncognitoWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Icon(
          Icons.warning_amber_outlined,
          size: 48,
          color: Colors.orange,
        ),
        title: const Text('Режим инкогнито'),
        content: const Text(
          'В режиме инкогнито история не сохраняется. '
          'Это может повлиять на работу рекомендаций.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    // Экспорт данных будет реализован в следующей версии
    // В продакшене: генерация JSON файла и сохранение через file_saver
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Экспорт данных будет реализован в следующей версии'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _deleteData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Icon(
          Icons.warning_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text('Удалить все данные?'),
        content: const Text(
          'Это действие нельзя отменить. '
          'Все локальные данные будут удалены.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Используем post-frame callback для безопасности
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Все данные удалены'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    }
  }
}
