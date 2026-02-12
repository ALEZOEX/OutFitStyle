import 'package:flutter/material.dart';

class UserStatisticsWidget extends StatelessWidget {
  final Map<String, dynamic>? statistics;

  const UserStatisticsWidget({
    Key? key,
    this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (statistics == null) {
      return const Center(child: Text('Статистика недоступна'));
    }

    final statsList = <Map<String, dynamic>>[
      {
        'title': 'Всего рекомендаций',
        'value': (statistics!['totalRecommendations'] ?? 0).toString(),
        'icon': Icons.recommend,
      },
      {
        'title': 'Сохранено',
        'value': (statistics!['totalSaved'] ?? 0).toString(),
        'icon': Icons.bookmark,
      },
      {
        'title': 'Понравилось',
        'value': (statistics!['totalLiked'] ?? 0).toString(),
        'icon': Icons.favorite,
      },
      {
        'title': 'Дней активности',
        'value': _calculateActiveDays().toString(),
        'icon': Icons.calendar_today,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Статистика использования',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: statsList.length,
            itemBuilder: (context, index) {
              final stat = statsList[index];
              return Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      stat['icon'] as IconData,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stat['value'].toString(),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['title'] as String,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  int _calculateActiveDays() {
    final joinDate = statistics?['joinDate'] as DateTime?;
    if (joinDate == null) return 0;

    final now = DateTime.now();
    final difference = now.difference(joinDate);
    return difference.inDays;
  }
}
