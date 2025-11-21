import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';
import '../providers/theme_provider.dart';

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

  @override
  void initState() {
    super.initState();
    notificationsEnabled = widget.settings.notificationsEnabled;
    autoSaveOutfits = widget.settings.autoSaveOutfits;
    temperatureUnit = widget.settings.temperatureUnit.isNotEmpty
        ? widget.settings.temperatureUnit
        : 'celsius';
    language =
        widget.settings.language.isNotEmpty ? widget.settings.language : 'ru';
  }

  Future<void> saveSettings() async {
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

    await updated.save();

    if (mounted) {
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
          // Appearance
          buildSectionTitle('Внешний вид', isDark),
          const SizedBox(height: 12),

          buildSwitchTile(
            'Темная тема',
            isDark,
            Icons.dark_mode,
            isDark,
            (value) => themeProvider.toggleTheme(),
          ),

          const SizedBox(height: 24),

          // Units
          buildSectionTitle('Единицы измерения', isDark),
          const SizedBox(height: 12),

          buildRadioGroup(
            'Температура',
            temperatureUnit,
            [
              ('celsius', '°C (Цельсий)'),
              ('fahrenheit', '°F (Фаренгейт)'),
            ],
            (value) => setState(() => temperatureUnit = value!),
            Icons.thermostat,
            isDark,
          ),

          const SizedBox(height: 24),

          // App behavior
          buildSectionTitle('Поведение приложения', isDark),
          const SizedBox(height: 12),
          buildSwitchTile(
            'Уведомления',
            notificationsEnabled,
            Icons.notifications,
            isDark,
            (value) => setState(() => notificationsEnabled = value),
          ),

          const SizedBox(height: 8),

          buildSwitchTile(
            'Автосохранение комплектов',
            autoSaveOutfits,
            Icons.auto_awesome,
            isDark,
            (value) => setState(() => autoSaveOutfits = value),
          ),

          const SizedBox(height: 24),

          // Language
          buildSectionTitle('Язык', isDark),
          const SizedBox(height: 12),

          buildRadioGroup(
            'Язык интерфейса',
            language,
            [
              ('ru', 'Русский'),
              ('en', 'English'),
            ],
            (value) => setState(() => language = value!),
            Icons.language,
            isDark,
          ),

          const SizedBox(height: 32),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Сохранить настройки',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title, bool isDark) {
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

  Widget buildSwitchTile(
    String title,
    bool value,
    IconData icon,
    bool isDark,
    void Function(bool) onChanged,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.primaryColor,
          ),
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
            activeThumbColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget buildRadioGroup(
    String title,
    String groupValue,
    List<(String, String)> options,
    void Function(String?) onChanged,
    IconData icon,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.primaryColor,
              ),
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
            return RadioListTile<String>(
              title: Text(
                option.$2,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              value: option.$1,
              // Эти два параметра помечены как deprecated в новых SDK.
              // Мы осознанно их используем и глушим предупреждение.
              // ignore: deprecated_member_use
              groupValue: groupValue,
              // ignore: deprecated_member_use
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
