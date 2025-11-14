import'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final UserSettings settings;

  const SettingsScreen({Key? key, required this.settings}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _notificationsEnabled;
  late bool _autoSaveOutfits;
  late String _temperatureUnit;
  late String _language;

  @override
  voidinitState() {
    super.initState();
    _notificationsEnabled = widget.settings.notificationsEnabled;
    _autoSaveOutfits = widget.settings.autoSaveOutfits;
    _temperatureUnit = widget.settings.temperatureUnit;
    _language = widget.settings.language;
  }

  Future<void> _saveSettings() async {
    final updated =UserSettings(
      userId: widget.settings.userId,
      name: widget.settings.name,
      email: widget.settings.email,
      avatarUrl: widget.settings.avatarUrl,
      temperatureSensitivity: widget.settings.temperatureSensitivity,
      stylePreference: widget.settings.stylePreference,
      ageRange: widget.settings.ageRange,
      preferredCategories: widget.settings.preferredCategories,
      notificationsEnabled: _notificationsEnabled,
      autoSaveOutfits: _autoSaveOutfits,
      temperatureUnit: _temperatureUnit,
      language: _language,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Appearance
          _buildSectionTitle('Внешний вид', isDark),
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            'Темная тема',
            isDark,
           Icons.dark_mode,
            isDark,
            (value) => themeProvider.toggleTheme(),
          ),

          const SizedBox(height: 24),

          // Units
          _buildSectionTitle('Единицы измерения', isDark),
          const SizedBox(height: 12),
          
          _buildRadioGroup(
'Температура',
            _temperatureUnit,
            [
              ('celsius', '°C (Цельсий)'),
              ('fahrenheit', '°F (Фаренгейт)'),
            ],
            (value) => setState(() => _temperatureUnit = value!),
            Icons.thermostat,
            isDark,
          ),

          const SizedBox(height: 24),

          // App behavior
          _buildSectionTitle('Поведение приложения', isDark),
          const SizedBox(height: 12),
_buildSwitchTile(
            'Уведомления',
            _notificationsEnabled,
            Icons.notifications,
            isDark,
            (value) => setState(() => _notificationsEnabled = value),
          ),
          
          const SizedBox(height: 8),
          
          _buildSwitchTile(
            'Автосохранение комплектов',
            _autoSaveOutfits,
            Icons.auto_awesome,
            isDark,
            (value) => setState(() => _autoSaveOutfits = value),
          ),

          const SizedBox(height: 24),

          // Language
          _buildSectionTitle('Язык', isDark),
const SizedBox(height: 12),
          
          _buildRadioGroup(
            'Язык интерфейса',
            _language,
            [
              ('ru', 'Русский'),
              ('en', 'English'),
            ],
            (value) => setState(() => _language = value!),
            Icons.language,
            isDark,
          ),

          const SizedBox(height: 32),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppTheme.primary
                   : const Color(0xFF007bff),
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? AppTheme.textPrimary : Colors.black87,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    IconData icon,
    bool isDark,
    void Function(bool) onChanged,
  ) {
    return Container(
     padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: AppTheme.primary.withOpacity(0.3))
            : null,
      ),
     child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? AppTheme.primary : const Color(0xFF007bff),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppTheme.textPrimary : Colors.black87,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isDark ? AppTheme.primary : const Color(0xFF007bff),
          ),
        ],
      ),
);
  }

  Widget _buildRadioGroup(
    String title,
    String groupValue,
    List<(String, String)> options,
    void Function(String?) onChanged,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration:BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: AppTheme.primary.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isDark ? AppTheme.primary : const Color(0xFF007bff),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textPrimary : Colors.black87,
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
                  color: isDark ? AppTheme.textPrimary : Colors.black87,
                ),
              ),
              value: option.$1,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: isDark ? AppTheme.primary :const Color(0xFF007bff),
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          }).toList(),
        ],
      ),
    );
  }
}