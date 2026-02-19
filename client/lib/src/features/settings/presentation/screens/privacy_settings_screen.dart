import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Экран настроек приватности
class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  // Настройки приватности
  bool _isProfilePublic = false;
  bool _showOnlineStatus = true;
  bool _allowMessages = true;
  bool _showWardrobe = false;
  bool _allowRecommendations = true;
  bool _shareAnalytics = true;
  bool _allowPersonalizedAds = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Приватность'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Заголовок
          _buildHeader(context),
          const SizedBox(height: 24),

          // Профиль
          _buildSection(
            context,
            title: 'Профиль',
            icon: Icons.person,
            children: [
              _buildSwitchTile(
                context,
                title: 'Публичный профиль',
                subtitle: 'Ваш профиль виден другим пользователям',
                value: _isProfilePublic,
                onChanged: (value) {
                  setState(() => _isProfilePublic = value);
                },
              ),
              _buildSwitchTile(
                context,
                title: 'Показывать статус онлайн',
                subtitle: 'Другие видят, когда вы в сети',
                value: _showOnlineStatus,
                onChanged: (value) {
                  setState(() => _showOnlineStatus = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Взаимодействие
          _buildSection(
            context,
            title: 'Взаимодействие',
            icon: Icons.chat,
            children: [
              _buildSwitchTile(
                context,
                title: 'Разрешить сообщения',
                subtitle: 'Пользователи могут писать вам',
                value: _allowMessages,
                onChanged: (value) {
                  setState(() => _allowMessages = value);
                },
              ),
              _buildSwitchTile(
                context,
                title: 'Показывать гардероб',
                subtitle: 'Другие видят ваши вещи',
                value: _showWardrobe,
                onChanged: (value) {
                  setState(() => _showWardrobe = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Рекомендации
          _buildSection(
            context,
            title: 'Рекомендации',
            icon: Icons.auto_awesome,
            children: [
              _buildSwitchTile(
                context,
                title: 'Персональные рекомендации',
                subtitle: 'Использовать данные для подбора образов',
                value: _allowRecommendations,
                onChanged: (value) {
                  setState(() => _allowRecommendations = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Данные и аналитика
          _buildSection(
            context,
            title: 'Данные и аналитика',
            icon: Icons.analytics,
            children: [
              _buildSwitchTile(
                context,
                title: 'Делиться аналитикой',
                subtitle: 'Помогает улучшить приложение',
                value: _shareAnalytics,
                onChanged: (value) {
                  setState(() => _shareAnalytics = value);
                },
              ),
              _buildSwitchTile(
                context,
                title: 'Персонализированная реклама',
                subtitle: 'Показ релевантной рекламы',
                value: _allowPersonalizedAds,
                onChanged: (value) {
                  setState(() => _allowPersonalizedAds = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Информация
          _buildInfoCard(context),
          const SizedBox(height: 24),

          // Кнопка сохранения
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: () => _saveSettings(context),
              icon: const Icon(Icons.save),
              label: const Text('Сохранить настройки'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.5),
            theme.colorScheme.secondaryContainer.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.privacy_tip,
              color: theme.colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Приватность',
                  style: theme.textTheme.titleLarge?.copyWith(
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
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок секции
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
          // Элементы секции
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
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
      ),
      onTap: () {
        onChanged(!value);
      },
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.infoContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ваши данные под защитой',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Мы не передаём ваши данные третьим лицам',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings(BuildContext context) {
    // В реальной реализации здесь будет сохранение настроек на сервер
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700]),
            const SizedBox(width: 12),
            const Text('Настройки приватности сохранены'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Extension для цвета infoContainer
extension on ColorScheme {
  Color get infoContainer => primaryContainer;
}
