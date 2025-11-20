import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';
import '../models/outfit_plan.dart';
import '../models/weather_data.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/outfit_dialog.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  late Future<List<OutfitPlan>> _plansFuture;
  late ApiService _apiService;
  late LocationService _locationService;

  DateTime _selectedDate = DateTime.now();
  String _currentCity = 'Moscow';
  bool _isLoadingWeather = false;
  WeatherData? _weatherData;
  String? _weatherError;

  @override
  void initState() {
    super.initState();

    _apiService = Provider.of<ApiService>(context, listen: false);
    _locationService = LocationService();

    // Важно: сразу инициализируем, чтобы не было LateInitializationError
    _plansFuture = Future.value(<OutfitPlan>[]);

    _loadLocationAndPlans();
  }

  Future<void> _loadLocationAndPlans() async {
    await _getCurrentLocation();
    await _loadPlans();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final status = await _locationService.checkLocationService();

      if (status == LocationPermission.denied) {
        _showLocationServicesDisabledDialog();
        return;
      }

      final permission = await _locationService.requestPermission();

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedForeverDialog();
        return;
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await _getLocationAndWeather();
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      _getWeatherData('Moscow');
    }
  }

  Future<void> _getLocationAndWeather() async {
    try {
      final position = await _locationService.getCurrentPosition();
      final city = await _locationService.getCityFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _currentCity = city ?? 'Moscow';
      });
      _getWeatherData(_currentCity);
    } catch (e) {
      debugPrint('Error getting location data: $e');
      if (mounted) {
        _getWeatherData('Moscow');
      }
    }
  }

  Future<void> _getWeatherData(String city) async {
    setState(() {
      _isLoadingWeather = true;
      _weatherData = null;
      _weatherError = null;
    });

    try {
      final weatherService = WeatherService(
        apiKey: AppConfig.weatherApiKey,
        baseUrl: AppConfig.weatherBaseUrl,
      );

      final weatherData = await weatherService.getWeather(city);

      if (!mounted) return;

      setState(() {
        _weatherData = weatherData;
        _isLoadingWeather = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _weatherError = 'Не удалось загрузить погоду: $e';
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _loadPlans() async {
    setState(() {
      _plansFuture = _apiService.getOutfitPlans(
        userId: 1,
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 14)),
      );
    });

    // Если нужно ждать результат (например, при pull-to-refresh):
    await _plansFuture;
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
              await _locationService.openLocationSettings();
              _getCurrentLocation();
            },
            child: const Text('Настройки'),
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
            'Вы навсегда запретили доступ к местоположению. Пожалуйста, вручную выберите город в настройках профиля.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRecommendations() async {
    if (_isLoadingWeather) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, подождите загрузки погоды')),
      );
      return;
    }

    if (_weatherData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Погода не загружена')),
      );
      return;
    }

    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final isDark = themeProvider.isDarkMode;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      );

      final recommendation = await _apiService.getRecommendations(_currentCity);

      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => OutfitDialog(
          recommendation: recommendation,
          weatherData: _weatherData!,
          onOutfitSelected: (outfitItems) async {
            Navigator.pop(context);
            await _showAddPlanDialog(outfitItems);
          },
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка получения рекомендаций: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _showAddPlanDialog(
    List<Map<String, dynamic>> outfitItems,
  ) async {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          String notes = '';
          bool isCreating = false;

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
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
                          child: const Icon(Icons.calendar_today,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Новый план нарядов',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                DateFormat('d MMMM yyyy', 'ru_RU')
                                    .format(_selectedDate),
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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_weatherData != null) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.backgroundDark
                                    : const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.primaryColor.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.wb_sunny,
                                      color: theme.primaryColor, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Температура: ${_weatherData!.temperature.toStringAsFixed(1)}°C, ${_weatherData!.condition}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            'Выбранные вещи',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...outfitItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: isDark
                                          ? AppTheme.primaryGradientDark
                                          : AppTheme.primaryGradientLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item['icon_emoji'] ?? '👕',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    item['name'] ?? 'Без названия',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 20),
                          Text(
                            'Примечания (опционально)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (value) => notes = value,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Добавьте примечания к плану...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? theme.textTheme.bodyMedium?.color
                                              ?.withOpacity(0.3) ??
                                          Colors.grey
                                      : Colors.grey,
                                ),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF2D2D2D)
                                  : const Color(0xFFF8F9FA),
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color:
                                    isDark ? Colors.grey : theme.primaryColor,
                              ),
                            ),
                            child: Text(
                              'Отмена',
                              style: TextStyle(
                                color:
                                    isDark ? Colors.grey : theme.primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isCreating
                                ? null
                                : () async {
                                    setState(() => isCreating = true);
                                    final success = await _createOutfitPlan(
                                      _selectedDate,
                                      outfitItems
                                          .map((item) => item['id'] as int)
                                          .toList(),
                                      notes,
                                      _weatherData?.condition,
                                      _weatherData?.temperature,
                                    );
                                    setState(() => isCreating = false);
                                    if (success && mounted) {
                                      Navigator.pop(context);
                                      _loadPlans();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('План успешно добавлен!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: theme.primaryColor,
                            ),
                            child: isCreating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Добавить план',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _createOutfitPlan(
    DateTime date,
    List<int> itemIds,
    String notes,
    String? weatherCondition,
    double? temperature,
  ) async {
    try {
      await _apiService.createOutfitPlan(
        userId: 1,
        date: date,
        itemIds: itemIds,
        notes: notes.isNotEmpty ? notes : null,
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка создания плана: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return false;
    }
  }

  void _fabAction() {
    _showRecommendations();
  }

  void _editPlan(OutfitPlan plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Функция редактирования плана будет реализована позже',
        ),
      ),
    );
  }

  Future<void> _deletePlan(OutfitPlan plan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение удаления'),
        content: const Text(
            'Вы уверены, что хотите удалить этот план? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteOutfitPlan(1, plan.id);
        await _loadPlans();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('План успешно удален')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления плана: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Планировщик'),
        centerTitle: true,
        backgroundColor: isDark ? theme.cardColor : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
        shadowColor: isDark
            ? Colors.black.withOpacity(0.3)
            : Colors.grey.withOpacity(0.2),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPlans,
        color: theme.primaryColor,
        child: FutureBuilder<List<OutfitPlan>>(
          future: _plansFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Ошибка загрузки: ${snapshot.error}'),
              );
            }

            final plans = snapshot.data ?? [];

            if (plans.isEmpty) {
              return _buildEmptyState(theme, isDark);
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildCityHeader(theme, isDark),
                const SizedBox(height: 16),
                _buildCalendarHeader(plans, theme, isDark),
                const SizedBox(height: 16),
                _buildTodaySection(plans, theme, isDark),
                const SizedBox(height: 16),
                _buildWeatherRecommendations(theme, isDark),
                const SizedBox(height: 16),
                ...plans.map((plan) => _buildPlanItem(plan, theme, isDark)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fabAction,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
        tooltip: 'Получить рекомендации и создать план',
      ),
    );
  }

  Widget _buildCityHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.location_city, color: theme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            _currentCity,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 18),
            onPressed: _getCurrentLocation,
            tooltip: 'Обновить местоположение',
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(
      List<OutfitPlan> plans, ThemeData theme, bool isDark) {
    final today = DateTime.now();
    final days = List<DateTime>.generate(
      7,
      (i) => today.subtract(Duration(days: 3 - i)),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = DateUtils.isSameDay(_selectedDate, day);
          final isToday = DateUtils.isSameDay(today, day);
          final hasPlan =
              plans.any((plan) => DateUtils.isSameDay(plan.date, day));

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = day;
              });
            },
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.primaryColor
                    : isDark
                        ? const Color(0xFF2D2D2D)
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected
                    ? Border.all(color: theme.primaryColor, width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('E', 'ru_RU').format(day),
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white70
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  if (hasPlan) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodaySection(
      List<OutfitPlan> plans, ThemeData theme, bool isDark) {
    final selectedDatePlans = plans
        .where((plan) => DateUtils.isSameDay(plan.date, _selectedDate))
        .toList();

    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    final headerText = isToday
        ? 'Сегодня'
        : DateFormat('d MMMM', 'ru_RU').format(_selectedDate);

    return Card(
      margin: EdgeInsets.zero,
      elevation: isDark ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.today, color: theme.primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    headerText,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppTheme.primaryGradientDark
                          : AppTheme.primaryGradientLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                  onPressed: _showRecommendations,
                  tooltip: 'Создать план',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (selectedDatePlans.isNotEmpty)
              Text(
                'Запланировано: ${selectedDatePlans.length} комплектов',
                style: const TextStyle(fontSize: 15),
              )
            else
              const Text(
                'На этот день планов нет. Добавьте комплект!',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherRecommendations(ThemeData theme, bool isDark) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: isDark ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.wb_sunny, color: theme.primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Рекомендации по погоде',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingWeather)
              const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_weatherError != null)
              Text(
                _weatherError!,
                style: const TextStyle(color: Colors.red),
              )
            else if (_weatherData != null)
              Column(
                children: [
                  Text(
                    'Температура: ${_weatherData!.temperature.toStringAsFixed(1)}°C, ${_weatherData!.condition}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showRecommendations,
                      icon: const Icon(Icons.lightbulb_outline, size: 18),
                      label: const Text('Получить рекомендации'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        side: BorderSide(color: theme.primaryColor, width: 1.5),
                        foregroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              )
            else
              const Text(
                'Не удалось загрузить данные о погоде',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanItem(OutfitPlan plan, ThemeData theme, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDark ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(
          DateFormat('d MMMM yyyy', 'ru_RU').format(plan.date),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${plan.items.length} вещей',
          style: const TextStyle(fontSize: 14),
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              DateFormat('dd').format(plan.date),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plan.notes != null && plan.notes!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Примечания: ${plan.notes}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: plan.items.map((item) {
                    return Chip(
                      label: Text(item.customName),
                      avatar: Text(item.customIcon),
                      backgroundColor: isDark
                          ? const Color(0xFF333333)
                          : const Color(0xFFF0F2F5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _editPlan(plan),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Редактировать'),
                      style: TextButton.styleFrom(
                          foregroundColor: theme.primaryColor),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deletePlan(plan),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Удалить'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Нет запланированных комплектов',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите "+", чтобы создать первый план одежды',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: _showRecommendations,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Создать первый план',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
