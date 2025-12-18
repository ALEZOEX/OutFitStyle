import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../utils/preferences_constants.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  int _tempSens = 0;
  bool _notificationsEnabled = true;

  final Set<String> _preferredStyles = {'casual'};
  final Set<String> _avoidStyles = {};
  final Set<String> _colorPrefs = {'black'};
  final Set<String> _avoidColors = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFromProfile();
    });
  }

  void _loadFromProfile() {
    final p = context.read<ProfileProvider>();
    final user = p.user;
    final prefs = (user?['preferences'] as Map?)?.cast<String, dynamic>();
    if (prefs == null) return;

    final ts = prefs['temperature_sensitivity'];
    if (ts is int) _tempSens = ts;

    final ne = prefs['notifications_enabled'];
    if (ne is bool) _notificationsEnabled = ne;

    final ps = prefs['preferred_styles'];
    if (ps is List) {
      _preferredStyles
        ..clear()
        ..addAll(ps.map((e) => e.toString()));
      if (_preferredStyles.isEmpty) _preferredStyles.add('casual');
    }

    final as = prefs['avoid_styles'];
    if (as is List) {
      _avoidStyles
        ..clear()
        ..addAll(as.map((e) => e.toString()));
      // не допускаем пересечения
      _avoidStyles.removeWhere(_preferredStyles.contains);
    }

    final cp = prefs['color_preferences'];
    if (cp is List) {
      _colorPrefs
        ..clear()
        ..addAll(cp.map((e) => e.toString()));
      if (_colorPrefs.isEmpty) _colorPrefs.add('black');
    }

    final ac = prefs['avoid_colors'];
    if (ac is List) {
      _avoidColors
        ..clear()
        ..addAll(ac.map((e) => e.toString()));
      _avoidColors.removeWhere(_colorPrefs.contains);
    }

    setState(() {});
  }

  Future<void> _save() async {
    final patch = <String, dynamic>{
      'preferred_styles': _preferredStyles.toList(),
      'avoid_styles': _avoidStyles.toList(),
      'color_preferences': _colorPrefs.toList(),
      'avoid_colors': _avoidColors.toList(),
      'temperature_sensitivity': _tempSens,
      'notifications_enabled': _notificationsEnabled,
    };

    await context.read<ProfileProvider>().updatePreferences(patch);
    if (!mounted) return;

    final err = context.read<ProfileProvider>().error;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $err')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сохранено')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Предпочтения'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Сохранить'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Температура', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Чувствительность: $_tempSens (−2 мёрзну … +2 жарко)'),
          Slider(
            value: _tempSens.toDouble(),
            min: -2,
            max: 2,
            divisions: 4,
            label: '$_tempSens',
            onChanged: (v) => setState(() => _tempSens = v.round()),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Уведомления'),
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          const SizedBox(height: 16),

          const Text('Предпочитаемые стили', style: TextStyle(fontWeight: FontWeight.w600)),
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
                    if (_preferredStyles.length > 1) {
                      _preferredStyles.remove(s);
                    }
                  }
                });
              },
            )).toList(),
          ),
          const SizedBox(height: 16),

          const Text('Стили, которых избегать', style: TextStyle(fontWeight: FontWeight.w600)),
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

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          const Text('Любимые цвета', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _ColorGrid(
            selected: _colorPrefs,
            onToggle: (c) {
              setState(() {
                if (_colorPrefs.contains(c)) {
                  if (_colorPrefs.length > 1) {
                    _colorPrefs.remove(c);
                  }
                } else {
                  _colorPrefs.add(c);
                  _avoidColors.remove(c);
                }
              });
            },
          ),

          const SizedBox(height: 16),
          const Text('Цвета, которых избегать', style: TextStyle(fontWeight: FontWeight.w600)),
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

          if (p.error != null) ...[
            const SizedBox(height: 16),
            Text(p.error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
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
            child: Center(
              child: Text(
                c == 'white' ? 'W' : '',
                style: TextStyle(
                  color: c == 'white' ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}