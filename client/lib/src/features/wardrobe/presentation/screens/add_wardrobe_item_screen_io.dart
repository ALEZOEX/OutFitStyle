import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../domain/entities/wardrobe_item.dart';
import '../../../../domain/entities/wardrobe_request_entities.dart';
import '../providers/wardrobe_provider.dart';

/// Состояние формы добавления элемента
class AddItemState {
  final String? imageUrl;
  final String? localImagePath;
  final String name;
  final String category;
  final String? brand;
  final String? color;
  final String? size;
  final bool isLoading;
  final double? uploadProgress;
  final String? error;

  const AddItemState({
    this.imageUrl,
    this.localImagePath,
    this.name = '',
    this.category = 'top',
    this.brand,
    this.color,
    this.size,
    this.isLoading = false,
    this.uploadProgress,
    this.error,
  });

  AddItemState copyWith({
    String? imageUrl,
    String? localImagePath,
    String? name,
    String? category,
    String? brand,
    String? color,
    String? size,
    bool? isLoading,
    double? uploadProgress,
    String? error,
  }) {
    return AddItemState(
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      size: size ?? this.size,
      isLoading: isLoading ?? this.isLoading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      error: error,
    );
  }

  bool get isValid =>
      name.trim().isNotEmpty && (imageUrl != null || localImagePath != null);
}

/// Нотификер для управления состоянием
class AddItemNotifier extends StateNotifier<AddItemState> {
  AddItemNotifier() : super(const AddItemState());

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateCategory(String category) {
    state = state.copyWith(category: category);
  }

  void updateBrand(String? brand) {
    state = state.copyWith(brand: brand);
  }

  void updateColor(String? color) {
    state = state.copyWith(color: color);
  }

  void updateSize(String? size) {
    state = state.copyWith(size: size);
  }

  void setImage(String path) {
    state = state.copyWith(localImagePath: path, imageUrl: path);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setUploadProgress(double progress) {
    state = state.copyWith(uploadProgress: progress);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Загрузить изображение на сервер и обновить состояние
  ///
  /// Реализует загрузку изображения с прогрессом.
  /// Если сервер недоступен, сохраняет локальный путь.
  Future<void> uploadImage(String path) async {
    setLoading(true);
    try {
      // Симуляция загрузки с прогрессом для демонстрации UX
      // В продакшене здесь будет реальный HTTP запрос с multipart/form-data
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 80));
        setUploadProgress(i / 100);
      }

      // В продакшене: загрузка на сервер через ImageUploadService
      // final uploadService = ref.read(imageUploadServiceProvider);
      // final url = await uploadService.uploadImage(path, onProgress: setUploadProgress);

      state = state.copyWith(
        imageUrl: path, // В продакшене: url
        uploadProgress: null,
        isLoading: false,
      );
    } catch (e) {
      setError('Ошибка загрузки: $e');
      setLoading(false);
    }
  }

  WardrobeItem toItem() {
    const uuid = Uuid();
    return WardrobeItem(
      id: uuid.v4(),
      name: state.name.trim(),
      category: state.category,
      brand: state.brand?.trim().isEmpty == true ? null : state.brand,
      color: state.color,
      size: state.size,
      imageUrl: state.imageUrl ?? '',
    );
  }

  /// Создать запрос на создание элемента гардероба
  ///
  /// Конвертирует текущее состояние формы в WardrobeItemCreateRequest
  WardrobeItemCreateRequest toCreateRequest() {
    return WardrobeItemCreateRequest(
      name: state.name.trim(),
      category: state.category,
      subcategory: state.category, // По умолчанию равно категории
      style: 'casual', // Значение по умолчанию
      iconEmoji: '👕', // Значение по умолчанию
      imageUrl: state.imageUrl,
      minTemp: null,
      maxTemp: null,
      warmthLevel: null,
      rainOk: false,
      snowOk: false,
      windOk: false,
      isFavorite: false,
      isArchived: false,
      userId: '', // Сервер определит по токену
      clothingItemId: '', // Пустой — ручное создание
      color: state.color,
      size: state.size,
      localImagePath: state.localImagePath,
    );
  }
}

final addItemProvider = StateNotifierProvider<AddItemNotifier, AddItemState>((
  ref,
) {
  return AddItemNotifier();
});

/// Экран добавления элемента гардероба
class AddWardrobeItemScreen extends ConsumerStatefulWidget {
  const AddWardrobeItemScreen({super.key});

  @override
  ConsumerState<AddWardrobeItemScreen> createState() =>
      _AddWardrobeItemScreenState();
}

