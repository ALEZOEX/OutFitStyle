import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recommendation_models.dart';
import '../services/recommendation_service.dart';

class RegenerateScreen extends StatefulWidget {
  final RecommendationRecord originalRec;

  const RegenerateScreen({super.key, required this.originalRec});

  @override
  State<RegenerateScreen> createState() => _RegenerateScreenState();
}

class _RegenerateScreenState extends State<RegenerateScreen> {
  final Set<String> _excludedIds = {}; // item.id to exclude
  bool _loading = false;
  RecommendationRecord? _newRec;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final lines = widget.originalRec.outfitLines();

    if (_newRec != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Новый образ')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Готово! Вот ваш новый образ:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              // Show new items
              ..._newRec!.outfitLines().map((l) => ListTile(
                title: Text(l['item']['name'] ?? ''),
                subtitle: Text(l['category'] ?? ''),
                leading: Text(l['item']['icon_emoji'] ?? ''),
              )),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pop(context), // back to home
                child: const Text('Отлично'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Пересобрать')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Выберите вещи, которые хотите заменить:'),
                ),
                Expanded(
                  child: ListView(
                    children: lines.map((l) {
                      final item = l['item'] ?? {};
                      final id = item['id'];
                      final name = item['name'];
                      final cat = l['category'];
                      final isExcluded = _excludedIds.contains(id);

                      return CheckboxListTile(
                        title: Text(name),
                        subtitle: Text(cat),
                        value: isExcluded,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _excludedIds.add(id);
                            } else {
                              _excludedIds.remove(id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Отмена'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _excludedIds.isEmpty ? null : _regenerate,
                          child: const Text('Заменить'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _regenerate() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final svc = context.read<RecommendationService>();
      final rec = await svc.regenerate(
        recommendationId: widget.originalRec.id,
        excludeItems: _excludedIds.toList(),
      );
      setState(() => _newRec = rec);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}