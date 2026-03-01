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
import 'package:outfitstyle_client/src/presentation/providers/user_location_provider.dart';
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
    // Проверяем есть ли extra параметр с индексом вкладки
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
        // Кнопка местоположения
        IconButton(
          icon: Icon(
            Icons.location_on_outlined,
            color:
                _currentIndex == 0
                    ? Theme.of(context).colorScheme.primary
                    : null,
          ),
          onPressed: () => _showCitySelector(context),
          tooltip: userLocation.cityName ?? 'Выбрать город',
        ),
        // Кнопка смены темы
        IconButton(
          icon: Icon(_getThemeIcon(themeMode)),
          onPressed: () {
            ref.read(themeModeProvider.notifier).toggle();
          },
          tooltip: _getThemeTooltip(themeMode),
        ),
        // Кнопка уведомлений с badge
        NotificationIconButton(
          unreadCount: unreadCount,
          onPressed: () {
            context.push('/notifications');
          },
        ),
        // Кнопка настроек в профиле
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
      builder:
          (context) => CitySelectorDialog(
            onCitySelected: (city) {
              // Инвалидируем провайдеры для обновления данных
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
    Key? key,
    required this.title,
    required this.child,
    this.appBarActions,
    this.showAppBar = true,
    this.showBottomNav = true,
    this.currentIndex = 0,
    this.onNavigationDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget body = SafeArea(
      top: false,
      child: showAppBar ? child : SingleChildScrollView(child: child),
    );

    if (showBottomNav) {
      body = Column(
        children: [
          Expanded(child: body),
          NavigationBar(
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
                icon: Icon(Icons.person_outlined),
                selectedIcon: Icon(Icons.person),
                label: 'Профиль',
              ),
            ],
            selectedIndex: currentIndex,
            onDestinationSelected: (int index) {
              onNavigationDestinationSelected?.call(index);
            },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ],
      );
    }

    return Scaffold(
      appBar:
          showAppBar
              ? AppBar(
                title: Text(title),
                centerTitle: false,
                scrolledUnderElevation: 0,
                actions: appBarActions ?? const [],
              )
              : null,
      body: body,
    );
  }
}
