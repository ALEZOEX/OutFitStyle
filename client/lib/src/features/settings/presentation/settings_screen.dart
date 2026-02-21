import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/theme_controller.dart';
import '../../../ui/widgets/notification_dialog.dart';
import 'screens/preferences_screen.dart';
import 'screens/profile_settings_screen.dart';
import 'screens/security_screen.dart';
import 'screens/language_screen.dart';
import 'screens/about_screen.dart';
import 'screens/notification_settings_screen.dart';
import '../../achievements/presentation/pages/achievements_page.dart';

/// Провайдер для состояния разрешений
class PermissionState extends StateNotifier<Map<String, bool>> {
  PermissionState() : super({});

  void updatePermission(String permission, bool granted) {
    state = {...state, permission: granted};
  }
}

final permissionStateProvider = StateNotifierProvider<PermissionState, Map<String, bool>>((ref) {
  return PermissionState();
});

/// Экран настроек приложения
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _locationEnabled = false;
  String? _locationError;
  bool _notificationDialogShown = false;

  // Настройки типов уведомлений
  bool _weatherNotifications = true;
  bool _newArrivalsNotifications = true;
  bool _recommendationNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationDialogFlag();
    _checkPermissions();
    _loadNotificationSettings();
  }

  /// Загрузить настройки типов уведомлений
  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weatherNotifications = prefs.getBool('weather_notifications') ?? true;
      _newArrivalsNotifications = prefs.getBool('new_arrivals_notifications') ?? true;
      _recommendationNotifications = prefs.getBool('recommendation_notifications') ?? true;
    });
  }

  Future<void> _loadNotificationDialogFlag() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationDialogShown = prefs.getBool('notificationDialogShown') ?? false;
    });
  }

  Future<void> _saveNotificationDialogFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationDialogShown', true);
  }

  /// Сохранить настройку уведомления
  Future<void> _saveNotificationSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _checkPermissions() async {
    // Проверка уведомлений
    final notificationStatus = await Permission.notification.status;
    setState(() {
      _notificationsEnabled = notificationStatus.isGranted;
    });

    // Проверка геолокации
    final locationStatus = await Permission.location.status;
    setState(() {
      _locationEnabled = locationStatus.isGranted;
    });
  }

  /// Показать красивый диалог запроса уведомлений
  void _showNotificationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NotificationPermissionDialog(
        onEnable: () async {
          Navigator.of(context).pop();
          await _saveNotificationDialogFlag();
          await _requestNotificationPermission();
        },
        onLater: () {
          Navigator.of(context).pop();
          _saveNotificationDialogFlag();
          NotificationSnackbar.show(
            context: context,
            title: 'Уведомления отложены',
            message: 'Вы можете включить уведомления в любое время',
            icon: Icons.notifications_none,
            duration: const Duration(seconds: 3),
          );
        },
      ),
    );
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      _notificationsEnabled = status.isGranted;
    });

    if (mounted) {
      if (status.isGranted) {
        NotificationSnackbar.show(
          context: context,
          title: 'Уведомления включены',
          message: 'Вы будете получать своевременные рекомендации',
          icon: Icons.notifications_active,
          backgroundColor: Theme.of(context).colorScheme.primary,
        );
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      } else {
        NotificationSnackbar.show(
          context: context,
          title: 'Уведомления отклонены',
          message: 'Вы можете включить их в настройках устройства',
          icon: Icons.notifications_off,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    }
  }

  /// Диалог с предложением открыть настройки
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Icon(
          Icons.settings_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text(
          'Открыть настройки?',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Уведомления были отключены навсегда. '
          'Откройте настройки приложения, чтобы включить их.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Настройки'),
          ),
        ],
        actionsPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    try {
      final status = await Permission.location.request();

      if (status.isGranted) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        setState(() {
          _locationEnabled = true;
          _locationError = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Геолокация: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _locationEnabled = false;
          _locationError = 'Разрешение отклонено';
        });
      }
    } catch (e) {
      setState(() {
        _locationEnabled = false;
        _locationError = 'Ошибка: $e';
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_notificationsEnabled && !_notificationDialogShown && mounted) {
        _showNotificationPermissionDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final themeController = ref.read(themeModeProvider.notifier);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Заголовок
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Профиль
          SliverToBoxAdapter(
            child: _buildProfileCard(context),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Основные настройки
          SliverToBoxAdapter(
            child: _buildMainSettings(context),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Уведомления
          SliverToBoxAdapter(
            child: _buildNotificationsSection(context),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Геолокация
          SliverToBoxAdapter(
            child: _buildLocationSection(context),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Тема
          SliverToBoxAdapter(
            child: _buildThemeSection(context, themeMode, themeController),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Text(
        'Настройки',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(Icons.person, color: theme.colorScheme.onPrimary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Профиль',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Управление аккаунтом',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onSurfaceVariant,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainSettings(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            context,
            icon: Icons.style,
            title: 'Предпочтения',
            subtitle: 'Размер, стили, бренды',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PreferencesScreen()),
              );
            },
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
          _buildSettingTile(
            context,
            icon: Icons.notifications_active,
            title: 'Уведомления',
            subtitle: 'Push, Email, SMS настройки',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
              );
            },
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
          _buildSettingTile(
            context,
            icon: Icons.emoji_events,
            title: 'Достижения',
            subtitle: 'Ваши награды',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AchievementsPage()),
              );
            },
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
          _buildSettingTile(
            context,
            icon: Icons.security,
            title: 'Безопасность',
            subtitle: 'Пароль, 2FA, сессии',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecurityScreen()),
              );
            },
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
          _buildSettingTile(
            context,
            icon: Icons.language,
            title: 'Язык',
            subtitle: 'Выберите язык приложения',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguageScreen()),
              );
            },
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
          _buildSettingTile(
            context,
            icon: Icons.info_outline,
            title: 'О приложении',
            subtitle: 'Версия, команда, лицензии',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
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
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
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

  Widget _buildNotificationsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _notificationsEnabled
              ? [
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ]
              : [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _notificationsEnabled
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _notificationsEnabled
                        ? [theme.colorScheme.primary, theme.colorScheme.secondary]
                        : [Colors.grey.shade400, Colors.grey.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _notificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Уведомления',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _notificationsEnabled
                          ? 'Включены'
                          : 'Отключены',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _notificationsEnabled,
                onChanged: (_) => _requestNotificationPermission(),
                activeThumbColor: theme.colorScheme.primary,
              ),
            ],
          ),
          if (_notificationsEnabled) ...[
            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            _buildNotificationTypeToggle(
              context,
              icon: Icons.cloud,
              title: 'Погода',
              subtitle: 'Рекомендации по погоде',
              value: _weatherNotifications,
              onChanged: (value) {
                setState(() => _weatherNotifications = value);
                _saveNotificationSetting('weather_notifications', value);
              },
            ),
            const SizedBox(height: 8),
            _buildNotificationTypeToggle(
              context,
              icon: Icons.new_releases,
              title: 'Новые поступления',
              subtitle: 'Обновления гардероба',
              value: _newArrivalsNotifications,
              onChanged: (value) {
                setState(() => _newArrivalsNotifications = value);
                _saveNotificationSetting('new_arrivals_notifications', value);
              },
            ),
            const SizedBox(height: 8),
            _buildNotificationTypeToggle(
              context,
              icon: Icons.auto_awesome,
              title: 'Рекомендации',
              subtitle: 'Персональные подборки',
              value: _recommendationNotifications,
              onChanged: (value) {
                setState(() => _recommendationNotifications = value);
                _saveNotificationSetting('recommendation_notifications', value);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationTypeToggle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium,
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

  Widget _buildLocationSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _locationEnabled
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : theme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _locationEnabled
                  ? Icons.location_on
                  : Icons.location_off_outlined,
              color: _locationEnabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Геолокация',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _locationEnabled
                      ? 'Используется для погодных рекомендаций'
                      : (_locationError ?? 'Отключено'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _locationEnabled,
            onChanged: (_) => _requestLocationPermission(),
            activeThumbColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    ThemeMode themeMode,
    ThemeModeController controller,
  ) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Тема оформления',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeDescription(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => 'Светлая тема всегда активна',
      ThemeMode.dark => 'Тёмная тема всегда активна',
      ThemeMode.system => 'Тема автоматически подстраивается под настройки системы',
    };
  }
}
