import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../presentation/providers/user_location_provider.dart';

/// Данные города
class CityData {
  final String name;
  final double lat;
  final double lon;

  const CityData({required this.name, required this.lat, required this.lon});

  @override
  String toString() => name;
}

/// Диалог выбора города
/// Используется для выбора местоположения когда геолокация недоступна
class CitySelectorDialog extends ConsumerStatefulWidget {
  final Function(CityData city)? onCitySelected;

  const CitySelectorDialog({super.key, this.onCitySelected});

  @override
  ConsumerState<CitySelectorDialog> createState() => _CitySelectorDialogState();
}

class _CitySelectorDialogState extends ConsumerState<CitySelectorDialog> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<CityData> _searchResults = [];

  // Популярные города
  final List<CityData> _popularCities = [
    const CityData(name: 'Москва', lat: 55.7558, lon: 37.6173),
    const CityData(name: 'Санкт-Петербург', lat: 59.9343, lon: 30.3351),
    const CityData(name: 'Казань', lat: 55.7961, lon: 49.1064),
    const CityData(name: 'Новосибирск', lat: 55.0084, lon: 82.9357),
    const CityData(name: 'Екатеринбург', lat: 56.8389, lon: 60.6057),
    const CityData(name: 'Нижний Новгород', lat: 56.2965, lon: 43.9361),
    const CityData(name: 'Краснодар', lat: 45.0355, lon: 38.9753),
    const CityData(name: 'Сочи', lat: 43.6028, lon: 39.7342),
    const CityData(name: 'Владивосток', lat: 43.1056, lon: 131.8735),
    const CityData(name: 'Калининград', lat: 54.7104, lon: 20.4522),
    const CityData(name: 'Минск', lat: 53.9006, lon: 27.5590),
    const CityData(name: 'Алматы', lat: 43.2220, lon: 76.9806),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCity(CityData city) {
    widget.onCitySelected?.call(city);
    ref
        .read(userLocationProvider.notifier)
        .setLocation(city.lat, city.lon, city.name);
    Navigator.of(context).pop(city);
  }

  /// Поиск городов через Nominatim OpenStreetMap API
  Future<void> _searchCity(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'q=${Uri.encodeComponent(query)}&'
        'format=json&'
        'limit=5&'
        'countrycodes=ru,kz,by&'
        'accept-language=ru',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'OutfitStyle/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final results =
            data
                .where(
                  (item) =>
                      item['type'] == 'city' ||
                      item['type'] == 'town' ||
                      item['type'] == 'village',
                )
                .take(5)
                .map(
                  (item) => CityData(
                    name: item['display_name'].split(',')[0],
                    lat: double.parse(item['lat']),
                    lon: double.parse(item['lon']),
                  ),
                )
                .toList();

        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка поиска: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Выберите город',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Для получения точных рекомендаций',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Поиск
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Введите название города...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon:
                      _isSearching
                          ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                          : _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          )
                          : null,
                ),
                onChanged: (value) {
                  _searchCity(value);
                },
                onSubmitted: (value) {
                  if (_searchResults.isNotEmpty) {
                    _selectCity(_searchResults.first);
                  }
                },
              ),
            ),

            const SizedBox(height: 16),

            // Результаты или популярные города
            Flexible(
              child:
                  _isSearching
                      ? const Center(child: CircularProgressIndicator())
                      : _searchResults.isNotEmpty
                      ? _buildSearchResults(theme)
                      : _searchController.text.isEmpty
                      ? _buildPopularCities(theme)
                      : const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('Городы не найдены'),
                        ),
                      ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final city = _searchResults[index];
        return ListTile(
          leading: Icon(Icons.location_city, color: theme.colorScheme.primary),
          title: Text(city.name),
          subtitle: Text(
            'Шир: ${city.lat.toStringAsFixed(2)}, Долг: ${city.lon.toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall,
          ),
          onTap: () => _selectCity(city),
        );
      },
    );
  }

  Widget _buildPopularCities(ThemeData theme) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Text(
          'Популярные города',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _popularCities.map((city) {
                return ActionChip(
                  avatar: const Icon(Icons.location_city, size: 18),
                  label: Text(city.name),
                  onPressed: () => _selectCity(city),
                );
              }).toList(),
        ),
      ],
    );
  }
}
