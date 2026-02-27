import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Провайдер для хранения выбранного города
final selectedCityProvider = StateProvider<String?>((ref) => null);

/// Виджет выбора города для Web-версии
/// Отображается когда геолокация недоступна или отклонена
class CitySelectorWidget extends ConsumerStatefulWidget {
  final Function(String city)? onCitySelected;

  const CitySelectorWidget({
    super.key,
    this.onCitySelected,
  });

  @override
  ConsumerState<CitySelectorWidget> createState() => _CitySelectorWidgetState();
}

class _CitySelectorWidgetState extends ConsumerState<CitySelectorWidget> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  bool _showDropdown = false;

  // Популярные города для выбора
  final List<Map<String, String>> _popularCities = [
    {'name': 'Москва', 'lat': '55.7558', 'lon': '37.6173'},
    {'name': 'Санкт-Петербург', 'lat': '59.9343', 'lon': '30.3351'},
    {'name': 'Казань', 'lat': '55.7961', 'lon': '49.1064'},
    {'name': 'Новосибирск', 'lat': '55.0084', 'lon': '82.9357'},
    {'name': 'Екатеринбург', 'lat': '56.8389', 'lon': '60.6057'},
    {'name': 'Нижний Новгород', 'lat': '56.2965', 'lon': '43.9361'},
    {'name': 'Краснодар', 'lat': '45.0355', 'lon': '38.9753'},
    {'name': 'Сочи', 'lat': '43.6028', 'lon': '39.7342'},
  ];

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _selectCity(String city, {String? lat, String? lon}) {
    ref.read(selectedCityProvider.notifier).state = city;
    widget.onCitySelected?.call(city);
    
    if (mounted) {
      Navigator.of(context).pop(city);
    }
  }

  void _showCitySearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
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
                hintText: 'Поиск города...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _cityController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _cityController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _selectCity(value);
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Популярные города
            if (_cityController.text.isEmpty) ...[
              Text(
                'Популярные города',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popularCities.map((city) {
                  return ActionChip(
                    label: Text(city['name']!),
                    onPressed: () => _selectCity(
                      city['name']!,
                      lat: city['lat'],
                      lon: city['lon'],
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              // Результаты поиска
              ListTile(
                leading: const Icon(Icons.location_city),
                title: Text(_cityController.text),
                subtitle: const Text('Нажмите для выбора'),
                onTap: () => _selectCity(_cityController.text),
              ),
            ],
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCity = ref.watch(selectedCityProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                  ? 'Ваш город: $selectedCity'
                  : 'Геолокация недоступна в браузере',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selectedCity != null
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
                label: Text(selectedCity != null ? 'Изменить' : 'Выбрать город'),
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
                'Рекомендации будут обновлены с учётом погоды в городе $selectedCity',
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

/// Хелпер для получения координат города (mock, нужно подключить геокодер)
Future<Map<String, double>?> getCityCoordinates(String cityName) async {
  // TODO: Подключить реальный геокодинг (Nominatim, Google Geocoding API)
  final popularCities = {
    'москва': {'lat': 55.7558, 'lon': 37.6173},
    'санкт-петербург': {'lat': 59.9343, 'lon': 30.3351},
    'казань': {'lat': 55.7961, 'lon': 49.1064},
    'новосибирск': {'lat': 55.0084, 'lon': 82.9357},
    'екатеринбург': {'lat': 56.8389, 'lon': 60.6057},
    'нижний новгород': {'lat': 56.2965, 'lon': 43.9361},
    'краснодар': {'lat': 45.0355, 'lon': 38.9753},
    'сочи': {'lat': 43.6028, 'lon': 39.7342},
  };

  final normalized = cityName.toLowerCase().trim();
  return popularCities[normalized];
}
