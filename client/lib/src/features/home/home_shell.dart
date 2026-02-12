import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/misc/app_avatar.dart';
import '../../ui/buttons/app_icon_button.dart';

/// Shell layout for the home screen with app bar and navigation
class HomeShell extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showAppBar;
  final bool showBottomNav;
  final int currentIndex;
  final Function(int)? onNavigationDestinationSelected;
  final List<NavigationDestination> navigationDestinations;

  const HomeShell({
    Key? key,
    required this.title,
    required this.child,
    this.actions,
    this.showAppBar = true,
    this.showBottomNav = true,
    this.currentIndex = 0,
    this.onNavigationDestinationSelected,
    this.navigationDestinations = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget body = SafeArea(
      top: false,
      child: showAppBar ? child : SingleChildScrollView(child: child),
    );

    if (showBottomNav && navigationDestinations.isNotEmpty) {
      body = Column(
        children: [
          Expanded(child: body),
          NavigationBar(
            destinations: navigationDestinations,
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
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              centerTitle: false,
              scrolledUnderElevation: 0,
              actions: actions ??
                  [
                    AppIconButton(
                      icon: Icons.notifications_outlined,
                      onPressed: () {
                        // Navigate to notifications
                        context.push('/notifications');
                      },
                      tooltip: 'Уведомления',
                    ),
                    const SizedBox(width: 8.0),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: AppAvatar(
                        name: 'User',
                        radius: 16.0,
                        onTap: () {
                          // Navigate to profile
                          context.push('/profile');
                        },
                      ),
                    ),
                  ],
            )
          : null,
      body: body,
    );
  }
}

/// Specialized home shell for the outfit recommendation app
class OutfitHomeShell extends StatelessWidget {
  final String title;
  final Widget child;
  final int currentIndex;
  final Function(int)? onNavigationDestinationSelected;
  final bool showSearch;
  final VoidCallback? onSearch;

  const OutfitHomeShell({
    Key? key,
    required this.title,
    required this.child,
    this.currentIndex = 0,
    this.onNavigationDestinationSelected,
    this.showSearch = false,
    this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeShell(
      title: title,
      child: child,
      showBottomNav: true,
      currentIndex: currentIndex,
      onNavigationDestinationSelected: onNavigationDestinationSelected,
      navigationDestinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Главная',
        ),
        NavigationDestination(
          icon: Icon(Icons.local_cafe_outlined),
          selectedIcon: Icon(Icons.local_cafe),
          label: 'Рекомендации',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'История',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outlined),
          selectedIcon: Icon(Icons.person),
          label: 'Профиль',
        ),
      ],
      actions: [
        if (showSearch)
          AppIconButton(
            icon: Icons.search,
            onPressed: onSearch,
            tooltip: 'Поиск',
          )
        else
          AppIconButton(
            icon: Icons.tune_outlined,
            onPressed: () {
              // Navigate to filters/settings
              context.push('/filters');
            },
            tooltip: 'Фильтры',
          ),
        const SizedBox(width: 8.0),
        AppIconButton(
          icon: Icons.notifications_outlined,
          onPressed: () {
            context.push('/notifications');
          },
          tooltip: 'Уведомления',
        ),
        const SizedBox(width: 8.0),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: AppAvatar(
            name: 'User',
            radius: 16.0,
            onTap: () {
              context.push('/profile');
            },
          ),
        ),
      ],
    );
  }
}
