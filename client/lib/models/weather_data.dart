class WeatherData {
  final double temperature;
  final String condition;
  final int? humidity;
  final double? windSpeed;

  WeatherData({
    required this.temperature,
    required this.condition,
    this.humidity,
    this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final main = (json['main'] as Map<String, dynamic>? ?? {});
    final weatherList = (json['weather'] as List? ?? []);

    final tempRaw = main['temp'];
    final temp = tempRaw is num ? tempRaw.toDouble() : 0.0;

    final description = weatherList.isNotEmpty
        ? (weatherList[0]['description']?.toString() ?? '')
        : '';

    final windMap = json['wind'] as Map<String, dynamic>?;

    return WeatherData(
      temperature: temp,
      condition: description,
      humidity: main['humidity'] is num ? main['humidity'] as int : null,
      windSpeed: windMap?['speed'] is num
          ? (windMap!['speed'] as num).toDouble()
          : null,
    );
  }
}
