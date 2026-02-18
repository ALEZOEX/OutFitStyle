import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../theme/theme_controller.dart';
import '../../../ui/widgets/notification_dialog.dart';

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
  bool _showNotificationDialog = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
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
          await _requestNotificationPermission();
        },
        onLater: () {
          Navigator.of(context).pop();
          setState(() {
            _showNotificationDialog = false;
          });
          // Показываем Snackbar с информацией
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
        // Показываем диалог с предложением открыть настройки
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
    // Показываем диалог при первом запуске если уведомления не включены
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_notificationsEnabled && _showNotificationDialog && mounted) {
        _showNotificationPermissionDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final themeController = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
        actions: [
          if (!_notificationsEnabled)
            IconButton(
              icon: Badge(
                child: Icon(Icons.notifications_none),
              ),
              onPressed: _showNotificationPermissionDialog,
              tooltip: 'Включить уведомления',
            ),
        ],
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
          // Секция уведомлений
          _buildSection(
            context,
            title: 'Уведомления',
            children: [
              _buildNotificationTile(context),
            ],
          ),
          const SizedBox(height: 16),
          // Секция геолокации
          _buildSection(
            context,
            title: 'Местоположение',
            children: [
              ListTile(
                leading: Icon(
                  _locationEnabled
                    ? Icons.location_on
                    : Icons.location_off_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Геолокация'),
                subtitle: Text(
                  _locationEnabled
                    ? 'Разрешено'
                    : (_locationError ?? 'Нажмите для включения'),
                ),
                trailing: Switch(
                  value: _locationEnabled,
                  onChanged: (_) => _requestLocationPermission(),
                ),
                onTap: _requestLocationPermission,
              ),
              if (_locationEnabled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Используется для погодных рекомендаций',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
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

  /// Красивая плитка уведомлений
  Widget _buildNotificationTile(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _notificationsEnabled
              ? [
                  theme.colorScheme.primary.withOpacity(0.2),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ]
              : [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _notificationsEnabled
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Иконка
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _notificationsEnabled
                    ? [theme.colorScheme.primary, theme.colorScheme.secondary]
                    : [Colors.grey.shade400, Colors.grey.shade600],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_notificationsEnabled
                          ? theme.colorScheme.primary
                          : Colors.grey)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Текст
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Уведомления',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _notificationsEnabled
                      ? 'Включены • Получайте рекомендации'
                      : 'Отключены • Нажмите для включения',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Переключатель
          Switch(
            value: _notificationsEnabled,
            onChanged: (_) => _requestNotificationPermission(),
            activeColor: theme.colorScheme.primary,
          ),
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
      ThemeMode.system => 'Тема автоматически подстраивается под настройки системы',
    };
  }
}
