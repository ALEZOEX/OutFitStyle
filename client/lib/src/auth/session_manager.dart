import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../utils/logger.dart';

/// Модель данных пользователя
class UserSession {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime loginTime;
  final bool isEmailVerified;

  UserSession({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.loginTime,
    this.isEmailVerified = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'loginTime': loginTime.millisecondsSinceEpoch,
      'isEmailVerified': isEmailVerified,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      loginTime: DateTime.fromMillisecondsSinceEpoch(json['loginTime'] as int),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }
}

/// Менеджер сессии пользователя
class SessionManager {
  final FirebaseAuth _firebaseAuth;
  final SharedPreferences _sharedPreferences;

  UserSession? _currentUserSession;
  late final StreamController<UserSession?> _sessionStreamController;
  StreamSubscription<User?>? _authSubscription;

  SessionManager(this._firebaseAuth, this._sharedPreferences) {
    _sessionStreamController = StreamController<UserSession?>.broadcast();
    _initializeSession();
    _setupAuthStateListener();
  }

  /// Маскирование email для логирования
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '*@$domain';
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  /// Инициализация сессии из сохраненного состояния
  void _initializeSession() {
    final sessionJson = _sharedPreferences.getString('user_session');
    if (sessionJson != null) {
      try {
        final session = UserSession.fromJson(
          Map<String, dynamic>.from(
            jsonDecode(sessionJson) as Map,
          ),
        );
        _currentUserSession = session;
        AppLogger.info('Session restored for user: ${_maskEmail(session.email ?? 'unknown')}');
      } catch (e) {
        AppLogger.error('Error deserializing session: $e', e);
        _clearSession();
      }
    }
  }

  /// Поток изменений состояния аутентификации (для тестирования и явного ожидания)
  Stream<User?> get _authStateChanges => _firebaseAuth.authStateChanges();

  /// Установка слушателя состояния аутентификации
  void _setupAuthStateListener() {
    _authSubscription = _authStateChanges.listen((firebaseUser) {
      if (firebaseUser == null) {
        // Пользователь вышел, очищаем сессию
        AppLogger.info('User signed out, clearing session');
        _clearSession();
      } else {
        // Обновляем сессию только если UID изменился
        if (_currentUserSession?.uid != firebaseUser.uid) {
          AppLogger.info('User authenticated: ${_maskEmail(firebaseUser.email ?? 'unknown')}');
          _updateSessionFromFirebase(firebaseUser);
        }
      }
    });
  }

  /// Получение текущей сессии пользователя
  UserSession? get currentUserSession => _currentUserSession;

  /// Проверка, вошел ли пользователь
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  /// Получение UID текущего пользователя
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  /// Поток изменений состояния аутентификации (Stream [bool])
  ///
  /// Возвращает true, если пользователь авторизован, и false в противном случае
  Stream<bool> get authStateChanges => _firebaseAuth.authStateChanges().map((user) => user != null);

  /// Поток обновлений сессии
  Stream<UserSession?> get sessionStream => _sessionStreamController.stream;

  /// Обновление сессии из Firebase
  Future<void> _updateSessionFromFirebase(User firebaseUser) async {
    _currentUserSession = UserSession(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      loginTime: DateTime.now(),
      isEmailVerified: firebaseUser.emailVerified,
    );

    // Сохраняем сессию в SharedPreferences
    // Безопасно: _currentUserSession только что установлен выше
    final sessionJson = _currentUserSession?.toJson();
    if (sessionJson != null) {
      await _sharedPreferences.setString(
        'user_session',
        jsonEncode(sessionJson),
      );
    }

    // Уведомляем подписчиков о новой сессии
    _sessionStreamController.add(_currentUserSession);
    AppLogger.info('Session updated for user: ${_maskEmail(firebaseUser.email ?? 'unknown')}');
  }

  /// Вход пользователя
  Future<bool> signIn({String? email, String? password}) async {
    try {
      AppLogger.info('Attempting sign in for user: ${_maskEmail(email ?? 'unknown')}');
      UserCredential credential;

      if (email != null && password != null) {
        // Вход с email/password
        credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // Вход через Google или другие провайдеры может быть реализован здесь
        AppLogger.warning('No credentials provided for sign in');
        throw Exception('Не указаны учетные данные для входа');
      }

      final user = credential.user;
      if (user == null) {
        AppLogger.warning('No user in credential after sign in');
        throw Exception('Не удалось получить данные пользователя');
      }

      // Явно ждём событие authStateChanges, подтверждающее вход
      await _authStateChanges.firstWhere(
        (firebaseUser) => firebaseUser?.uid == user.uid,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Auth state change timeout'),
      );

      AppLogger.info('Sign in successful for user: ${user.uid}');
      return true;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Sign in error: ${e.code} - ${e.message}', e);
      return false;
    } catch (e) {
      AppLogger.error('Sign in error: $e', e);
      return false;
    }
  }

