import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/user_preference.dart';
import '../../../presentation/providers/presentation_providers_exports.dart';
import '../presentation/controllers/recommendation_state_notifier.dart';

class UserPreferencesScreen extends ConsumerWidget {
  const UserPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider) ?? '';

    // Load user preferences when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(recommendationStateNotifierProvider.notifier)
          .loadUserPreferences(userId: userId);
    });

    final state = ref.watch(recommendationStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои предпочтения'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(
                  child: Text('Ошибка: ${state.errorMessage}'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Цвета'),
                      _buildColorChips(state.preferences.preferredColors),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Стили'),
                      _buildStyleChips(state.preferences.preferredStyles),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Поводы'),
                      _buildOccasionChips(
                          state.preferences.occasionsOfInterest),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Предпочтения по материалам'),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildPreferenceChip(
                            'Натуральные материалы',
                            state.preferences.prefersNaturalMaterials,
                          ),
                          _buildPreferenceChip(
                            'Синтетические материалы',
                            state.preferences.prefersSyntheticMaterials,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Бюджет'),
                      Text(
                        'Максимальный бюджет: ${(state.preferences.maxBudget ?? 0) > 0 ? '${state.preferences.maxBudget} руб.' : 'Не указан'}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Материалы'),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildPreferenceChip(
                            'Натуральные материалы',
                            state.preferences.prefersNaturalMaterials,
                          ),
                          _buildPreferenceChip(
                            'Синтетические материалы',
                            state.preferences.prefersSyntheticMaterials,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Размер'),
                      Text(
                        'Предпочтение по фасону: ${(state.preferences.fitPreference?.isNotEmpty ?? false) ? state.preferences.fitPreference : 'Не указано'}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to edit preferences
                          _showEditPreferencesDialog(
                              context, ref, state.preferences);
                        },
                        child: const Text('Редактировать предпочтения'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildColorChips(List<String> colors) {
    if (colors.isEmpty) {
      return const Text('Цвета не указаны');
    }

    return Wrap(
      spacing: 8,
      children:
          colors.take(6).map((color) => Chip(label: Text(color))).toList(),
    );
  }

  Widget _buildStyleChips(List<String> styles) {
    if (styles.isEmpty) {
      return const Text('Стили не указаны');
    }

    return Wrap(
      spacing: 8,
      children:
          styles.take(6).map((style) => Chip(label: Text(style))).toList(),
    );
  }

  Widget _buildOccasionChips(List<String> occasions) {
    if (occasions.isEmpty) {
      return const Text('Поводы не указаны');
    }

    return Wrap(
      spacing: 8,
      children: occasions
          .take(6)
          .map((occasion) => Chip(label: Text(occasion)))
          .toList(),
    );
  }


  Widget _buildPreferenceChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
    );
  }

  void _showEditPreferencesDialog(
      BuildContext context, WidgetRef ref, UserPreference currentPreferences) {
    final TextEditingController budgetController = TextEditingController(
      text: currentPreferences.maxBudget.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        String fitPreference = currentPreferences.fitPreference ?? '';

        return AlertDialog(
          title: const Text('Редактировать предпочтения'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Максимальный бюджет:'),
                TextField(
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Введите сумму в рублях',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Предпочтение по фасону:'),
                DropdownButton<String>(
                  value: fitPreference,
                  onChanged: (String? newValue) {
                    fitPreference = newValue ?? '';
                  },
                  items: const [
                    DropdownMenuItem<String>(
                        value: '', child: Text('Не указано')),
                    DropdownMenuItem<String>(
                        value: 'tight', child: Text('Плотный')),
                    DropdownMenuItem<String>(
                        value: 'regular', child: Text('Обычный')),
                    DropdownMenuItem<String>(
                        value: 'loose', child: Text('Свободный')),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final userId = ref.read(userIdProvider) ?? '';

                final updatedPreferences = currentPreferences.copyWith(
                  maxBudget:
                      (int.tryParse(budgetController.text) ?? 0).toDouble(),
                  fitPreference: fitPreference,
                );

                ref
                    .read(recommendationStateNotifierProvider.notifier)
                    .updateUserPreferences(
                      userId: userId,
                      preferences: updatedPreferences,
                    );

                Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}
