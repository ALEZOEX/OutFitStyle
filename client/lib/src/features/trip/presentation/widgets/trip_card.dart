import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/trip.dart';
import 'trip_status_badge.dart';

/// Карточка поездки для списка
class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(trip.startDate);
    final isPast = DateTime.now().isAfter(trip.endDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и статус
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Color(0xFF757575),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                trip.destination,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF757575),
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
                  TripStatusBadge(status: trip.status),
                ],
              ),

              const SizedBox(height: 16),

              // Даты
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: isPast
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF1976D2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateRange(trip.startDate, trip.endDate),
                      style: TextStyle(
                        fontSize: 13,
                        color: isPast
                            ? const Color(0xFF9E9E9E)
                            : const Color(0xFF1976D2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Сегодня!',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1976D2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Прогресс сборки
              if (trip.packingList.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.backpack_outlined,
                      size: 16,
                      color: Color(0xFF757575),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${trip.packedCount} из ${trip.totalCount} вещей собрано',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF757575),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(trip.packingProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: trip.packingProgress,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF1976D2),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],

              // Погода
              if (trip.weather != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      _getWeatherIcon(trip.weather!.condition),
                      size: 18,
                      color: const Color(0xFF1976D2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${trip.weather!.temperature.round()}°C, ${trip.weather!.condition}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ],

              // Кнопка удаления
              if (onDelete != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Удалить'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFD32F2F),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final dateFormat = DateFormat('d MMM', 'ru_RU');
    final sameMonth = start.month == end.month && start.year == end.year;

    if (sameMonth) {
      return '${dateFormat.format(start)} – ${end.day} ${_getMonthName(end.month)}';
    } else {
      return '${dateFormat.format(start)} – ${dateFormat.format(end)}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'янв', 'фев', 'мар', 'апр', 'мая', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return months[month];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  IconData _getWeatherIcon(String condition) {
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('ясно') || conditionLower.contains('sun')) {
      return Icons.wb_sunny_outlined;
    } else if (conditionLower.contains('облач') || conditionLower.contains('cloud')) {
      return Icons.cloud_outlined;
    } else if (conditionLower.contains('дожд') || conditionLower.contains('rain')) {
      return Icons.grain_outlined;
    } else if (conditionLower.contains('снег') || conditionLower.contains('snow')) {
      return Icons.ac_unit_outlined;
    } else if (conditionLower.contains('гро') || conditionLower.contains('storm')) {
      return Icons.thunderstorm_outlined;
    }
    return Icons.cloud_outlined;
  }
}
