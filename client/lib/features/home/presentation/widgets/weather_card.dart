import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final Map<String, dynamic> weather;
  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    // Пытаемся извлечь типичные поля (гибко)
    final temp = _toDouble(weather['temp'] ?? weather['temperature'] ?? weather['t']) ?? 0.0;
    final condition = (weather['condition'] ?? weather['description'] ?? weather['weather'] ?? '').toString();
    final city = (weather['city'] ?? weather['location'] ?? '').toString();

    final bg = _backgroundFor(condition, Theme.of(context).colorScheme);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                city.isEmpty ? 'Сегодня' : city,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                condition.isEmpty ? 'Погода уточняется' : condition,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
                    ),
              ),
            ]),
          ),
          _AnimatedTemp(temp: temp),
        ],
      ),
    );
  }

  LinearGradient _backgroundFor(String condition, ColorScheme scheme) {
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('дожд')) {
      return LinearGradient(
        colors: [scheme.primaryContainer, scheme.surfaceContainerHighest],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (c.contains('clear') || c.contains('ясн') || c.contains('sun')) {
      return LinearGradient(
        colors: [scheme.tertiaryContainer, scheme.primaryContainer],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: [scheme.surfaceContainerHighest, scheme.surface],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  double? _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '');
  }
}

class _AnimatedTemp extends StatelessWidget {
  final double temp;
  const _AnimatedTemp({required this.temp});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: temp, end: temp),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final t = value.round();
        return Text(
          '$t°',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
        );
      },
    );
  }
}