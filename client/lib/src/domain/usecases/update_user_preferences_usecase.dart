import 'package:outfitstyle_client/src/domain/entities/user_preference.dart';
import 'package:outfitstyle_client/src/domain/repositories/profile_repository.dart';

/// UseCase для обновления пользовательских предпочтений
class UpdateUserPreferencesUseCase {
  final ProfileRepository _repository;

  UpdateUserPreferencesUseCase(this._repository);

  /// Обновить предпочтения пользователя
  Future<void> call(UserPreference userPreference) async {
    await _repository.updateUserPreferences(userPreference);
  }
}
