import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/auth_state.dart';
import '../../../domain/repositories/i_auth_repository.dart';

class AuthController extends StateNotifier<AuthState> {
  final IAuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AuthState.initial());

  // Add methods to handle authentication
}