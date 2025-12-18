import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recommendation_provider.dart';
import '../models/recommendation_models.dart';

class RecommendationHistoryScreen extends StatefulWidget {
  const RecommendationHistoryScreen({super.key});

  @override
  State<RecommendationHistoryScreen> createState() => _RecommendationHistoryScreenState();
}

class _RecommendationHistoryScreenState extends State<RecommendationHistoryScreen> {
  // Фильтры
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  String? _occasionFilter;
  int? _minRatingFilter;
  bool? _isFavoriteFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationProvider>().loadHistory(refresh: true);
    });
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  Future<void> _applyFilters() async {
    // В реальном приложении нужно было бы вызвать метод с фильтрами
    // Но текущий loadHistory не поддерживает фильтры, поэтому просто обновим
    await context.read<RecommendationProvider>().loadHistory(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RecommendationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('История рекомендаций'),
        actions: [
          IconButton(
            onPressed: _showFilters,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Фильтры',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<RecommendationProvider>().loadHistory(refresh: true),
        child: ListView.builder(
          itemCount: p.history.length + (p.hasMore ? 1 : 0),
          itemBuilder: (context, i) {
            if (i == p.history.length) {
              if (p.hasMore) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<RecommendationProvider>().loadHistory();
                });
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Загрузка...')),
                );
              }
            }

            if (i < p.history.length) {
              final rec = p.history[i];
              return Card(
                child: ListTile(
                  title: Text(_formatDateTime(rec.createdAt)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...rec.outfitLines().take(3).map((l) => Text(
                            '${l['category']}: ${(l['item']?['icon_emoji'] ?? '')} ${(l['item']?['name'] ?? '')}',
                            style: const TextStyle(fontSize: 12),
                          )),
                      if (rec.outfitLines().length > 3) const Text('...', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: rec.isFavorite ? const Icon(Icons.favorite, color: Colors.red) : null,
                ),
              );
            }

            return Container();
          },
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0) {
      return 'Сегодня, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Вчера, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${dt.day} ${_monthName(dt.month)}, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dt.day}.${dt.month}.${dt.year}';
    }
  }

  String _monthName(int month) {
    const months = [
      '',
      'янв',
      'фев',
      'мар',
      'апр',
      'мая',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];
    return months[month];
  }

  Future<void> _showFilters() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Фильтры'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _fromDateController,
                decoration: const InputDecoration(labelText: 'С (дд.мм.гггг)'),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (date != null) {
                    _fromDateController.text = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _toDateController,
                decoration: const InputDecoration(labelText: 'По (дд.мм.гггг)'),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (date != null) {
                    _toDateController.text = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                  }
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _occasionFilter,
                decoration: const InputDecoration(labelText: 'Повод'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Все поводы')),
                  DropdownMenuItem(value: 'daily', child: Text('Повседневный')),
                  DropdownMenuItem(value: 'work', child: Text('Работа')),
                  DropdownMenuItem(value: 'sports', child: Text('Спорт')),
                  DropdownMenuItem(value: 'evening', child: Text('Вечеринка')),
                ],
                onChanged: (value) => setState(() => _occasionFilter = value),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _minRatingFilter,
                decoration: const InputDecoration(labelText: 'Мин. оценка'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Любая')),
                  DropdownMenuItem(value: 1, child: Text('1 звезда')),
                  DropdownMenuItem(value: 2, child: Text('2 звезды')),
                  DropdownMenuItem(value: 3, child: Text('3 звезды')),
                  DropdownMenuItem(value: 4, child: Text('4 звезды')),
                  DropdownMenuItem(value: 5, child: Text('5 звёзд')),
                ],
                onChanged: (value) => setState(() => _minRatingFilter = value),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Только избранные'),
                value: _isFavoriteFilter ?? false,
                onChanged: (value) => setState(() => _isFavoriteFilter = value ? true : null),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Сбросить фильтры
              setState(() {
                _fromDateController.clear();
                _toDateController.clear();
                _occasionFilter = null;
                _minRatingFilter = null;
                _isFavoriteFilter = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Сбросить'),
          ),
          TextButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Применить'),
          ),
        ],
      ),
    );
  }
}