/// Состояние настроек
class SettingsState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> settings;

  const SettingsState({
    this.isLoading = false,
    this.error,
    this.settings = const {},
  });

  factory SettingsState.initial() => const SettingsState();

  SettingsState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? settings,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      settings: settings ?? this.settings,
    );
  }
}