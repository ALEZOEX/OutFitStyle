import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

import 'package:outfitstyle_client/l10n/app_localizations.dart';
import 'package:outfitstyle_client/src/ui/widgets/city_selector_dialog.dart';
import 'package:outfitstyle_client/src/features/onboarding/data/models/onboarding_data.dart';
import 'package:outfitstyle_client/src/features/onboarding/presentation/providers/onboarding_provider.dart';

/// Экран онбординга для новых пользователей
/// Состоит из 5 страниц:
/// 1. Приветствие
/// 2. Выбор города
/// 3. Выбор стилей
/// 4. Предпочтения (бюджет, бренды)
/// 5. Завершение
class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late ConfettiController _confettiController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  final _brandsController = TextEditingController();
  bool _isDetectingCity = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    );
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    _fadeAnimationController.dispose();
    _brandsController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    ref.read(onboardingNotifierProvider.notifier).goToPage(index);
    _fadeAnimationController.forward(from: 0);
  }

  void _nextPage() {
    final page = _pageController.page;
    if (page != null && page.toInt() < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    final page = _pageController.page;
    if (page != null && page.toInt() > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _detectCityByIp() async {
    setState(() => _isDetectingCity = true);

    try {
      final notifier = ref.read(onboardingNotifierProvider.notifier);
      final cityData = await notifier.detectCityByIp();

      if (cityData != null && mounted) {
        final cityName = cityData['city'] as String?;
        final lat = cityData['lat'] as double?;
        final lon = cityData['lon'] as double?;

        if (cityName != null && lat != null && lon != null) {
          notifier.setCity(
            cityId: 0, // Временный ID для автоопределённого города
            cityName: cityName,
            cityLat: lat,
            cityLon: lon,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Город определён: $cityName'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось определить город: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDetectingCity = false);
      }
    }
  }

  void _selectCity(CityData city) {
    ref
        .read(onboardingNotifierProvider.notifier)
        .setCity(
          cityId: 0, // ID будет назначен сервером
          cityName: city.name,
          cityLat: city.lat,
          cityLon: city.lon,
        );
  }

  void _openCitySelector() {
    showDialog<CityData>(
      context: context,
      builder:
          (context) =>
              CitySelectorDialog(onCitySelected: (city) => _selectCity(city)),
    );
  }

  Future<void> _completeOnboarding() async {
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final success = await notifier.completeOnboarding();

    if (success && mounted) {
      _confettiController.play();
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        widget.onComplete?.call();
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notifier.state.error ?? 'Ошибка сохранения'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();

    final state = ref.watch(onboardingNotifierProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDarkMode
                      ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                      : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
            ),
          ),
          child: Column(
            children: [
              // Индикатор прогресса
              _buildProgressIndicator(state.currentPage),

              // PageView с экранами
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildWelcomePage(l10n, isDarkMode),
                      _buildCityPage(l10n, isDarkMode, state),
                      _buildStylesPage(l10n, isDarkMode, state),
                      _buildPreferencesPage(l10n, isDarkMode, state),
                      _buildCompletePage(l10n, isDarkMode),
                    ],
                  ),
                ),
              ),

              // Навигационные кнопки
              _buildNavigationButtons(state, l10n),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      // Confetti effect for the last page
    );
  }

  Widget _buildProgressIndicator(int currentPage) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final activeColor =
        isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
    final inactiveColor =
        isDarkMode ? const Color(0xFF374151) : const Color(0xFFD1D5DB);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final isActive = index <= currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage(AppLocalizations l10n, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Логотип
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isDarkMode
                        ? [const Color(0xFF60A5FA), const Color(0xFF3B82F6)]
                        : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: (isDarkMode
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF3B82F6))
                      .withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.checkroom_rounded,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            l10n.onboardingWelcomeTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingWelcomeSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color:
                  isDarkMode
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.onboardingWelcomeDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color:
                  isDarkMode
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityPage(
    AppLocalizations l10n,
    bool isDarkMode,
    OnboardingState state,
  ) {
    final cityName = state.data.cityName;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: (isDarkMode
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF3B82F6))
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: (isDarkMode
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF3B82F6))
                    .withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.location_on_rounded,
              size: 60,
              color:
                  isDarkMode
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingCityTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingCityDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  isDarkMode
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 40),

          // Кнопка автоопределения
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isDetectingCity ? null : _detectCityByIp,
              icon:
                  _isDetectingCity
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.gps_fixed_rounded),
              label: Text(l10n.onboardingCityDetectByIp),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color:
                      isDarkMode
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF3B82F6),
                ),
                foregroundColor:
                    isDarkMode
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Кнопка выбора города
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openCitySelector,
              icon: const Icon(Icons.location_city_rounded),
              label: Text(cityName ?? l10n.onboardingCitySearchHint),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    cityName != null
                        ? (isDarkMode
                            ? const Color(0xFF60A5FA)
                            : const Color(0xFF3B82F6))
                        : null,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          if (cityName != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Город выбран: $cityName',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStylesPage(
    AppLocalizations l10n,
    bool isDarkMode,
    OnboardingState state,
  ) {
    final selectedStyles = state.data.stylePreferences;
    final styles = StylePreference.values;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (isDarkMode
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF3B82F6))
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.palette_rounded,
              size: 40,
              color:
                  isDarkMode
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.onboardingStylesTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingStylesDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  isDarkMode
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${selectedStyles.length}/3',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color:
                  selectedStyles.length >= 3
                      ? Colors.green
                      : (isDarkMode
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF3B82F6)),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: styles.length,
              itemBuilder: (context, index) {
                final style = styles[index];
                final isSelected = selectedStyles.contains(style.value);

                return _buildStyleChip(style.displayName, isSelected, () {
                  ref
                      .read(onboardingNotifierProvider.notifier)
                      .toggleStylePreference(style.value);
                }, isDarkMode);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (isDarkMode
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF3B82F6))
                  : (isDarkMode
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? (isDarkMode
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF3B82F6))
                    : (isDarkMode
                        ? const Color(0xFF374151)
                        : const Color(0xFFE2E8F0)),
            width: 2,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Colors.white,
                )
              else
                Icon(
                  Icons.circle_outlined,
                  size: 18,
                  color:
                      isDarkMode
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF94A3B8),
                ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected
                          ? Colors.white
                          : (isDarkMode
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFF475569)),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesPage(
    AppLocalizations l10n,
    bool isDarkMode,
    OnboardingState state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (isDarkMode
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF3B82F6))
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.settings_rounded,
              size: 40,
              color:
                  isDarkMode
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.onboardingPreferencesTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingPreferencesDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  isDarkMode
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 32),

          // Бюджет
          Text(
            l10n.onboardingBudgetLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  isDarkMode
                      ? const Color(0xFFE5E7EB)
                      : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildBudgetChip(
                  l10n.budgetEconomy,
                  'до 5000₽',
                  state.data.budgetRange == 'economy',
                  () {
                    ref
                        .read(onboardingNotifierProvider.notifier)
                        .setBudgetRange('economy');
                  },
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBudgetChip(
                  l10n.budgetMedium,
                  '5000-15000₽',
                  state.data.budgetRange == 'medium',
                  () {
                    ref
                        .read(onboardingNotifierProvider.notifier)
                        .setBudgetRange('medium');
                  },
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBudgetChip(
                  l10n.budgetPremium,
                  '15000₽+',
                  state.data.budgetRange == 'premium',
                  () {
                    ref
                        .read(onboardingNotifierProvider.notifier)
                        .setBudgetRange('premium');
                  },
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Любимые бренды
          Text(
            l10n.onboardingBrandsLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  isDarkMode
                      ? const Color(0xFFE5E7EB)
                      : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _brandsController,
            onChanged: (value) {
              ref
                  .read(onboardingNotifierProvider.notifier)
                  .setFavoriteBrands(value);
            },
            decoration: InputDecoration(
              hintText: l10n.onboardingBrandsHint,
              hintStyle: TextStyle(
                color:
                    isDarkMode
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor:
                  isDarkMode
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetChip(
    String title,
    String subtitle,
    bool isSelected,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (isDarkMode
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF3B82F6))
                  : (isDarkMode
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? (isDarkMode
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF3B82F6))
                    : (isDarkMode
                        ? const Color(0xFF374151)
                        : const Color(0xFFE2E8F0)),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : (isDarkMode
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF475569)),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white.withOpacity(0.9)
                        : (isDarkMode
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF64748B)),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletePage(AppLocalizations l10n, bool isDarkMode) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(80),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                l10n.onboardingCompleteTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.onboardingCompleteDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color:
                      isDarkMode
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        // Confetti widget
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            maxBlastForce: 100,
            minBlastForce: 80,
            gravity: 0.2,
            colors: const [
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
              Color(0xFF34D399),
              Color(0xFFFBBF24),
              Color(0xFFF472B6),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(OnboardingState state, AppLocalizations l10n) {
    final currentPage = state.currentPage;
    final isLastPage = currentPage == 4;
    final isFirstPage = currentPage == 0;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Кнопка "Назад"
          if (!isFirstPage && !isLastPage)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor:
                      isDarkMode
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF64748B),
                  side: BorderSide(
                    color:
                        isDarkMode
                            ? const Color(0xFF374151)
                            : const Color(0xFFE2E8F0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.onboardingBackButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          if (!isFirstPage && !isLastPage) const SizedBox(width: 16),

          // Кнопка "Далее" / "Завершить" / "Начать"
          Expanded(
            flex: isFirstPage || isLastPage ? 1 : 1,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed:
                    state.isSubmitting
                        ? null
                        : isLastPage
                        ? widget.onComplete
                        : currentPage == 3
                        ? _completeOnboarding
                        : _nextPage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor:
                      isDarkMode
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: (isDarkMode
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF3B82F6))
                      .withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child:
                    state.isSubmitting
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          isLastPage
                              ? l10n.onboardingStartButton
                              : currentPage == 3
                              ? l10n.onboardingFinishButton
                              : l10n.onboardingNextButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
