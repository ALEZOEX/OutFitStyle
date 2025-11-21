import'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recommendation.dart'as recommendation_model;
import '../models/weather_data.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

typedef Recommendation = recommendation_model.Recommendation;
typedef ClothingItem = recommendation_model.ClothingItem;

class OutfitDialog extends StatelessWidget {
 final Recommendation recommendation;
  final WeatherData weatherData;
  final Function(List<Map<String, dynamic>>) onOutfitSelected;

  const OutfitDialog({
    super.key,
    required this.recommendation,
    required this.weatherData,
    required this.onOutfitSelected,
});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints:BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
color: Colors.black.withValues(alpha:0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppTheme.primaryGradientDark
                          : AppTheme.primaryGradientLight,
                      borderRadius: BorderRadius.circular(12),
                   ),
                   child: const Icon(Icons.lightbulb, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Рекомендации по погоде',
                          style: TextStyle(
fontSize:20,
                           fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          'На основе текущей погоды',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 14,
),
                        ),
],
                   ),
),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weather info
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.backgroundDark
                            : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.wb_sunny, color: theme.primaryColor, size: 20),
const SizedBox(width:8),
                          Text(
                            'Температура: ${weatherData.temperature.toStringAsFixed(1)}°C, ${weatherData.condition}',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
],
                      ),
                    ),
const SizedBox(height: 16),
                    // Recommendation reason
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.backgroundDark
                            : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
border: Border.all(
color: theme.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Почему эти вещи?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            recommendation.message,
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                       ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Outfit items
                   Text(
                      'Рекомендуемый комплект',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                     ),
                    ),
                    const SizedBox(height: 12),
                    ...recommendation.items.map((item){
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: isDark
                                    ? AppTheme.primaryGradientDark: AppTheme.primaryGradientLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                               child: Text(
                                  item.iconEmoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.name,
                              style:TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                 ],
                ),
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(16.0),
child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding:const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: isDark ? Colors.grey : theme.primaryColor,
                        ),
                      ),
                      child: Text(
                        'Закрыть',
                        style: TextStyle(
                         color: isDark ? Colors.grey : theme.primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                 Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onOutfitSelected(recommendation.items.map((item) => {
                          'id': item.id,
                          'name': item.name,
                          'icon_emoji': item.iconEmoji,
                          'category': item.category,
                        }).toList());
                      },
                     style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: theme.primaryColor,
                      ),
                      child: const Text(
                        'Добавить в план',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                 ),
                ],
             ),
            ),
          ],
        ),
      ),
    );
 }
}