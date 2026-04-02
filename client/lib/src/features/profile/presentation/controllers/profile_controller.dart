import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/states/profile_state.dart';

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(const ProfileInitial());

  // Add methods to interact with profile
}
