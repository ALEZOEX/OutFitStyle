import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../app/onboarding/onboarding_providers.dart';
import '../../../ui/atoms/haptics.dart';

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  ConsumerState<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends ConsumerState<OnboardingWizardScreen> {
  int _step = 0;

  // Preferences
  String _tempSensitivity = 'normal'; // cold|normal|warm
  List<String> _selectedStyles = ['casual']; // List of selected styles
  final Set<String> _prefCats = {'outerwear', 'top', 'bottom', 'footwear'};
  bool _enableNotifs = true;

  // Body params (optional)
  int? _height;
  int? _weight;

  bool _busy = false;
  String? _error;

  Future<void> _finishOnboarding() async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });

    try {
      final repo = ref.read(profileRepositoryProvider);

      // Save preferences
      await repo.updatePreferences({
        'temperature_sensitivity': _tempSensitivity,
        'preferred_styles': _selectedStyles, // Array of selected styles
        'preferred_categories': _prefCats.toList(),
        'notifications_enabled': _enableNotifs,
      });

      // Save body data if provided
      if (_height != null || _weight != null) {
        final bodyData = <String, dynamic>{};
        if (_height != null) bodyData['height_cm'] = _height;
        if (_weight != null) bodyData['weight_kg'] = _weight;
        await repo.updateBody(bodyData);
      }

      // Mark onboarding as complete
      await ref.read(onboardingStorageProvider).setDone();
      ref.invalidate(onboardingDoneProvider);

      Haptics.success();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _PreferencesStep(
        tempSensitivity: _tempSensitivity,
        selectedStyles: _selectedStyles,
        preferredCategories: _prefCats,
        notificationsEnabled: _enableNotifs,
        onTempSensitivityChanged: (v) => setState(() => _tempSensitivity = v),
        onStylesChanged: (styles) => setState(() => _selectedStyles = styles),
        onCategoryToggled: (cat) => setState(() {
          if (_prefCats.contains(cat)) {
            _prefCats.remove(cat);
          } else {
            _prefCats.add(cat);
          }
        }),
        onNotificationsChanged: (v) => setState(() => _enableNotifs = v),
      ),
      _BodyParamsStep(
        height: _height,
        weight: _weight,
        onHeightChanged: (v) => setState(() => _height = v),
        onWeightChanged: (v) => setState(() => _weight = v),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройка профиля'),
        leading: _step > 0
            ? IconButton(
                onPressed: () => setState(() => _step--),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null) _ErrorBox(_error!),
          Text(
            'Шаг ${_step + 1} из ${steps.length}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          steps[_step],
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    Haptics.selection();
                    if (_step < steps.length - 1) {
                      setState(() => _step++);
                    } else {
                      await _finishOnboarding();
                    }
                  },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _busy
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    _step < steps.length - 1 ? 'Далее' : 'Готово',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ),
    );
  }
}

class _PreferencesStep extends StatelessWidget {
  final String tempSensitivity;
  final List<String> selectedStyles; // Changed to List
  final Set<String> preferredCategories;
  final bool notificationsEnabled;

  final ValueChanged<String> onTempSensitivityChanged;
  final ValueChanged<List<String>> onStylesChanged; // Changed to List
  final ValueChanged<String> onCategoryToggled;
  final ValueChanged<bool> onNotificationsChanged;

  const _PreferencesStep({
    required this.tempSensitivity,
    required this.selectedStyles,
    required this.preferredCategories,
    required this.notificationsEnabled,
    required this.onTempSensitivityChanged,
    required this.onStylesChanged,
    required this.onCategoryToggled,
    required this.onNotificationsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Чувствительность к температуре', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Холодно'),
              selected: tempSensitivity == 'cold',
              onSelected: (_) => onTempSensitivityChanged('cold'),
            ),
            FilterChip(
              label: const Text('Нормально'),
              selected: tempSensitivity == 'normal',
              onSelected: (_) => onTempSensitivityChanged('normal'),
            ),
            FilterChip(
              label: const Text('Жарко'),
              selected: tempSensitivity == 'warm',
              onSelected: (_) => onTempSensitivityChanged('warm'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        const Text('Предпочитаемые стили', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Повседневный'),
              selected: selectedStyles.contains('casual'),
              onSelected: (isSelected) {
                if (isSelected) {
                  onStylesChanged([...selectedStyles, 'casual']);
                } else {
                  onStylesChanged(selectedStyles.where((s) => s != 'casual').toList());
                }
              },
            ),
            FilterChip(
              label: const Text('Офисный'),
              selected: selectedStyles.contains('business'),
              onSelected: (isSelected) {
                if (isSelected) {
                  onStylesChanged([...selectedStyles, 'business']);
                } else {
                  onStylesChanged(selectedStyles.where((s) => s != 'business').toList());
                }
              },
            ),
            FilterChip(
              label: const Text('Спорт'),
              selected: selectedStyles.contains('sporty'),
              onSelected: (isSelected) {
                if (isSelected) {
                  onStylesChanged([...selectedStyles, 'sporty']);
                } else {
                  onStylesChanged(selectedStyles.where((s) => s != 'sporty').toList());
                }
              },
            ),
            FilterChip(
              label: const Text('Элегантный'),
              selected: selectedStyles.contains('elegant'),
              onSelected: (isSelected) {
                if (isSelected) {
                  onStylesChanged([...selectedStyles, 'elegant']);
                } else {
                  onStylesChanged(selectedStyles.where((s) => s != 'elegant').toList());
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        const Text('Предпочтения по категориям', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final cat in const ['outerwear', 'top', 'bottom', 'footwear', 'accessories'])
              FilterChip(
                label: Text(_categoryLabel(cat)),
                selected: preferredCategories.contains(cat),
                onSelected: (_) => onCategoryToggled(cat),
              ),
          ],
        ),
        const SizedBox(height: 16),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Умные уведомления'),
          value: notificationsEnabled,
          onChanged: onNotificationsChanged,
        ),
      ],
    );
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'outerwear': return 'Верхняя одежда';
      case 'top': return 'Топы';
      case 'bottom': return 'Низ';
      case 'footwear': return 'Обувь';
      case 'accessories': return 'Аксессуары';
      default: return cat;
    }
  }
}

class _BodyParamsStep extends StatelessWidget {
  final int? height;
  final int? weight;

  final ValueChanged<int?> onHeightChanged;
  final ValueChanged<int?> onWeightChanged;

  const _BodyParamsStep({
    required this.height,
    required this.weight,
    required this.onHeightChanged,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Параметры тела (опционально)', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Рост (см)',
            prefixIcon: Icon(Icons.straighten_rounded),
          ),
          onChanged: (v) => onHeightChanged(int.tryParse(v)),
        ),
        const SizedBox(height: 10),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Вес (кг)',
            prefixIcon: Icon(Icons.scale_rounded),
          ),
          onChanged: (v) => onWeightChanged(int.tryParse(v)),
        ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String text;
  const _ErrorBox(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }
}