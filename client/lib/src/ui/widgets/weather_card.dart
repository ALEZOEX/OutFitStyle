import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/weather_data.dart';
import '../../theme/app_theme.dart';

/// Расширенная карточка погоды с прогнозом и деталями
class WeatherCard extends StatelessWidget {
  final WeatherData? weatherData;
  final List<WeatherData>? forecast;
  final VoidCallback? onTap;
  final VoidCallback? onRefresh;

  const WeatherCard({
    super.key,
    this.weatherData,
    this.forecast,
    this.onTap,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final data = weatherData;
    if (data == null) {
      return _buildErrorState(context);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXxl,
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getGradientStartColor(data),
                _getGradientEndColor(data),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.lg),
                _buildCurrentWeather(context),
                const SizedBox(height: AppSpacing.xl),
                _buildWeatherDetails(context),
                const SizedBox(height: AppSpacing.xl),
                if (forecast != null && forecast!.isNotEmpty)
                  _buildForecast(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: AppRadius.radiusMd,
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Москва',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _formatCurrentTime(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (onRefresh != null)
          InkWell(
            onTap: onRefresh,
            borderRadius: AppRadius.radiusMd,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: AppRadius.radiusMd,
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
          ),
      ],
    );
  }

  Widget _buildCurrentWeather(BuildContext context) {
    final theme = Theme.of(context);
    final data = weatherData;
    if (data == null) return const SizedBox.shrink();

    final temp = data.temperature?.round() ?? 0;
    final feelsLike = data.feelsLike?.round();
    final description = data.description ?? '';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$temp',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  Text(
                    '°C',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              if (feelsLike != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Ощущается как $feelsLike°',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getWeatherIcon(data.description ?? ''),
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _getWeatherDescription(data.description ?? ''),
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherDetails(BuildContext context) {
    final data = weatherData;
    if (data == null) return const SizedBox.shrink();

    final humidity = data.humidity;
    final windSpeed = data.windSpeed;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppRadius.radiusLg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            context,
            icon: Icons.water_drop,
            value: humidity != null ? '$humidity%' : '—',
            label: 'Влажность',
          ),
          _buildDivider(),
          _buildDetailItem(
            context,
            icon: Icons.air,
            value: windSpeed != null ? '${windSpeed.round()} м/с' : '—',
            label: 'Ветер',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildForecast(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Прогноз на 3 дня',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: forecast!.take(3).length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final day = forecast![index];
              return _buildForecastItem(context, day, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForecastItem(BuildContext context, WeatherData day, int index) {
    final theme = Theme.of(context);
    final temp = day.temperature?.round() ?? 0;

    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppRadius.radiusMd,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'День ${index + 1}',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            _getWeatherIcon(day.description ?? ''),
            color: Colors.white.withValues(alpha: 0.9),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            '$temp°',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off,
                color: theme.colorScheme.onErrorContainer,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Нет данных о погоде',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Проверьте подключение к интернету',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Обновить'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCurrentTime() {
    return DateFormat('EEEE, d MMMM', 'ru_RU').format(DateTime.now());
  }

  String _formatDayOfWeek(DateTime? date) {
    if (date == null) return '—';
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Сегодня';
    if (difference == 1) return 'Завтра';

    return DateFormat('EEE', 'ru_RU').format(date);
  }

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();

    if (desc.contains('ясно') ||
        desc.contains('sunny') ||
        desc.contains('clear') ||
        desc.contains('преимущ')) {
      return Icons.wb_sunny;
    } else if (desc.contains('облач') ||
        desc.contains('cloud') ||
        desc.contains('пасмурно') ||
        desc.contains('overcast')) {
      return desc.contains('перемен') ? Icons.cloud_queue : Icons.cloud;
    } else if (desc.contains('дожд') ||
        desc.contains('rain') ||
        desc.contains('морось')) {
      return (desc.contains('гром') || desc.contains('thunder'))
          ? Icons.thunderstorm
          : Icons.grain;
    } else if (desc.contains('снег') || desc.contains('snow')) {
      return Icons.ac_unit;
    } else if (desc.contains('туман') || desc.contains('fog')) {
      return Icons.foggy;
    } else if (desc.contains('ветр') || desc.contains('wind')) {
      return Icons.air;
    }

    return Icons.wb_sunny;
  }

  String _getWeatherDescription(String description) {
    if (description.isEmpty) return 'Ясно';

    final desc = description.toLowerCase();

    if (desc.contains('ясно') ||
        desc.contains('sunny') ||
        desc.contains('clear')) {
      return 'Ясно';
    } else if (desc.contains('облач') || desc.contains('cloud')) {
      return desc.contains('перемен') ? 'Переменная облачность' : 'Облачно';
    } else if (desc.contains('дожд') || desc.contains('rain')) {
      return (desc.contains('гром') || desc.contains('thunder'))
          ? 'Гроза'
          : 'Дождь';
    } else if (desc.contains('снег') || desc.contains('snow')) {
      return 'Снег';
    } else if (desc.contains('туман') || desc.contains('fog')) {
      return 'Туман';
    } else if (desc.contains('ветр') || desc.contains('wind')) {
      return 'Ветрено';
    }

    return description;
  }

  Color _getGradientStartColor(WeatherData weather) {
    final temp = weather.temperature ?? 20;
    final desc = weather.description?.toLowerCase() ?? '';
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour > 21;

    if (isNight) return const Color(0xFF1A237E);
    if (desc.contains('дожд') ||
        desc.contains('thunder') ||
        desc.contains('rain'))
      return const Color(0xFF546E7A);
    if (desc.contains('снег') || desc.contains('snow'))
      return const Color(0xFF90A4AE);
    if (temp >= 25) return const Color(0xFFFF6F00);
    if (temp >= 15) return const Color(0xFF42A5F5);
    if (temp >= 5) return const Color(0xFF78909C);
    return const Color(0xFF5C6BC0);
  }

  Color _getGradientEndColor(WeatherData weather) {
    final temp = weather.temperature ?? 20;
    final desc = weather.description?.toLowerCase() ?? '';
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour > 21;

    if (isNight) return const Color(0xFF0D47A1);
    if (desc.contains('дожд') ||
        desc.contains('thunder') ||
        desc.contains('rain'))
      return const Color(0xFF37474F);
    if (desc.contains('снег') || desc.contains('snow'))
      return const Color(0xFF607D8B);
    if (temp >= 25) return const Color(0xFFFF8F00);
    if (temp >= 15) return const Color(0xFF2196F3);
    if (temp >= 5) return const Color(0xFF546E7A);
    return const Color(0xFF3949AB);
  }
}
