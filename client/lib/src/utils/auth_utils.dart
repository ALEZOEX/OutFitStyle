import 'package:firebase_auth/firebase_auth.dart';

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
}
