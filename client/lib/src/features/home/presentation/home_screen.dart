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
      weatherProvider(
          const (lat: 55.7558, lon: 37.6173)), // Moscow coordinates as example
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
                isLoading: weatherAsync.isLoading,
                onRefresh: () {
                  ref.invalidate(weatherProvider);
                },
              ),

              // Quick actions
              QuickActions(
                onAddOutfit: () {
                  // Navigate to add outfit screen
                },
                onWeatherRefresh: () {
                  ref.invalidate(weatherProvider);
                },
                onRecommendations: () {
                  // Navigate to recommendations screen
                },
                onProfile: () {
                  // Navigate to profile screen
                },
                onWardrobe: () {
                  // Navigate to wardrobe screen
                },
              ),

              // Wardrobe summary
              WardrobeSummary(
                totalItems: 42,
                topsCount: 15,
                bottomsCount: 12,
                shoesCount: 8,
                accessoriesCount: 7,
                outfitsCount: 12,
                onTap: () {
                  // Navigate to wardrobe screen
                },
              ),

              // Daily outfit recommendation
              DailyOutfitCard(
                date: 'Сегодня',
                weatherCondition: 'Облачно',
                recommendedOutfit: 'Джинсы, свитер, куртка',
                temperature: '12°C',
                occasion: 'Работа',
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
                  StyleTip(
                    title: 'Слои для переменчивой погоды',
                    description:
                        'Носите одежду в несколько слоев, чтобы адаптироваться к изменению температуры в течение дня.',
                    category: 'Сезон',
                    imageUrl: 'https://example.com/style-tip-1.jpg',
                  ),
                  StyleTip(
                    title: 'Цвета по сезону',
                    description:
                        'Выбирайте цвета, которые подходят текущему сезону и подчеркивают ваш тон кожи.',
                    category: 'Стиль',
                    imageUrl: 'https://example.com/style-tip-2.jpg',
                  ),
                  StyleTip(
                    title: 'Универсальные вещи',
                    description:
                        'Инвестируйте в универсальные вещи, которые сочетаются с несколькими другими предметами.',
                    category: 'Стиль',
                    imageUrl: 'https://example.com/style-tip-3.jpg',
                  ),
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
