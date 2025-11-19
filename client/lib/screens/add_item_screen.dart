import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../exceptions/api_exceptions.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isSaving = false;

  String _selectedCategoryId = 'upper';
  String _selectedIcon = '👕';

  // Данные вынесены как статическая константа
  static const Map<String, List<String>> _categories = {
    'Верх': ['upper', '👕', '👚', '👔'],
    'Верхняя одежда': ['outerwear', '🧥', '🦺'],
    'Низ': ['lower', '👖', '🩳', '👗'],
    'Обувь': ['footwear', '👟', '👢', '👞'],
    'Аксессуары': ['accessories', '🧢', '🧣', '🧤', '🎒'],
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_isSaving) return;
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);

      final itemName = _nameController.text.trim();

      try {
        await _apiService.addWardrobeItem(
          userId: 1, // ЗАГЛУШКА: Заменить на реальный ID пользователя
          name: itemName,
          category: _selectedCategoryId,
          icon: _selectedIcon,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Вещь успешно добавлена!'),
              backgroundColor: AppTheme.success,
            ),
          );
          if (mounted) Navigator.pop(context, true);
        }
      } on ApiException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: ${e.message}'),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить вещь'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: _onSave,
              tooltip: 'Сохранить',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название вещи',
                  hintText: 'Например, "Любимые синие джинсы"',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text('Категория', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories.entries.map((entry) {
                  return DropdownMenuItem(
                      value: entry.value[0], child: Text(entry.key));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategoryId = value;
                      _selectedIcon = _categories.values
                          .firstWhere((val) => val[0] == value)[1];
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              Text('Иконка', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _categories.values
                    .firstWhere((val) => val[0] == _selectedCategoryId)
                    .sublist(1)
                    .map((icon) {
                  final isSelected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.primaryColor.withValues(alpha: 0.2)
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.primaryColor
                              : (isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300),
                          width: isSelected ? 2.5 : 1.0,
                        ),
                      ),
                      child: Center(
                          child:
                              Text(icon, style: const TextStyle(fontSize: 32))),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
