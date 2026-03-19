import 'package:outfitstyle_client/src/core/api/api_client.dart';

/// Сервис для работы с API управления паролем
class PasswordApiService {
  final ApiClient _apiClient;

  PasswordApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Установить пароль (для Google-пользователей без пароля)
  ///
  /// Требования к паролю:
  /// - Минимум 12 символов
  /// - Буквы верхнего и нижнего регистра
  /// - Хотя бы одна цифра
  /// - Хотя бы один специальный символ
  ///
  /// Для Google-пользователей current_password не требуется.
  /// Для обычных пользователей с паролем требуется проверка текущего пароля.
  Future<SetPasswordResponse> setPassword({
    String? currentPassword,
    required String newPassword,
  }) async {
    final requestData = <String, dynamic>{'new_password': newPassword};

    // current_password опционален (требуется только если у пользователя уже есть пароль)
    if (currentPassword != null && currentPassword.isNotEmpty) {
      requestData['current_password'] = currentPassword;
    }

    final response = await _apiClient.post(
      '/api/v1/user/set-password',
      data: requestData,
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      return SetPasswordResponse(
        success: data['success'] as bool? ?? false,
        message: data['message'] as String? ?? 'Пароль успешно установлен',
      );
    } else {
      throw ApiException('Ошибка установки пароля: ${response.statusCode}');
    }
  }

  /// Изменить пароль (требуется текущий пароль)
  Future<SetPasswordResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/user/change-password',
      data: {'current_password': currentPassword, 'new_password': newPassword},
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      return SetPasswordResponse(
        success: data['success'] as bool? ?? false,
        message: data['message'] as String? ?? 'Пароль успешно изменен',
      );
    } else {
      throw ApiException('Ошибка смены пароля: ${response.statusCode}');
    }
  }
}

/// Ответ на запрос установки/изменения пароля
class SetPasswordResponse {
  final bool success;
  final String message;

  SetPasswordResponse({required this.success, required this.message});

  @override
  String toString() =>
      'SetPasswordResponse(success: $success, message: $message)';
}
