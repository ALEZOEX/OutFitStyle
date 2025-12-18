import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recommendation_provider.dart';
import '../providers/weather_provider.dart';
import '../models/recommendation_models.dart';
import 'regenerate_screen.dart';

class RecommendationHomeScreen extends StatefulWidget {
  const RecommendationHomeScreen({super.key});

  @override
  State<RecommendationHomeScreen> createState() => _RecommendationHomeScreenState();
}

class _RecommendationHomeScreenState extends State<RecommendationHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().load();
      context.read<RecommendationProvider>().loadHistory(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WeatherProvider>();
    final rp = context.watch<RecommendationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('OutfitStyle')),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<WeatherProvider>().load(),
            context.read<RecommendationProvider>().loadHistory(refresh: true),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Погода
            if (wp.isLoading) const LinearProgressIndicator(),
            if (wp.error != null) Text(wp.error!, style: const TextStyle(color: Colors.red)),
            if (wp.current != null) _WeatherCard(data: wp.current!),

            const SizedBox(height: 16),

            // Кнопки создания образа
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: rp.isLoading
                      ? null
                      : () => context.read<RecommendationProvider>().createUsingProfile(),
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(rp.isLoading ? 'Думаем...' : 'Подобрать по городу профиля'),
                ),
                FilledButton.icon(
                  onPressed: rp.isLoading
                      ? null
                      : () => _showCoordinatesInput(context),
                  icon: const Icon(Icons.location_on),
                  label: Text(rp.isLoading ? 'Думаем...' : 'По координатам'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                  ),
                ),
              ],
            ),

            if (rp.error != null) ...[
              const SizedBox(height: 8),
              Text(rp.error!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 24),

            // Последняя рекомендация (Сегодня)
            if (rp.latest != null) ...[
              const Text('Ваш образ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _RecommendationCard(
                rec: rp.latest!,
                showActions: true,
                onRegenerate: () => _openRegenerate(context, rp.latest!),
              ),
            ],

            const SizedBox(height: 24),
            const Text('История', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            ...rp.history.map((r) => _RecommendationCard(rec: r)),

            if (rp.hasMore)
              TextButton(
                onPressed: rp.isLoadingMore ? null : () => context.read<RecommendationProvider>().loadHistory(),
                child: Text(rp.isLoadingMore ? 'Загрузка...' : 'Показать ещё'),
              ),
          ],
        ),
      ),
    );
  }

  void _showCoordinatesInput(BuildContext context) {
    final latController = TextEditingController();
    final lonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Введите координаты'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latController,
              decoration: const InputDecoration(labelText: 'Широта (lat)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: lonController,
              decoration: const InputDecoration(labelText: 'Долгота (lon)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final latStr = latController.text;
              final lonStr = lonController.text;

              if (latStr.isEmpty || lonStr.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введите координаты')),
                  );
                }
                return;
              }

              try {
                final lat = double.parse(latStr);
                final lon = double.parse(lonStr);
                Navigator.pop(context);

                if (context.mounted) {
                  context.read<RecommendationProvider>().create(
                    lat: lat,
                    lon: lon,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Некорректные координаты')),
                  );
                }
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openRegenerate(BuildContext context, RecommendationRecord rec) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegenerateScreen(originalRec: rec)),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _WeatherCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final current = (data['current'] as Map?) ?? {};
    final loc = data['location'] ?? '';
    final temp = current['temperature'];
    final feels = current['feels_like'];
    final main = current['weather_main'] ?? '';

    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: ListTile(
        leading: const Icon(Icons.cloud),
        title: Text('$loc • $temp°C'),
        subtitle: Text('Ощущается как $feels°C • $main'),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final RecommendationRecord rec;
  final bool showActions;
  final VoidCallback? onRegenerate;

  const _RecommendationCard({required this.rec, this.showActions = false, this.onRegenerate});

  @override
  Widget build(BuildContext context) {
    final lines = rec.outfitLines();
    final dateStr = rec.createdAt.toLocal().toString().split('.')[0];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                if (rec.isFavorite) const Icon(Icons.favorite, size: 16, color: Colors.red),
              ],
            ),
            const SizedBox(height: 8),
            ...lines.map((l) {
              final cat = l['category'];
              final item = l['item'] ?? {};
              final name = item['name'] ?? '';
              final emoji = item['icon_emoji'] ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('$cat: $emoji $name'),
              );
            }),
            if (showActions) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onRegenerate,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Пересобрать'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}