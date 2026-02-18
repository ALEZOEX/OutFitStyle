import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

import '../../wardrobe/presentation/wardrobe_screen.dart';
import '../../recommendations/presentation/recommendations_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../../domain/entities/weather_data.dart';

/// Провайдер для отслеживания состояния авторизации
final authStateProvider = StateProvider<bool>((ref) => false);

/// Провайдер для данных о погоде на главной странице
final homeWeatherProvider = StateNotifierProvider<HomeWeatherNotifier, WeatherState>((ref) {
  return HomeWeatherNotifier();
});

class WeatherState {
  final WeatherData? weather;
  final bool isLoading;
  final String? error;
  final String? locationName;

  const WeatherState({
    this.weather,
    this.isLoading = true,
    this.error,
    this.locationName,
  });

  WeatherState copyWith({
    WeatherData? weather,
    bool? isLoading,
    String? error,
    String? locationName,
  }) {
    return WeatherState(
      weather: weather ?? this.weather,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      locationName: locationName ?? this.locationName,
    );
  }
}

class HomeWeatherNotifier extends StateNotifier<WeatherState> {
  HomeWeatherNotifier() : super(const WeatherState()) {
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    state = const WeatherState(isLoading: true);
    try {
      // Проверка разрешений геолокации
      var locationPermission = await Permission.location.status;
      double? lat, lon;
      String locationName = 'Москва';

      if (locationPermission.isGranted) {
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          lat = position.latitude;
          lon = position.longitude;
          // TODO: Получить название города через reverse geocoding
        } catch (e) {
          // Используем дефолтные координаты
          lat = 55.75;
          lon = 37.61;
        }
      } else {
        // Запрос разрешения
        locationPermission = await Permission.location.request();
        if (locationPermission.isGranted) {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          lat = position.latitude;
          lon = position.longitude;
        } else {
          // Дефолтные координаты
          lat = 55.75;
          lon = 37.61;
        }
      }

      // TODO: Запрос к реальному погодному API
      // Для пока используем mock данные с задержкой
      await Future.delayed(const Duration(milliseconds: 800));
      
      state = WeatherState(
        weather: WeatherData(
          latitude: lat,
          longitude: lon,
          temperature: 12, // Реальная температура будет с API
          feelsLike: 10,
          humidity: 72,
          windSpeed: 4.5,
          condition: 'cloudy',
          description: 'Облачно',
          locationName: locationName,
          iconUrl: null,
        ),
        isLoading: false,
        locationName: locationName,
      );
    } catch (e) {
      state = WeatherState(
        isLoading: false,
        error: 'Ошибка загрузки: $e',
        weather: const WeatherData(
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
        ),
      );
    }
  }

  Future<void> refresh() async {
    await _loadWeather();
  }
}

/// Провайдер для советов дня
final dailyTipsProvider = Provider<List<DailyTip>>((ref) {
  return DailyTipService.getTips();
});

class DailyTip {
  final String id;
  final String text;
  final String category;
  final IconData icon;

  const DailyTip({
    required this.id,
    required this.text,
    required this.category,
    required this.icon,
  });
}

