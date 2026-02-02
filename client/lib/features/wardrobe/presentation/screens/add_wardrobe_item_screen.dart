import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/outfit_app_bar.dart';
import '../../../ui/design_system/outfit_style_components.dart';

class AddWardrobeItemScreen extends ConsumerStatefulWidget {
  const AddWardrobeItemScreen({super.key});

  @override
  ConsumerState<AddWardrobeItemScreen> createState() => _AddWardrobeItemScreenState();
}

class _AddWardrobeItemScreenState extends ConsumerState<AddWardrobeItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  String _category = 'top';
  String _subcategory = 't-shirt';
  String _style = 'casual';
  String _season = 'all';
  String _gender = 'unisex';
  String _fit = 'regular';
  String _pattern = 'solid';
  String? _baseColour;
  int? _formalityLevel;
  int? _warmthLevel;
  int? _minTemp;
  int? _maxTemp;

  bool _rainOk = false;
  bool _snowOk = false;
  bool _windOk = false;

  List<String> _usage = [];
  List<String> _materials = [];

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OutfitAppBar(
        title: 'Добавить вещь',
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('Сохранить'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Название
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название',
                prefixIcon: Icon(Icons.edit_rounded),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите название';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Категория
            _buildCategoryField(),

            // Подкатегория
            _buildSubcategoryField(),

            // Стиль
            _buildStyleField(),

            // Сезон
            _buildSeasonField(),

            // Пол
            _buildGenderField(),

            // Цвет
            _buildColourField(),

            // Уровень формальности
            _buildFormalitySlider(),

            // Уровень теплоты
            _buildWarmthSlider(),

            // Температурный диапазон
            _buildTemperatureFields(),

            // Погодные условия
            _buildWeatherOptions(),

            // Назначение
            _buildUsageField(),

            // Материалы
            _buildMaterialsField(),

            // Посадка
            _buildFitField(),

            // Узор
            _buildPatternField(),

            // Примечания
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Примечания',
                prefixIcon: Icon(Icons.note_rounded),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Категория',
          prefixIcon: Icon(Icons.category_rounded),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _category,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'top', child: Text('Верх')),
              DropdownMenuItem(value: 'bottom', child: Text('Низ')),
              DropdownMenuItem(value: 'outerwear', child: Text('Верхняя одежда')),
              DropdownMenuItem(value: 'footwear', child: Text('Обувь')),
              DropdownMenuItem(value: 'accessory', child: Text('Аксессуар')),
              DropdownMenuItem(value: 'dress', child: Text('Платье')),
              DropdownMenuItem(value: 'suit', child: Text('Костюм')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _category = value);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSubcategoryField() {
    final subcategories = _getSubcategoriesForCategory(_category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Подкатегория',
          prefixIcon: Icon(Icons.tag_rounded),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _subcategory,
            isExpanded: true,
            items: subcategories
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _subcategory = value);
              }
            },
          ),
        ),
      ),
    );
  }

  List<String> _getSubcategoriesForCategory(String category) {
    switch (category) {
      case 'top':
        return ['t-shirt', 'shirt', 'blouse', 'sweater', 'hoodie', 'jacket', 'cardigan'];
      case 'bottom':
        return ['jeans', 'trousers', 'skirt', 'shorts', 'leggings'];
      case 'outerwear':
        return ['coat', 'jacket', 'vest', 'blazer', 'raincoat'];
      case 'footwear':
        return ['sneakers', 'boots', 'sandals', 'heels', 'loafers'];
      case 'accessory':
        return ['hat', 'scarf', 'bag', 'belt', 'sunglasses', 'jewelry'];
      case 'dress':
        return ['casual', 'formal', 'evening', 'summer', 'winter'];
      case 'suit':
        return ['business', 'formal', 'wedding', 'casual'];
      default:
        return ['other'];
    }
  }

  Widget _buildStyleField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Стиль',
          prefixIcon: Icon(Icons.design_services_rounded),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _style,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'casual', child: Text('Повседневный')),
              DropdownMenuItem(value: 'business', child: Text('Офисный')),
              DropdownMenuItem(value: 'sport', child: Text('Спорт')),
              DropdownMenuItem(value: 'formal', child: Text('Формальный')),
              DropdownMenuItem(value: 'elegant', child: Text('Элегантный')),
              DropdownMenuItem(value: 'street', child: Text('Уличный')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _style = value);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Сезон',
          prefixIcon: Icon(Icons.beach_access_rounded),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _season,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'spring', child: Text('Весна')),
              DropdownMenuItem(value: 'summer', child: Text('Лето')),
              DropdownMenuItem(value: 'fall', child: Text('Осень')),
              DropdownMenuItem(value: 'winter', child: Text('Зима')),
              DropdownMenuItem(value: 'all', child: Text('Все сезоны')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _season = value);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Пол',
          prefixIcon: Icon(Icons.people_rounded),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _gender,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Мужской')),
              DropdownMenuItem(value: 'female', child: Text('Женский')),
              DropdownMenuItem(value: 'unisex', child: Text('Унисекс')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _gender = value);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildColourField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Цвет',
          prefixIcon: Icon(Icons.palette_rounded),
        ),
        onChanged: (value) => _baseColour = value,
      ),
    );
  }

  Widget _buildFormalitySlider() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Уровень формальности'),
          Slider(
            value: (_formalityLevel ?? 5).toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: (_formalityLevel ?? 5).toString(),
            onChanged: (value) {
              setState(() => _formalityLevel = value.round());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWarmthSlider() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Уровень теплоты'),
          Slider(
            value: (_warmthLevel ?? 5).toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: (_warmthLevel ?? 5).toString(),
            onChanged: (value) {
              setState(() => _warmthLevel = value.round());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureFields() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Мин. темп.',
                prefixIcon: Icon(Icons.ac_unit_rounded),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _minTemp = int.tryParse(value),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Макс. темп.',
                prefixIcon: Icon(Icons.wb_sunny_rounded),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _maxTemp = int.tryParse(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherOptions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Подходит для погоды'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Дождь'),
                selected: _rainOk,
                onSelected: (selected) => setState(() => _rainOk = selected),
              ),
              FilterChip(
                label: const Text('Снег'),
                selected: _snowOk,
                onSelected: (selected) => setState(() => _snowOk = selected),
              ),
              FilterChip(
                label: const Text('Ветер'),
                selected: _windOk,
                onSelected: (selected) => setState(() => _windOk = selected),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageField() {
    final allUsage = ['work', 'casual', 'sports', 'formal', 'party', 'travel'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Назначение'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: allUsage.map((u) {
              final selected = _usage.contains(u);
              return FilterChip(
                label: Text(_translateUsage(u)),
                selected: selected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _usage.add(u);
                    } else {
                      _usage.remove(u);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsField() {
    final allMaterials = ['cotton', 'wool', 'polyester', 'silk', 'denim', 'leather', 'linen'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Материалы'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: allMaterials.map((m) {
              final selected = _materials.contains(m);
              return FilterChip(
                label: Text(_translateMaterial(m)),
                selected: selected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _materials.add(m);
                    } else {
                      _materials.remove(m);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFitField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Посадка',
          prefixIcon: Icon(Icons.straighten_rounded),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _fit,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'tight', child: Text('Прилегающий')),
              DropdownMenuItem(value: 'regular', child: Text('Обычный')),
              DropdownMenuItem(value: 'loose', child: Text('Свободный')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _fit = value);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPatternField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Узор',
          prefixIcon: Icon(Icons.texture_rounded),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _pattern,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'solid', child: Text('Однотонный')),
              DropdownMenuItem(value: 'striped', child: Text('Полоска')),
              DropdownMenuItem(value: 'dotted', child: Text('Точки')),
              DropdownMenuItem(value: 'floral', child: Text('Цветочный')),
              DropdownMenuItem(value: 'checked', child: Text('Клетка')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _pattern = value);
              }
            },
          ),
        ),
      ),
    );
  }

  String _translateUsage(String usage) {
    switch (usage) {
      case 'work': return 'Работа';
      case 'casual': return 'Повседневное';
      case 'sports': return 'Спорт';
      case 'formal': return 'Формальное';
      case 'party': return 'Вечеринка';
      case 'travel': return 'Путешествие';
      default: return usage;
    }
  }

  String _translateMaterial(String material) {
    switch (material) {
      case 'cotton': return 'Хлопок';
      case 'wool': return 'Шерсть';
      case 'polyester': return 'Полиэстер';
      case 'silk': return 'Шелк';
      case 'denim': return 'Джинса';
      case 'leather': return 'Кожа';
      case 'linen': return 'Лен';
      default: return material;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    Haptics.selection();

    try {
      final newItem = WardrobeItemCreateRequest(
        name: _nameController.text,
        category: _category,
        subcategory: _subcategory,
        style: _style,
        season: _season,
        gender: _gender,
        baseColour: _baseColour,
        formalityLevel: _formalityLevel,
        warmthLevel: _warmthLevel,
        minTemp: _minTemp,
        maxTemp: _maxTemp,
        rainOk: _rainOk,
        snowOk: _snowOk,
        windOk: _windOk,
        usage: _usage,
        materials: _materials,
        fit: _fit,
        pattern: _pattern,
        notes: _notesController.text,
      );

      final repo = ref.read(wardrobeRepositoryProvider);
      await repo.createItem(newItem);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вещь добавлена в шкаф')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }
}