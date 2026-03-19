import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Провайдер для хранения выбранного города
final selectedCityProvider = StateProvider<CityData?>((ref) => null);

/// Данные города
class CityData {
  final String name;
  final double lat;
  final double lon;

  const CityData({required this.name, required this.lat, required this.lon});

  @override
  String toString() => name;
}

/// Виджет выбора города для Web-версии
/// Отображается когда геолокация недоступна или отклонена
class CitySelectorWidget extends ConsumerStatefulWidget {
  final Function(CityData city)? onCitySelected;

  const CitySelectorWidget({super.key, this.onCitySelected});

  @override
  ConsumerState<CitySelectorWidget> createState() => _CitySelectorWidgetState();
}

class _CitySelectorWidgetState extends ConsumerState<CitySelectorWidget> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  bool _showDropdown = false;
  bool _isSearching = false;
  List<CityData> _searchResults = [];

  // Популярные города для выбора
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
  ];

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _selectCity(CityData city) {
    ref.read(selectedCityProvider.notifier).state = city;
    widget.onCitySelected?.call(city);

    if (mounted) {
      Navigator.of(context).pop(city);
    }
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
      // Nominatim API (бесплатный, не требует API ключа)
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'q=${Uri.encodeComponent(query)}&'
        'format=json&'
        'limit=5&'
        'countrycodes=ru&'
        'accept-language=ru',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'OutFitStyle/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final results =
            data
                .where(
                  (item) => item['type'] == 'city' || item['type'] == 'town',
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

  void _showCitySearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Заголовок
                      Text(
                        'Выберите город',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Поиск
                      TextField(
                        controller: _cityController,
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                  : _cityController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _cityController.clear();
                                      setModalState(() {
                                        _searchResults = [];
                                      });
                                    },
                                  )
                                  : null,
                        ),
                        onChanged: (value) {
                          setModalState(() {});
                          _searchCity(value);
                        },
                        onSubmitted: (value) {
                          if (_searchResults.isNotEmpty) {
                            _selectCity(_searchResults.first);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Результаты поиска или популярные города
                      if (_isSearching)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_searchResults.isNotEmpty) ...[
                        Text(
                          'Результаты поиска',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            separatorBuilder:
                                (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final city = _searchResults[index];
                              return ListTile(
                                leading: const Icon(Icons.location_city),
                                title: Text(city.name),
                                subtitle: Text(
                                  'Шир: ${city.lat.toStringAsFixed(2)}, Долг: ${city.lon.toStringAsFixed(2)}',
                                ),
                                onTap: () => _selectCity(city),
                              );
                            },
                          ),
                        ),
                      ] else if (_cityController.text.isEmpty) ...[
                        Text(
                          'Популярные города',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _popularCities.map((city) {
                                return ActionChip(
                                  label: Text(city.name),
                                  onPressed: () => _selectCity(city),
                                );
                              }).toList(),
                        ),
                      ] else ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('Городы не найдены'),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCity = ref.watch(selectedCityProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_city,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Местоположение',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              selectedCity != null
                  ? 'Ваш город: ${selectedCity.name}'
                  : 'Геолокация недоступна в браузере',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    selectedCity != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showCitySearch,
                icon: const Icon(Icons.edit_location),
                label: Text(
                  selectedCity != null ? 'Изменить' : 'Выбрать город',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            if (selectedCity != null) ...[
              const SizedBox(height: 8),
              Text(
                'Рекомендации будут обновлены с учётом погоды в городе ${selectedCity.name}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
