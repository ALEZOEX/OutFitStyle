import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_settings.dart';
import '../providers/theme_provider.dart';
import '../services/user_settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final UserSettings settings;

  const SettingsScreen({super.key, required this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool notificationsEnabled;
  late bool autoSaveOutfits;
  late String temperatureUnit;
  late String language;

  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    notificationsEnabled = widget.settings.notificationsEnabled;
    autoSaveOutfits = widget.settings.autoSaveOutfits;
    temperatureUnit =
    widget.settings.temperatureUnit.isNotEmpty
        ? widget.settings.temperatureUnit
        : 'celsius';
    language =
    widget.settings.language.isNotEmpty
        ? widget.settings.language
        : 'ru';
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> saveSettings() async {
    setState(() => _isSaving = true);

    final updated = UserSettings(
      userId: widget.settings.userId,
      name: widget.settings.name,
      email: widget.settings.email,
      avatarUrl: widget.settings.avatarUrl,
      temperatureSensitivity: widget.settings.temperatureSensitivity,
      stylePreference: widget.settings.stylePreference,
      ageRange: widget.settings.ageRange,
      preferredCategories: widget.settings.preferredCategories,
      notificationsEnabled: notificationsEnabled,
      autoSaveOutfits: autoSaveOutfits,
      temperatureUnit: temperatureUnit,
      language: language,
    );

    final service = context.read<UserSettingsService>();

    try {
      await service.updateSettings(updated);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Настройки сохранены'),
            ],
          ),
          backgroundColor: const Color(0xFF28a745),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения настроек: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: theme.cardColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          buildSectionTitle('Внешний вид'),
          const SizedBox(height: 12),
          buildSwitchTile(
            title: 'Тёмная тема',
            value: isDark,
            icon: Icons.dark_mode,
            onChanged: (_) {
              themeProvider.toggleTheme();
              _markChanged();
            },
          ),
          const SizedBox(height: 24),

          buildSectionTitle('Единицы измерения'),
          const SizedBox(height: 12),
          buildRadioGroup(
            title: 'Температура',
            groupValue: temperatureUnit,
            options: const [
              ('celsius', '°C (Цельсий)'),
              ('fahrenheit', '°F (Фаренгейт)'),
            ],
            icon: Icons.thermostat,
            onChanged: (v) {
              setState(() => temperatureUnit = v!);
              _markChanged();
            },
          ),
          const SizedBox(height: 24),

          buildSectionTitle('Поведение приложения'),
          const SizedBox(height: 12),
          buildSwitchTile(
            title: 'Уведомления',
            value: notificationsEnabled,
            icon: Icons.notifications,
            onChanged: (v) {
              setState(() => notificationsEnabled = v);
              _markChanged();
            },
          ),
          const SizedBox(height: 8),
          buildSwitchTile(
            title: 'Автосохранение комплектов',
            value: autoSaveOutfits,
            icon: Icons.auto_awesome,
            onChanged: (v) {
              setState(() => autoSaveOutfits = v);
              _markChanged();
            },
          ),
          const SizedBox(height: 24),

          buildSectionTitle('Язык'),
          const SizedBox(height: 12),
          buildRadioGroup(
            title: 'Язык интерфейса',
            groupValue: language,
            options: const [
              ('ru', 'Русский'),
              ('en', 'English'),
            ],
            icon: Icons.language,
            onChanged: (v) {
              setState(() => language = v!);
              _markChanged();
            },
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
              _hasChanges && !_isSaving ? saveSettings : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text(
                'Сохранить настройки',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: theme.textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget buildSwitchTile({
    required String title,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? theme.primaryColor.withOpacity(0.3)
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget buildRadioGroup({
    required String title,
    required String groupValue,
    required List<(String, String)> options,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? theme.primaryColor.withOpacity(0.3)
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.primaryColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...options.map((option) {
            final value = option.$1;
            final label = option.$2;
            return RadioListTile<String>(
              title: Text(
                label,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: theme.primaryColor,
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }),
        ],
      ),
    );
  }
}