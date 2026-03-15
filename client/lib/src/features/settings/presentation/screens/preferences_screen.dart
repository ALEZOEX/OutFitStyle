import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:outfitstyle_client/src/ui/widgets/max_width_container.dart';
import '../../../../core/api/api_client.dart';
import '../../../../presentation/providers/session_provider.dart';
import '../../data/repositories/preferences_repository.dart';

/// Модели предпочтений (UI enum)
enum ClothingSizeUI {
  xs('XS'),
  s('S'),
  m('M'),
  l('L'),
  xl('XL'),
  xxl('XXL');

  final String label;
  const ClothingSizeUI(this.label);

  static ClothingSizeUI? fromString(String? size) {
    if (size == null) return null;
    return ClothingSizeUI.values.firstWhere(
      (e) => e.label.toLowerCase() == size.toLowerCase(),
      orElse: () => ClothingSizeUI.m,
    );
  }
}

enum StylePreferenceUI {
  casual('casual', '👕'),
  classic('classic', '👔'),
  sport('sport', '👟'),
  streetwear('streetwear', '🧢'),
  bohemian('bohemian', '🌸'),
  minimal('minimal', '⚫');

  final String apiValue;
  final String emoji;
  const StylePreferenceUI(this.apiValue, this.emoji);

  /// Получить отображаемое название стиля через локализацию
  String getDisplayName() {
    switch (this) {
      case StylePreferenceUI.casual:
        return 'Кэжуал';
      case StylePreferenceUI.classic:
        return 'Классический';
      case StylePreferenceUI.sport:
        return 'Спортивный';
      case StylePreferenceUI.streetwear:
        return 'Стритвир';
      case StylePreferenceUI.bohemian:
        return 'Бохо';
      case StylePreferenceUI.minimal:
        return 'Минимализм';
    }
  }

  static List<String> toStyleList(List<StylePreferenceUI> styles) {
    return styles.map((s) => s.apiValue).toList();
  }

  static List<StylePreferenceUI> fromStyleList(List<String> styles) {
    return styles.map((s) {
      return StylePreferenceUI.values.firstWhere(
        (e) => e.apiValue.toLowerCase() == s.toLowerCase(),
        orElse: () => StylePreferenceUI.casual,
      );
    }).toList();
  }
}

/// Состояние предпочтений
class PreferencesState {
  final ClothingSizeUI? size;
  final List<StylePreferenceUI> styles;
  final List<String> brands;
  final List<String> colors;
  final int minBudget;
  final int maxBudget;
  final bool isLoading;
  final String? error;
  final bool isSaving;

  const PreferencesState({
    this.size,
    this.styles = const [],
    this.brands = const [],
    this.colors = const [],
    this.minBudget = 0,
    this.maxBudget = 50000,
    this.isLoading = false,
    this.error,
    this.isSaving = false,
  });

