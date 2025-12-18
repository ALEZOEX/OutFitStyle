import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/geo_service.dart';

class CityPickerResult {
  final String displayName;
  final double lat;
  final double lon;

  CityPickerResult({required this.displayName, required this.lat, required this.lon});
}

class CityPickerScreen extends StatefulWidget {
  const CityPickerScreen({super.key});

  @override
  State<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends State<CityPickerScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;

  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _places = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(v));
  }

  Future<void> _search(String q) async {
    q = q.trim();
    if (q.length < 2) {
      setState(() {
        _places = const [];
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final geo = context.read<GeoService>();
      final places = await geo.autocomplete(q);
      setState(() => _places = places);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор города')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                labelText: 'Город',
                hintText: 'Москва',
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null) Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _places.length,
                itemBuilder: (_, i) {
                  final p = _places[i];
                  final name = (p['display_name'] ?? '').toString();
                  final lat = (p['latitude'] as num).toDouble();
                  final lon = (p['longitude'] as num).toDouble();

                  return ListTile(
                    title: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text('$lat, $lon'),
                    onTap: () {
                      Navigator.pop(context, CityPickerResult(displayName: name, lat: lat, lon: lon));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}