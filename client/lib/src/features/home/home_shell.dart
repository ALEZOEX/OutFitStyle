import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/home_screen.dart';
import '../../features/wardrobe/presentation/wardrobe_screen.dart';
import '../../features/recommendations/presentation/recommendations_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/notifications/presentation/providers/notification_providers.dart';
import '../../features/notifications/presentation/widgets/notification_icon.dart';
import '../../theme/theme_controller.dart';
import '../../theme/app_theme.dart';
import 'package:outfitstyle_client/src/presentation/providers/user_location_provider.dart';
import 'package:outfitstyle_client/src/presentation/providers/weather_provider.dart'
    show weatherProvider;
import 'package:outfitstyle_client/src/ui/widgets/city_selector_dialog.dart';

/// Wrapper для главного экрана с навигацией
class HomeShellWrapper extends ConsumerStatefulWidget {
  const HomeShellWrapper({super.key});

  @override
  ConsumerState<HomeShellWrapper> createState() => _HomeShellWrapperState();
}

class _HomeShellWrapperState extends ConsumerState<HomeShellWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    WardrobeScreen(),
    RecommendationsScreen(),
    ProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = GoRouterState.of(context).extra as int?;
    if (args != null && args >= 0 && args < _screens.length) {
      setState(() {
        _currentIndex = args;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadCountProvider);
    final themeMode = ref.watch(themeModeProvider);
    final userLocation = ref.watch(userLocationProvider);

    return HomeShell(
      title: _getTitle(_currentIndex),
      child: _screens[_currentIndex],
      currentIndex: _currentIndex,
      onNavigationDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      showBottomNav: true,
      showAppBar: true,
      appBarActions: [
        IconButton(
          icon: Icon(
            Icons.location_on_outlined,
            color: _currentIndex == 0
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          onPressed: () => _showCitySelector(context),
          tooltip: userLocation.cityName ?? 'Выбрать город',
        ),
        IconButton(
          icon: Icon(_getThemeIcon(themeMode)),
          onPressed: () {
            ref.read(themeModeProvider.notifier).toggle();
          },
          tooltip: _getThemeTooltip(themeMode),
        ),
        NotificationIconButton(
          unreadCount: unreadCount,
          onPressed: () {
            context.push('/notifications');
          },
        ),
        if (_currentIndex == 3)
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings/profile');
            },
            tooltip: 'Настройки',
          ),
      ],
    );
  }

  void _showCitySelector(BuildContext context) {
    showDialog<CityData>(
      context: context,
      builder: (context) => CitySelectorDialog(
        onCitySelected: (city) {
          ref.invalidate(userLocationProvider);
          ref.invalidate(weatherProvider);
        },
      ),
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => Icons.dark_mode,
      ThemeMode.light => Icons.light_mode,
      ThemeMode.system => Icons.brightness_auto,
    };
  }

  String _getThemeTooltip(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => 'Тёмная тема',
      ThemeMode.light => 'Светлая тема',
      ThemeMode.system => 'Системная тема',
    };
  }

  String _getTitle(int index) {
    return switch (index) {
      0 => 'Главная',
      1 => 'Гардероб',
      2 => 'Рекомендации',
      3 => 'Профиль',
      _ => 'OutfitStyle',
    };
  }
}

/// Shell layout для главного экрана с навигацией
class HomeShell extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? appBarActions;
  final bool showAppBar;
  final bool showBottomNav;
  final int currentIndex;
  final Function(int)? onNavigationDestinationSelected;

  const HomeShell({
    super.key,
    required this.title,
    required this.child,
    this.appBarActions,
    this.showAppBar = true,
    this.showBottomNav = true,
    this.currentIndex = 0,
    this.onNavigationDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget body = SafeArea(
      top: false,
      child: showAppBar ? child : SingleChildScrollView(child: child),
    );

    if (showBottomNav) {
      body = Stack(
        children: [
          body,
          // Floating glass bottom bar — constrained width on wide screens
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _GlassBottomBar(
                    currentIndex: currentIndex,
                    onTap: (index) =>
                        onNavigationDestinationSelected?.call(index),
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      // Glass app bar — замороженное стекло как Landing glass-header
      appBar: showAppBar
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: AppBar(
                    title: Text(title),
                    centerTitle: false,
                    scrolledUnderElevation: 0,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.7),
                    actions: appBarActions ?? const [],
                  ),
                ),
              ),
            )
          : null,
      body: body,
    );
  }
}

/// Glassmorphism floating bottom navigation bar — Landing style
class _GlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _GlassBottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Landing: bg-white/60 dark:bg-gray-800/40 backdrop-blur-xl border-white/40
    return ClipRRect(
      borderRadius: AppRadius.radiusXxl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1F2937).withValues(alpha: 0.4) // gray-800/40
                : Colors.white.withValues(alpha: 0.6), // white/60
            borderRadius: AppRadius.radiusXxl,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1) // white/10
                  : Colors.white.withValues(alpha: 0.4), // white/40
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                blurRadius: 32,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Главная',
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.checkroom_outlined,
                  activeIcon: Icons.checkroom_rounded,
                  label: 'Гардероб',
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome_rounded,
                  label: 'Рекомендации',
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Профиль',
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Навигационный элемент с градиентным пузырём для активного
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isActive ? AppGradients.primary : null,
          borderRadius: AppRadius.radiusPill,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
