import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/src/domain/entities/weather_data.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData? weatherData;
  final VoidCallback? onTap;

  const WeatherCard({
    Key? key,
    this.weatherData,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (weatherData == null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Данные о погоде недоступны'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Погода',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Icon(Icons.wb_sunny),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '${weatherData!.temperature?.round()}°C',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(weatherData!.description ?? ''),
            Text('Ощущается как ${weatherData!.feelsLike?.round()}°C'),
          ],
        ),
      ),
    );
  }
}
