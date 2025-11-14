import'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/recommendation.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../models/outfit.dart';
import '../widgets/top_outfit_card.dart';
import '../widgets/alternative_outfits.dart';
import '../utils/city_translator.dart';
import 'profile_screen.dart';
import '../widgets/onboarding_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
 final TextEditingController _cityController = TextEditingController(text: 'Moscow');
  
  Recommendation? _recommendation;
  bool _isLoading = false;
  String? _error;
  String? _errorDetails;
  int _selectedRating = 0;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadData();
    
    // Показываем онбординг после загрузки
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

  Future<void> _loadData() async {
   setState(() {
      _isLoading = true;
      _error = null;
      _errorDetails = null;
    });

    try {
      //Транслитерация города
      final translatedCity = CityTranslator.translate(_cityController.text);
      
      final recommendation = await _api.getRecommendations(translatedCity);
      if (mounted) {
        setState(() {
          _recommendation = recommendation;
          _isLoading =false;
          _error = null;
});
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Ошибка загрузки данных';
        String? details;
        
        final errorString = e.toString();
        
        if(errorString.contains('404')){
          errorMessage = 'Город не найден';
          details = 'Проверьте правильность названия города.\nПопробуйте использовать английское название (например, "New York" вместо "Нью Йорк")';
       } else if (errorString.contains('400')) {
          errorMessage = 'Неверный запрос';
          details = 'Попробуйте ввести название города на английском языке.\nНапример: Moscow, London, Paris, New York';
        } else if (errorString.contains('timeout')) {
          errorMessage = 'Превышено время ожидания';
          details = 'Сервер не отвечает. Проверьте подключение к интернету.';
        } else if (errorString.contains('Failed host lookup') || errorString.contains('SocketException')) {
          errorMessage = 'Нет подключения к интернету';
          details= 'Проверьте подключение к сети и попробуйте снова.';
        } else if (errorString.contains('Connection refused')) {
          errorMessage = 'Сервер недоступен';
          details = 'Не удается подключиться к серверу. Убедитесь, что сервер запущен.';
} else {
          details = errorString;
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
   final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // Animated background
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark 
                          ? [
                              Color.lerp(AppTheme.backgroundDark, Colors.black, themeProvider.isAnimating ? 0.3 : 0.0)!,
                              Color.lerp(AppTheme.cardDark, Colors.grey[900]!, themeProvider.isAnimating ? 0.3 : 0.0)!,
                            ]
                          : [
                              Color.lerp(const Color(0xFFF0F2F5), Colors.white, themeProvider.isAnimating ? 0.3 : 0.0)!,
                              Color.lerp(const Color(0xFFE4E6E9), Colors.grey[300]!, themeProvider.isAnimating ? 0.3 : 0.0)!,
                            ],
                    ),
                  ),
                );
              },
            ),
            
            // Content
            _isLoading
                ? _buildLoadingState(isDark)
                : _error != null
                    ? _buildErrorWidget(isDark)
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                children: [
                                  _buildHeader(isDark, themeProvider),
                                  const SizedBox(height: 20),
                                  _buildSearchPanel(isDark),
                                  const SizedBox(height: 20),
                                  if (_recommendation != null) ...[
                                    _buildWeatherCard(isDark),
                                    const SizedBox(height: 20),
                                    _buildOutfitGrid(isDark),
                                    const SizedBox(height: 20),
                                    _buildRatingPanel(isDark),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(bool isDark, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          // Profile button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primary.withOpacity(0.2)
                    : const Color(0xFF007bff).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: isDark ? AppTheme.primary : const Color(0xFF007bff),
                size: 24,
              ),
            ),
          ),

          // Logo
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
                            colors: [Color(0xFF007bff), Color(0xFF0056b3)],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.checkroom, color: Colors.white, size: 28),
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
          
          // Theme Toggle
          IconButton(
            onPressed: themeProvider.toggleTheme,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: animation,
                  child:FadeTransition(opacity: animation, child: child),
                );
              },
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(isDark),
                color: isDark ? Colors.amber : const Color(0xFF007bff),
                size: 28,
              ),
            ),
            tooltip: isDark ? 'Светлая тема' : 'Темная тема',
         ),
        ],
      ),
    );
  }

  // ==================== SEARCH PANEL ====================
  Widget _buildSearchPanel(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark? Border.all(color: AppTheme.primary.withOpacity(0.3))
            : null,
        boxShadow: isDark ? null : [
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
                  color: isDark ? AppTheme.textSecondary : Colors.grey,
                  fontSize: 14,
                ),
                prefixIcon:Icon(
                  Icons.location_city,
                  color: isDark ? AppTheme.primary : const Color(0xFF007bff),
),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted:(_) => _loadData(),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
gradient: isDark 
                  ? AppTheme.primaryGradient
                  : const LinearGradient(
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

  // ==================== WEATHER CARD ====================
Widget _buildWeatherCard(bool isDark) {
    if (_recommendation == null) return const SizedBox();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark 
            ? Border.all(color: AppTheme.primary.withOpacity(0.3))
            : null,
       boxShadow: isDark ? null : [
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
              color: isDark ?AppTheme.textSecondary : Colors.black54,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark 
                  ? AppTheme.backgroundDark 
                  : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment:MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  Icons.water_drop,
                  'Влажность',
                  '${_recommendation!.humidity}%',
                  isDark,
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: isDark 
                      ?AppTheme.textSecondary.withOpacity(0.3)
                      : Colors.grey[300],
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
              color: isDark 
? AppTheme.primary.withOpacity(0.15)
                  : const Color(0xFF007bff).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _recommendation!.message,
              textAlign: TextAlign.center,
              style: TextStyle(
fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.primary : const Color(0xFF007bff),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value, bool isDark) {
    return Column(
      children: [
        Icon(
          icon,
          color:isDark ? AppTheme.primary : const Color(0xFF007bff),
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

// ==================== OUTFIT GRID ====================
  Widget _buildOutfitGrid(bool isDark) {
    if (_recommendation == null || _recommendation!.items.isEmpty) {
      return const SizedBox();
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark 
            ? Border.all(color: AppTheme.primary.withOpacity(0.3))
            : null,
       boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checkroom,
                color: isDark ? AppTheme.primary : const Color(0xFF007bff),
                size: 24,
              ),
              const SizedBox(width:8),
              Text(
                'Рекомендуем надеть',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textPrimary : Colors.black87,
                ),
              ),
              const Spacer(),
              if (_recommendation!.mlPowered)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: isDark 
                        ? AppTheme.primaryGradient
                        : const LinearGradient(
                            colors: [Color(0xFF28a745), Color(0xFF20883b)],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.psychology, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
'AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          GridView.builder(
            shrinkWrap: true,
           physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.85,
            ),
            itemCount:_recommendation!.items.length,
            itemBuilder: (context, index) {
              return _buildOutfitItem(_recommendation!.items[index], isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitItem(item, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? AppTheme.backgroundDark 
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
              ? AppTheme.primary.withOpacity(0.2)
              : Colors.grey[200]!,
        ),
boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.iconEmoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 10),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                   fontSize:14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textPrimary : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  _getCategoryName(item.category),
                 style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.textSecondary : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (item.mlScore != null)
            Positioned(
              top: 5,
              right: 5,
child:Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF28a745),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${(item.mlScore! * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category.toLowerCase()) {
case 'outerwear': return 'Верхняя одежда';
      case 'upper': return 'Верх';
      case 'lower': return 'Низ';
      case 'footwear': return 'Обувь';
      case 'accessories': return 'Аксессуары';
      default: return category;
}
  }

  // ==================== RATING PANEL ====================
  Widget _buildRatingPanel(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark? Border.all(color: AppTheme.primary.withOpacity(0.3))
            : null,
        boxShadow: isDark ? null : [
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
                   index < _selectedRating ? Icons.star : Icons.star_border,
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
              color: isDark ? AppTheme.textSecondary : Colors.grey[600],
            ),
          ),
          
          if (_selectedRating > 0) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRating,
                style: ElevatedButton.styleFrom(
                 backgroundColor: isDark 
                      ? AppTheme.primary 
                      : const Color(0xFF007bff),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
elevation: isDark ? 0 : 2,
                ),
                child: const Text(
                  'Отправить оценку',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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
                'Спасибо! Вы поставили$_selectedRating ${_getStarWord(_selectedRating)}',
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF28a745),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
duration: const Duration(seconds:3),
      ),
    );
    
    setState(() {
      _selectedRating = 0;
    });
  }

  String _getStarWord(int count) {
    if (count == 1) return 'звезду';
    if (count >= 2 && count <= 4) return 'звезды';
    return 'звезд';
  }

  // ==================== LOADING STATE ====================
  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? AppTheme.primary: const Color(0xFF007bff),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Загрузка рекомендаций...',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.textSecondary: Colors.black54,
),
          ),
       ],
      ),
    );
  }

  // ==================== ERROR STATE ====================
  Widget _buildErrorWidget(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
            Container(
padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFdc3545).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
size: 64,
                color: Color(0xFFdc3545),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _error ?? 'Ошибка загрузки',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
               color: isDark ? AppTheme.textPrimary: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (_errorDetails != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppTheme.cardDark 
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: isDark 
                      ? Border.all(color: Colors.red.withOpacity(0.3))
                      : null,
                ),
                child: Text(
                  _errorDetails!,
textAlign: TextAlign.center,
                  style:TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.textSecondary : Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Подсказка
            Container(
              padding:const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF007bff).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF007bff).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: isDark ? AppTheme.primary : const Color(0xFF007bff),
                       size: 20,
                     ),
                      const SizedBox(width: 8),
                      Text(
                        'Совет:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.primary : const Color(0xFF007bff),
                        ),
                      ),
                    ],
                  ),
                 const SizedBox(height: 8),
Text(
                    'Используйте английские названия городов:\n• Moscow (Москва)\n• London (Лондон)\n• Paris (Париж)\n• New York (Нью-Йорк)',
                    style: TextStyle(
fontSize: 13,
                      color: isDark ? AppTheme.textSecondary : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
ElevatedButton.icon(
                 onPressed: () {
                    setState(() {
                      _error = null;
                      _errorDetails = null;
                      _cityController.text = 'Moscow';
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Назад'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:isDark 
                        ? AppTheme.cardDark 
                        : Colors.grey[300],
                    foregroundColor: isDark 
                        ? AppTheme.textPrimary 
                        : Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Повторить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark 
                        ? AppTheme.primary 
                        : const Color(0xFF007bff),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:BorderRadius.circular(10),
                    ),
                  ),
                ),
             ],
            ),
          ],
        ),
      ),
    );
  }
}