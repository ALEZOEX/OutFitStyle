import 'package:firebase_auth/firebase_auth.dart';

import '../core/api/api_client.dart';

class AuthUtils {
  /// Format user display name for consistent presentation
  static String formatDisplayName(User? user) {
    if (user == null) return 'Гость';

    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }

    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!.split('@')[0];
    }

    return 'Пользователь ${user.uid.substring(0, 5)}';
  }

  /// Check if user has valid email
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  /// Get user avatar initials
  static String getUserInitials(User? user) {
    if (user == null) return '?';

    if (user.displayName != null && user.displayName!.isNotEmpty) {
      final nameParts = user.displayName!.trim().split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else if (nameParts.isNotEmpty) {
        return nameParts[0].substring(0, 2).toUpperCase();
      }
    }

    if (user.email != null && user.email!.isNotEmpty) {
      return user.email![0].toUpperCase();
    }

    return user.uid.substring(0, 2).toUpperCase();
  }

  /// Validate password strength
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;

    // At least one uppercase, lowercase, and digit
    final upperCase = RegExp(r'[A-Z]');
    final lowerCase = RegExp(r'[a-z]');
    final digit = RegExp(r'\d');

    return upperCase.hasMatch(password) &&
        lowerCase.hasMatch(password) &&
        digit.hasMatch(password);
  }

  /// Извлечь человекочитаемое сообщение из любого исключения авторизации.
  ///
  /// Обрабатывает:
  /// - [NetworkException] / [UnauthorizedException] / [ApiException] из ApiClient
  /// - [FirebaseAuthException] с маппингом кодов на русский
  /// - [AuthException] (кастомные)
  /// - Сырые [Exception] с безопасным извлечением сообщения
  ///
  /// В релизе Dart обфусцирует имена классов — обычный '$e' даёт
  /// 'Instance of minified:mm'. Этот метод гарантирует чистую строку.
  static String extractAuthError(Object error) {
    // ApiClient ошибки
    if (error is NetworkException) return 'Нет соединения с интернетом';
    if (error is UnauthorizedException) return 'Неверный email или пароль';
    if (error is ApiException) return error.message;

    // Firebase Auth ошибки
    if (error is FirebaseAuthException) {
      return _mapFirebaseAuthError(error);
    }

    // Кастомные AuthException
    if (error is Exception) {
      final s = error.toString();
      // Убираем префиксы вида "Exception: ", "WardrobeException: " и т.д.
      final cleaned = s.replaceFirst(RegExp(r'^\w+Exception:\s*'), '');
      if (cleaned.startsWith('Instance of')) {
        return 'Произошла ошибка авторизации';
      }
      return cleaned;
    }

    return 'Произошла неизвестная ошибка';
  }

  /// Маппинг кодов Firebase Auth на русский язык
  static String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Пароль слишком слабый. Используйте минимум 8 символов';
      case 'email-already-in-use':
        return 'Пользователь с таким email уже существует';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'user-not-found':
        return 'Пользователь с таким email не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'user-disabled':
        return 'Аккаунт заблокирован';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте через несколько минут';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение к интернету';
      case 'operation-not-allowed':
        return 'Этот способ входа отключён';
      case 'invalid-credential':
        return 'Неверный email или пароль';
      case 'account-exists-with-different-credential':
        return 'Аккаунт с таким email уже зарегистрирован другим способом';
      case 'popup-closed-by-user':
        return 'Вход отменён';
      case 'popup-blocked':
        return 'Всплывающее окно заблокировано браузером';
      default:
        return e.message ?? 'Ошибка авторизации (${e.code})';
    }
  }
}
