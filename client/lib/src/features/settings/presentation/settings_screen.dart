import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../theme/theme_controller.dart';

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

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      _notificationsEnabled = status.isGranted;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status.isGranted
            ? '✅ Уведомления включены'
            : '❌ Уведомления отклонены'),
          backgroundColor: status.isGranted ? Colors.green : Colors.orange,
        ),
      );
    }
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
  Widget build(BuildContext context) {
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
          // Секция уведомлений
          _buildSection(
            context,
            title: 'Уведомления',
            children: [
              ListTile(
                leading: Icon(
                  _notificationsEnabled
                    ? Icons.notifications
                    : Icons.notifications_off_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Уведомления'),
                subtitle: Text(
                  _notificationsEnabled
                    ? 'Включены'
                    : 'Нажмите для включения',
                ),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (_) => _requestNotificationPermission(),
                ),
                onTap: _requestNotificationPermission,
              ),
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
}
