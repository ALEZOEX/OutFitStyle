import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';

class BodyMeasurementsScreen extends StatefulWidget {
  const BodyMeasurementsScreen({super.key});

  @override
  State<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends State<BodyMeasurementsScreen> {
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _top = TextEditingController();
  final _bottom = TextEditingController();
  final _shoes = TextEditingController();
  String _system = 'EU';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromProfile());
  }

  void _loadFromProfile() {
    final p = context.read<ProfileProvider>();
    final user = p.user;
    final bm = (user?['body_measurements'] as Map?)?.cast<String, dynamic>();
    if (bm == null) return;

    final h = bm['height'];
    final w = bm['weight'];
    if (h is int) _height.text = '$h';
    if (w is int) _weight.text = '$w';

    final sizes = (bm['sizes'] as Map?)?.cast<String, dynamic>();
    if (sizes != null) {
      _top.text = (sizes['top'] ?? '').toString();
      _bottom.text = (sizes['bottom'] ?? '').toString();
      _shoes.text = (sizes['shoes'] ?? '').toString();
      _system = (sizes['size_system'] ?? 'EU').toString();
    }

    setState(() {});
  }

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    _top.dispose();
    _bottom.dispose();
    _shoes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final patch = <String, dynamic>{
      'height': int.tryParse(_height.text.trim()),
      'weight': int.tryParse(_weight.text.trim()),
      'sizes': {
        'top': _top.text.trim().isEmpty ? null : _top.text.trim(),
        'bottom': _bottom.text.trim().isEmpty ? null : _bottom.text.trim(),
        'shoes': _shoes.text.trim().isEmpty ? null : _shoes.text.trim(),
        'size_system': _system,
      },
    };

    await context.read<ProfileProvider>().updateBodyMeasurements(patch);

    if (!mounted) return;
    final err = context.read<ProfileProvider>().error;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $err')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сохранено')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Размеры и тело'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Сохранить')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _height,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Рост (см)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _weight,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Вес (кг)'),
          ),
          const SizedBox(height: 16),

          const Text('Размеры', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _top,
                  decoration: const InputDecoration(labelText: 'Верх'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _bottom,
                  decoration: const InputDecoration(labelText: 'Низ'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _shoes,
                  decoration: const InputDecoration(labelText: 'Обувь'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _system,
                  items: const [
                    DropdownMenuItem(value: 'EU', child: Text('EU')),
                    DropdownMenuItem(value: 'US', child: Text('US')),
                    DropdownMenuItem(value: 'UK', child: Text('UK')),
                    DropdownMenuItem(value: 'RU', child: Text('RU')),
                  ],
                  onChanged: (v) => setState(() => _system = v ?? 'EU'),
                  decoration: const InputDecoration(labelText: 'Система'),
                ),
              ),
            ],
          ),

          if (p.error != null) ...[
            const SizedBox(height: 16),
            Text(p.error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}