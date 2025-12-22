import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../utils/preferences_constants.dart';
import 'city_picker_screen.dart';

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
  CityPickerResult? _location;

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
    try {
      await context.read<ProfileProvider>().updatePreferences(patch);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveProfilePatch(Map<String, dynamic> patch) async {
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
      await _savePreferencesPatch({'temperature_sensitivity': _tempSens});
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

    if (_step >= _totalSteps - 1) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
      }
      return;
    }

    setState(() => _step++);
    _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
    _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B1025),
              Color(0xFF0F172A),
              Color(0xFF121212),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3F4F6),
              Color(0xFFF8FAFC),
              Color(0xFFFFFFFF),
            ],
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: _Header(
                  step: _step,
                  total: _totalSteps,
                  onBack: _step > 0 ? _back : null,
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPage(
                      title: 'Какой у вас стиль?',
                      subtitle: 'Выберите то, что вам ближе',
                      icon: Icons.checkroom,
                      child: _stylesStep(),
                    ),
                    _buildPage(
                      title: 'Любимые цвета',
                      subtitle: 'Что вам нравится носить?',
                      icon: Icons.palette,
                      child: _colorsStep(),
                    ),
                    _buildPage(
                      title: 'Как вы переносите холод?',
                      subtitle: 'Настроим подбор одежды под вас',
                      icon: Icons.thermostat,
                      child: _tempStep(),
                    ),
                    _buildPage(
                      title: 'Где вы находитесь?',
                      subtitle: 'Чтобы знать погоду за окном',
                      icon: Icons.location_on,
                      child: _locationStep(),
                    ),
                    _buildPage(
                      title: 'Быть в курсе?',
                      subtitle: 'Напоминания о погоде утром',
                      icon: Icons.notifications_active,
                      child: _notificationsStep(),
                    ),
                  ],
                ),
              ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _ErrorBanner(text: _error!),
                ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _PrimaryGradientButton(
                  text: _step == _totalSteps - 1 ? 'Завершить' : 'Далее',
                  isLoading: _saving,
                  onPressed: _saving ? null : _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _GradientIconBox(icon: icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.3,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(isDark ? 0.9 : 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          _SurfaceCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: child,
          ),
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
          'Предпочитаемые (2-3)',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: kStyles
              .map((s) => _buildChip(s, _preferredStyles, _avoidStyles))
              .toList(),
        ),
        const SizedBox(height: 20),
        Text(
          'Избегать',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
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
          'Любимые',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 20),
        Text(
          'Избегать',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
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
    );
  }

  Widget _tempStep() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color valueColor() {
      if (_tempSens <= -2) return AppTheme.secondary;
      if (_tempSens == -1) return AppTheme.primary;
      if (_tempSens == 0) return theme.primaryColor;
      if (_tempSens == 1) return AppTheme.warning;
      return AppTheme.danger;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Чувствительность',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SurfaceCard(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? AppTheme.primaryGradientDark
                            : AppTheme.primaryGradientLight,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.22),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.thermostat, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$_tempSens  (-2: Мёрзну … +2: Жарко)',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.25,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    Text(
                      '$_tempSens',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: valueColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: theme.primaryColor,
            inactiveTrackColor: theme.primaryColor.withOpacity(0.25),
            thumbColor: theme.primaryColor,
            overlayColor: theme.primaryColor.withOpacity(0.18),
            trackHeight: 4,
          ),
          child: Slider(
            value: _tempSens.toDouble(),
            min: -2,
            max: 2,
            divisions: 4,
            onChanged: (v) => setState(() => _tempSens = v.round()),
          ),
        ),
      ],
    );
  }

  Widget _locationStep() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () async {
        final res = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CityPickerScreen()),
        );
        if (res is CityPickerResult) setState(() => _location = res);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark ? AppTheme.backgroundDark : theme.scaffoldBackgroundColor,
          border: Border.all(
            color: theme.primaryColor.withOpacity(isDark ? 0.28 : 0.16),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: theme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _location?.displayName ?? 'Нажмите, чтобы выбрать город',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _location == null
                      ? theme.textTheme.bodyMedium?.color
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationsStep() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color:
                isDark ? AppTheme.backgroundDark : theme.scaffoldBackgroundColor,
            border: Border.all(
              color: theme.primaryColor.withOpacity(isDark ? 0.25 : 0.14),
            ),
          ),
          child: SwitchListTile(
            title: Text(
              'Включить уведомления',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Text(
              'Короткое напоминание утром',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
            value: _notificationsEnabled,
            activeColor: theme.primaryColor,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color:
                isDark ? AppTheme.backgroundDark : theme.scaffoldBackgroundColor,
            border: Border.all(
              color: theme.primaryColor.withOpacity(isDark ? 0.20 : 0.12),
            ),
          ),
          child: TextField(
            controller: _reminderTime,
            keyboardType: TextInputType.datetime,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              labelText: 'Время (HH:MM)',
              labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
              hintText: '08:00',
              hintStyle:
                  TextStyle(color: theme.textTheme.bodyMedium?.color),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.schedule, color: theme.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String key, Set<String> selected, Set<String> anti) {
    final theme = Theme.of(context);
    final isSelected = selected.contains(key);
    final isDark = theme.brightness == Brightness.dark;

    return FilterChip(
      label: Text(translateStyle(key)),
      selected: isSelected,
      onSelected: (v) => setState(() {
        if (v) {
          selected.add(key);
          anti.remove(key);
        } else if (selected.length > 1) {
          selected.remove(key);
        }
      }),
      backgroundColor: isDark
          ? const Color(0xFF141A2E)
          : theme.cardColor.withOpacity(0.7),
      selectedColor: theme.primaryColor.withOpacity(isDark ? 0.26 : 0.18),
      checkmarkColor: theme.primaryColor,
      side: BorderSide(
        color: isSelected
            ? theme.primaryColor.withOpacity(0.65)
            : theme.textTheme.bodyMedium?.color?.withOpacity(isDark ? 0.22 : 0.18) ??
                Colors.grey,
      ),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: isSelected
            ? theme.textTheme.bodyLarge?.color
            : theme.textTheme.bodyMedium?.color,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }

  Widget _buildAvoidChip(String key, Set<String> selected, Set<String> anti) {
    final theme = Theme.of(context);
    final isSelected = selected.contains(key);
    final isDark = theme.brightness == Brightness.dark;

    return FilterChip(
      label: Text(translateStyle(key)),
      selected: isSelected,
      onSelected: (v) => setState(() {
        if (v) {
          selected.add(key);
          anti.remove(key);
          if (anti.isEmpty) anti.add('casual');
        } else {
          selected.remove(key);
        }
      }),
      backgroundColor: isDark
          ? const Color(0xFF17131A)
          : theme.cardColor.withOpacity(0.7),
      selectedColor: AppTheme.danger.withOpacity(isDark ? 0.22 : 0.14),
      checkmarkColor: AppTheme.danger,
      side: BorderSide(
        color: isSelected
            ? AppTheme.danger.withOpacity(0.65)
            : theme.textTheme.bodyMedium?.color?.withOpacity(isDark ? 0.22 : 0.18) ??
                Colors.grey,
      ),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: isSelected
            ? theme.textTheme.bodyLarge?.color
            : theme.textTheme.bodyMedium?.color,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }
}

class _Header extends StatelessWidget {
  final int step;
  final int total;
  final VoidCallback? onBack;

  const _Header({
    required this.step,
    required this.total,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = (step + 1) / total;

    return _SurfaceCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Material(
                  color: theme.primaryColor.withOpacity(isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: onBack,
                    child: Icon(
                      Icons.arrow_back,
                      color: onBack == null
                          ? theme.textTheme.bodyMedium?.color?.withOpacity(0.35)
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Шаг ${step + 1} из $total',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(isDark ? 0.18 : 0.12),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(theme.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(total, (i) {
                        final active = i <= step;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 16 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: active
                                ? theme.primaryColor
                                : theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(isDark ? 0.22 : 0.18),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = theme.primaryColor.withOpacity(isDark ? 0.18 : 0.10);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: isDark ? AppTheme.cardGradientDark : AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GradientIconBox extends StatelessWidget {
  final IconData icon;

  const _GradientIconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.primaryGradientDark : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(isDark ? 0.28 : 0.20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }
}

class _PrimaryGradientButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PrimaryGradientButton({
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null;

    final gradient = isEnabled ? AppTheme.primaryGradientDark : const LinearGradient(
      colors: [Color(0xFF2A2F45), Color(0xFF2A2F45)],
    );

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(isEnabled ? 0.25 : 0.10),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String text;
  const _ErrorBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.danger.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Обновлённый _ColorGrid под тёмный дизайн
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
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: kColors.map((c) {
        final isSel = selected.contains(c);
        final sw = kColorSwatches[c] ?? Colors.grey;

        final ringColor = isSel
            ? theme.primaryColor
            : theme.textTheme.bodyMedium?.color?.withOpacity(isDark ? 0.22 : 0.18) ??
                Colors.grey;

        return GestureDetector(
          onTap: () => onToggle(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: sw,
              shape: BoxShape.circle,
              border: Border.all(color: ringColor, width: isSel ? 3 : 1),
              boxShadow: [
                if (isSel)
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.35),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
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