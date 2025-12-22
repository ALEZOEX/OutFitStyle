import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wardrobe_provider.dart';
import '../models/wardrobe_models.dart';
import '../utils/preferences_constants.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardrobeProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WardrobeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Гардероб'),
        actions: [
          IconButton(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<WardrobeProvider>().refresh(),
        child: ListView.builder(
          itemCount: p.items.length + 1,
          itemBuilder: (ctx, i) {
            if (i == p.items.length) {
              if (p.isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (p.hasMore) {
                // auto-load more
                WidgetsBinding.instance.addPostFrameCallback((_) => context.read<WardrobeProvider>().loadMore());
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Загружаем...')),
                );
              }
              return const SizedBox(height: 24);
            }

            final item = p.items[i];
            return _WardrobeTile(item: item);
          },
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final name = TextEditingController();
    final category = TextEditingController(text: 'upper');
    final subcategory = TextEditingController(text: 'tshirt');
    final style = TextEditingController(text: 'casual');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Добавить вещь (ручной ввод)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Название')),
            TextField(controller: category, decoration: const InputDecoration(labelText: 'Категория (upper/...)')),
            TextField(controller: subcategory, decoration: const InputDecoration(labelText: 'Подкатегория')),
            TextField(controller: style, decoration: const InputDecoration(labelText: 'Стиль (casual/...)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          FilledButton(
            onPressed: () async {
              try {
                await context.read<WardrobeProvider>().addManual(
                      name: name.text.trim(),
                      category: category.text.trim(),
                      subcategory: subcategory.text.trim(),
                      style: style.text.trim(),
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Вещь успешно добавлена в гардероб')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка при добавлении вещи: $e')),
                  );
                }
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}

class _WardrobeTile extends StatelessWidget {
  final WardrobeItem item;

  const _WardrobeTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final emoji = item.item.iconEmoji ?? '';
    final title = item.item.name;
    final cat = translateCategory(item.item.category);
    final sub = translateSubcategory(item.item.subcategory);
    final style = translateStyle(item.item.style);
    final subtitle = '$cat / $sub • $style • ${item.item.source}';

    return ListTile(
      leading: Text(emoji.isEmpty ? '👕' : emoji, style: const TextStyle(fontSize: 22)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Wrap(
        spacing: 6,
        children: [
          IconButton(
            onPressed: () => context.read<WardrobeProvider>().markWorn(item),
            icon: const Icon(Icons.check),
            tooltip: 'Надел',
          ),
          IconButton(
            onPressed: () => context.read<WardrobeProvider>().toggleFavorite(item),
            icon: Icon(item.isFavorite ? Icons.favorite : Icons.favorite_border),
            tooltip: 'Избранное',
          ),
          IconButton(
            onPressed: () => context.read<WardrobeProvider>().toggleArchive(item),
            icon: Icon(item.isArchived ? Icons.archive : Icons.archive_outlined),
            tooltip: 'Архив',
          ),
        ],
      ),
    );
  }
}