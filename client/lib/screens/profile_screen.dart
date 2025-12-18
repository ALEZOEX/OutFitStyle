import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../services/auth_service.dart';
import '../services/user_settings_service.dart';
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
                    const SizedBox(height: 16),

                    const Text('Персонализация', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),

                    Text('Чувствительность к температуре: $_tempSens'),
                    Slider(
                      value: _tempSens.toDouble(),
                      min: -2,
                      max: 2,
                      divisions: 4,
                      label: '$_tempSens',
                      onChanged: (v) => setState(() => _tempSens = v.round()),
                    ),

                    const SizedBox(height: 8),
                    const Text('Предпочитаемые стили'),
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
                      leading: const Icon(Icons.straighten),
                      title: const Text('Размеры и тело'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BodyMeasurementsScreen())),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Город по умолчанию'),
                      subtitle: Text(user['default_location'] ?? 'Не выбран'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
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
                    ),

                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () async {
                        await context.read<ProfileProvider>().updatePreferences({
                          'preferred_styles': _preferredStyles.toList(),
                          'temperature_sensitivity': _tempSens,
                        });
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сохранено')));
                      },
                      child: const Text('Сохранить preferences'),
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
        label: Text(s),
        selected: selected,
        onSelected: (v) {
          setState(() {
            if (v) {
              _preferredStyles.add(s);
            } else {
              if (_preferredStyles.length > 1) {
                _preferredStyles.remove(s);
              }
            }
          });
        },
      );
    }).toList();
  }
}