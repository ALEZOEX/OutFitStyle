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
    final main = json['main'] as Map<String, dynamic>;
    final weatherList = json['weather'] as List;
    
    return WeatherData(
      temperature: main['temp'] as double,
      condition: weatherList[0]['description'] as String,
      humidity: main['humidity'] as int?,
      windSpeed: (json['wind'] as Map<String, dynamic>?)?['speed'] as double?,
    );
  }
}