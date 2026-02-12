import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/src/domain/entities/recommendation.dart';
import 'package:outfitstyle_client/src/domain/entities/user_preference.dart';
import 'package:outfitstyle_client/src/domain/repositories/profile_repository.dart';

// Provider для репозитория профиля
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw UnimplementedError('ProfileRepositoryImpl must be provided');
});

// AsyncNotifier для управления состоянием профиля
final profileStateNotifierProvider =
    StateNotifierProvider<ProfileStateNotifier, ProfileState>(
  (ref) => ProfileStateNotifier(
    ref.read(profileRepositoryProvider),
  ),
);

class ProfileState {
  final UserPreference? userPreference;
  final List<Recommendation> recommendationHistory;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({
    this.userPreference,
    this.recommendationHistory = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    UserPreference? userPreference,
    List<Recommendation>? recommendationHistory,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      userPreference: userPreference ?? this.userPreference,
      recommendationHistory:
          recommendationHistory ?? this.recommendationHistory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProfileStateNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileStateNotifier(this._profileRepository) : super(ProfileState());

  Future<void> fetchUserPreferences(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final userPreference =
          await _profileRepository.getUserPreferences(userId);
      state = state.copyWith(
        userPreference: userPreference,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateUserPreferences(UserPreference userPreference) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _profileRepository.updateUserPreferences(userPreference);
      state = state.copyWith(
        userPreference: userPreference,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}
