import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/profile_state.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
  return ProfileController();
});

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load profile data from repository
      state = state.copyWith(
        isLoading: false,
        profileData: const AsyncSuccess({}),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
