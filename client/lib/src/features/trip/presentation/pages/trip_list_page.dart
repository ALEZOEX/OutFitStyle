import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/trip.dart';
import '../providers/trip_providers.dart';
import '../widgets/trip_card.dart';

/// Страница списка поездок
class TripListPage extends ConsumerStatefulWidget {
  const TripListPage({super.key});

  @override
  ConsumerState<TripListPage> createState() => _TripListPageState();
}

class _TripListPageState extends ConsumerState<TripListPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripListProvider);
    final notifier = ref.read(tripListProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: CustomScrollView(
        slivers: [
          // Заголовок
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Мои поездки',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Планируйте путешествия и собирайте вещи',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Фильтры
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildFilterChips(state, notifier),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          // Список поездок
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
                        'Не удалось загрузить поездки',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => notifier.loadTrips(),
                        child: const Text('Попробовать снова'),
                      ),
                    ],
                  ),
                ),
              ),
            TripLoadStatus.initial ||
            TripLoadStatus.success ||
            TripLoadStatus.refreshing =>
              state.filteredTrips.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.backpack_outlined,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.trips.isEmpty
                                  ? 'У вас пока нет поездок'
                                  : 'Нет поездок с выбранным статусом',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.trips.isEmpty
                                  ? 'Создайте свою первую поездку'
                                  : 'Измените фильтр',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            if (state.trips.isEmpty) ...[
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => context.push('/trips/create'),
                                icon: const Icon(Icons.add),
                                label: const Text('Создать поездку'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final trip = state.filteredTrips[index];
                            return TripCard(
                              trip: trip,
                              onTap: () => context.push('/trips/${trip.id}'),
                              onDelete: () => _showDeleteDialog(trip),
                            );
                          },
                          childCount: state.filteredTrips.length,
                        ),
                      ),
                    ),
          },
        ],
      ),
      ),
      // Кнопка создания
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/trips/create'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Поездка'),
      ),
    );
  }

  Widget _buildFilterChips(TripListState state, TripListNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Все',
            isSelected: state.filterStatus == null,
            onTap: () => notifier.clearFilter(),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Планируются',
            isSelected: state.filterStatus == TripStatus.planned,
            onTap: () => notifier.setFilter(TripStatus.planned),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Активные',
            isSelected: state.filterStatus == TripStatus.active,
            onTap: () => notifier.setFilter(TripStatus.active),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Завершены',
            isSelected: state.filterStatus == TripStatus.completed,
            onTap: () => notifier.setFilter(TripStatus.completed),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить поездку?'),
        content: Text('Вы уверены, что хотите удалить поездку "${trip.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(tripListProvider.notifier).removeTrip(trip.id);
              // Вызываем API для удаления
              ref.read(tripRepositoryProvider).deleteTrip(trip.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
