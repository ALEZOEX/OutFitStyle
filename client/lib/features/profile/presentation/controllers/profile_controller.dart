import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/domain/states/profile_state.dart';

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(ProfileInitial());

  Future<void> loadProfile() async {
    state = ProfileLoading();
    // In a real implementation, we would load the profile from a repository
    // For now, we'll just simulate success
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      state = ProfileLoaded({
        'id': '1',
        'name': 'John Doe',
        'email': 'john@example.com',
        'avatar': '',
      });
    } catch (e) {
      state = ProfileError(e.toString());
    }
  }
}