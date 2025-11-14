import 'package:flutter/material.dart';
import '../models/recommendation.dart';
import '../theme/app_theme.dart';

class WeatherCard extends StatelessWidget {
  final Recommendation recommendation;

  const WeatherCard({
    super.key,
    required this.recommendation,
  });

  String _getWeatherEmoji(String weather) {
    final weatherLower = weather.toLowerCase();
    if (weatherLower.contains('ясно')) return '☀️';
    if (weatherLower.contains('облач')) return '☁️';
    if (weatherLower.contains('дожд')) return '🌧️';
    if (weatherLower.contains('снег')) return '❄️';
    if (weatherLower.contains('гроз')) return '⛈️';
    return '🌤️';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.withOpacity(AppTheme.primary, 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.withOpacity(AppTheme.primary, 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Location
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  recommendation.location,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Temperature
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getWeatherEmoji(recommendation.weather),
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${recommendation.temperature.round()}°',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1,
                      ),
                    ),
                    Text(
                      recommendation.weather,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.withOpacity(AppTheme.backgroundDark, 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailItem(
                    icon: Icons.water_drop,
                    label: 'Влажность',
                    value: '${recommendation.humidity}%',
                  ),
                  _buildDetailItem(
                    icon: Icons.air,
                    label: 'Ветер',
                    value: '${recommendation.windSpeed.toStringAsFixed(1)} м/с',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.withOpacity(AppTheme.primary, 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                recommendation.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
