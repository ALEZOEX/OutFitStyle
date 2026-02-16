/// Состояние административной панели
class AdminState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? stats;
  final List<Map<String, dynamic>> users;

  const AdminState({
    this.isLoading = false,
    this.error,
    this.stats,
    this.users = const [],
  });

  factory AdminState.initial() => const AdminState();

  AdminState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? stats,
    List<Map<String, dynamic>>? users,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      stats: stats ?? this.stats,
      users: users ?? this.users,
    );
  }
}