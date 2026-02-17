import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late ConfettiController _confettiController;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Персональные рекомендации',
      description:
          'Получайте рекомендации одежды, основанные на погоде и ваших предпочтениях',
      icon: Icons.auto_awesome,
    ),
    OnboardingPage(
      title: 'Умный гардероб',
      description:
          'Управляйте своим гардеробом и получайте советы по сочетанию вещей',
      icon: Icons.checkroom,
    ),
    OnboardingPage(
      title: 'Стиль каждый день',
      description: 'Создавайте идеальные образы для любого случая и погоды',
      icon: Icons.star,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPage(_pages[index]);
              },
            ),

            // Confetti effect for the last page
            if (_currentPage == _pages.length - 1)
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  emissionFrequency: 0.01,
                  numberOfParticles: 30,
                  maxBlastForce: 100,
                  minBlastForce: 80,
                  gravity: 0.3,
                ),
              ),

            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  _buildPageIndicator(),
                  const SizedBox(height: 24),
                  _buildActionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
              border: isDarkMode
                  ? Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      width: 2,
                    )
                  : null,
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: isDarkMode
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.9)
                  : Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).primaryColor
                : (isDarkMode ? const Color(0xFF6B7280) : Colors.grey[300]),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _currentPage == index
                ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: () {
          if (_currentPage < _pages.length - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            _confettiController.play();
            Future.delayed(const Duration(seconds: 1), () {
              widget.onComplete();
            });
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          _currentPage == _pages.length - 1 ? 'Начать' : 'Далее',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}
