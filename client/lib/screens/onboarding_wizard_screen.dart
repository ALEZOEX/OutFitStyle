import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../utils/city_translator.dart';
import '../utils/location_helper.dart';
import '../utils/preferences_constants.dart';

class OnboardingWizardScreen extends StatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  State<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> {
  final PageController _pageController = PageController();
  int _step = 0;
  bool _saving = false;
  String? _error;

  // Preferences state
  final Set<String> _preferredStyles = {'casual'};
  final Set<String> _avoidStyles = {};
  final Set<String> _colorPrefs = {'black'};
  final Set<String> _avoidColors = {};
  int _tempSens = 0;
  bool _notificationsEnabled = true;
  final _reminderTime = TextEditingController(text: '08:00');

  // Location (inline, без отдельного окна)
  final TextEditingController _cityController = TextEditingController();
  final FocusNode _cityFocus = FocusNode();
  List<String> _citySuggestions = [];
  bool _detectingCity = false;
  double? _selectedLat;
  double? _selectedLon;

  final int _totalSteps = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromProfile());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _reminderTime.dispose();
    _cityController.dispose();
    _cityFocus.dispose();
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

    // Профильные поля локации
    final rawCity = user?['default_location'];
    if (rawCity is String && rawCity.trim().isNotEmpty) {
      // в профиле лучше хранить "API city" (англ), а показывать локализованно
      _cityController.text = CityTranslator.getDisplayName(rawCity.trim());
    }

    final lat = user?['default_latitude'];
    final lon = user?['default_longitude'];
    if (lat is num) _selectedLat = lat.toDouble();
    if (lon is num) _selectedLon = lon.toDouble();

    setState(() {});
  }

  Future<void> _savePreferencesPatch(Map<String, dynamic> patch) async {
    if (_saving) return; // Предотвращаем множественные вызовы
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<ProfileProvider>().updatePreferences(patch);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveProfilePatch(Map<String, dynamic> patch) async {
    if (_saving) return; // Предотвращаем множественные вызовы
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<ProfileProvider>().updateProfilePatch(patch);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _next() async {
    if (_saving) return;

    // Проверка обязательных полей, которые не были проверены при вводе
    if (_step == 3) { // Шаг с локацией
      final cityText = _cityController.text.trim();
      if (cityText.isEmpty) {
        setState(() => _error = 'Введите город или нажмите “Автоопределение”');
        return;
      }
    }

    if (_error != null) return;

    if (_step >= _totalSteps - 1) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
      }
      return;
    }

    setState(() => _step++);
    _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
    _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onCityChanged(String value) async {
    setState(() {
      _error = null;
      _selectedLat = null; // при ручном вводе координаты неизвестны
      _selectedLon = null;
    });

    final q = value.trim();
    if (q.isEmpty) {
      setState(() => _citySuggestions = []);

      // Сохраняем пустое значение
      try {
        await _saveProfilePatch({
          'default_location': '',
        });
      } catch (e) {
        setState(() {
          _error = 'Ошибка сохранения города: $e';
        });
      }
      return;
    }

    // подмешиваем подсказки по вводу (и по переводу на англ)
    final s = <String>{};
    try {
      s.addAll(CityTranslator.getSuggestions(q));
      final en = CityTranslator.translate(q);
      if (en.trim().isNotEmpty && en.toLowerCase() != q.toLowerCase()) {
        s.addAll(CityTranslator.getSuggestions(en));
      }
    } catch (_) {
      // если внутри getSuggestions что-то пошло не так — просто не показываем подсказки
    }

    final list = s.toList();
    list.sort((a, b) => a.length.compareTo(b.length));

    setState(() {
      _citySuggestions = list.take(8).toList();
    });
  }

  void _selectSuggestion(String suggestion) async {
    final display = CityTranslator.getDisplayName(suggestion);
    final apiCity = CityTranslator.translate(suggestion);

    setState(() {
      _cityController.text = display;
      _citySuggestions = [];
      _error = null;
      _selectedLat = null;
      _selectedLon = null;
    });

    _cityFocus.unfocus();

    // Автосохранение
    try {
      await _saveProfilePatch({
        'default_location': apiCity,
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка сохранения города: $e';
      });
    }
  }

  Future<void> _detectCityAutomatically() async {
    if (_detectingCity) return;

    setState(() {
      _detectingCity = true;
      _error = null;
      _citySuggestions = [];
    });

    try {
      final enabled = await LocationHelper.isLocationServiceEnabled();
      if (!enabled) {
        if (mounted) await _showLocationServicesDisabledDialog();
        return;
      }

      final permission = await LocationHelper.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) await _showPermissionDeniedDialog();
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) await _showPermissionDeniedForeverDialog();
        return;
      }

      final pos = await LocationHelper.getCurrentPosition();
      if (pos == null) {
        setState(() => _error = 'Не удалось получить координаты');
        return;
      }

      final city = await LocationHelper.getCityFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (city == null || city.trim().isEmpty) {
        setState(() => _error = 'Не удалось определить город по координатам');
        return;
      }

      final apiCity = CityTranslator.translate(city.trim());

      setState(() {
        _cityController.text = CityTranslator.getDisplayName(city.trim());
        _selectedLat = pos.latitude;
        _selectedLon = pos.longitude;
      });

      // Автосохранение
      try {
        await _saveProfilePatch({
          'default_location': apiCity,
          'default_latitude': pos.latitude,
          'default_longitude': pos.longitude,
        });
      } catch (saveError) {
        setState(() {
          _error = 'Ошибка сохранения города: $saveError';
        });
      }

      _cityFocus.unfocus();
    } catch (e) {
      setState(() => _error = 'Ошибка геолокации: $e');
    } finally {
      if (mounted) setState(() => _detectingCity = false);
    }
  }

  Future<void> _showLocationServicesDisabledDialog() async {
    final theme = Theme.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сервисы локации отключены'),
        content: const Text(
          'Включите геолокацию в настройках устройства, чтобы определить город автоматически.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await LocationHelper.openLocationSettings();
            },
            child: Text(
              'Настройки',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionDeniedDialog() async {
    final theme = Theme.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Нужно разрешение'),
        content: const Text(
          'Разрешите доступ к местоположению, чтобы автоматически определить город.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await LocationHelper.openAppSettings();
            },
            child: Text(
              'Открыть настройки',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionDeniedForeverDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Доступ к локации запрещён'),
        content: const Text(
          'Вы запретили доступ к местоположению навсегда. Включите разрешение в настройках приложения или введите город вручную.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final progressBg = isDark
        ? cs.onSurface.withOpacity(0.14)
        : cs.onSurface.withOpacity(0.08);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Progress
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (_step > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _back,
                        )
                      else
                        const SizedBox(width: 48),
                      Expanded(
                        child: Text(
                          'Шаг ${_step + 1} из $_totalSteps',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.75),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (_step + 1) / _totalSteps,
                    backgroundColor: progressBg,
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                    borderRadius: BorderRadius.circular(999),
                    minHeight: 6,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPage(
                    title: 'Какой у вас стиль?',
                    subtitle: 'Выберите то, что вам ближе',
                    child: _stylesStep(),
                  ),
                  _buildPage(
                    title: 'Любимые цвета',
                    subtitle: 'Что вам нравится носить?',
                    child: _colorsStep(),
                  ),
                  _buildPage(
                    title: 'Как вы переносите холод?',
                    subtitle: 'Настроим подбор одежды под вас',
                    child: _tempStep(),
                  ),
                  _buildPage(
                    title: 'Где вы находитесь?',
                    subtitle:
                        'Можно вводить по‑русски. Мы переведём и сохраним корректно.',
                    child: _locationStep(),
                  ),
                  _buildPage(
                    title: 'Быть в курсе?',
                    subtitle: 'Напоминания о погоде утром',
                    child: _notificationsStep(),
                  ),
                ],
              ),
            ),

            // Error message
            if (_error != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: _PrimarySoftButton(
                  text: _step == _totalSteps - 1 ? 'Завершить' : 'Далее',
                  loading: _saving,
                  onPressed: _saving ? null : _next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.78),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          child,
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- STEPS CONTENT ---

  Widget _stylesStep() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Предпочитаемые (2-3):',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kStyles
              .map((s) => _buildChip(s, _preferredStyles, _avoidStyles))
              .toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Избегать:',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kStyles
              .map((s) => _buildAvoidChip(s, _avoidStyles, _preferredStyles))
              .toList(),
        ),
      ],
    );
  }

  Widget _colorsStep() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Любимые:',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        _ColorGrid(
          selected: _colorPrefs,
          onToggle: (c) async {
            setState(() {
              if (_colorPrefs.contains(c)) {
                if (_colorPrefs.length > 1) _colorPrefs.remove(c);
              } else {
                _colorPrefs.add(c);
                _avoidColors.remove(c);
              }
            });

            // Автосохранение
            await _savePreferencesPatch({
              'color_preferences': _colorPrefs.toList(),
              'avoid_colors': _avoidColors.toList(),
            });
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Избегать:',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        _ColorGrid(
          selected: _avoidColors,
          onToggle: (c) async {
            setState(() {
              if (_avoidColors.contains(c)) {
                _avoidColors.remove(c);
              } else {
                _avoidColors.add(c);
                _colorPrefs.remove(c);
                if (_colorPrefs.isEmpty) _colorPrefs.add('black');
              }
            });

            // Автосохранение
            await _savePreferencesPatch({
              'color_preferences': _colorPrefs.toList(),
              'avoid_colors': _avoidColors.toList(),
            });
          },
        ),
      ],
    );
  }

  Widget _tempStep() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        Text(
          '$_tempSens',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.primary,
          ),
        ),
        Text(
          '(-2: Мёрзну ... +2: Жарко)',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.78),
          ),
        ),
        const SizedBox(height: 24),
        Slider(
          value: _tempSens.toDouble(),
          min: -2,
          max: 2,
          divisions: 4,
          onChanged: (v) async {
            setState(() => _tempSens = v.round());

            // Автосохранение
            await _savePreferencesPatch({'temperature_sensitivity': _tempSens});
          },
        ),
      ],
    );
  }

  Widget _locationStep() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final apiPreview = _cityController.text.trim().isEmpty
        ? null
        : CityTranslator.translate(_cityController.text.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.primary.withOpacity(isDark ? 0.18 : 0.12),
            ),
          ),
          child: TextField(
            controller: _cityController,
            focusNode: _cityFocus,
            textInputAction: TextInputAction.done,
            onChanged: _onCityChanged,
            onSubmitted: (_) => setState(() => _citySuggestions = []),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              prefixIcon: Icon(Icons.location_city, color: cs.primary),
              hintText: 'Например: Москва / Saint Petersburg',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.60),
              ),
              suffixIcon: _cityController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Очистить',
                      onPressed: () {
                        setState(() {
                          _cityController.clear();
                          _citySuggestions = [];
                          _selectedLat = null;
                          _selectedLon = null;
                          _error = null;
                        });
                      },
                      icon: Icon(
                        Icons.close,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.75),
                      ),
                    ),
            ),
          ),
        ),

        // Suggestions
        if (_citySuggestions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withOpacity(isDark ? 0.35 : 0.7),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _citySuggestions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: theme.dividerColor.withOpacity(isDark ? 0.35 : 0.7),
              ),
              itemBuilder: (context, i) {
                final raw = _citySuggestions[i];
                final display = CityTranslator.getDisplayName(raw);
                return ListTile(
                  dense: true,
                  title: Text(
                    display,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: display.toLowerCase() == raw.toLowerCase()
                      ? null
                      : Text(
                          raw,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.70),
                          ),
                        ),
                  onTap: () => _selectSuggestion(raw),
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Auto detect button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _detectingCity ? null : _detectCityAutomatically,
            icon: _detectingCity
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                    ),
                  )
                : const Icon(Icons.my_location),
            label: const Text('Автоопределение по геолокации'),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.primary,
              side: BorderSide(
                color: cs.primary.withOpacity(isDark ? 0.45 : 0.30),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Preview / coords hint
        if (apiPreview != null)
          Text(
            'Для API будет использовано: $apiPreview',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
            ),
          ),
        if (_selectedLat != null && _selectedLon != null) ...[
          const SizedBox(height: 6),
          Text(
            'Координаты: ${_selectedLat!.toStringAsFixed(5)}, ${_selectedLon!.toStringAsFixed(5)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
            ),
          ),
        ],
      ],
    );
  }

  Widget _notificationsStep() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(
          color: cs.primary.withOpacity(isDark ? 0.18 : 0.12),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Включить уведомления',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            value: _notificationsEnabled,
            activeColor: cs.primary,
            onChanged: (v) async {
              setState(() => _notificationsEnabled = v);

              // Автосохранение
              await _savePreferencesPatch({
                'notifications_enabled': _notificationsEnabled,
                'morning_reminder_time': _reminderTime.text.trim(),
              });
            },
          ),
          Divider(color: theme.dividerColor.withOpacity(isDark ? 0.45 : 0.75)),
          TextField(
            controller: _reminderTime,
            keyboardType: TextInputType.datetime,
            onChanged: (value) async {
              // Автосохранение
              await _savePreferencesPatch({
                'notifications_enabled': _notificationsEnabled,
                'morning_reminder_time': value.trim(),
              });
            },
            decoration: const InputDecoration(
              labelText: 'Время (HH:MM)',
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String key, Set<String> preferred, Set<String> avoid) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final isPreferred = preferred.contains(key);

    return FilterChip(
      label: Text(translateStyle(key)),
      selected: isPreferred,
      showCheckmark: true,
      checkmarkColor: primary,
      backgroundColor: theme.cardColor,
      selectedColor: primary.withOpacity(isDark ? 0.14 : 0.10),
      side: BorderSide(
        color: isPreferred
            ? primary.withOpacity(isDark ? 0.55 : 0.35)
            : theme.dividerColor.withOpacity(isDark ? 0.35 : 0.70),
        width: 1,
      ),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: isPreferred
            ? theme.textTheme.bodyLarge?.color
            : theme.textTheme.bodyMedium?.color,
      ),
      onSelected: (v) async {
        setState(() {
          if (v) {
            preferred.add(key);
            avoid.remove(key);
          } else if (preferred.length > 1) {
            preferred.remove(key);
          }
        });

        // Автосохранение
        await _savePreferencesPatch({
          'preferred_styles': _preferredStyles.toList(),
          'avoid_styles': _avoidStyles.toList(),
        });
      },
    );
  }

  Widget _buildAvoidChip(String key, Set<String> avoid, Set<String> preferred) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final error = theme.colorScheme.error;

    final isAvoided = avoid.contains(key);

    return FilterChip(
      label: Text(translateStyle(key)),
      selected: isAvoided,
      showCheckmark: true,
      checkmarkColor: error,
      backgroundColor: theme.cardColor,
      selectedColor: error.withOpacity(isDark ? 0.14 : 0.10),
      side: BorderSide(
        color: isAvoided
            ? error.withOpacity(isDark ? 0.55 : 0.35)
            : theme.dividerColor.withOpacity(isDark ? 0.35 : 0.70),
        width: 1,
      ),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: isAvoided
            ? theme.textTheme.bodyLarge?.color
            : theme.textTheme.bodyMedium?.color,
      ),
      onSelected: (v) async {
        setState(() {
          if (v) {
            avoid.add(key);
            preferred.remove(key);
            if (preferred.isEmpty) preferred.add('casual');
          } else {
            avoid.remove(key);
          }
        });

        // Автосохранение
        await _savePreferencesPatch({
          'preferred_styles': _preferredStyles.toList(),
          'avoid_styles': _avoidStyles.toList(),
        });
      },
    );
  }
}

