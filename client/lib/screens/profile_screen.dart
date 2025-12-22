import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../services/auth_service.dart';
import '../services/user_settings_service.dart';
import '../utils/city_translator.dart';
import '../utils/preferences_constants.dart';
import 'city_picker_screen.dart';
import 'preferences_screen.dart';
import 'body_measurements_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tempSens = 0;
  final Set<String> _preferredStyles = {'casual'};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProfileProvider>().load();
      _syncFromProfile();
    });
  }

  void _syncFromProfile() {
    final p = context.read<ProfileProvider>();
    final user = p.user;
    if (user == null) return;

    final prefs = (user['preferences'] as Map?)?.cast<String, dynamic>();
    if (prefs == null) return;

    final ts = prefs['temperature_sensitivity'];
    if (ts is int) _tempSens = ts;

    final styles = prefs['preferred_styles'];
    if (styles is List) {
      _preferredStyles
        ..clear()
        ..addAll(styles.map((e) => e.toString()));
      if (_preferredStyles.isEmpty) _preferredStyles.add('casual');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    final user = p.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthService>().logout(allDevices: false);
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/auth', (r) => false);
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (user == null)
              ? Center(child: Text(p.error ?? 'Нет данных'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Проверяем, есть ли координаты у пользователя
                    if (user['default_latitude'] == null || user['default_longitude'] == null) ...[
                      Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Укажите город',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Выберите ваш город, чтобы получать персонализированные рекомендации по погоде и использовать его по умолчанию.',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CityPickerScreen()),
                                  );
                                  if (result is CityPickerResult) {
                                    await context.read<UserSettingsService>().updateProfile(
                                      defaultLocation: result.displayName,
                                      defaultLatitude: result.lat,
                                      defaultLongitude: result.lon,
                                    );
                                    await context.read<ProfileProvider>().load();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text('Город установлен'),
                                      ));
                                    }
                                  }
                                },
                                icon: const Icon(Icons.location_on, color: Colors.white),
                                label: const Text('Выбрать город'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text('Email: ${user['email'] ?? ''}'),
                    const SizedBox(height: 8),
                    if (user['display_name'] != null && user['display_name'] != '')
                      Text('Имя: ${user['display_name']}'),
                    if (user['gender'] != null && user['gender'] != '')
                      Text('Пол: ${user['gender']}'),
                    if (user['birth_date'] != null && user['birth_date'] != '')
                      Text('Дата рождения: ${user['birth_date']}'),
                    const SizedBox(height: 8),

                    const Text('Персонализация', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),

                    Text('Чувствительность к температуре: $_tempSens'),
                    Slider(
                      value: _tempSens.toDouble(),
                      min: -2,
                      max: 2,
                      divisions: 4,
                      label: '$_tempSens',
                      onChanged: (v) async {
                        setState(() => _tempSens = v.round());

                        // Автосохранение при изменении
                        await context.read<ProfileProvider>().updatePreferences({
                          'preferred_styles': _preferredStyles.toList(),
                          'temperature_sensitivity': _tempSens,
                        });
                      },
                    ),

                    const SizedBox(height: 8),
                    Text('Предпочитаемые стили: ${_preferredStyles.join(', ')}'),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      children: _styleChips(),
                    ),

                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.tune),
                      title: const Text('Предпочтения'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PreferencesScreen())),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Город по умолчанию'),
                      subtitle: Text(user['default_location'] ?? 'Не выбран'),
                    ),

                    const SizedBox(height: 12),

                    // Кнопка удаления аккаунта
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Удаление аккаунта'),
                            content: const Text(
                              'Вы уверены, что хотите удалить аккаунт? '
                              'Это действие нельзя будет отменить, и все ваши данные будут удалены.'
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          // Запрашиваем пароль у пользователя перед удалением
                          String? password = await showDialog<String>(
                            context: context,
                            builder: (ctx) => _PasswordInputDialog(),
                          );

                          if (password != null && password.isNotEmpty) {
                            try {
                              await context.read<UserSettingsService>().deleteAccount(password: password);
                              await context.read<AuthService>().logout();
                              if (context.mounted) {
                                Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Аккаунт успешно удалён'))
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Ошибка при удалении аккаунта: $e'))
                                );
                              }
                            }
                          }
                        }
                      },
                      child: const Text('Удалить аккаунт'),
                    ),

                    if (p.error != null) ...[
                      const SizedBox(height: 8),
                      Text(p.error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
    );
  }

  List<Widget> _styleChips() {
    const styles = ['casual', 'street', 'classic', 'sport', 'business', 'smart_casual', 'outdoor'];
    return styles.map((s) {
      final selected = _preferredStyles.contains(s);
      return FilterChip(
        label: Text(translateStyle(s)), // Переводим стиль для отображения
        selected: selected,
        onSelected: (v) async { // Делаем асинхронным для автосохранения
          setState(() {
            if (v) {
              _preferredStyles.add(s);
            } else {
              if (_preferredStyles.length > 1) {
                _preferredStyles.remove(s);
              }
            }
          });

          // Автосохранение при изменении
          await context.read<ProfileProvider>().updatePreferences({
            'preferred_styles': _preferredStyles.toList(),
            'temperature_sensitivity': _tempSens,
          });
        },
      );
    }).toList();
  }
}

// Виджет для ввода пароля при удалении аккаунта
class _PasswordInputDialog extends StatefulWidget {
  @override
  _PasswordInputDialogState createState() => _PasswordInputDialogState();
}

class _PasswordInputDialogState extends State<_PasswordInputDialog> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Подтверждение удаления'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Для удаления аккаунта введите ваш пароль:'),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Пароль',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => Navigator.of(context).pop(_passwordController.text),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_passwordController.text),
          child: const Text('Удалить'),
        ),
      ],
    );
  }
}