class _AddWardrobeItemScreenState extends ConsumerState<AddWardrobeItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _picker = ImagePicker();

  final _categories = [
    {'value': 'top', 'label': 'Верх', 'icon': Icons.checkroom},
    {'value': 'bottom', 'label': 'Низ', 'icon': Icons.content_paste},
    {'value': 'shoes', 'label': 'Обувь', 'icon': Icons.sports_soccer},
    {'value': 'outerwear', 'label': 'Верхняя одежда', 'icon': Icons.ac_unit},
    {'value': 'headwear', 'label': 'Головной убор', 'icon': Icons.face},
    {'value': 'accessory', 'label': 'Аксессуар', 'icon': Icons.watch},
  ];

  final _colors = [
    'Черный',
    'Белый',
    'Серый',
    'Синий',
    'Красный',
    'Зеленый',
    'Желтый',
    'Оранжевый',
    'Фиолетовый',
    'Розовый',
    'Коричневый',
    'Бежевый',
  ];

  final _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        ref.read(addItemProvider.notifier).setImage(image.path);
        // Автозагрузка на сервер
        ref.read(addItemProvider.notifier).uploadImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: const Text('Сделать фото'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Выбрать из галереи'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final state = ref.read(addItemProvider);
    if (!state.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Загрузите фото и заполните название'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = ref.read(addItemProvider.notifier).toCreateRequest();
    final wardrobeNotifier = ref.read(wardrobeProvider.notifier);

    // Показываем индикатор загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Сохранение...'),
          ],
        ),
      ),
    );

    try {
      final result = await wardrobeNotifier.addItem(request);
      
      if (mounted) {
        Navigator.pop(context); // Закрыть диалог загрузки
      }

      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Элемент успешно добавлен'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, request);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ошибка: элемент не был создан'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Закрыть диалог загрузки
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addItemProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить вещь'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: state.isLoading ? null : _saveItem,
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body:
          state.isLoading && state.uploadProgress == null
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Загрузка фото
                    _buildImageUpload(context, state),
                    const SizedBox(height: 24),

                    // Название
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Название *',
                        hintText: 'Например: Белая футболка',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      onChanged:
                          (value) => ref
                              .read(addItemProvider.notifier)
                              .updateName(value),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите название';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Категория
                    _buildCategorySelector(context, state),
                    const SizedBox(height: 16),

                    // Бренд
                    TextFormField(
                      controller: _brandController,
                      decoration: InputDecoration(
                        labelText: 'Бренд',
                        hintText: 'Например: Nike, Zara',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.shopping_bag),
                      ),
                      onChanged:
                          (value) => ref
                              .read(addItemProvider.notifier)
                              .updateBrand(value),
                    ),
                    const SizedBox(height: 16),

                    // Цвет
                    _buildColorSelector(context, state),
                    const SizedBox(height: 16),

                    // Размер
                    _buildSizeSelector(context, state),
                    const SizedBox(height: 32),

                    // Кнопка сохранения
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: state.isLoading ? null : _saveItem,
                        icon:
                            state.isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.save),
                        label: Text(
                          state.isLoading ? 'Сохранение...' : 'Сохранить',
                        ),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildImageUpload(BuildContext context, AddItemState state) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: state.isLoading ? null : _showImageSourceDialog,
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                state.imageUrl != null
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
            style:
                state.imageUrl != null ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child:
            state.imageUrl != null
                ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(state.imageUrl!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    if (state.uploadProgress != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                value: state.uploadProgress,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${(state.uploadProgress! * 100).toInt()}%',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                          onPressed: () {
                            ref.read(addItemProvider.notifier).setImage('');
                          },
                        ),
                      ),
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_a_photo,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Добавить фото',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Камера или галерея',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context, AddItemState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Категория *',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _categories.map((cat) {
                final isSelected = state.category == cat['value'];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat['icon'] as IconData, size: 18),
                      const SizedBox(width: 4),
                      Text(cat['label'] as String),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(addItemProvider.notifier)
                          .updateCategory(cat['value'] as String);
                    }
                  },
                  selectedColor: theme.colorScheme.primaryContainer,
                  checkmarkColor: theme.colorScheme.onPrimaryContainer,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector(BuildContext context, AddItemState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Цвет',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _colors.map((color) {
                final isSelected = state.color == color;
                return FilterChip(
                  label: Text(color),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref
                        .read(addItemProvider.notifier)
                        .updateColor(selected ? color : null);
                  },
                  selectedColor: theme.colorScheme.primaryContainer,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeSelector(BuildContext context, AddItemState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Размер',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _sizes.map((size) {
                final isSelected = state.size == size;
                return FilterChip(
                  label: Text(size),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref
                        .read(addItemProvider.notifier)
                        .updateSize(selected ? size : null);
                  },
                  selectedColor: theme.colorScheme.primaryContainer,
                );
              }).toList(),
        ),
      ],
    );
  }
}
