import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/weather_data.dart';
import '../../theme/app_theme.dart';
import '../containers/glass_container.dart';

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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final temp = data.temperature?.round() ?? 0;
    final textColor = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    final textMuted = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      gradient: LinearGradient(
        begin: isDark ? Alignment.topLeft : Alignment.topRight,
        end: isDark ? Alignment.bottomRight : Alignment.bottomLeft,
        colors: isDark
            ? [
                theme.colorScheme.primary.withValues(alpha: 0.2),
                theme.colorScheme.secondary.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.05),
              ]
            : [
                theme.colorScheme.primary.withValues(alpha: 0.12),
                theme.colorScheme.secondary.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.85),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, textColor, textSecondary, textMuted),
          const SizedBox(height: AppSpacing.xl),
          _buildMainWeather(
            context,
            data,
            temp,
            isDark,
            textColor,
            textSecondary,
            textMuted,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildDetails(context, data, isDark, textColor, textSecondary),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color textColor,
    Color textSecondary,
    Color textMuted,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, color: textColor, size: 14),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  'Москва',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDate(),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: textMuted, fontSize: 11),
            ),
            if (onRefresh != null) ...[
              const SizedBox(width: AppSpacing.sm),
              InkWell(
                onTap: onRefresh,
                borderRadius: AppRadius.radiusSm,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.3),
                          theme.colorScheme.primary.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: AppRadius.radiusSm,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(Icons.refresh, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMainWeather(
    BuildContext context,
    WeatherData data,
    int temp,
    bool isDark,
    Color textColor,
    Color textSecondary,
    Color textMuted,
  ) {
    final theme = Theme.of(context);
    final icon = _getWeatherIcon(data.description ?? '');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$temp°',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _getWeatherDescription(data.description ?? ''),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (data.feelsLike != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ощущается как ${data.feelsLike!.round()}°',
                  style: theme.textTheme.bodySmall?.copyWith(color: textMuted),
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
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.08),
                    ]
                  : [
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                    ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 36,
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(
    BuildContext context,
    WeatherData data,
    bool isDark,
    Color textColor,
    Color textSecondary,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailPill(
            context,
            icon: Icons.water_drop_outlined,
            value: data.humidity != null ? '${data.humidity}%' : '—',
            label: 'Влажность',
            isDark: isDark,
            textColor: textColor,
            textSecondary: textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildDetailPill(
            context,
            icon: Icons.air,
            value: data.windSpeed != null
                ? '${data.windSpeed!.round()} м/с'
                : '—',
            label: 'Ветер',
            isDark: isDark,
            textColor: textColor,
            textSecondary: textSecondary,
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
    required bool isDark,
    required Color textColor,
    required Color textSecondary,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: textSecondary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Нет данных о погоде'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Проверьте подключение к интернету',
            style: AppTypography.bodySmall(context),
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: AppSpacing.lg),
            InkWell(
              onTap: onRefresh,
              borderRadius: AppRadius.radiusPill,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.3),
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: AppRadius.radiusPill,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Colors.white, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Обновить',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
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
    }
    if (desc.contains('облач') ||
        desc.contains('cloud') ||
        desc.contains('пасмурно')) {
      return desc.contains('перемен')
          ? Icons.cloud_queue_rounded
          : Icons.cloud_rounded;
    }
    if (desc.contains('дожд') ||
        desc.contains('rain') ||
        desc.contains('морось')) {
      return (desc.contains('гром') || desc.contains('thunder'))
          ? Icons.thunderstorm_rounded
          : Icons.water_drop_rounded;
    }
    if (desc.contains('снег') || desc.contains('snow')) {
      return Icons.ac_unit_rounded;
    }
    if (desc.contains('туман') || desc.contains('fog')) {
      return Icons.foggy;
    }
    return Icons.wb_sunny_rounded;
  }

  String _getWeatherDescription(String description) {
    if (description.isEmpty) return 'Ясно';
    final desc = description.toLowerCase();
    if (desc.contains('ясно') || desc.contains('clear')) {
      return 'Ясно';
    }
    if (desc.contains('облач') || desc.contains('cloud')) {
      return desc.contains('перемен') ? 'Переменная облачность' : 'Облачно';
    }
    if (desc.contains('дожд') || desc.contains('rain')) {
      return (desc.contains('гром') || desc.contains('thunder'))
          ? 'Гроза'
          : 'Дождь';
    }
    if (desc.contains('снег') || desc.contains('snow')) {
      return 'Снег';
    }
    if (desc.contains('туман') || desc.contains('fog')) {
      return 'Туман';
    }
    return description;
  }
}
