import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../utils/logger.dart';
import '../core/api/public_api_client.dart';

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
  final PublicApiClient _apiClient;

  UserSession? _currentUserSession;
  late final StreamController<UserSession?> _sessionStreamController;
  StreamSubscription<User?>? _authSubscription;

  SessionManager(this._firebaseAuth, this._sharedPreferences)
      : _apiClient = PublicApiClient() {
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

  /// Вход пользователя через backend API
  ///
  /// Flow:
  /// 1. Отправляем email/password на backend /auth/login
  /// 2. Backend возвращает access token и refresh token (в httpOnly cookie)
  /// 3. Используем access token для получения данных пользователя
  /// 4. Синхронизируем с Firebase (silent sign-in)
  Future<bool> signIn({String? email, String? password}) async {
    try {
      AppLogger.info('Attempting sign in for user: ${_maskEmail(email ?? 'unknown')}');

      if (email == null || password == null) {
        AppLogger.warning('No credentials provided for sign in');
        throw Exception('Не указаны учетные данные для входа');
      }

      // Вызываем backend API /auth/login
      final response = await _apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      if (data is! Map) {
        AppLogger.warning('Invalid response from login endpoint');
        throw Exception('Неверный формат ответа сервера');
      }

      // Backend вернул tokens и user
      final user = data['user'] as Map?;
      final tokens = data['tokens'] as Map?;

      if (user == null || tokens == null) {
        AppLogger.warning('Invalid response structure from login');
        throw Exception('Ошибка получения данных пользователя');
      }

      // Для email/password пользователей Firebase не используется
      // Создаём сессию напрямую из данных backend
      final backendUid = user['id'] as String?;
      if (backendUid == null) {
        AppLogger.warning('No user ID in response');
        throw Exception('Не удалось получить ID пользователя');
      }

      // Обновляем сессию
      _currentUserSession = UserSession(
        uid: backendUid,
        email: user['email'] as String?,
        displayName: user['display_name'] as String?,
        photoUrl: user['avatar_url'] as String?,
        loginTime: DateTime.now(),
        isEmailVerified: user['is_verified'] as bool? ?? false,
      );

      // Сохраняем сессию в SharedPreferences
      final sessionJson = _currentUserSession?.toJson();
      if (sessionJson != null) {
        await _sharedPreferences.setString(
          'user_session',
          jsonEncode(sessionJson),
        );
      }

      // Уведомляем подписчиков
      _sessionStreamController.add(_currentUserSession);

      AppLogger.info('Sign in successful for user: ${_maskEmail(email)}');
      return true;
    } catch (e) {
      AppLogger.error('Sign in error: $e', e);
      rethrow;
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

  /// Регистрация нового пользователя через backend API
  ///
  /// Flow:
  /// 1. Отправляем email/password/displayName на backend /auth/register
  /// 2. Backend создаёт пользователя в PostgreSQL и возвращает токены
  /// 3. Сохраняем сессию локально
  ///
  /// ВАЖНО: Firebase Auth НЕ используется для email/password регистрации
  /// Firebase используется только для Google Sign-In
  Future<bool> signUp(String email, String password, {String? displayName}) async {
    try {
      AppLogger.info('Attempting sign up for user: ${_maskEmail(email)}');

      // Вызываем backend API /auth/register
      final Map<String, dynamic> registerData = {
        'email': email,
        'password': password,
      };
      if (displayName != null && displayName.isNotEmpty) {
        registerData['display_name'] = displayName;
      }

      final response = await _apiClient.post('/auth/register', data: registerData);

      final data = response.data;
      if (data is! Map) {
        AppLogger.warning('Invalid response from register endpoint');
        throw Exception('Неверный формат ответа сервера');
      }

      // Backend вернул tokens и user
      final user = data['user'] as Map?;
      final tokens = data['tokens'] as Map?;

      if (user == null || tokens == null) {
        AppLogger.warning('Invalid response structure from register');
        throw Exception('Ошибка регистрации пользователя');
      }

      // Создаём сессию из данных backend
      final backendUid = user['id'] as String?;
      if (backendUid == null) {
        AppLogger.warning('No user ID in response');
        throw Exception('Не удалось получить ID пользователя');
      }

      // Обновляем сессию
      _currentUserSession = UserSession(
        uid: backendUid,
        email: user['email'] as String?,
        displayName: user['display_name'] as String?,
        photoUrl: user['avatar_url'] as String?,
        loginTime: DateTime.now(),
        isEmailVerified: user['is_verified'] as bool? ?? false,
      );

      // Сохраняем сессию в SharedPreferences
      final sessionJson = _currentUserSession?.toJson();
      if (sessionJson != null) {
        await _sharedPreferences.setString(
          'user_session',
          jsonEncode(sessionJson),
        );
      }

      // Уведомляем подписчиков
      _sessionStreamController.add(_currentUserSession);

      AppLogger.info('Sign up successful for user: ${_maskEmail(email)}');
      return true;
    } catch (e) {
      AppLogger.error('Sign up error: $e', e);
      rethrow;
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

  /// Сброс пароля — шаг 1: запрос кода на email через backend API
  ///
  /// Backend отправляет 6-значный код на email пользователя
  Future<void> resetPassword(String email) async {
    try {
      AppLogger.info('Requesting password reset code for: ${_maskEmail(email)}');

      // Вызываем backend API /auth/forgot-password
      await _apiClient.post('/auth/forgot-password', data: {
        'email': email,
      });

      AppLogger.info('Password reset code sent to: ${_maskEmail(email)}');
    } catch (e) {
      AppLogger.error('Error requesting password reset: $e', e);
      rethrow;
    }
  }

  /// Сброс пароля — шаг 2: проверка кода и установка нового пароля
  ///
  /// Backend проверяет код и обновляет пароль пользователя
  Future<void> resetPasswordWithCode(String email, String code, String newPassword) async {
    try {
      AppLogger.info('Resetting password for: ${_maskEmail(email)}');

      // Вызываем backend API /auth/reset-password
      await _apiClient.post('/auth/reset-password', data: {
        'email': email,
        'code': code,
        'new_password': newPassword,
      });

      AppLogger.info('Password reset successfully for: ${_maskEmail(email)}');
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
