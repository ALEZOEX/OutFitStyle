import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/enums/user_role.dart';

/// Провайдер для проверки прав администратора
final adminAuthProvider = Provider<AdminAuthService>((ref) {
  return AdminAuthService();
});

/// Сервис для проверки прав администратора
class AdminAuthService {
  AdminAuthService();

  /// Проверяет, является ли текущий пользователь администратором
  /// Возвращает false по умолчанию (роль администратора не реализована)
  Future<bool> isAdmin() async {
    try {
      // Роль администратора требует интеграции с Firestore
      // В текущей реализации возвращаем false
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Получает роль текущего пользователя
  /// Временно возвращает UserRole.user
  Future<UserRole> getUserRole() async {
    return UserRole.user;
  }

  /// Проверяет доступ к админ-панели
  /// Бросает исключение если пользователь не админ
  Future<void> requireAdmin() async {
    final isAdmin = await this.isAdmin();
    if (!isAdmin) {
      throw AdminAccessDeniedException('Доступ запрещён. Требуются права администратора.');
    }
  }
}

/// Исключение доступа к админ-панели
class AdminAccessDeniedException implements Exception {
  final String message;

  const AdminAccessDeniedException(this.message);

  @override
  String toString() => 'AdminAccessDeniedException: $message';
}
