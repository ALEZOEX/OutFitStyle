import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../models/outfit.dart';
import '../models/recommendation.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/city_translator.dart';
import '../utils/location_helper.dart';
import '../widgets/alternative_outfits.dart';
import '../widgets/onboarding_dialog.dart';
import '../widgets/top_outfit_card.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final ApiService _api;
  final TextEditingController _cityController =
      TextEditingController(text: 'Москва');
  bool _isLocationLoading = true;

  Recommendation? _recommendation;
  bool _isLoading = true;
  String? _error;
  String? _errorDetails;
  int _selectedRating = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _api = ApiService();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Запрашиваем разрешение на геолокацию
    _requestLocationPermission();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      OnboardingDialog.showIfNeeded(context);
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    try {
      // Проверяем сервисы локации
      bool serviceEnabled = await LocationHelper.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Показываем диалог для включения сервисов локации
        _showLocationServicesDisabledDialog();
        return;
      }

      // Запрашиваем разрешение
      LocationPermission permission = await LocationHelper.requestPermission();

      if (permission == LocationPermission.denied) {
        // Показываем диалог для настройки разрешений
        _showPermissionDeniedDialog();
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        // Пользователь навсегда отклонил разрешение
        _showPermissionDeniedForeverDialog();
        return;
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        _getCurrentPosition();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cityController.text = 'Moscow';
          _isLocationLoading = false;
        });
        _loadData();
      }
    }
  }

  Future<void> _getCurrentPosition() async {
    try {
      setState(() => _isLocationLoading = true);

      // Получаем текущее местоположение
      Position? position = await LocationHelper.getCurrentPosition();
      if (position == null) {
        _fallbackToDefaultCity();
        return;
      }

      // Получаем город по координатам
      String? city = await LocationHelper.getCityFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (city != null) {
        // Переводим город на английский для API
        String translatedCity = CityTranslator.translate(city);

        if (mounted) {
          setState(() {
            _cityController.text = city; // Для отображения пользователю
            _isLocationLoading = false;
          });
          _loadDataWithCity(translatedCity);
        }
      } else {
        _fallbackToDefaultCity();
      }
    } catch (e) {
      _fallbackToDefaultCity();
    }
  }

  void _fallbackToDefaultCity() {
    if (mounted) {
      setState(() {
        _cityController.text = 'Moscow';
        _isLocationLoading = false;
      });
      _loadData();
    }
  }

  Future<void> _loadDataWithCity(String city) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _errorDetails = null;
    });

    try {
      final recommendation = await _api.getRecommendations(city);
      if (mounted) {
        setState(() {
          _recommendation = recommendation;
          _isLoading = false;
        });
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Ошибка загрузки данных';
        String? details;
        final errorDescription = e.toString().toLowerCase();

        if (errorDescription.contains('404') ||
            errorDescription.contains('city not found')) {
          errorMessage = 'Город не найден';
          details =
              'Проверьте правильность названия города. Попробуйте использовать английское название (например, "New York").';
        } else if (errorDescription.contains('400')) {
          errorMessage = 'Неверный запрос';
          details =
              'Попробуйте ввести название города на английском языке, например: Moscow, London, Paris.';
        } else if (errorDescription.contains('timeout')) {
          errorMessage = 'Сервер не отвечает';
          details =
              'Превышено время ожидания. Проверьте ваше подключение к интернету или попробуйте позже.';
        } else if (errorDescription.contains('failed hostlookup') ||
            errorDescription.contains('socketexception')) {
          errorMessage = 'Нет подключения к интернету';
          details = 'Проверьте ваше сетевое подключение и попробуйте снова.';
        } else if (errorDescription.contains('connection refused')) {
          errorMessage = 'Сервер недоступен';
          details =
              'Не удается подключиться к серверу. Убедитесь, что все компоненты запущены.';
        } else {
          details = e.toString();
        }

        setState(() {
          _error = errorMessage;
          _errorDetails = details;
          _isLoading = false;
        });
      }
    }
  }

  void _showLocationServicesDisabledDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сервисы локации отключены'),
        content: const Text(
            'Пожалуйста, включите сервисы локации в настройках устройства для автоматического определения вашего города.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await LocationHelper.openLocationSettings();
              if (mounted) {
                _requestLocationPermission();
              }
            },
            child: const Text('Настройки'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Разрешение на локацию'),
        content: const Text(
            'Пожалуйста, разрешите доступ к вашему местоположению для автоматического определения города.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await LocationHelper.openAppSettings();
              if (mounted) {
                _requestLocationPermission();
              }
            },
            child: const Text('Настроить'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedForeverDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Нет доступа к локации'),
        content: const Text(
            'Вы навсегда запретили доступ к местоположению. Пожалуйста, вручную введите город в поиске.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _cityController.text = 'Moscow';
          _isLocationLoading = false;
        });
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    if (_isLocationLoading) return;

    final cityText = _cityController.text;
    if (cityText.isEmpty || cityText == '...') {
      _fallbackToDefaultCity();
      return;
    }

    final translatedCity = CityTranslator.translate(cityText);
    _loadDataWithCity(translatedCity);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: theme.primaryColor,
          child: _buildBody(isDark, themeProvider),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark, ThemeProvider themeProvider) {
    if (_isLoading) {
      return _buildLoadingState(isDark);
    }
    if (_error != null) {
      return _buildErrorWidget(isDark);
    }
    if (_recommendation == null) {
      return const Center(
        child: Text('Введите город для получения рекомендаций'),
      );
    }

    return CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(isDark, themeProvider),
                const SizedBox(height: 16),
                _buildSearchPanel(isDark),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildWeatherCard(isDark),
                      const SizedBox(height: 32),
                      _buildOutfitSection(isDark),
                      const SizedBox(height: 32),
                      _buildRatingPanel(isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark, ThemeProvider themeProvider) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderButton(
            icon: Icons.person_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            isDark: isDark,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? AppTheme.primaryGradientDark
                        : AppTheme.primaryGradientLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.checkroom,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Text(
                  'OutfitStyle',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderButton(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            onTap: () => themeProvider.toggleTheme(),
            isDark: isDark,
            iconColor: isDark ? Colors.amber : theme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final color = theme.primaryColor;
    return Material(
      color: color.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            icon,
            color: iconColor ?? color,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchPanel(bool isDark) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: theme.primaryColor.withValues(alpha: 0.3))
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _cityController,
              enabled: !_isLocationLoading,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: _isLocationLoading
                    ? 'Определяем ваше местоположение...'
                    : 'Введите город (например: Moscow)',
                hintStyle: TextStyle(
                  color:
                      theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                prefixIcon: _isLocationLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.location_city, color: theme.primaryColor),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => _loadData(),
            ),
          ),
          if (!_isLocationLoading)
            Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradientLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: _loadData,
                tooltip: 'Найти',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(bool isDark) {
    final theme = Theme.of(context);

    if (_recommendation == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: theme.primaryColor.withValues(alpha: 0.3))
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                )
              ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: theme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                _recommendation!.location,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_recommendation!.temperature.round()}°C',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _recommendation!.weather,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.scaffoldBackgroundColor
                  : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(Icons.water_drop, 'Влажность',
                    '${_recommendation!.humidity}%', isDark),
                Container(
                  width: 1,
                  height: 50,
                  color: isDark ? const Color(0xFF666666) : Colors.grey[300],
                ),
                _buildWeatherDetail(
                  Icons.air,
                  'Ветер',
                  '${_recommendation!.windSpeed.toStringAsFixed(1)} м/с',
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _recommendation!.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(
      IconData icon, String label, String value, bool isDark) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.primaryColor, size: 28),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOutfitSection(bool isDark) {
    if (_recommendation == null || _recommendation!.items.isEmpty) {
      return const SizedBox.shrink();
    }
    final outfitRecommendations = OutfitRecommendations.fromItems(
      _recommendation!.items,
      _recommendation!.temperature,
      _recommendation!.weather,
    );
    return Column(
      children: [
        TopOutfitCard(
          outfit: outfitRecommendations.topChoice,
          isDark: isDark,
          onSelect: (_) => _onOutfitSelected(outfitRecommendations.topChoice),
        ),
        const SizedBox(height: 32),
        AlternativeOutfits(
          alternatives: outfitRecommendations.alternatives,
          isDark: isDark,
          onSelect: _onOutfitSelected,
        ),
      ],
    );
  }

  void _onOutfitSelected(OutfitSet outfit) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppTheme.primaryGradientDark
                          : AppTheme.primaryGradientLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.checkroom, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Детали комплекта',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          'Уверенность: ${(outfit.confidence * 100).toInt()}%',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reason
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.backgroundDark
                            : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        outfit.reason,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Items
                    Text(
                      'Состав комплекта:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...outfit.items
                        .map((item) => _buildOutfitItem(item, theme)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitItem(ClothingItem item, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.1) ??
              Colors.grey,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.iconEmoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  item.category,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          if (item.mlScore != null)
            Text(
              '${(item.mlScore! * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingPanel(bool isDark) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: theme.primaryColor.withValues(alpha: 0.3))
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                )
              ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Оцените рекомендацию',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: index < _selectedRating
                        ? const Color(0xFFffc107)
                        : const Color(0xFF9E9E9E),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ваша оценка помогает улучшить AI!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          if (_selectedRating > 0) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text(
                  'Отправить оценку',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0 || _recommendation == null) return;

    try {
      await _api.submitRating(
        userId: 1,
        recommendationId: _recommendation!.id,
        rating: _selectedRating,
        feedback: null,
      );

      if (mounted) {
        // Показываем уведомление об успешной отправке
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Спасибо за вашу оценку!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Сбрасываем выбранную оценку
        setState(() {
          _selectedRating = 0;
        });

        // Обновляем рекомендации
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка отправки оценки. Попробуйте позже.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildLoadingState(bool isDark) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
          const SizedBox(height: 20),
          Text(
            'Подбираем идеальный образ...',
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 64, color: AppTheme.danger),
            ),
            const SizedBox(height: 24),
            Text(
              _error ?? 'Ошибка подключения',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            if (_errorDetails != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark
                      ? Border.all(
                          color: AppTheme.danger.withValues(alpha: 0.3))
                      : null,
                ),
                child: Text(
                  _errorDetails!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Попробовать снова'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              icon: Icon(Icons.settings_rounded,
                  color: theme.textTheme.bodyMedium?.color),
              label: Text(
                'Проверить настройки',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
