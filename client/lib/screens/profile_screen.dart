import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_settings.dart';
import '../providers/theme_provider.dart';
import '../services/user_settings_service.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserSettings> _settingsFuture;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _settingsFuture = _loadSettings();
      _initialized = true;
    }
  }

  Future<UserSettings> _loadSettings() async {
    // 1) Если кто-то передал UserSettings через arguments — используем их
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is UserSettings) {
      return args;
    }

    // 2) Иначе грузим с бэкенда
    final service = context.read<UserSettingsService>();
    return service.fetchSettings();
  }

  Future<void> _reload() async {
    setState(() {
      _settingsFuture = _loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: theme.cardColor,
        elevation: 0,
      ),
      body: FutureBuilder<UserSettings>(
        future: _settingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Ошибка загрузки профиля: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final settings = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _reload,
            color: theme.primaryColor,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeader(settings, theme),
                const SizedBox(height: 24),
                _buildPreferences(settings, theme),
                const SizedBox(height: 24),
                _buildActions(settings, theme, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(UserSettings settings, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            backgroundImage: settings.avatarUrl.isNotEmpty
                ? NetworkImage(settings.avatarUrl)
                : null,
            child: settings.avatarUrl.isEmpty
                ? Text(
              settings.name.isNotEmpty
                  ? settings.name[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.name.isNotEmpty ? settings.name : 'Без имени',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  settings.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color
                        ?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferences(UserSettings settings, ThemeData theme) {
    String styleLabel(String v) {
      switch (v) {
        case 'business':
          return 'Деловой стиль';
        case 'sporty':
          return 'Спортивный стиль';
        case 'elegant':
          return 'Элегантный стиль';
        case 'casual':
        default:
          return 'Повседневный стиль';
      }
    }

    String tempLabel(String v) {
      switch (v) {
        case 'cold':
          return 'Мерзну';
        case 'warm':
          return 'Жарко';
        case 'normal':
        default:
          return 'Нормально';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Предпочтения',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(
                icon: Icons.style,
                label: styleLabel(settings.stylePreference),
                theme: theme,
              ),
              _buildChip(
                icon: Icons.thermostat,
                label: tempLabel(settings.temperatureSensitivity),
                theme: theme,
              ),
              _buildChip(
                icon: Icons.calendar_today,
                label: 'Возраст: ${settings.ageRange}',
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: theme.primaryColor,
      ),
      label: Text(label),
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.primaryColor.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildActions(
      UserSettings settings, ThemeData theme, bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Редактировать профиль'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(settings: settings),
                ),
              );
              if (result == true) {
                await _reload();
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.settings),
            label: const Text('Настройки'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: theme.primaryColor),
              foregroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(settings: settings),
                ),
              );
              if (result == true) {
                await _reload();
              }
            },
          ),
        ),
      ],
    );
  }
}