  /// Вход через Google с использованием Firebase Auth
  ///
  /// Flow:
  /// 1. Открываем popup для Google OAuth (Web) или нативное окно (Mobile)
  /// 2. Получаем UserCredential из Firebase
  /// 3. SessionManager автоматически обновит сессию через _setupAuthStateListener
  ///
  /// Возвращает true при успешном входе, false при ошибке или отмене
  Future<bool> signInWithGoogle() async {
    try {
      AppLogger.info('Starting Google Sign-In via Firebase Auth...');

      // Создаём Google Auth Provider с нужными скоупами
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');

      // Открываем popup для входа через Google
      // На Web: signInWithPopup, на Mobile: нативное окно
      final UserCredential credential = await _firebaseAuth.signInWithPopup(provider);

      final User? user = credential.user;
      if (user == null) {
        AppLogger.warning('Google Sign-In cancelled by user');
        return false;
      }

      AppLogger.info('Google Sign-In successful: ${_maskEmail(user.email ?? 'unknown')}');

      // Явно ждём событие authStateChanges, подтверждающее вход
      await _authStateChanges.firstWhere(
        (firebaseUser) => firebaseUser?.uid == user.uid,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Auth state change timeout'),
      );

      AppLogger.info('Google Sign-In completed for user: ${user.uid}');
      return true;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Google Sign-In error: ${e.code} - ${e.message}', e);
      return false;
    } catch (e) {
      AppLogger.error('Google Sign-In error: $e', e);
      return false;
    }
  }

  /// Выход пользователя
  Future<void> signOut() async {
    try {
      final userId = _currentUserSession?.uid;
      AppLogger.info('Signing out user: $userId');
      await _firebaseAuth.signOut();
      await _clearSession();
      AppLogger.info('Sign out completed for user: $userId');
    } catch (e) {
      AppLogger.error('Sign out error: $e', e);
    }
  }

  /// Регистрация нового пользователя
  Future<bool> signUp(String email, String password) async {
    try {
      AppLogger.info('Attempting sign up for user: ${_maskEmail(email)}');
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        AppLogger.warning('No user in credential after sign up');
        throw Exception('Не удалось получить данные пользователя');
      }

      // Явно ждём событие authStateChanges, подтверждающее вход
      await _authStateChanges.firstWhere(
        (firebaseUser) => firebaseUser?.uid == user.uid,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Auth state change timeout'),
      );

      AppLogger.info('Sign up successful for user: ${user.uid}');
      return true;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Sign up error: ${e.code} - ${e.message}', e);
      return false;
    } catch (e) {
      AppLogger.error('Sign up error: $e', e);
      return false;
    }
  }

  /// Обновление данных пользователя
  Future<bool> updateUserProfile({String? displayName, String? photoUrl}) async {
    try {
      final user = _firebaseAuth.currentUser;
      final currentSession = _currentUserSession;
      
      if (user == null || currentSession == null) {
        AppLogger.warning('No user or session for profile update');
        return false;
      }

      AppLogger.info('Updating profile for user: ${user.uid}');
      
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Обновляем сессию с новыми данными
      _currentUserSession = UserSession(
        uid: user.uid,
        email: user.email,
        displayName: displayName ?? user.displayName,
        photoUrl: photoUrl ?? user.photoURL,
        loginTime: currentSession.loginTime,
        isEmailVerified: user.emailVerified,
      );

      // Сохраняем обновленную сессию
      // Безопасно: _currentUserSession только что установлен выше
      final sessionJson = _currentUserSession?.toJson();
      if (sessionJson != null) {
        await _sharedPreferences.setString(
          'user_session',
          jsonEncode(sessionJson),
        );
      }

      // Уведомляем подписчиков
      _sessionStreamController.add(_currentUserSession);
      AppLogger.info('Profile updated for user: ${user.uid}');
      return true;
    } catch (e) {
      AppLogger.error('Error updating profile: $e', e);
      return false;
    }
  }

  /// Отправка письма для подтверждения email
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        AppLogger.info('Sending email verification to: ${_maskEmail(user.email ?? 'unknown')}');
        await user.sendEmailVerification();
        AppLogger.info('Email verification sent');
      }
    } catch (e) {
      AppLogger.error('Error sending email verification: $e', e);
      rethrow;
    }
  }

  /// Сброс пароля
  Future<void> resetPassword(String email) async {
    try {
      AppLogger.info('Resetting password for: ${_maskEmail(email)}');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      AppLogger.info('Password reset email sent');
    } catch (e) {
      AppLogger.error('Error resetting password: $e', e);
      rethrow;
    }
  }

  /// Очистка сессии
  Future<void> _clearSession() async {
    final userId = _currentUserSession?.uid;
    _currentUserSession = null;
    await _sharedPreferences.remove('user_session');
    _sessionStreamController.add(null);
    AppLogger.info('Session cleared for user: $userId');
  }

  /// Закрытие потока сессии и отмена подписок
  Future<void> dispose() async {
    await _authSubscription?.cancel();
    _authSubscription = null;
    await _sessionStreamController.close();
    AppLogger.info('Session manager disposed');
  }
}
