import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../../presentation/providers/auth_provider.dart';

/// Провайдер для проверки прав администратора
final adminAuthProvider = Provider<AdminAuthService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AdminAuthService(authRepository);
});

/// Сервис для проверки прав администратора
class AdminAuthService {
  final AuthRepository _authRepository;

  AdminAuthService(this._authRepository);

  /// Проверяет, является ли текущий пользователь администратором
  /// Возвращает true если пользователь авторизован и имеет роль admin
  Future<bool> isAdmin() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (!isLoggedIn) return false;

      // Получаем роль пользователя из токена или профиля
      final role = await _getUserRole();
      return role == UserRole.admin;
    } catch (e) {
      return false;
    }
  }

  /// Получает роль текущего пользователя
  Future<UserRole> _getUserRole() async {
    try {
      // Получаем токен из хранилища
      final token = await _authRepository.authStorage.readAccessToken();
      if (token == null) return UserRole.user;

      // Декодируем JWT payload для получения роли
      final parts = token.split('.');
      if (parts.length != 3) return UserRole.user;

      String payload = parts[1];
      // Добавляем padding если нужно
      final padding = 4 - payload.length % 4;
      if (padding != 4) {
        payload += '=' * padding;
      }

      // Заменяем URL-safe символы
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');

      final decoded = utf8.decode(base64.decode(payload));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      // Получаем роль из claims
      final roleStr = json['role'] as String?;
      if (roleStr == 'admin') return UserRole.admin;
      return UserRole.user;
    } catch (e) {
      return UserRole.user;
    }
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
