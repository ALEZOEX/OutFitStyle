import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../ui/widgets/max_width_container.dart';
import '../../../../core/api/api_client.dart';
import '../../../../services/auth_storage.dart';
import '../../../../presentation/routing/router.dart';

/// Экран настроек конфиденциальности
///
/// Позволяет пользователю управлять настройками приватности:
/// - Видимость профиля
/// - Видимость статистики
/// - Видимость гардероба
/// - Управление данными
class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  // Настройки приватности
  bool _profileVisibility = true; // Публичный профиль
  bool _statsVisibility = true; // Публичная статистика
  bool _wardrobeVisibility = false; // Приватный гардероб
  bool _allowDataCollection = true; // Сбор анонимных данных
  bool _showOnlineStatus = true; // Показывать статус "онлайн"
  
  // API клиент и хранилище
  late final ApiClient _apiClient;
  late final AuthStorage _authStorage;

  @override
  void initState() {
    super.initState();
    _authStorage = AuthStorage();
    _apiClient = ApiClient(storage: _authStorage);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileVisibility = prefs.getBool('profile_visibility') ?? true;
      _statsVisibility = prefs.getBool('stats_visibility') ?? true;
      _wardrobeVisibility = prefs.getBool('wardrobe_visibility') ?? false;
      _allowDataCollection = prefs.getBool('allow_data_collection') ?? true;
      _showOnlineStatus = prefs.getBool('show_online_status') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Конфиденциальность'),
        centerTitle: true,
      ),
      body: ResponsiveMaxWidthContainer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Видимость профиля
            _buildSection(
              context,
              title: 'Видимость профиля',
              icon: Icons.person_outline,
              child: Column(
                children: [
                  _buildToggle(
                    context,
                    title: 'Публичный профиль',
                    subtitle: 'Другие пользователи могут видеть ваш профиль',
                    value: _profileVisibility,
                    onChanged:
                        (value) => _saveSetting('profile_visibility', value),
                  ),
                  _buildToggle(
                    context,
                    title: 'Показывать статус "онлайн"',
                    subtitle: 'Другие видят, когда вы в сети',
                    value: _showOnlineStatus,
                    onChanged:
                        (value) => _saveSetting('show_online_status', value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Видимость контента
            _buildSection(
              context,
              title: 'Видимость контента',
              icon: Icons.visibility,
              child: Column(
                children: [
                  _buildToggle(
                    context,
                    title: 'Публичная статистика',
                    subtitle: 'Показывать количество образов и лайков',
                    value: _statsVisibility,
                    onChanged:
                        (value) => _saveSetting('stats_visibility', value),
                  ),
                  _buildToggle(
                    context,
                    title: 'Публичный гардероб',
                    subtitle: 'Другие могут смотреть ваш гардероб',
                    value: _wardrobeVisibility,
                    onChanged:
                        (value) => _saveSetting('wardrobe_visibility', value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Данные и аналитика
            _buildSection(
              context,
              title: 'Данные и аналитика',
              icon: Icons.analytics,
              child: Column(
                children: [
                  _buildToggle(
                    context,
                    title: 'Анонимная аналитика',
                    subtitle:
                        'Помочь улучшить приложение, отправляя анонимные данные',
                    value: _allowDataCollection,
                    onChanged:
                        (value) => _saveSetting('allow_data_collection', value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Управление данными
            Card(
              elevation: 1,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.download,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    title: const Text('Экспорт данных'),
                    subtitle: const Text('Скачать копию ваших данных'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showExportDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    title: Text(
                      'Удалить все данные',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    subtitle: const Text('Безвозвратное удаление аккаунта'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showDeleteDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Информация о приватности
            Card(
              elevation: 1,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'О приватности',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Мы уважаем вашу конфиденциальность и защищаем ваши данные. '
                      'Настройки приватности позволяют контролировать, кто может видеть '
                      'ваш профиль и контент.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Экспорт данных'),
            content: const Text(
              'Мы подготовим архив со всеми вашими данными: профиль, гардероб, '
              'рекомендации, история действий. Это может занять несколько минут.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _exportData();
                },
                icon: const Icon(Icons.download),
                label: const Text('Экспортировать'),
              ),
            ],
          ),
    );
  }

  Future<void> _exportData() async {
    try {
      // Экспорт данных через API
      final response = await _apiClient.post('/api/v1/user/export-data');
      
      if (response.statusCode == 200 || response.statusCode == 202) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Данные подготовлены! Ссылка для скачивания отправлена на email',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        throw Exception('Ошибка экспорта данных');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка экспорта данных: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                const Text('Удаление данных'),
              ],
            ),
            content: const Text(
              'Вы уверены, что хотите удалить все данные? Это действие нельзя отменить. '
              'Ваш аккаунт будет безвозвратно удалён.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _deleteAccount();
                },
                child: const Text('Удалить'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      // Удаление аккаунта через API
      final response = await _apiClient.delete('/api/v1/user/delete-account');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Выход из системы и очистка сессии
        await _authStorage.clearSession();
        
        if (mounted) {
          // Перенаправление на экран входа
          ref.read(appRouterProvider).go('/auth');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Аккаунт успешно удалён'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Ошибка удаления аккаунта');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка удаления аккаунта: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
