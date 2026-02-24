import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Провайдер для текущего языка
final currentLanguageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('ru') {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('app_language') ?? 'ru';
    state = savedLanguage;
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', languageCode);
    state = languageCode;
  }
}

/// Провайдер для авто-определения языка
final autoLanguageProvider = StateNotifierProvider<AutoLanguageNotifier, bool>((ref) {
  return AutoLanguageNotifier();
});

class AutoLanguageNotifier extends StateNotifier<bool> {
  AutoLanguageNotifier() : super(true) {
    _loadAutoLanguage();
  }

  Future<void> _loadAutoLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final autoLanguage = prefs.getBool('auto_language') ?? true;
    state = autoLanguage;
  }

  Future<void> setAutoLanguage(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_language', value);
    state = value;
  }
}

/// Модель языка
class AppLanguage {
  final String code;
  final String name;
  final String flag;
  final String nativeName;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.flag,
    required this.nativeName,
  });

  static const List<AppLanguage> availableLanguages = [
    AppLanguage(code: 'ru', name: 'Русский', flag: '🇷🇺', nativeName: 'Русский'),
    AppLanguage(code: 'en', name: 'English', flag: '🇬🇧', nativeName: 'English'),
    AppLanguage(code: 'es', name: 'Español', flag: '🇪🇸', nativeName: 'Español'),
    AppLanguage(code: 'fr', name: 'Français', flag: '🇫🇷', nativeName: 'Français'),
    AppLanguage(code: 'de', name: 'Deutsch', flag: '🇩🇪', nativeName: 'Deutsch'),
    AppLanguage(code: 'it', name: 'Italiano', flag: '🇮🇹', nativeName: 'Italiano'),
    AppLanguage(code: 'zh', name: '中文', flag: '🇨🇳', nativeName: '中文'),
    AppLanguage(code: 'ja', name: '日本語', flag: '🇯🇵', nativeName: '日本語'),
    AppLanguage(code: 'pt', name: 'Português', flag: '🇵🇹', nativeName: 'Português'),
    AppLanguage(code: 'tr', name: 'Türkçe', flag: '🇹🇷', nativeName: 'Türkçe'),
  ];
}

/// Экран выбора языка
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLanguage = ref.watch(currentLanguageProvider);
    final autoLanguage = ref.watch(autoLanguageProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Заголовок
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          
          // Авто-определение
          SliverToBoxAdapter(
            child: _buildAutoLanguageSection(context, theme, ref, autoLanguage),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          
          // Список языков
          SliverToBoxAdapter(
            child: _buildLanguagesSection(context, theme, ref, currentLanguage, autoLanguage),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Text(
        'Язык',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildAutoLanguageSection(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    bool autoLanguage,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: autoLanguage
              ? [
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ]
              : [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: autoLanguage
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: autoLanguage
                    ? [theme.colorScheme.primary, theme.colorScheme.secondary]
                    : [Colors.grey.shade400, Colors.grey.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              autoLanguage
                  ? Icons.language
                  : Icons.language_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Авто-определение',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  autoLanguage
                      ? 'Использовать язык системы'
                      : 'Выберите язык вручную',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: autoLanguage,
            onChanged: (value) {
              ref.read(autoLanguageProvider.notifier).setAutoLanguage(value);
              _showLanguageChangedSnackbar(context);
            },
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return theme.colorScheme.primary;
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    String currentLanguage,
    bool autoLanguage,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.translate,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Язык приложения',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...AppLanguage.availableLanguages.map((language) {
            final isSelected = currentLanguage == language.code;
            final isDisabled = autoLanguage;
            
            return Column(
              children: [
                if (AppLanguage.availableLanguages.first != language)
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ListTile(
                  leading: Text(
                    language.flag,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    language.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isDisabled
                          ? theme.colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    language.nativeName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: isSelected
                      ? Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: theme.colorScheme.onPrimary,
                            size: 18,
                          ),
                        )
                      : null,
                  onTap: isDisabled
                      ? null
                      : () {
                          ref.read(currentLanguageProvider.notifier).setLanguage(language.code);
                          _showLanguageChangedSnackbar(context);
                        },
                ),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showLanguageChangedSnackbar(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Язык изменен. Перезапустите приложение для применения.'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
