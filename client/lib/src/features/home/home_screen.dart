import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/weather_data.dart';
import '../../presentation/providers/presentation_providers_exports.dart';
import '../../ui/widgets/weather_card.dart';
import '../../ui/widgets/style_tips_carousel.dart';
import '../../ui/widgets/daily_outfit_card.dart';

/// Главный экран: погода + персональные рекомендации + советы
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Получаем данные о погоде
    final weatherAsync = ref.watch(
      weatherProvider((lat: 55.7558, lon: 37.6173)), // Москва
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(weatherProvider);
        ref.invalidate(dailyOutfitProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Приветствие
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Добрый день!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Вот ваш персональный стиль сегодня',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),

            // Карточка погоды
            WeatherCard(
              weatherData: weatherAsync.maybeWhen(
                data: (data) => data,
                orElse: () => null,
              ),
              onTap: () {
                ref.invalidate(weatherProvider);
              },
            ),

            const SizedBox(height: 16),

            // Карточка ежедневного образа
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ваш образ на сегодня',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            DailyOutfitCard(
              outfit: null,
              onTap: () {
                context.push('/recommendations');
              },
            ),

            const SizedBox(height: 24),

            // Советы стилиста
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Советы стилиста',
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
                'Аксессуары решают всё: правильные аксессуары могут преобразить даже самый простой образ.',
              ],
            ),

            const SizedBox(height: 24),

            // Быстрые действия
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Быстрые действия',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickActions(context),

            const SizedBox(height: 24),

            // Недавняя активность
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Недавняя активность',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            _buildRecentActivity(context),

            const SizedBox(height: 100), // Отступ для bottom navigation
          ],
        ),
      ),
    );
  }

  /// Быстрые действия
  Widget _buildQuickActions(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _QuickActionItem(
            icon: Icons.add,
            label: 'Добавить',
            color: Colors.blue,
            onTap: () => context.push('/wardrobe/add'),
          ),
          const SizedBox(width: 12),
          _QuickActionItem(
            icon: Icons.refresh,
            label: 'Погода',
            color: Colors.orange,
            onTap: () => ref.invalidate(weatherProvider),
          ),
          const SizedBox(width: 12),
          _QuickActionItem(
            icon: Icons.auto_awesome,
            label: 'Рекомендации',
            color: Colors.purple,
            onTap: () => context.push('/recommendations'),
          ),
          const SizedBox(width: 12),
          _QuickActionItem(
            icon: Icons.checkroom,
            label: 'Гардероб',
            color: Colors.green,
            onTap: () => context.push('/wardrobe'),
          ),
          const SizedBox(width: 12),
          _QuickActionItem(
            icon: Icons.person,
            label: 'Профиль',
            color: Colors.pink,
            onTap: () => context.push('/profile'),
          ),
        ],
      ),
    );
  }

  /// Недавняя активность
  Widget _buildRecentActivity(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _buildActivityItem(context, index),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, int index) {
    final activities = [
      {'icon': Icons.favorite, 'label': 'Новый образ', 'color': Colors.red},
      {'icon': Icons.auto_awesome, 'label': 'Совет стилиста', 'color': Colors.blue},
      {'icon': Icons.checkroom, 'label': 'Вещь добавлена', 'color': Colors.green},
      {'icon': Icons.star, 'label': 'Достижение', 'color': Colors.amber},
      {'icon': Icons.shopping_bag, 'label': 'Покупка', 'color': Colors.purple},
    ];

    final activity = activities[index % activities.length];

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (activity['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                activity['icon'] as IconData,
                color: activity['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              activity['label'] as String,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${index + 1} ч. назад',
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

/// Элемент быстрого действия
class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
