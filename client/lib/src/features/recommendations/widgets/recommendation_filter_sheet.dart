import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/recommendation.dart';
import '../../../domain/enums/recommendation_type.dart';
import '../../../domain/enums/outfit_weather.dart';

class RecommendationFilterSheet extends ConsumerStatefulWidget {
  final Function(RecommendationFilterOptions)? onApply;

  const RecommendationFilterSheet({super.key, this.onApply});

  @override
  ConsumerState<RecommendationFilterSheet> createState() =>
      _RecommendationFilterSheetState();
}

class _RecommendationFilterSheetState
    extends ConsumerState<RecommendationFilterSheet> {
  final RecommendationFilterOptions _options = RecommendationFilterOptions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Фильтры рекомендаций',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Confidence threshold
          const Text('Минимальное доверие модели:'),
          Slider(
            value: _options.minConfidence.toDouble(),
            min: 0,
            max: 100,
            divisions: 10,
            label: '${_options.minConfidence.toInt()}%',
            onChanged: (value) {
              setState(() {
                _options.minConfidence = value.toInt();
              });
            },
          ),
          Text('${_options.minConfidence.toInt()}%'),
          const SizedBox(height: 16),

          // Recommendation type filter
          const Text('Тип рекомендаций:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                RecommendationType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.displayName),
                    selected: _options.selectedTypes.contains(type),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _options.selectedTypes.add(type);
                        } else {
                          _options.selectedTypes.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),

          // Weather conditions filter
          const Text('Погодные условия:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                RecommendationWeatherCondition.values.map((condition) {
                  return ChoiceChip(
                    label: Text(condition.displayName),
                    selected: _options.selectedWeatherConditions.contains(
                      condition,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _options.selectedWeatherConditions.add(condition);
                        } else {
                          _options.selectedWeatherConditions.remove(condition);
                        }
                      });
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onApply?.call(_options);
                  Navigator.pop(context);
                },
                child: const Text('Применить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecommendationFilterOptions {
  int minConfidence = 50;
  List<RecommendationType> selectedTypes = [];
  List<RecommendationWeatherCondition> selectedWeatherConditions = [];

  bool matchesRecommendation(Recommendation recommendation) {
    // Check confidence
    if ((recommendation.confidenceScore ?? 0) < minConfidence) {
      return false;
    }

    // Check recommendation type
    if (selectedTypes.isNotEmpty &&
        !selectedTypes.contains(recommendation.type)) {
      return false;
    }

    // Check weather conditions
    if (selectedWeatherConditions.isNotEmpty &&
        !(recommendation.outfit?.weatherConditions ?? []).any(
          (outfitCondition) => selectedWeatherConditions.any(
            (selectedCondition) =>
                _convertToOutfitWeather(selectedCondition) == outfitCondition,
          ),
        )) {
      return false;
    }

    return true;
  }

  OutfitWeather _convertToOutfitWeather(
    RecommendationWeatherCondition condition,
  ) {
    switch (condition) {
      case RecommendationWeatherCondition.sunny:
        return OutfitWeather.sunny;
      case RecommendationWeatherCondition.cloudy:
        return OutfitWeather.cloudy;
      case RecommendationWeatherCondition.rainy:
        return OutfitWeather.rainy;
      case RecommendationWeatherCondition.snowy:
        return OutfitWeather.snowy;
      case RecommendationWeatherCondition.windy:
        return OutfitWeather.windy;
      case RecommendationWeatherCondition.cold:
        return OutfitWeather.cold;
      case RecommendationWeatherCondition.hot:
        return OutfitWeather.hot;
      case RecommendationWeatherCondition.allWeather:
        // Return a common default value since OutfitWeather doesn't have allWeather
        return OutfitWeather.mild;
    }
  }
}

enum RecommendationWeatherCondition {
  sunny('Солнечно'),
  cloudy('Облачно'),
  rainy('Дождь'),
  snowy('Снег'),
  windy('Ветрено'),
  cold('Холодно'),
  hot('Жарко'),
  allWeather('Любая погода');

  const RecommendationWeatherCondition(this.displayName);
  final String displayName;
}
