import 'package:outfitstyle_client/src/domain/entities/user_preference.dart';
import 'package:outfitstyle_client/src/domain/repositories/profile_repository.dart';

/// UseCase для получения пользовательских предпочтений
class GetUserPreferencesUseCase {
  final ProfileRepository _repository;

  GetUserPreferencesUseCase(this._repository);

  /// Получить предпочтения пользователя
  Future<UserPreference> call(String userId) async {
    return await _repository.getUserPreferences(userId);
  }
}
