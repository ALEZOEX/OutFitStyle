import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../utils/preferences_constants.dart';
import 'city_picker_screen.dart';

class OnboardingWizardScreen extends StatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  State<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> {
  int _step = 0;
  bool _saving = false;
  String? _error;

  final Set<String> _preferredStyles = {'casual'};
  final Set<String> _avoidStyles = {};

  final Set<String> _colorPrefs = {'black'};
  final Set<String> _avoidColors = {};

  int _tempSens = 0;

  bool _notificationsEnabled = true;
  final _reminderTime = TextEditingController(text: '08:00');

  CityPickerResult? _location;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromProfile());
  }

  @override
  void dispose() {
    _reminderTime.dispose();
    super.dispose();
  }

  void _loadFromProfile() {
    final p = context.read<ProfileProvider>();
    final user = p.user;
    final prefs = (user?['preferences'] as Map?)?.cast<String, dynamic>();

    if (prefs != null) {
      final ps = prefs['preferred_styles'];
      if (ps is List && ps.isNotEmpty) {
        _preferredStyles
          ..clear()
          ..addAll(ps.map((e) => e.toString()));
      }

      final as = prefs['avoid_styles'];
      if (as is List) {
        _avoidStyles
          ..clear()
          ..addAll(as.map((e) => e.toString()));
        _avoidStyles.removeWhere(_preferredStyles.contains);
      }

      final cp = prefs['color_preferences'];
      if (cp is List && cp.isNotEmpty) {
        _colorPrefs
          ..clear()
          ..addAll(cp.map((e) => e.toString()));
      }

      final ac = prefs['avoid_colors'];
      if (ac is List) {
        _avoidColors
          ..clear()
          ..addAll(ac.map((e) => e.toString()));
        _avoidColors.removeWhere(_colorPrefs.contains);
      }

      final ts = prefs['temperature_sensitivity'];
      if (ts is int) _tempSens = ts;

      final ne = prefs['notifications_enabled'];
      if (ne is bool) _notificationsEnabled = ne;

      final rt = prefs['morning_reminder_time'];
      if (rt is String && rt.isNotEmpty) _reminderTime.text = rt;
    }

    setState(() {});
  }

  Future<void> _savePreferencesPatch(Map<String, dynamic> patch) async {
    setState(() {
      _saving = true;
      _error = null;
    });

    await context.read<ProfileProvider>().updatePreferences(patch);

    if (!mounted) return;

    final err = context.read<ProfileProvider>().error;
    setState(() {
      _saving = false;
      _error = err;
    });
  }

  Future<void> _saveProfilePatch(Map<String, dynamic> patch) async {
    setState(() {
      _saving = true;
      _error = null;
    });

    await context.read<ProfileProvider>().updateProfilePatch(patch);

    if (!mounted) return;

    final err = context.read<ProfileProvider>().error;
    setState(() {
      _saving = false;
      _error = err;
    });
  }

  Future<void> _next() async {
    // сохраняем на каждом шаге
    if (_step == 0) {
      await _savePreferencesPatch({
        'preferred_styles': _preferredStyles.toList(),
        'avoid_styles': _avoidStyles.toList(),
      });
    } else if (_step == 1) {
      await _savePreferencesPatch({
        'color_preferences': _colorPrefs.toList(),
        'avoid_colors': _avoidColors.toList(),
      });
    } else if (_step == 2) {
      await _savePreferencesPatch({
        'temperature_sensitivity': _tempSens,
      });
    } else if (_step == 3) {
      if (_location == null) {
        setState(() => _error = 'Выберите город');
        return;
      }
      await _saveProfilePatch({
        'default_location': _location!.displayName,
        'default_latitude': _location!.lat,
        'default_longitude': _location!.lon,
      });
    } else if (_step == 4) {
      await _savePreferencesPatch({
        'notifications_enabled': _notificationsEnabled,
        'morning_reminder_time': _reminderTime.text.trim(),
      });
    }

    if (_error != null) return;

    if (_step >= 4) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
      return;
    }

    setState(() => _step += 1);
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step -= 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Онбординг'),
      ),
      body: Stepper(
        currentStep: _step,
        onStepContinue: _saving ? null : _next,
        onStepCancel: _saving ? null : _back,
        controlsBuilder: (context, details) {
          return Row(
            children: [
              FilledButton(
                onPressed: details.onStepContinue,
                child: _saving ? const Text('Сохраняем...') : const Text('Далее'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: details.onStepCancel,
                child: const Text('Назад'),
              ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text('Стили'),
            isActive: _step >= 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Выберите 2–3 предпочитаемых стиля'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kStyles.map((s) => FilterChip(
                    label: Text(kStyleTitlesRu[s] ?? s),
                    selected: _preferredStyles.contains(s),
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _preferredStyles.add(s);
                          _avoidStyles.remove(s);
                        } else {
                          if (_preferredStyles.length > 1) _preferredStyles.remove(s);
                        }
                      });
                    },
                  )).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Стили, которых избегать'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kStyles.map((s) => FilterChip(
                    label: Text(kStyleTitlesRu[s] ?? s),
                    selected: _avoidStyles.contains(s),
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _avoidStyles.add(s);
                          _preferredStyles.remove(s);
                          if (_preferredStyles.isEmpty) _preferredStyles.add('casual');
                        } else {
                          _avoidStyles.remove(s);
                        }
                      });
                    },
                  )).toList(),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Цвета'),
            isActive: _step >= 1,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Любимые цвета'),
                const SizedBox(height: 8),
                _ColorGrid(
                  selected: _colorPrefs,
                  onToggle: (c) {
                    setState(() {
                      if (_colorPrefs.contains(c)) {
                        if (_colorPrefs.length > 1) _colorPrefs.remove(c);
                      } else {
                        _colorPrefs.add(c);
                        _avoidColors.remove(c);
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Цвета, которых избегать'),
                const SizedBox(height: 8),
                _ColorGrid(
                  selected: _avoidColors,
                  onToggle: (c) {
                    setState(() {
                      if (_avoidColors.contains(c)) {
                        _avoidColors.remove(c);
                      } else {
                        _avoidColors.add(c);
                        _colorPrefs.remove(c);
                        if (_colorPrefs.isEmpty) _colorPrefs.add('black');
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Температура'),
            isActive: _step >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Чувствительность: $_tempSens (−2 … +2)'),
                Slider(
                  value: _tempSens.toDouble(),
                  min: -2,
                  max: 2,
                  divisions: 4,
                  label: '$_tempSens',
                  onChanged: (v) => setState(() => _tempSens = v.round()),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Город'),
            isActive: _step >= 3,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_location == null ? 'Город не выбран' : _location!.displayName, maxLines: 2),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CityPickerScreen()),
                    );
                    if (res is CityPickerResult) {
                      setState(() => _location = res);
                    }
                  },
                  child: const Text('Выбрать город'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Уведомления'),
            isActive: _step >= 4,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Включить уведомления'),
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reminderTime,
                  decoration: const InputDecoration(
                    labelText: 'Время утреннего напоминания (HH:MM)',
                    hintText: '08:00',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: (_error == null)
          ? null
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  final Set<String> selected;
  final void Function(String colorKey) onToggle;

  const _ColorGrid({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: kColors.map((c) {
        final isSel = selected.contains(c);
        final sw = kColorSwatches[c] ?? Colors.grey;

        return InkWell(
          onTap: () => onToggle(c),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: sw,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSel ? Theme.of(context).colorScheme.primary : Colors.black12,
                width: isSel ? 3 : 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}