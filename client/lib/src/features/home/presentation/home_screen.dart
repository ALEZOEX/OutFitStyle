import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../wardrobe/presentation/wardrobe_screen.dart';
import '../../recommendations/presentation/recommendations_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../../domain/entities/weather_data.dart';

/// Провайдер для отслеживания состояния авторизации
final authStateProvider = StateProvider<bool>((ref) => false);

/// Провайдер для данных о погоде на главной странице
final homeWeatherProvider = StateNotifierProvider<HomeWeatherNotifier, WeatherData?>((ref) {
  return HomeWeatherNotifier();
});

class HomeWeatherNotifier extends StateNotifier<WeatherData?> {
  HomeWeatherNotifier() : super(null) {
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    // Mock данные о погоде
    await Future.delayed(const Duration(milliseconds: 500));
    state = const WeatherData(
      latitude: 55.75,
      longitude: 37.61,
      temperature: 18,
      feelsLike: 16,
      humidity: 65,
      windSpeed: 5.2,
      condition: 'partly_cloudy',
      description: 'Переменная облачность',
      locationName: 'Москва',
      iconUrl: null,
    );
  }

  Future<void> refresh() async {
    await _loadWeather();
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.checkroom_outlined),
            selectedIcon: Icon(Icons.checkroom),
            label: 'Гардероб',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Рекомендации',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }

  final List<Widget> _screens = [
    const _HomeContent(),
    const WardrobeScreen(),
    const RecommendationsScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    'Главная',
    'Гардероб',
    'Рекомендации',
    'Настройки',
  ];
}

/// Контент для главной страницы
class _HomeContent extends ConsumerStatefulWidget {
  const _HomeContent();

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
    final theme = Theme.of(context);
    final weatherData = ref.watch(homeWeatherProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(homeWeatherProvider.notifier).refresh();
      },
      child: CustomScrollView(
        slivers: [
          // Приветствие
          SliverToBoxAdapter(
            child: _buildGreeting(context),
          ),
          // Погода
          SliverToBoxAdapter(
            child: _buildWeatherCard(context, weatherData),
          ),
          // Быстрые действия
          SliverToBoxAdapter(
            child: _buildQuickActions(context),
          ),
          // Статистика гардероба
          SliverToBoxAdapter(
            child: _buildWardrobeStats(context),
          ),
          // Последние рекомендации
          SliverToBoxAdapter(
            child: _buildRecentRecommendations(context),
          ),
          // Совет дня
          SliverToBoxAdapter(
            child: _buildDailyTip(context),
          ),
          // Отступ снизу
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }

  /// Приветствие
  Widget _buildGreeting(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 6) {
      greeting = 'Доброй ночи!';
    } else if (hour < 12) {
      greeting = 'Доброе утро!';
    } else if (hour < 18) {
      greeting = 'Добрый день!';
    } else {
      greeting = 'Добрый вечер!';
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'OutfitStyle',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            // Аватар или иконка профиля
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Карточка погоды
  Widget _buildWeatherCard(BuildContext context, WeatherData? weatherData) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          shadowColor: theme.colorScheme.primary.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.8),
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weatherData?.locationName ?? 'Москва',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${weatherData?.temperature?.round() ?? 18}°C',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 56,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(
                          _getWeatherIcon(weatherData?.condition),
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weatherData?.description ?? 'Переменная облачность',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Детали погоды
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherDetail(
                      context,
                      icon: Icons.thermometer_outlined,
                      label: 'Ощущается',
                      value: '${weatherData?.feelsLike?.round() ?? 16}°C',
                    ),
                    _buildWeatherDetail(
                      context,
                      icon: Icons.water_drop,
                      label: 'Влажность',
                      value: '${weatherData?.humidity ?? 65}%',
                    ),
                    _buildWeatherDetail(
                      context,
                      icon: Icons.air,
                      label: 'Ветер',
                      value: '${weatherData?.windSpeed ?? 5.2} м/с',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// Быстрые действия
  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Быстрые действия',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.auto_awesome,
                    label: 'Outfit дня',
                    color: theme.colorScheme.primary,
                    onTap: () => _navigateToRecommendations(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.add_circle_outline,
                    label: 'Добавить вещь',
                    color: theme.colorScheme.secondary,
                    onTap: () => _navigateToWardrobe(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Планы',
                    color: theme.colorScheme.tertiary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Функция в разработке')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Статистика гардероба
  Widget _buildWardrobeStats(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: () => _navigateToWardrobe(context),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Гардероб',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          context,
                          icon: Icons.checkroom,
                          value: '12',
                          label: 'Вещей',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          icon: Icons.favorite,
                          value: '5',
                          label: 'Избранное',
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          icon: Icons.category,
                          value: '6',
                          label: 'Категорий',
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Последние рекомендации
  Widget _buildRecentRecommendations(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Популярное',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToRecommendations(context),
                  child: const Text('Все'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Горизонтальный список рекомендаций
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildRecommendationPreview(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationPreview(BuildContext context, int index) {
    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
      theme.colorScheme.tertiaryContainer,
    ];

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _navigateToRecommendations(context),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors[index % colors.length],
                      colors[(index + 1) % colors.length],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 32,
                    ),
                    const Spacer(),
                    Text(
                      'Outfit #${index + 1}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Рекомендация дня',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Совет дня
  Widget _buildDailyTip(BuildContext context) {
    final theme = Theme.of(context);
    final tips = [
      'Сочетайте контрастные цвета для создания яркого образа',
      'Многослойность — ключ к стильному образу в прохладную погоду',
      'Аксессуары могут полностью изменить ваш outfit',
      'Подбирайте обувь под ремень для классического стиля',
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.tertiaryContainer.withOpacity(0.5),
                  theme.colorScheme.secondaryContainer.withOpacity(0.3),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb,
                    color: theme.colorScheme.tertiary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Совет дня',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tips[DateTime.now().day % tips.length],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToRecommendations(BuildContext context) {
    // Навигация на вкладку рекомендаций
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    homeState?._onItemTapped(2);
  }

  void _navigateToWardrobe(BuildContext context) {
    // Навигация на вкладку гардероба
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    homeState?._onItemTapped(1);
  }

  IconData _getWeatherIcon(String? condition) {
    return switch (condition?.toLowerCase()) {
      'sunny' || 'ясно' => Icons.wb_sunny,
      'cloudy' || 'облачно' => Icons.cloud,
      'rainy' || 'дождь' => Icons.grain,
      'snowy' || 'снег' => Icons.ac_unit,
      'partly_cloudy' || 'переменная облачность' => Icons.cloud,
      _ => Icons.wb_sunny,
    };
  }
}
