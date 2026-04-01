import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/weather_data.dart';
import '../../theme/app_theme.dart';

/// Glassmorphism weather card — Landing liquid glass style
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
    if (data == null) return _buildErrorState(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final temp = data.temperature?.round() ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: AppRadius.radiusXxl,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.primary.withValues(alpha: 0.2),
                        AppColors.secondary.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.05),
                      ]
                    : [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.secondary.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.6),
                      ],
              ),
              borderRadius: AppRadius.radiusXxl,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.xl),
                  _buildMainWeather(context, data, temp),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildDetails(context, data),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Локация
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white.withValues(alpha: 0.9),
                size: 14,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  'Москва',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Дата + кнопка обновить
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDate(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onRefresh,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMainWeather(BuildContext context, WeatherData data, int temp) {
    final theme = Theme.of(context);
    final icon = _getWeatherIcon(data.description ?? '');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Color(0xCCFFFFFF)],
                ).createShader(bounds),
                child: Text(
                  '$temp°',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                    letterSpacing: -2,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _getWeatherDescription(data.description ?? ''),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (data.feelsLike != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ощущается как ${data.feelsLike!.round()}°',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: Colors.white, size: 36),
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context, WeatherData data) {
    final humidity = data.humidity;
    final windSpeed = data.windSpeed;

    return Row(
      children: [
        Expanded(
          child: _buildDetailPill(
            context,
            icon: Icons.water_drop_outlined,
            value: humidity != null ? '$humidity%' : '—',
            label: 'Влажность',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildDetailPill(
            context,
            icon: Icons.air,
            value: windSpeed != null ? '${windSpeed.round()} м/с' : '—',
            label: 'Ветер',
          ),
        ),
      ],
    );
  }

  Widget _buildDetailPill(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: AppRadius.radiusXxl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: AppRadius.radiusXxl,
            border: Border.all(color: AppColors.grey200.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 40, color: AppColors.grey400),
              const SizedBox(height: AppSpacing.md),
              const Text('Нет данных о погоде'),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Проверьте подключение к интернету',
                style: AppTypography.bodySmall(context),
              ),
              if (onRefresh != null) ...[
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Обновить'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate() =>
      DateFormat('EEEE, d MMMM', 'ru_RU').format(DateTime.now());

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('ясно') ||
        desc.contains('clear') ||
        desc.contains('sunny')) {
      return Icons.wb_sunny_rounded;
    } else if (desc.contains('облач') ||
        desc.contains('cloud') ||
        desc.contains('пасмурно')) {
      return desc.contains('перемен')
          ? Icons.cloud_queue_rounded
          : Icons.cloud_rounded;
    } else if (desc.contains('дожд') ||
        desc.contains('rain') ||
        desc.contains('морось')) {
      return (desc.contains('гром') || desc.contains('thunder'))
          ? Icons.thunderstorm_rounded
          : Icons.water_drop_rounded;
    } else if (desc.contains('снег') || desc.contains('snow')) {
      return Icons.ac_unit_rounded;
    } else if (desc.contains('туман') || desc.contains('fog')) {
      return Icons.foggy;
    }
    return Icons.wb_sunny_rounded;
  }

  String _getWeatherDescription(String description) {
    if (description.isEmpty) return 'Ясно';
    final desc = description.toLowerCase();
    if (desc.contains('ясно') || desc.contains('clear')) return 'Ясно';
    if (desc.contains('облач') || desc.contains('cloud')) {
      return desc.contains('перемен') ? 'Переменная облачность' : 'Облачно';
    }
    if (desc.contains('дожд') || desc.contains('rain')) {
      return (desc.contains('гром') || desc.contains('thunder'))
          ? 'Гроза'
          : 'Дождь';
    }
    if (desc.contains('снег') || desc.contains('snow')) return 'Снег';
    if (desc.contains('туман') || desc.contains('fog')) return 'Туман';
    return description;
  }
}