  PreferencesState copyWith({
    ClothingSizeUI? size,
    List<StylePreferenceUI>? styles,
    List<String>? brands,
    List<String>? colors,
    int? minBudget,
    int? maxBudget,
    bool? isLoading,
    String? error,
    bool? isSaving,
  }) {
    return PreferencesState(
      size: size ?? this.size,
      styles: styles ?? this.styles,
      brands: brands ?? this.brands,
      colors: colors ?? this.colors,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  /// Конвертировать в [Map<String, dynamic>] для отправки на сервер
  Map<String, dynamic> toPreferencesMap() {
    return <String, dynamic>{
      'preferred_temperature': 'comfortable',
      'preferred_colors': colors,
      'preferred_styles': StylePreferenceUI.toStyleList(styles),
      'preferred_brands': brands,
      'max_budget': maxBudget.toDouble(),
      'fit_preference': size?.label.toLowerCase(),
    };
  }

  /// Создать из [Map<String, dynamic>]
  factory PreferencesState.fromPreferencesMap(Map<String, dynamic> pref) {
    return PreferencesState(
      colors: List<String>.from(pref['preferred_colors'] ?? []),
      styles: StylePreferenceUI.fromStyleList(
        List<String>.from(pref['preferred_styles'] ?? []),
      ),
      brands: List<String>.from(pref['preferred_brands'] ?? []),
      minBudget: ((pref['max_budget'] as num?) ?? 50000) ~/ 2,
      maxBudget: ((pref['max_budget'] as num?) ?? 50000).round(),
      size: ClothingSizeUI.fromString(pref['fit_preference'] as String?),
    );
  }
}

class PreferencesNotifier extends StateNotifier<PreferencesState> {
  final PreferencesRepository _repository;

  PreferencesNotifier({required PreferencesRepository repository})
    : _repository = repository,
      super(const PreferencesState()) {
    _loadPreferences();
  }

  /// Загрузить предпочтения с сервера
  Future<void> _loadPreferences() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final pref = await _repository.getPreferences();
      state = PreferencesState.fromPreferencesMap(
        pref,
      ).copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка загрузки предпочтений: $e',
      );
    }
  }

  /// Сохранить предпочтения на сервере
  Future<bool> savePreferences() async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final preferencesMap = state.toPreferencesMap();
      await _repository.updatePreferences(preferencesMap);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Ошибка сохранения предпочтений: $e',
      );
      return false;
    }
  }

  void updateSize(ClothingSizeUI? size) {
    state = state.copyWith(size: size);
  }

  void toggleStyle(StylePreferenceUI style) {
    final styles = List<StylePreferenceUI>.from(state.styles);
    if (styles.contains(style)) {
      styles.remove(style);
    } else {
      styles.add(style);
    }
    state = state.copyWith(styles: styles);
  }

  void addBrand(String brand) {
    if (brand.isNotEmpty && !state.brands.contains(brand)) {
      state = state.copyWith(brands: [...state.brands, brand]);
    }
  }

  void removeBrand(String brand) {
    state = state.copyWith(
      brands: state.brands.where((b) => b != brand).toList(),
    );
  }

  void toggleColor(String color) {
    final colors = List<String>.from(state.colors);
    if (colors.contains(color)) {
      colors.remove(color);
    } else {
      colors.add(color);
    }
    state = state.copyWith(colors: colors);
  }

  void updateBudget(int min, int max) {
    state = state.copyWith(minBudget: min, maxBudget: max);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Провайдеры для создания зависимостей (используют глобальные провайдеры из router.dart)
final _apiClientProvider = Provider<ApiClient>((ref) {
  return ref.watch(apiClientProvider);
});

final _preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  final apiClient = ref.watch(_apiClientProvider);
  return PreferencesRepository(apiClient: apiClient);
});

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, PreferencesState>((ref) {
      final repository = ref.watch(_preferencesRepositoryProvider);
      return PreferencesNotifier(repository: repository);
    });