class _ColorGrid extends StatelessWidget {
  final Set<String> selected;
  final void Function(String colorKey) onToggle;

  const _ColorGrid({
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: kColors.map((c) {
        final isSel = selected.contains(c);
        final sw = kColorSwatches[c] ?? Colors.grey;

        final borderColor = isSel
            ? cs.primary
            : theme.dividerColor.withOpacity(isDark ? 0.55 : 0.75);

        return GestureDetector(
          onTap: () => onToggle(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: sw,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: isSel ? 2.5 : 1,
              ),
              boxShadow: [
                if (isSel)
                  BoxShadow(
                    color: cs.primary.withOpacity(0.22),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: isSel
                ? Icon(
                    Icons.check,
                    color: c == 'white' || c == 'yellow'
                        ? Colors.black
                        : Colors.white,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _PrimarySoftButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback? onPressed;

  const _PrimarySoftButton({
    required this.text,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return theme.cardColor.withOpacity(isDark ? 0.55 : 0.80);
          }
          return theme.cardColor;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return theme.textTheme.bodyMedium?.color?.withOpacity(0.45);
          }
          return primary;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          final base =
              states.contains(WidgetState.disabled) ? theme.dividerColor : primary;
          return BorderSide(
            color: base.withOpacity(isDark ? 0.50 : 0.35),
            width: 1.2,
          );
        }),
        overlayColor: WidgetStateProperty.all(primary.withOpacity(0.10)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      child: loading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
            )
          : Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
    );
  }
}