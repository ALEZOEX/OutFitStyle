import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Провайдер для отслеживания состояния авторизации
final authStateProvider = StateProvider<bool>((ref) => false);

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
    // Имитируем загрузку данных
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
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
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

  final List<Widget> _screens = const [
    _HomeContent(),
    _PlaceholderContent(
      icon: Icons.checkroom,
      title: 'Гардероб',
      message: 'Здесь будет ваш гардероб',
    ),
    _PlaceholderContent(
      icon: Icons.auto_awesome,
      title: 'Рекомендации',
      message: 'Персональные рекомендации одежды',
    ),
    _PlaceholderContent(
      icon: Icons.settings,
      title: 'Настройки',
      message: 'Настройки приложения',
    ),
  ];

  final List<String> _titles = [
    'Главная',
    'Гардероб',
    'Рекомендации',
    'Настройки',
  ];
}

/// Контент для главной страницы
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? theme.colorScheme.primaryContainer.withOpacity(0.2)
                  : theme.colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
              border: isDarkMode
                  ? Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    )
                  : null,
            ),
            child: Icon(
              Icons.home,
              size: 60,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Добро пожаловать в OutfitStyle!',
            style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Умные рекомендации одежды с учетом погоды',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDarkMode
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Контент для остальных вкладок
class _PlaceholderContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _PlaceholderContent({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? theme.colorScheme.primaryContainer.withOpacity(0.2)
                  : theme.colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
              border: isDarkMode
                  ? Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    )
                  : null,
            ),
            child: Icon(
              icon,
              size: 60,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}