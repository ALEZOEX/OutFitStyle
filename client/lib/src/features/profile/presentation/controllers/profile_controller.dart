import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/profile_state.dart';

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(const ProfileState.initial());

  // Add methods to interact with profile
}