import 'package:flutter/foundation.dart';

class WeatherProvider extends ChangeNotifier {
  final dynamic weatherService; // Will be replaced with actual WeatherService type once implemented

  WeatherProvider(this.weatherService);

  bool _isLoading = false;
  String? _error;
  dynamic _current; // Will be replaced with actual weather data model

  bool get isLoading => _isLoading;
  String? get error => _error;
  dynamic get current => _current;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual weather loading logic once WeatherService is fully implemented
      // _current = await weatherService.getCurrentWeather();
      _current = null; // Placeholder
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}