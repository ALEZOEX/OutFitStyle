import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final UserSettings settings;

  const EditProfileScreen({Key? key, required this.settings}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _stylePreference;
  late String _temperatureSensitivity;
  late String _ageRange;
  bool _hasChanges = false;

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
    final updated = UserSettings(
      userId: widget.settings.userId,
      name: _nameController.text,
      email: _emailController.text,
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

    await updated.save();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Профиль обновлен'),
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
        title: const Text('Редактировать профиль'),
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        elevation: 0,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveChanges,
              child: const Text('Сохранить'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal info
            _buildSectionTitle('Личная информация', isDark),
            const SizedBox(height: 16),
            
            TextField(
              controller: _nameController,
              onChanged: (_) => _markChanged(),
              style: TextStyle(
                color: isDark ? AppTheme.textPrimary : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: 'Имя',
                prefixIcon: const Icon(Icons.person),
                filled: true,
                fillColor: isDark ? AppTheme.cardDark : Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _emailController,
              onChanged: (_) => _markChanged(),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: isDark ? AppTheme.textPrimary : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: isDark ? AppTheme.cardDark : Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // Preferences
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
                  onPressed: _saveChanges,
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
                    'Сохранить изменения',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
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

  Widget _buildDropdown(
    String label,
    String value,
    List<(String, String)> items,
    void Function(String?) onChanged,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: AppTheme.primary.withOpacity(0.3))
            : Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? AppTheme.primary : const Color(0xFF007bff),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                style: TextStyle(
                  color: isDark ? AppTheme.textPrimary : Colors.black87,
                  fontSize: 15,
                ),
                dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
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