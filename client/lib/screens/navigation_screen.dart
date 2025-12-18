import 'package:flutter/material.dart';
import 'recommendation_home_screen.dart';
import 'wardrobe_screen.dart';
import 'profile_screen.dart';
import 'recommendation_history_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _index = 0;

  final _pages = const [
    RecommendationHomeScreen(),
    WardrobeScreen(),
    RecommendationHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Образ'),
          NavigationDestination(icon: Icon(Icons.checkroom), label: 'Гардероб'),
          NavigationDestination(icon: Icon(Icons.history), label: 'История'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}