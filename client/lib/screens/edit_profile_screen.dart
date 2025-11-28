import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_settings.dart';
import '../providers/theme_provider.dart';
import '../services/user_settings_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserSettings settings;

  const EditProfileScreen({super.key, required this.settings});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _stylePreference;
  late String _temperatureSensitivity;
  late String _ageRange;

  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.settings.name);
    _emailController = TextEditingController(text: widget.settings.email);
    _stylePreference = widget.settings.stylePreference;
    _temperatureSensitivity = widget.settings.temperatureSensitivity;
    _ageRange = widget.settings.ageRange;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updated = UserSettings(
      userId: widget.settings.userId,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      avatarUrl: widget.settings.avatarUrl,
      temperatureSensitivity: _temperatureSensitivity,
      stylePreference: _stylePreference,
      ageRange: _ageRange,
      preferredCategories: widget.settings.preferredCategories,
      notificationsEnabled: widget.settings.notificationsEnabled,
      autoSaveOutfits: widget.settings.autoSaveOutfits,
      temperatureUnit: widget.settings.temperatureUnit,
      language: widget.settings.language,
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
              Text('Профиль обновлён'),
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
          content: Text('Ошибка сохранения профиля: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _inputDecoration(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: theme.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        backgroundColor: theme.cardColor,
        elevation: 0,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isSaving ? null : _saveChanges,
              child: _isSaving
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Сохранить'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          onChanged: _markChanged,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Личная информация', isDark),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(context, 'Имя', Icons.person),
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите имя';
                  }
                  if (value.trim().length < 2) {
                    return 'Слишком короткое имя';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration(context, 'Email', Icons.email),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'Введите email';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegex.hasMatch(email)) {
                    return 'Некорректный email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              _buildSectionTitle('Предпочтения', isDark),
              const SizedBox(height: 16),

              _buildDropdown(
                'Стиль одежды',
                _stylePreference,
                [
                  ('casual', 'Повседневный'),
                  ('business', 'Деловой'),
                  ('sporty', 'Спортивный'),
                  ('elegant', 'Элегантный'),
                ],
                    (value) {
                  setState(() => _stylePreference = value!);
                  _markChanged();
                },
                Icons.style,
                isDark,
              ),

              const SizedBox(height: 16),

              _buildDropdown(
                'Чувствительность к температуре',
                _temperatureSensitivity,
                [
                  ('cold', 'Мерзну'),
                  ('normal', 'Нормально'),
                  ('warm', 'Жарко'),
                ],
                    (value) {
                  setState(() => _temperatureSensitivity = value!);
                  _markChanged();
                },
                Icons.thermostat,
                isDark,
              ),

              const SizedBox(height: 16),

              _buildDropdown(
                'Возраст',
                _ageRange,
                [
                  ('18-25', '18-25'),
                  ('25-35', '25-35'),
                  ('35-45', '35-45'),
                  ('45+', '45+'),
                ],
                    (value) {
                  setState(() => _ageRange = value!);
                  _markChanged();
                },
                Icons.calendar_today,
                isDark,
              ),

              const SizedBox(height: 32),

              if (_hasChanges)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
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
                      'Сохранить изменения',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
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

  Widget _buildDropdown(
      String label,
      String value,
      List<(String, String)> items,
      void Function(String?) onChanged,
      IconData icon,
      bool isDark,
      ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? theme.primaryColor.withValues(alpha: 0.2)
              : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 15,
                ),
                dropdownColor: theme.cardColor,
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item.$1,
                    child: Text(item.$2),
                  );
                }).toList(),
                onChanged: onChanged,
                hint: Text(label),
              ),
            ),
          ),
        ],
      ),
    );
  }
}