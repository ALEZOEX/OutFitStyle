import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/trip.dart';
import '../providers/trip_providers.dart';
import '../widgets/trip_status_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Страница деталей поездки
class TripDetailPage extends ConsumerStatefulWidget {
  final String tripId;

  const TripDetailPage({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends ConsumerState<TripDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripDetailProvider(widget.tripId));
    final notifier = ref.read(tripDetailProvider(widget.tripId).notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // App Bar с градиентом
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue[600],
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/trips/${widget.tripId}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showOptionsBottomSheet(state.trip, notifier),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[600]!,
                      Colors.blue[400]!,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                state.trip?.name ?? 'Загрузка...',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (state.trip != null)
                              TripStatusBadge(status: state.trip!.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                state.trip?.destination ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Табы
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.blue[600],
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.blue[600],
                tabs: const [
                  Tab(text: 'Инфо'),
                  Tab(text: 'Вещи'),
                  Tab(text: 'Погода'),
                ],
              ),
            ),
          ),

          // Контент
          switch (state.status) {
            TripLoadStatus.loading => SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ),
            TripLoadStatus.error => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.error ?? 'Ошибка загрузки',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            TripLoadStatus.success ||
            TripLoadStatus.initial ||
            TripLoadStatus.refreshing =>
              state.trip == null
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          'Поездка не найдена',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  : _buildTabContent(state.trip!),
          },
        ],
      ),
    );
  }

  Widget _buildTabContent(Trip trip) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 300,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildInfoTab(trip),
            _buildPackingListTab(trip),
            _buildWeatherTab(trip),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(Trip trip) {
    final dateFormat = DateFormat('d MMMM yyyy', 'ru_RU');

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(
            icon: Icons.calendar_today,
            title: 'Даты поездки',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateRow('Начало', dateFormat.format(trip.startDate)),
                const SizedBox(height: 8),
                _buildDateRow('Окончание', dateFormat.format(trip.endDate)),
                const SizedBox(height: 12),
                Text(
                  '${trip.endDate.difference(trip.startDate).inDays + 1} дней',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (trip.occasions.isNotEmpty)
            _InfoCard(
              icon: Icons.celebration_outlined,
              title: 'Поводы',
              content: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: trip.occasions
                    .map((occasion) => Chip(
                          label: Text(occasion),
                          backgroundColor: Colors.blue[50],
                          labelStyle: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 13,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ),

          const SizedBox(height: 16),

          _InfoCard(
            icon: Icons.backpack_outlined,
            title: 'Сбор вещей',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${trip.packedCount} из ${trip.totalCount}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'вещей собрано',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: trip.packingProgress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      trip.packingProgress >= 1
                          ? Colors.green
                          : Colors.blue[600]!,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(trip.packingProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Кнопка добавления вещей
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _showWardrobeSelection(trip),
              icon: const Icon(Icons.add),
              label: const Text('Добавить вещи из гардероба'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[600],
                side: BorderSide(color: Colors.blue[600]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackingListTab(Trip trip) {
    if (trip.packingList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.backpack_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Список вещей пуст',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте вещи из гардероба',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Статистика
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.check_circle_outline,
                  trip.packedCount,
                  'Собрано',
                  Colors.green,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[200],
                ),
                _buildStatItem(
                  Icons.circle_outlined,
                  trip.totalCount - trip.packedCount,
                  'Осталось',
                  Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Список вещей
          Expanded(
            child: ListView.separated(
              itemCount: trip.packingList.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = trip.packingList[index];
                return _PackingListItem(
                  item: item,
                  onToggle: (isPacked) {
                    ref
                        .read(tripDetailProvider(widget.tripId).notifier)
                        .togglePackingItem(item.id, isPacked);
                  },
                  onRemove: () {
                    ref
                        .read(tripDetailProvider(widget.tripId).notifier)
                        .removePackingItem(item.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    int value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherTab(Trip trip) {
    final weather = trip.weather;

    if (weather == null) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.cloud_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Нет данных о погоде',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(tripDetailProvider(widget.tripId).notifier)
                    .refreshWeather();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Обновить'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Карточка погоды
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[400]!,
                  Colors.blue[300]!,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getWeatherIcon(weather.condition),
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.temperature.round()}°C',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          weather.condition,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (weather.feelsLike != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Ощущается как ${weather.feelsLike!.round()}°C',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Детали
          Row(
            children: [
              Expanded(
                child: _WeatherDetailCard(
                  icon: Icons.water_drop_outlined,
                  label: 'Влажность',
                  value: weather.humidity != null ? '${weather.humidity}%' : '—',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WeatherDetailCard(
                  icon: Icons.air_outlined,
                  label: 'Ветер',
                  value:
                      weather.windSpeed != null ? '${weather.windSpeed} м/с' : '—',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Рекомендации
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getWeatherRecommendation(weather),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.amber[900],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Кнопка обновления
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(tripDetailProvider(widget.tripId).notifier)
                    .refreshWeather();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Обновить погоду'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[600],
                side: BorderSide(color: Colors.blue[600]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('ясно') || c.contains('sun')) return Icons.wb_sunny;
    if (c.contains('облач') || c.contains('cloud')) return Icons.cloud;
    if (c.contains('дожд') || c.contains('rain')) return Icons.grain;
    if (c.contains('снег') || c.contains('snow')) return Icons.ac_unit;
    if (c.contains('гро') || c.contains('storm')) return Icons.thunderstorm;
    return Icons.cloud;
  }

  String _getWeatherRecommendation(TripWeather weather) {
    if (weather.temperature < 0) {
      return 'Очень холодно! Не забудьте тёплую одежду: пуховик, шапку, перчатки.';
    } else if (weather.temperature < 10) {
      return 'Прохладно. Возьмите куртку или тёплый свитер.';
    } else if (weather.temperature < 20) {
      return 'Комфортная температура. Подойдёт лёгкая куртка или кофта.';
    } else if (weather.temperature < 30) {
      return 'Тёплая погода. Одевайтесь легко и удобно.';
    } else {
      return 'Жарко! Выбирайте лёгкую одежду из дышащих материалов.';
    }
  }

  void _showWardrobeSelection(Trip trip) {
    // Навигация на страницу выбора вещей из гардероба
    context.push('/trips/${trip.id}/add-items');
  }

  void _showOptionsBottomSheet(Trip? trip, TripDetailNotifier notifier) {
    if (trip == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Редактировать'),
              onTap: () {
                Navigator.pop(context);
                context.push('/trips/${trip.id}/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Обновить погоду'),
              onTap: () {
                Navigator.pop(context);
                notifier.refreshWeather();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить поездку', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(trip, notifier);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Trip trip, TripDetailNotifier notifier) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить поездку?'),
        content: Text('Вы уверены, что хотите удалить "${trip.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await notifier.deleteTrip();
              // Используем dialogContext для проверки mounted
              if (dialogContext.mounted) {
                // Закрываем диалог если ещё открыт
                Navigator.pop(dialogContext);
              }
              // Переходим на список поездок
              if (mounted) {
                ref.read(tripListProvider.notifier).removeTrip(trip.id);
                context.go('/trips');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget content;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF525252),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}

class _WeatherDetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherDetailCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue[600], size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackingListItem extends StatelessWidget {
  final TripPackingItem item;
  final Function(bool) onToggle;
  final VoidCallback onRemove;

  const _PackingListItem({
    required this.item,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onRemove(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isPacked ? Colors.green[200]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            // Чекбокс
            GestureDetector(
              onTap: () => onToggle(!item.isPacked),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: item.isPacked ? Colors.green : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: item.isPacked ? Colors.green : Colors.grey[400]!,
                  ),
                ),
                child: item.isPacked
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Изображение
            if (item.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 20),
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decoration: item.isPacked ? TextDecoration.lineThrough : null,
                      color: item.isPacked ? Colors.grey : const Color(0xFF1A1A1A),
                    ),
                  ),
                  if (item.category != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.category!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Кнопка удаления
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onRemove,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabDelegate oldDelegate) => false;
}