/// Экран настроек предпочтений
class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  final _brandController = TextEditingController();
  final _popularBrands = [
    'Nike',
    'Adidas',
    'Zara',
    'H&M',
    'Uniqlo',
    'Gucci',
    'Prada',
    'Louis Vuitton',
    'Chanel',
    'Levi\'s',
    'Tommy Hilfiger',
    'Calvin Klein',
  ];

  final _availableColors = [
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

  @override
  void dispose() {
    _brandController.dispose();
    super.dispose();
  }

  void _showAddBrandDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Добавить бренд'),
            content: TextField(
              controller: _brandController,
              decoration: const InputDecoration(
                hintText: 'Название бренда',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () {
                  ref
                      .read(preferencesProvider.notifier)
                      .addBrand(_brandController.text.trim());
                  _brandController.clear();
                  Navigator.pop(context);
                },
                child: const Text('Добавить'),
              ),
            ],
          ),
    );
  }

  Future<void> _savePreferences() async {
    // Показываем индикатор загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success =
          await ref.read(preferencesProvider.notifier).savePreferences();

      if (mounted) {
        Navigator.of(context).pop(); // Закрываем индикатор

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Предпочтения сохранены'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final state = ref.read(preferencesProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Ошибка сохранения'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(preferencesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Предпочтения'),
        centerTitle: true,
        actions: [
          if (state.isSaving)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _savePreferences,
              tooltip: 'Сохранить',
            ),
        ],
      ),
      body:
          state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ResponsiveMaxWidthContainer(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Размер одежды
                    _buildSection(
                      context,
                      title: 'Размер одежды',
                      icon: Icons.checkroom,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            ClothingSizeUI.values.map((size) {
                              final isSelected = state.size == size;
                              return FilterChip(
                                label: Text(size.label),
                                selected: isSelected,
                                onSelected: (_) {
                                  ref
                                      .read(preferencesProvider.notifier)
                                      .updateSize(isSelected ? null : size);
                                },
                                selectedColor:
                                    theme.colorScheme.primaryContainer,
                                checkmarkColor:
                                    theme.colorScheme.onPrimaryContainer,
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Предпочитаемые стили (с локализацией)
                    _buildSection(
                      context,
                      title: 'Предпочитаемые стили',
                      icon: Icons.style,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            StylePreferenceUI.values.map((style) {
                              final isSelected = state.styles.contains(style);
                              return FilterChip(
                                avatar: Text(
                                  style.emoji,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                label: Text(style.getDisplayName()),
                                selected: isSelected,
                                onSelected: (_) {
                                  ref
                                      .read(preferencesProvider.notifier)
                                      .toggleStyle(style);
                                },
                                selectedColor:
                                    theme.colorScheme.primaryContainer,
                                checkmarkColor:
                                    theme.colorScheme.onPrimaryContainer,
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Любимые бренды
                    _buildSection(
                      context,
                      title: 'Любимые бренды',
                      icon: Icons.shopping_bag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.brands.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  state.brands.map((brand) {
                                    return Chip(
                                      label: Text(brand),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 18,
                                      ),
                                      onDeleted: () {
                                        ref
                                            .read(preferencesProvider.notifier)
                                            .removeBrand(brand);
                                      },
                                    );
                                  }).toList(),
                            ),
                            const SizedBox(height: 12),
                          ],
                          // Популярные бренды
                          Text(
                            'Популярные бренды:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                _popularBrands
                                    .where((b) => !state.brands.contains(b))
                                    .take(6)
                                    .map((brand) {
                                      return ActionChip(
                                        label: Text(brand),
                                        onPressed: () {
                                          ref
                                              .read(
                                                preferencesProvider.notifier,
                                              )
                                              .addBrand(brand);
                                        },
                                      );
                                    })
                                    .toList(),
                          ),
                          const SizedBox(height: 12),
                          // Поиск бренда
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Найти бренд...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _showAddBrandDialog,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            onChanged: (value) {
                              // Поиск брендов
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Цветовые предпочтения
                    _buildSection(
                      context,
                      title: 'Цветовые предпочтения',
                      icon: Icons.palette,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _availableColors.map((color) {
                              final isSelected = state.colors.contains(color);
                              return FilterChip(
                                label: Text(color),
                                selected: isSelected,
                                onSelected: (_) {
                                  ref
                                      .read(preferencesProvider.notifier)
                                      .toggleColor(color);
                                },
                                selectedColor:
                                    theme.colorScheme.primaryContainer,
                                checkmarkColor:
                                    theme.colorScheme.onPrimaryContainer,
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Бюджет (скоро)
                    _buildSection(
                      context,
                      title: 'Бюджет (скоро)',
                      icon: Icons.attach_money,
                      child: Column(
                        children: [
                          // Индикатор "скоро"
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.hourglass_empty,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Настройка бюджета',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        'Возможность будет доступна в следующем обновлении',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Неактивный RangeSlider для визуализации
                          const SizedBox(height: 16),
                          Opacity(
                            opacity: 0.5,
                            child: AbsorbPointer(
                              child: RangeSlider(
                                values: RangeValues(
                                  state.minBudget.toDouble(),
                                  state.maxBudget.toDouble(),
                                ),
                                min: 0,
                                max: 100000,
                                divisions: 100,
                                labels: RangeLabels(
                                  '${state.minBudget}₽',
                                  '${state.maxBudget}₽',
                                ),
                                onChanged: (values) {
                                  ref
                                      .read(preferencesProvider.notifier)
                                      .updateBudget(
                                        values.start.round(),
                                        values.end.round(),
                                      );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${state.minBudget}₽',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '${state.maxBudget}₽',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Кнопка сохранения
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _savePreferences,
                        icon:
                            state.isSaving
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.save),
                        label: const Text('Сохранить предпочтения'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
