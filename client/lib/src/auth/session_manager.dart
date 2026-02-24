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
  StreamController<UserSession?>? _sessionStreamController;

  SessionManager(this._firebaseAuth, this._sharedPreferences) {
    _initializeSession();
    _setupAuthStateListener();
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

        // Проверяем, не истекла ли сессия (по умолчанию 24 часа)
        final now = DateTime.now();
        final sessionAge = now.difference(session.loginTime);
        if (sessionAge.inHours < 24) {
          _currentUserSession = session;
        } else {
          // Сессия истекла, очищаем
          AppLogger.info('Session expired for user: ${session.uid}');
          _clearSession();
        }
      } catch (e) {
        // Ошибка при десериализации сессии, очищаем
        AppLogger.error('Error deserializing session: $e', e);
        _clearSession();
      }
    }
  }

  /// Установка слушателя состояния аутентификации
  void _setupAuthStateListener() {
    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser == null) {
        // Пользователь вышел, очищаем сессию
        AppLogger.info('User signed out, clearing session');
        _clearSession();
      } else {
        // Обновляем сессию, если пользователь вошел
        if (_currentUserSession?.uid != firebaseUser.uid) {
          AppLogger.info('User authenticated: ${firebaseUser.uid}');
          _updateSessionFromFirebase(firebaseUser);
        }
      }
    });
  }

  /// Получение текущей сессии пользователя
  UserSession? get currentUserSession => _currentUserSession;

  /// Проверка, вошел ли пользователь
  bool get isAuthenticated => _currentUserSession != null;

  /// Получение UID текущего пользователя
  String? get currentUserId => _currentUserSession?.uid;

  /// Поток обновлений сессии
  Stream<UserSession?> get sessionStream {
    _sessionStreamController ??= StreamController<UserSession?>.broadcast()
      ..add(_currentUserSession);
    return _sessionStreamController!.stream;
  }

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
    await _sharedPreferences.setString(
      'user_session',
      jsonEncode(_currentUserSession!.toJson()),
    );

    // Уведомляем подписчиков о новой сессии
    _sessionStreamController?.add(_currentUserSession);
    AppLogger.info('Session updated for user: ${firebaseUser.uid}');
  }

  /// Вход пользователя
  Future<bool> signIn({String? email, String? password}) async {
    try {
      AppLogger.info('Attempting sign in for user: $email');
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
      
      await _updateSessionFromFirebase(user);
      AppLogger.info('Sign in successful for user: ${user.uid}');
      return true;
    } catch (e) {
      // Логирование ошибки входа
      AppLogger.error('Sign in error: $e', e);
      return false;
    }
  }

  /// Выход пользователя
  Future<void> signOut() async {
    try {
      final userId = _currentUserSession?.uid;
      AppLogger.info('Signing out user: $userId');
      await _firebaseAuth.signOut();
      _clearSession();
      AppLogger.info('Sign out completed for user: $userId');
    } catch (e) {
      // Логирование ошибки выхода
      AppLogger.error('Sign out error: $e', e);
    }
  }

  /// Регистрация нового пользователя
  Future<bool> signUp(String email, String password) async {
    try {
      AppLogger.info('Attempting sign up for user: $email');
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        AppLogger.warning('No user in credential after sign up');
        throw Exception('Не удалось получить данные пользователя');
      }
      
      await _updateSessionFromFirebase(user);
      AppLogger.info('Sign up successful for user: ${user.uid}');
      return true;
    } catch (e) {
      // Логирование ошибки регистрации
      AppLogger.error('Sign up error: $e', e);
      return false;
    }
  }

  /// Обновление данных пользователя
  Future<bool> updateUserProfile(
      {String? displayName, String? photoUrl}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        AppLogger.info('Updating profile for user: ${user.uid}');
        await user.updateDisplayName(displayName);
        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
        }

        // Обновляем сессию с новыми данными
        _currentUserSession = UserSession(
          uid: user.uid,
          email: user.email,
          displayName: displayName ?? user.displayName,
          photoUrl: photoUrl ?? user.photoURL,
          loginTime: _currentUserSession!.loginTime,
          isEmailVerified: user.emailVerified,
        );

        // Сохраняем обновленную сессию
        await _sharedPreferences.setString(
          'user_session',
          jsonEncode(_currentUserSession!.toJson()),
        );

        // Уведомляем подписчиков
        _sessionStreamController?.add(_currentUserSession);
        AppLogger.info('Profile updated for user: ${user.uid}');
        return true;
      }
      return false;
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
        AppLogger.info('Sending email verification to: ${user.email}');
        await user.sendEmailVerification();
        AppLogger.info('Email verification sent to: ${user.email}');
      }
    } catch (e) {
      AppLogger.error('Error sending email verification: $e', e);
    }
  }

  /// Сброс пароля
  Future<void> resetPassword(String email) async {
    try {
      AppLogger.info('Resetting password for: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      AppLogger.info('Password reset email sent to: $email');
    } catch (e) {
      AppLogger.error('Error resetting password: $e', e);
    }
  }

  /// Очистка сессии
  void _clearSession() {
    final userId = _currentUserSession?.uid;
    _currentUserSession = null;
    _sharedPreferences.remove('user_session');
    _sessionStreamController?.add(null);
    AppLogger.info('Session cleared for user: $userId');
  }

  /// Закрытие потока сессии
  void dispose() {
    _sessionStreamController?.close();
    AppLogger.info('Session manager disposed');
  }
}
