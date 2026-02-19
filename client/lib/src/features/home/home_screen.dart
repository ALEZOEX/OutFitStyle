import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/weather_data.dart';
import '../../presentation/providers/presentation_providers_exports.dart';
import '../../ui/widgets/weather_card.dart';
import '../../ui/widgets/quick_actions.dart';
import '../../ui/widgets/wardrobe_summary.dart';
import '../../ui/widgets/style_tips_carousel.dart';
import '../../ui/widgets/daily_outfit_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Get weather data using Riverpod
    final weatherAsync = ref.watch(
      weatherProvider((lat: 55.7558, lon: 37.6173)), // Moscow coordinates
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh weather data
          ref.invalidate(weatherProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Добрый день!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'Вот ваш персональный стиль сегодня',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),

              // Weather card
              WeatherCard(
                weatherData: weatherAsync.maybeWhen(
                  data: (data) => data,
                  orElse: () => null,
                ),
                onTap: () {
                  ref.invalidate(weatherProvider);
                },
              ),

              // Quick actions
              QuickActions(
                actions: [
                  QuickActionItem(
                    label: 'Добавить',
                    icon: Icons.add,
                    onPressed: () {
                      // Navigate to add outfit screen
                    },
                  ),
                  QuickActionItem(
                    label: 'Погода',
                    icon: Icons.refresh,
                    onPressed: () {
                      ref.invalidate(weatherProvider);
                    },
                  ),
                  QuickActionItem(
                    label: 'Советы',
                    icon: Icons.lightbulb,
                    onPressed: () {
                      // Navigate to recommendations screen
                    },
                  ),
                  QuickActionItem(
                    label: 'Профиль',
                    icon: Icons.person,
                    onPressed: () {
                      // Navigate to profile screen
                    },
                  ),
                  QuickActionItem(
                    label: 'Гардероб',
                    icon: Icons.checkroom,
                    onPressed: () {
                      // Navigate to wardrobe screen
                    },
                  ),
                ],
              ),

              // Wardrobe summary
              WardrobeSummary(
                totalItemsCount: 42,
                categoryCounts: {
                  'Верх': 15,
                  'Низ': 12,
                  'Обувь': 8,
                  'Аксессуары': 7,
                },
                recentItems: [],
              ),

              // Daily outfit recommendation
              DailyOutfitCard(
                outfit: null,
                onTap: () {
                  // Navigate to detailed outfit view
                },
              ),

              // Style tips carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Стилистические советы',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              StyleTipsCarousel(
                tips: [
                  'Слои для переменчивой погоды: носите одежду в несколько слоев, чтобы адаптироваться к изменению температуры.',
                  'Цвета по сезону: выбирайте цвета, которые подходят текущему сезону и подчеркивают ваш тон кожи.',
                  'Универсальные вещи: инвестируйте в базовые предметы, которые сочетаются с несколькими другими.',
                ],
              ),

              // Recent activity section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Недавняя активность',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _buildActivityItem(index),
      ),
    );
  }

  Widget _buildActivityItem(int index) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              index % 2 == 0 ? Icons.favorite : Icons.auto_awesome,
              color: index % 2 == 0 ? Colors.red : Colors.blue,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              index % 2 == 0 ? 'Новый образ' : 'Стильный совет',
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '2 часа назад',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
