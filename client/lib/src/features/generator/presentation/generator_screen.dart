import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../recommendations/presentation/providers/recommendations_provider.dart';
import '../../../presentation/providers/weather_provider.dart';

/// Экран генератора образов — создание персональной рекомендации
class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({super.key});

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Параметры генерации
  String _selectedOccasion = 'casual';
  String _selectedActivity = 'everyday';
  double _temperatureOverride = 20;
  bool _useCurrentWeather = true;

  final _occasions = [
    {'id': 'casual', 'label': 'Повседневный', 'icon': Icons.checkroom, 'color': Colors.blue},
    {'id': 'business', 'label': 'Деловой', 'icon': Icons.business_center, 'color': Colors.purple},
    {'id': 'sport', 'label': 'Спорт', 'icon': Icons.sports, 'color': Colors.orange},
    {'id': 'evening', 'label': 'Вечерний', 'icon': Icons.nightlight, 'color': Colors.indigo},
    {'id': 'romantic', 'label': 'Романтический', 'icon': Icons.favorite, 'color': Colors.pink},
  ];

  final _activities = [
    {'id': 'everyday', 'label': 'На каждый день', 'icon': Icons.calendar_today},
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
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
      body: CustomScrollView(
        slivers: [
          // Заголовок
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          // Параметры генерации
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Случ
                    _buildSection(
                      context,
                      title: 'Случай',
                      icon: Icons.event,
                      child: _buildOccasionSelector(context),
                    ),
                    const SizedBox(height: 20),

                    // Активность
                    _buildSection(
                      context,
                      title: 'Активность',
                      icon: Icons.directions_run,
                      child: _buildActivitySelector(context),
                    ),
                    const SizedBox(height: 20),

                    // Температура
                    _buildSection(
                      context,
                      title: 'Температура',
                      icon: Icons.thermostat,
                      child: _buildTemperatureSelector(context),
                    ),
                    const SizedBox(height: 32),

                    // Кнопка генерации
                    _buildGenerateButton(context, state),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Генератор образов',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Создайте идеальный outfit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
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
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildOccasionSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _occasions.map((occasion) {
        final isSelected = _selectedOccasion == occasion['id'];
        final color = occasion['color'] as Color;

        return GestureDetector(
          onTap: () => setState(() => _selectedOccasion = occasion['id'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.3)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    occasion['icon'] as IconData,
                    color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  occasion['label'] as String,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivitySelector(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _activities.map((activity) {
        final isSelected = _selectedActivity == activity['id'];

        return ChoiceChip(
          avatar: Icon(
            activity['icon'] as IconData,
            size: 18,
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
          label: Text(
            activity['label'] as String,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedActivity = activity['id'] as String);
            }
          },
          selectedColor: theme.colorScheme.primaryContainer,
          checkmarkColor: theme.colorScheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTemperatureSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _useCurrentWeather
                    ? 'Использовать текущую погоду'
                    : 'Температура: ${_temperatureOverride.round()}°C',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: _useCurrentWeather,
              onChanged: (value) {
                setState(() => _useCurrentWeather = value);
              },
            ),
          ],
        ),
        if (!_useCurrentWeather) ...[
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.3),
              thumbColor: theme.colorScheme.primary,
              overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _temperatureOverride,
              min: -20,
              max: 40,
              divisions: 60,
              label: '${_temperatureOverride.round()}°C',
              onChanged: (value) {
                setState(() => _temperatureOverride = value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '-20°C',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.blue,
                  ),
                ),
                Text(
                  '40°C',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenerateButton(BuildContext context, RecommendationsState state) {
    final theme = Theme.of(context);
    final isGenerating = state.isGenerating;

    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isGenerating ? null : () => _generateRecommendation(context),
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: isGenerating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Генерация...',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Сгенерировать образ',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateRecommendation(BuildContext context) async {
    final notifier = ref.read(recommendationsProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Если используем текущую погоду, получаем её
    double? temperature = _useCurrentWeather ? null : _temperatureOverride;
    if (_useCurrentWeather) {
      try {
        final weatherAsync = await ref.read(
          weatherProvider((lat: 55.7558, lon: 37.6173)).future,
        );
        temperature = weatherAsync.temperature ?? temperature;
      } catch (e) {
        // Игнорируем ошибку, используем дефолтную
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
            children: [
              Icon(Icons.check_circle, color: Colors.green[700]),
              const SizedBox(width: 12),
              const Text('Образ сгенерирован!'),
            ],
          ),
          backgroundColor: colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'Посмотреть',
            textColor: Colors.white,
            onPressed: () {
              context.go('/recommendations');
            },
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700]),
              const SizedBox(width: 12),
              const Text('Ошибка генерации'),
            ],
          ),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
