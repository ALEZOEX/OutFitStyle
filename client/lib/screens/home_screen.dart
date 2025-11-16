import'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/outfit.dart';
import '../models/recommendation.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/city_translator.dart';
import '../widgets/alternative_outfits.dart';
import '../widgets/onboarding_dialog.dart';
import '../widgets/top_outfit_card.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final TextEditingController _cityController =
      TextEditingController(text: 'Moscow');

  Recommendation? _recommendation;
  String? _error;
  String? _errorDetails;
  int _selectedRating = 0;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _loadData();

    WidgetsBinding.instance.addPostFrameCallback((_){
OnboardingDialog.showIfNeeded(context);
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading =true;
      _error = null;
      _errorDetails = null;
    });

    try {
      final translatedCity = CityTranslator.translate(_cityController.text);
      final recommendation = await _api.getRecommendations(translatedCity);

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
        final errorString = e.toString().toLowerCase();

        if (errorString.contains('404') ||
            errorString.contains('city not found')) {
          errorMessage = 'Город не найден';
          details =
              'Проверьте правильность названия города. Попробуйте использовать английское название (например, "New York").';
        } else if(errorString.contains('400')) {
          errorMessage = 'Неверный запрос';
          details =
              'Попробуйте ввести название города на английском языке, например: Moscow, London, Paris.';
        } else if (errorString.contains('timeout')) {
          errorMessage= 'Сервер не отвечает';
          details =
              'Превышено время ожидания. Проверьте ваше подключение к интернету или попробуйте позже.';
        } else if (errorString.contains('failed host lookup') ||
            errorString.contains('socketexception')) {
errorMessage = 'Нет подключения к интернету';
          details = 'Проверьте ваше сетевое подключение и попробуйте снова.';
        } else if (errorString.contains('connection refused')) {
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

 @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF0F2F5),
      body: SingleChildScrollView(
        child: Container(
         padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(isDark),
             const SizedBox(height: 16),
              _buildSearchBar(isDark),
              const SizedBox(height: 24),
              if (_isLoading) ...[
                _buildLoadingState(isDark),
              ] else if (_recommendation != null) ...[
                _buildWeatherCard(isDark),
                const SizedBox(height:32),
                _buildOutfitSection(isDark),
                const SizedBox(height: 32),
                _buildRatingPanel(isDark),
              ] else if (_error != null) ...[
                _buildErrorWidget(isDark),
              ] else ...[
                Center(
                  child: Padding(
                    padding:const EdgeInsets.all(32.0),
                    child: Text(
                      'Введите город для получения рекомендаций',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? AppTheme.textSecondary : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
           ],
          ),
        ),
      ),
    );
  }

Widget _buildHeader(bool isDark){
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderButton(
            icon: Icons.person_outline,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) =>const ProfileScreen())),
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
                        ? AppTheme.primaryGradient
                        : const LinearGradient(
                            colors: [Color(0xFF007bff), Color(0xFF0056b3)]),
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
                    color: isDark ? AppTheme.primary : const Color(0xFF007bff),
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderButton(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            onTap: Provider.of<ThemeProvider>(context).toggleTheme,
isDark: isDark,
            iconColor: isDark ? Colors.amber : const Color(0xFF007bff),
          ),
        ],
),
    );
  }

  Widget _buildHeaderButton(
      {required IconData icon,
      required VoidCallback onTap,
      required bool isDark,
      Color? iconColor}) {
    return Material(
      color: (isDark ? AppTheme.primary : const Color(0xFF007bff))
          .withOpacity(0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
       child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            icon,
            color: iconColor ??
               (isDark ? AppTheme.primary : const Color(0xFF007bff)),
            size: 24,
          ),
        ),
      ),
    );
}

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark :Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: AppTheme.withOpacity(AppTheme.primary, 0.3))
            : null,
boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _cityController,
              style: TextStyle(
                color: isDark ? AppTheme.textPrimary : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Введите город (например: Moscow, London)',
                hintStyle: TextStyle(
                  color: isDark? AppTheme.textSecondary : Colors.grey,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                 Icons.location_city,
                  color: isDark ? AppTheme.primary : const Color(0xFF007bff),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: (_) =>_loadData(),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppTheme.primaryGradient
                  :const LinearGradient(
                      colors: [Color(0xFF007bff), Color(0xFF0056b3)],
),
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
    if (_recommendation == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ?AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: AppTheme.primary.withOpacity(0.3))
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: isDark ? AppTheme.primary : const Color(0xFF007bff),
               size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _recommendation!.location,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textPrimary : Colors.black87,
                ),
             ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_recommendation!.temperature.round()}°C',
            style: TextStyle(
              fontSize: 64,
             fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textPrimary : Colors.black87,
            ),
),
          const SizedBox(height: 8),
          Text(
            _recommendation!.weather,
            style: TextStyle(
              fontSize: 18,
              color: isDark ? AppTheme.textSecondary: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          Container(
           padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.backgroundDark : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  Icons.water_drop,
                  'Влажность',
                  '${_recommendation!.humidity}%',
                  isDark,
                ),
                Container(
                  width: 1,
                  height:50,
                  color: isDark
                      ? AppTheme.textSecondary.withOpacity(0.3)
                      :Colors.grey[300],
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
              color: (isDark ? AppTheme.primary : const Color(0xFF007bff))
                 .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
           child: Text(
              _recommendation!.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color:isDark ? AppTheme.primary : const Color(0xFF007bff),
              ),
            ),
          ),
       ],
      ),
    );
  }

  Widget _buildWeatherDetail(
      IconData icon, String label, String value, bool isDark) {
    return Column(
      children: [
        Icon(
         icon,
          color: isDark ? AppTheme.primary : const Color(0xFF007bff),
          size: 28,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppTheme.textSecondary : Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
         value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textPrimary : Colors.black87,
          ),
        ),
     ],
    );
  }

  Widget _buildOutfitSection(bool isDark) {
    if (_recommendation == null|| _recommendation!.items.isEmpty) {
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
          onSelect: () => _onOutfitSelected(outfitRecommendations.topChoice),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
             decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.textSecondary.withOpacity(0.3)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ... (здесь ваш код для отображения деталей комплекта)
                  ],
                ),
              ),
           ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingPanel(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: AppTheme.primary.withOpacity(0.3))
            : null,
        boxShadow: isDark
            ? null
           : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
            ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Оцените рекомендацию',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textPrimary : Colors.black87,
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
                    index <_selectedRating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: index < _selectedRating
                        ? const Color(0xFFffc107)
                        : (isDark ? Colors.grey[700] : Colors.grey[400]),
                  ),
                ),
             );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'Ваша оценка помогает улучшить AI!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark? AppTheme.textSecondary : Colors.grey[600],
            ),
          ),
          if (_selectedRating > 0) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ?AppTheme.primary : const Color(0xFF007bff),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: isDark ? 0 :2,
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

  void _submitRating() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Спасибо! Вы поставили $_selectedRating ${_getStarWord(_selectedRating)}',
              ),
           ),
          ],
        ),
        backgroundColor: const Color(0xFF28a745),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
   setState(() {
      _selectedRating =0;
    });
  }

  String _getStarWord(int count) {
    if (count == 1) return 'звезду';
    if (count >= 2 && count <= 4) return 'звезды';
    return 'звезд';
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? AppTheme.primary : const Color(0xFF007bff),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
           'Подбираем идеальный образ...',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.textSecondary : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Center(
     child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFdc3545).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 64, color: Color(0xFFdc3545)),
            ),
            const SizedBox(height: 24),
            Text(
              _error ?? 'Ошибкаподключения',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textPrimary : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (_errorDetails != null)...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: isDark
                      ? Border.all(color: Colors.red.withOpacity(0.3))
                      : null,
                ),
                child: Text(
                  _errorDetails!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.textSecondary : Colors.black54,
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
                 backgroundColor:
                      isDark ? AppTheme.primary : const Color(0xFF007bff),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
             ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen())),
              icon: Icon(Icons.settings_rounded,
                  color: isDark ? AppTheme.textSecondary : Colors.grey[700]),
              label: Text(
'Проверить настройки',
                style: TextStyle(
                    color: isDark ? AppTheme.textSecondary : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
