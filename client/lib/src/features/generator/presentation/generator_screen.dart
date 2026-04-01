import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../recommendations/presentation/providers/recommendations_provider.dart';
import '../../../presentation/providers/weather_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/logger.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({super.key});

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedOccasion = 'casual';
  String _selectedActivity = 'everyday';
  double _temperatureOverride = 20;
  bool _useCurrentWeather = true;

  final _occasions = [
    {
      'id': 'casual',
      'label': 'Повседневный',
      'icon': Icons.checkroom,
      'color': AppColors.primary,
    },
    {
      'id': 'business',
      'label': 'Деловой',
      'icon': Icons.business_center,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'id': 'sport',
      'label': 'Спорт',
      'icon': Icons.sports,
      'color': AppColors.warning,
    },
    {
      'id': 'evening',
      'label': 'Вечерний',
      'icon': Icons.nightlight,
      'color': const Color(0xFF6366F1),
    },
    {
      'id': 'romantic',
      'label': 'Романтический',
      'icon': Icons.favorite,
      'color': AppColors.secondary,
    },
  ];

  final _activities = [
    {'id': 'everyday', 'label': 'Каждый день', 'icon': Icons.calendar_today},
    {'id': 'work', 'label': 'Работа', 'icon': Icons.work},
    {'id': 'walk', 'label': 'Прогулка', 'icon': Icons.park},
    {'id': 'party', 'label': 'Вечеринка', 'icon': Icons.celebration},
    {'id': 'date', 'label': 'Свидание', 'icon': Icons.favorite},
    {'id': 'travel', 'label': 'Путешествие', 'icon': Icons.flight_takeoff},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Генератор'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () {
              setState(() {
                _selectedOccasion = 'casual';
                _selectedActivity = 'everyday';
                _temperatureOverride = 20;
                _useCurrentWeather = true;
              });
            },
            tooltip: 'Сбросить',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      title: 'Случай',
                      icon: Icons.event,
                      child: _buildOccasionSelector(context),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSection(
                      context,
                      title: 'Активность',
                      icon: Icons.directions_run,
                      child: _buildActivitySelector(context),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSection(
                      context,
                      title: 'Температура',
                      icon: Icons.thermostat,
                      child: _buildTemperatureSelector(context),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildGenerateButton(context, state),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Glass секция
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: AppRadius.radiusXl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text(title, style: AppTypography.labelLarge(context)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              child,
            ],
          ),
        ),
      ),
    );
  }

  /// Карточки случая — компактные, без толстых бордеров
  Widget _buildOccasionSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _occasions.map((occasion) {
        final isSelected = _selectedOccasion == occasion['id'];
        final color = occasion['color'] as Color;

        return GestureDetector(
          onTap: () =>
              setState(() => _selectedOccasion = occasion['id'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: isDark ? 0.2 : 0.12)
                  : Colors.transparent,
              borderRadius: AppRadius.radiusPill,
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.6)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppColors.grey200),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  occasion['icon'] as IconData,
                  size: 16,
                  color: isSelected
                      ? color
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  occasion['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? color
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Чипы активности — pill-стиль
  Widget _buildActivitySelector(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _activities.map((activity) {
        final isSelected = _selectedActivity == activity['id'];

        return GestureDetector(
          onTap: () =>
              setState(() => _selectedActivity = activity['id'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm - 2,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: AppRadius.radiusPill,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppColors.grey200),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  activity['icon'] as IconData,
                  size: 14,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  activity['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTemperatureSelector(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _useCurrentWeather
                    ? 'Использовать текущую погоду'
                    : 'Температура: ${_temperatureOverride.round()}°C',
                style: AppTypography.bodyMedium(
                  context,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: _useCurrentWeather,
                onChanged: (value) =>
                    setState(() => _useCurrentWeather = value),
              ),
            ),
          ],
        ),
        if (!_useCurrentWeather) ...[
          const SizedBox(height: AppSpacing.sm),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _temperatureOverride,
              min: -20,
              max: 40,
              divisions: 60,
              label: '${_temperatureOverride.round()}°C',
              onChanged: (value) =>
                  setState(() => _temperatureOverride = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('-20°', style: AppTypography.bodySmall(context)),
                Text('40°', style: AppTypography.bodySmall(context)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenerateButton(
    BuildContext context,
    RecommendationsState state,
  ) {
    final isGenerating = state.isGenerating;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isGenerating ? null : AppGradients.heroButton,
          color: isGenerating ? AppColors.grey200 : null,
          borderRadius: AppRadius.radiusPill,
          boxShadow: isGenerating
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isGenerating ? null : () => _generateRecommendation(context),
            borderRadius: AppRadius.radiusPill,
            child: Center(
              child: isGenerating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Генерация...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Сгенерировать образ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateRecommendation(BuildContext context) async {
    AppLogger.info('[GeneratorScreen] _generateRecommendation вызван');

    final notifier = ref.read(recommendationsProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    double? temperature = _useCurrentWeather ? null : _temperatureOverride;
    if (_useCurrentWeather) {
      try {
        final weatherAsync = await ref.read(
          weatherProvider((lat: 55.7558, lon: 37.6173)).future,
        );
        temperature = weatherAsync.temperature ?? temperature;
      } catch (e) {
        AppLogger.warning('[GeneratorScreen] Ошибка получения погоды: $e');
      }
    }

    final result = await notifier.generateRecommendation(
      temperature: temperature,
      weatherCondition: 'sunny',
      occasion: _selectedOccasion,
    );

    if (!context.mounted) return;

    if (result != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: AppSpacing.sm),
              Text('Образ сгенерирован!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          action: SnackBarAction(
            label: 'Посмотреть',
            textColor: Colors.white,
            onPressed: () => context.go('/recommendations'),
          ),
        ),
      );
    } else {
      final errorMsg =
          ref.read(recommendationsProvider).error ?? 'Что-то пошло не так';
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(errorMsg)),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Повторить',
            textColor: Colors.white,
            onPressed: () => _generateRecommendation(context),
          ),
        ),
      );
    }
  }
}
