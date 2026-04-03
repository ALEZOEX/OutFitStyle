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
import '../../ui/containers/glass_container.dart';
import 'package:outfitstyle_client/src/presentation/providers/user_location_provider.dart';
import 'package:outfitstyle_client/src/presentation/providers/weather_provider.dart'
    show weatherProvider;
import 'package:outfitstyle_client/src/ui/widgets/city_selector_dialog.dart';

class HomeShellWrapper extends ConsumerStatefulWidget {
  const HomeShellWrapper({super.key});

  @override
  ConsumerState<HomeShellWrapper> createState() => _HomeShellWrapperState();
}

class _HomeShellWrapperState extends ConsumerState<HomeShellWrapper>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<Widget> _screens = const [
    HomeScreen(),
    WardrobeScreen(),
    RecommendationsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
  }

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
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _switchTo(int index, {required bool fromLeft}) {
    if (index == _currentIndex) return;
    setState(() {
      _slideAnimation =
          Tween<Offset>(
            begin: Offset(fromLeft ? 1.0 : -1.0, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutCubic,
            ),
          );
      _slideController.forward(from: 0);
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadCountProvider);
    final themeMode = ref.watch(themeModeProvider);
    final userLocation = ref.watch(userLocationProvider);

    return HomeShell(
      currentIndex: _currentIndex,
      onNavigationDestinationSelected: (index) {
        _switchTo(index, fromLeft: index > _currentIndex);
      },
      showBottomNav: true,
      showAppBar: true,
      title: _getTitle(_currentIndex),
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
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! < -300 &&
              _currentIndex < _screens.length - 1) {
            _switchTo(_currentIndex + 1, fromLeft: true);
          } else if (details.primaryVelocity! > 300 && _currentIndex > 0) {
            _switchTo(_currentIndex - 1, fromLeft: false);
          }
        },
        child: SlideTransition(
          position: _slideAnimation,
          child: _screens[_currentIndex],
        ),
      ),
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

/// Shell layout с glass bottom bar и glass app bar
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
    final theme = Theme.of(context);

    Widget body = SafeArea(
      top: false,
      child: showAppBar ? child : SingleChildScrollView(child: child),
    );

    if (showBottomNav) {
      body = SizedBox.expand(
        child: Stack(
          children: [
            body,
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
        ),
      );
    }

    return Scaffold(
      appBar: showAppBar
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight + 16),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.radiusXxl,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: isDark ? 0.2 : 0.08,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadius.radiusXxl,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          height: kToolbarHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      const Color(
                                        0xFF1F2937,
                                      ).withValues(alpha: 0.5),
                                      const Color(
                                        0xFF111827,
                                      ).withValues(alpha: 0.35),
                                    ]
                                  : [
                                      Colors.white.withValues(alpha: 0.8),
                                      Colors.white.withValues(alpha: 0.6),
                                    ],
                            ),
                            borderRadius: AppRadius.radiusXxl,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.06),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Верхний блик
                              Positioned(
                                top: 0,
                                left: 20,
                                right: 20,
                                height: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withValues(
                                          alpha: isDark ? 0.12 : 0.4,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // AppBar контент
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                      ),
                                    ),
                                    if (appBarActions != null &&
                                        appBarActions!.isNotEmpty)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: appBarActions!,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: body,
    );
  }
}

class _GlassBottomBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _GlassBottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_GlassBottomBar> createState() => _GlassBottomBarState();
}

class _GlassBottomBarState extends State<_GlassBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _bubbleController;
  late Animation<double> _bubbleX;
  int _previousIndex = 0;

  // Позиции для 4 вкладок (в процентах от ширины)
  static const _positions = [0.125, 0.375, 0.625, 0.875];

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _updateBubbleAnimation(_previousIndex, widget.currentIndex);
  }

  @override
  void didUpdateWidget(_GlassBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _updateBubbleAnimation(_previousIndex, widget.currentIndex);
      _bubbleController.forward(from: 0);
      setState(() => _previousIndex = widget.currentIndex);
    }
  }

  void _updateBubbleAnimation(int from, int to) {
    final fromX = _positions[from];
    final toX = _positions[to];
    _bubbleX = Tween<double>(begin: fromX, end: toX).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Анимированный пузырёк-индикатор
          AnimatedBuilder(
            animation: _bubbleController,
            builder: (context, child) {
              return Positioned(
                left: MediaQuery.of(context).size.width * _bubbleX.value - 28,
                bottom: 8,
                child: Container(
                  width: 56,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: AppRadius.radiusPill,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Кнопки
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Главная',
                isActive: widget.currentIndex == 0,
                onTap: () => widget.onTap(0),
              ),
              _NavItem(
                icon: Icons.checkroom_outlined,
                activeIcon: Icons.checkroom_rounded,
                label: 'Гардероб',
                isActive: widget.currentIndex == 1,
                onTap: () => widget.onTap(1),
              ),
              _NavItem(
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome_rounded,
                label: 'Рекомендации',
                isActive: widget.currentIndex == 2,
                onTap: () => widget.onTap(2),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Профиль',
                isActive: widget.currentIndex == 3,
                onTap: () => widget.onTap(3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
