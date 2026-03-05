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
  /// Возвращает true если пользователь авторизован и имеет роль admin
  Future<bool> isAdmin() async {
    try {
      // Получаем сессию пользователя
      // В текущей реализации Firebase Auth не хранит роль пользователя
      // Роль должна храниться в Firestore или передаваться с сервера
      // Для совместимости возвращаем false по умолчанию
      // 
      // TODO: Интегрировать с Firestore для хранения ролей пользователей
      // Пример:
      // final user = FirebaseAuth.instance.currentUser;
      // if (user == null) return false;
      // final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      // return doc.data()?['role'] == 'admin';
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Получает роль текущего пользователя
  /// Временно возвращает UserRole.user
  /// TODO: Интегрировать с Firestore для получения роли
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
