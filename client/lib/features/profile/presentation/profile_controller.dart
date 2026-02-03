import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
  return ProfileController();
});

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(const ProfileState());
}

class ProfileState {}