class DailyTipService {
  static List<DailyTip> getTips() {
    final allTips = [
      const DailyTip(
        id: '1',
        text: 'Сочетайте контрастные цвета для создания яркого образа',
        category: 'Стиль',
        icon: Icons.palette,
      ),
      const DailyTip(
        id: '2',
        text: 'Многослойность — ключ к стильному образу в прохладную погоду',
        category: 'Комбинации',
        icon: Icons.layers,
      ),
      const DailyTip(
        id: '3',
        text: 'Аксессуары могут полностью изменить ваш outfit',
        category: 'Стиль',
        icon: Icons.auto_awesome,
      ),
      const DailyTip(
        id: '4',
        text: 'Подбирайте обувь под ремень для классического стиля',
        category: 'Стиль',
        icon: Icons.checkroom,
      ),
      const DailyTip(
        id: '5',
        text: 'Храните одежду на плечиках для сохранения формы',
        category: 'Уход',
        icon: Icons.cleaning_services,
      ),
      const DailyTip(
        id: '6',
        text: 'Проветривайте гардероб для свежести одежды',
        category: 'Уход',
        icon: Icons.air,
      ),
      const DailyTip(
        id: '7',
        text: 'Создавайте капсульный гардероб из базовых вещей',
        category: 'Комбинации',
        icon: Icons.style,
      ),
    ];

    // Выбираем 3-5 случайных советов на день
    final seed = DateTime.now().day;
    final shuffled = List<DailyTip>.from(allTips)..shuffle(math.Random(seed));
    return shuffled.take(4).toList();
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
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          _HomeContent(),
          WardrobeScreen(),
          RecommendationsScreen(),
          SettingsScreen(),
        ],
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
    final weatherState = ref.watch(homeWeatherProvider);

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
            child: _buildWeatherCard(context, weatherState),
          ),
          // Быстрые действия
          SliverToBoxAdapter(
            child: _buildQuickActions(context),
          ),
          // ML Рекомендации дня
          SliverToBoxAdapter(
            child: _buildMLRecommendations(context),
          ),
          // Статистика гардероба
          SliverToBoxAdapter(
            child: _buildWardrobeStats(context),
          ),
          // Советы дня (3-5 штук)
          SliverToBoxAdapter(
            child: _buildDailyTips(context),
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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
  Widget _buildWeatherCard(BuildContext context, WeatherState weatherState) {
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
            child: weatherState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 18,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    weatherState.locationName ?? 'Москва',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${weatherState.weather?.temperature?.round() ?? 18}°C',
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
                                _getWeatherIcon(weatherState.weather?.condition),
                                size: 64,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                weatherState.weather?.description ?? 'Загрузка...',
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
                            icon: Icons.water_drop_outlined,
                            label: 'Ощущается',
                            value: '${weatherState.weather?.feelsLike?.round() ?? 16}°C',
                          ),
                          _buildWeatherDetail(
                            context,
                            icon: Icons.water_drop,
                            label: 'Влажность',
                            value: '${weatherState.weather?.humidity ?? 65}%',
                          ),
                          _buildWeatherDetail(
                            context,
                            icon: Icons.air,
                            label: 'Ветер',
                            value: '${weatherState.weather?.windSpeed ?? 5.2} м/с',
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

  /// ML Рекомендации дня
  Widget _buildMLRecommendations(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Рекомендации дня',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _navigateToRecommendations(context),
                  child: const Text('Все'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Основная рекомендация (большая карточка)
            _buildMainRecommendation(context),
            const SizedBox(height: 12),
            // Альтернативные варианты (маленькие карточки)
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildAltRecommendation(context, 'Кэжуал', Colors.blue),
                  const SizedBox(width: 12),
                  _buildAltRecommendation(context, 'Спорт', Colors.green),
                  const SizedBox(width: 12),
                  _buildAltRecommendation(context, 'Классика', Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainRecommendation(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.checkroom,
              size: 150,
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Выбор ИИ',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Идеальный образ на сегодня',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'На основе погоды и ваших предпочтений',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _navigateToRecommendations(context),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Смотреть'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAltRecommendation(BuildContext context, String title, Color color) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToRecommendations(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.style, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Альтернатива',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
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

  /// Советы дня (3-5 штук)
  Widget _buildDailyTips(BuildContext context) {
    final theme = Theme.of(context);
    final tips = ref.watch(dailyTipsProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: theme.colorScheme.tertiary),
                const SizedBox(width: 8),
                Text(
                  'Советы дня',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildTipCard(context, tip),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(BuildContext context, DailyTip tip) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.tertiary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(tip.icon, color: theme.colorScheme.tertiary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.category,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tip.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRecommendations(BuildContext context) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    homeState?._onItemTapped(2);
  }

  void _navigateToWardrobe(BuildContext context) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    homeState?._onItemTapped(1);
  }

  IconData _getWeatherIcon(String? condition) {
    return switch (condition?.toLowerCase()) {
      'sunny' || 'ясно' => Icons.wb_sunny,
      'cloudy' || 'облачно' => Icons.cloud,
      'rainy' || 'дождь' => Icons.grain,
      'snowy' || 'снег' => Icons.ac_unit,
      'partly_cloudy' || 'переменная облачность' => Icons.partly_cloudy_outlined,
      _ => Icons.wb_sunny,
    };
  }
}
