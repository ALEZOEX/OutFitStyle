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

  SessionManager(this._firebaseAuth, this._sharedPreferences, [PublicApiClient? apiClient])
      : _apiClient = apiClient ?? PublicApiClient() {
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

        // Restore access_token if available
        final accessToken = _sharedPreferences.getString('access_token');
        if (accessToken != null && accessToken.isNotEmpty) {
          AppLogger.info('Access token restored for user: ${_maskEmail(session.email ?? 'unknown')}');
        } else {
          AppLogger.warning('No access_token found in storage for user: ${_maskEmail(session.email ?? 'unknown')}');
        }
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
  /// Для email/password - проверяем по наличию сессии в _currentUserSession
  /// Для Google - проверяем по Firebase
  bool get isAuthenticated => _currentUserSession != null || _firebaseAuth.currentUser != null;

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

      // Вызываем backend API /api/v1/auth/login
      final response = await _apiClient.post('/api/v1/auth/login', data: {
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

      // Extract and store access_token for Bearer authentication
      final accessToken = tokens['access_token'] as String?;
      if (accessToken != null && accessToken.isNotEmpty) {
        await _sharedPreferences.setString('access_token', accessToken);
        AppLogger.info('Access token stored for user: ${_maskEmail(email)}');
        // Verify it was saved
        final saved = _sharedPreferences.getString('access_token');
        AppLogger.info('Access token verification: ${saved != null ? "saved successfully (${saved.length} chars)" : "FAILED TO SAVE"}');
      } else {
        AppLogger.warning('No access_token in login response for user: ${_maskEmail(email)}');
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
  /// 3. Получаем Firebase ID token
  /// 4. Отправляем ID token на backend для получения access_token
  /// 5. Сохраняем access_token и обновляем сессию
  ///
  /// Возвращает true при успешном входе, false при ошибке или отмене
  Future<bool> signInWithGoogle() async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      AppLogger.info('[$timestamp] [Auth] [GoogleSignIn] Начало Google Sign-In через Firebase Auth...');

      // Создаём Google Auth Provider с нужными скоупами
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');

      AppLogger.debug('[$timestamp] [Auth] [GoogleSignIn] Открытие popup для Google OAuth');

      // Открываем popup для входа через Google
      // На Web: signInWithPopup, на Mobile: нативное окно
      final UserCredential credential = await _firebaseAuth.signInWithPopup(provider);

      final User? user = credential.user;
      if (user == null) {
        AppLogger.warning('[$timestamp] [Auth] [GoogleSignIn] Google Sign-In отменён пользователем');
        return false;
      }

      AppLogger.info('[$timestamp] [Auth] [GoogleSignIn] Google Sign-In успешен: ${_maskEmail(user.email ?? 'unknown')}');
      AppLogger.debug('[$timestamp] [Auth] [GoogleSignIn] Firebase user UID: ${user.uid}');

      // Явно ждём событие authStateChanges, подтверждающее вход
      AppLogger.debug('[$timestamp] [Auth] [GoogleSignIn] Ожидание authStateChanges...');
      await _authStateChanges.firstWhere(
        (firebaseUser) => firebaseUser?.uid == user.uid,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Auth state change timeout'),
      );

      // Get Firebase ID token to exchange for backend access_token
      AppLogger.debug('[$timestamp] [Auth] [GoogleSignIn] Получение Firebase ID token...');
      final idToken = await user.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        AppLogger.error('[$timestamp] [Auth] [GoogleSignIn] Не удалось получить Firebase ID token для пользователя: ${user.uid}');
        throw Exception('Не удалось получить токен аутентификации');
      }

      AppLogger.info('[$timestamp] [Auth] [GoogleSignIn] Firebase ID token получен (длина: ${idToken.length} символов)');
      AppLogger.debug('[$timestamp] [Auth] [GoogleSignIn] Firebase ID token (первые 50 символов): ${idToken.substring(0, idToken.length > 50 ? 50 : idToken.length)}...');

      AppLogger.info('[$timestamp] [Auth] [GoogleSignIn] Обмен Firebase token на backend access_token...');
      
      // Call backend to exchange Firebase token for access_token
      try {
        final backendTimestamp = DateTime.now().toIso8601String();
        AppLogger.debug('[$backendTimestamp] [Auth] [GoogleSignIn] Отправка запроса на POST /api/v1/auth/google');
        
        final response = await _apiClient.post('/api/v1/auth/google', data: {
          'id_token': idToken,
        });

        AppLogger.info('[$backendTimestamp] [Auth] [GoogleSignIn] Backend response status: ${response.statusCode}');
        AppLogger.debug('[$backendTimestamp] [Auth] [GoogleSignIn] Backend response data: ${response.data}');

        final data = response.data;
        if (data is! Map) {
          AppLogger.warning('[$backendTimestamp] [Auth] [GoogleSignIn] Неверный формат ответа от Google auth endpoint');
          throw Exception('Неверный формат ответа сервера');
        }

        // Extract tokens from backend response
        final backendUser = data['user'] as Map?;
        final tokens = data['tokens'] as Map?;

        if (backendUser == null || tokens == null) {
          AppLogger.warning('[$backendTimestamp] [Auth] [GoogleSignIn] Неверная структура ответа от Google auth');
          throw Exception('Ошибка получения данных пользователя');
        }

        // Extract and store access_token for Bearer authentication
        final accessToken = tokens['access_token'] as String?;
        if (accessToken != null && accessToken.isNotEmpty) {
          AppLogger.debug('[$backendTimestamp] [Auth] [GoogleSignIn] Сохранение access_token (длина: ${accessToken.length} символов)');
          await _sharedPreferences.setString('access_token', accessToken);
          AppLogger.info('[$backendTimestamp] [Auth] [GoogleSignIn] Access token сохранён для Google пользователя: ${_maskEmail(user.email ?? 'unknown')}');
          
          // Verify it was saved
          final saved = _sharedPreferences.getString('access_token');
          if (saved != null && saved.isNotEmpty) {
            AppLogger.debug('[$backendTimestamp] [Auth] [GoogleSignIn] Access token успешно сохранён и верифицирован');
          } else {
            AppLogger.error('[$backendTimestamp] [Auth] [GoogleSignIn] НЕ УДАЛОСЬ сохранить access_token в SharedPreferences');
          }
        } else {
          AppLogger.warning('[$backendTimestamp] [Auth] [GoogleSignIn] Нет access_token в ответе Google auth для пользователя: ${_maskEmail(user.email ?? 'unknown')}');
        }

        // Update session with backend user data
        final backendUid = backendUser['id'] as String?;
        if (backendUid == null) {
          AppLogger.warning('[$backendTimestamp] [Auth] [GoogleSignIn] Нет user ID в ответе Google auth');
          throw Exception('Не удалось получить ID пользователя');
        }

        AppLogger.debug('[$backendTimestamp] [Auth] [GoogleSignIn] Обновление сессии с backend данными');
        _currentUserSession = UserSession(
          uid: backendUid,
          email: backendUser['email'] as String?,
          displayName: backendUser['display_name'] as String?,
          photoUrl: backendUser['avatar_url'] as String?,
          loginTime: DateTime.now(),
          isEmailVerified: backendUser['is_verified'] as bool? ?? false,
        );

        // Save session to SharedPreferences
        final sessionJson = _currentUserSession?.toJson();
        if (sessionJson != null) {
          await _sharedPreferences.setString(
            'user_session',
            jsonEncode(sessionJson),
          );
          AppLogger.debug('[$backendTimestamp] [Auth] [GoogleSignIn] Сессия сохранена в SharedPreferences');
        }

        // Notify subscribers
        _sessionStreamController.add(_currentUserSession);

        AppLogger.info('[$backendTimestamp] [Auth] [GoogleSignIn] Google Sign-In завершён для пользователя: ${user.uid}');
        AppLogger.info('[$backendTimestamp] [Auth] [GoogleSignIn] Сессия обновлена, токены сохранены');
        return true;
      } catch (e) {
        AppLogger.error('[$timestamp] [Auth] [GoogleSignIn] Ошибка backend Google auth: $e', e);
        if (e.toString().contains('401')) {
          AppLogger.error('[$timestamp] [Auth] [GoogleSignIn] 401 Unauthorized от backend - Firebase token может быть невалиден или истёк');
        }
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.error('[$timestamp] [Auth] [GoogleSignIn] Ошибка Google Sign-In: ${e.code} - ${e.message}', e);
      return false;
    } catch (e) {
      AppLogger.error('[$timestamp] [Auth] [GoogleSignIn] Ошибка Google Sign-In: $e', e);
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

      // Вызываем backend API /api/v1/auth/register
      final Map<String, dynamic> registerData = {
        'email': email,
        'password': password,
      };
      if (displayName != null && displayName.isNotEmpty) {
        registerData['display_name'] = displayName;
      }

      final response = await _apiClient.post('/api/v1/auth/register', data: registerData);

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

      // Extract and store access_token for Bearer authentication
      final accessToken = tokens['access_token'] as String?;
      if (accessToken != null && accessToken.isNotEmpty) {
        await _sharedPreferences.setString('access_token', accessToken);
        AppLogger.info('Access token stored for user: ${_maskEmail(email)}');
      } else {
        AppLogger.warning('No access_token in register response for user: ${_maskEmail(email)}');
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
  /// Работает как для Firebase (Google), так и для email/password (backend)
  Future<bool> updateUserProfile({String? displayName, String? photoUrl}) async {
    try {
      final currentSession = _currentUserSession;
      final firebaseUser = _firebaseAuth.currentUser;

      if (currentSession == null) {
        AppLogger.warning('No session for profile update');
        return false;
      }

      final String uid = firebaseUser?.uid ?? currentSession.uid;
      AppLogger.info('Updating profile for user: $uid');

      // Если есть Firebase user (Google) - обновляем в Firebase
      if (firebaseUser != null) {
        if (displayName != null) {
          await firebaseUser.updateDisplayName(displayName);
        }
        if (photoUrl != null) {
          await firebaseUser.updatePhotoURL(photoUrl);
        }
      }

      // Обновляем сессию с новыми данными (работает для обоих типов)
      _currentUserSession = UserSession(
        uid: uid,
        email: currentSession.email,
        displayName: displayName ?? currentSession.displayName,
        photoUrl: photoUrl ?? currentSession.photoUrl,
        loginTime: currentSession.loginTime,
        isEmailVerified: currentSession.isEmailVerified,
      );

      // Сохраняем обновленную сессию
      final sessionJson = _currentUserSession?.toJson();
      if (sessionJson != null) {
        await _sharedPreferences.setString(
          'user_session',
          jsonEncode(sessionJson),
        );
      }

      // Уведомляем подписчиков
      _sessionStreamController.add(_currentUserSession);
      AppLogger.info('Profile updated for user: $uid');
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

      // Вызываем backend API /api/v1/auth/forgot-password
      await _apiClient.post('/api/v1/auth/forgot-password', data: {
        'email': email,
      });

      AppLogger.info('Password reset code sent to: ${_maskEmail(email)}');
    } catch (e) {
      AppLogger.error('Error requesting password reset: $e', e);
      rethrow;
    }
  }

  /// Проверка кода восстановления пароля — шаг 2: валидация кода на сервере
  ///
  /// Backend проверяет код БЕЗ его потребления (код остается валидным для финального сброса)
  Future<void> verifyResetCode(String email, String code) async {
    try {
      AppLogger.info('Verifying reset code for: ${_maskEmail(email)}');

      // Вызываем backend API /api/v1/auth/verify-reset-code
      await _apiClient.post('/api/v1/auth/verify-reset-code', data: {
        'email': email,
        'code': code,
      });

      AppLogger.info('Reset code verified for: ${_maskEmail(email)}');
    } catch (e) {
      AppLogger.error('Error verifying reset code: $e', e);
      rethrow;
    }
  }

  /// Сброс пароля — шаг 3: проверка кода и установка нового пароля
  ///
  /// Backend проверяет код и обновляет пароль пользователя
  Future<void> resetPasswordWithCode(String email, String code, String newPassword) async {
    try {
      AppLogger.info('Resetting password for: ${_maskEmail(email)}');

      // Вызываем backend API /api/v1/auth/reset-password
      await _apiClient.post('/api/v1/auth/reset-password', data: {
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
    await _sharedPreferences.remove('access_token');
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
