import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/routing/router.dart';
import '../../../ui/misc/app_avatar.dart';
import '../../../models/token_pair.dart';

final authLoadingProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<String?>((ref) => null);

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Проверяем, не авторизован ли уже пользователь
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authStateProvider);
      if (authState.isAuthenticated) {
        // Уже авторизован, переходим на home
        if (mounted) {
          context.go('/home');
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// Вход через Google
  /// Примечание: на вебе googleAuth.accessToken всегда null, используем только idToken
  Future<void> _signInWithGoogle() async {
    print('[Google Sign-In] Начало входа...');
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      // 1. Инициализация GoogleSignIn
      print('[Google Sign-In] Инициализация GoogleSignIn...');
      final googleSignIn = GoogleSignIn();
      
      // 2. Вызов signIn()
      print('[Google Sign-In] Вызов signIn()...');
      final googleUser = await googleSignIn.signIn();
      print('[Google Sign-In] googleUser: ${googleUser == null ? "null (отмена)" : "ok"}');
      
      if (googleUser == null) {
        print('[Google Sign-In] Пользователь отменил вход');
        ref.read(authLoadingProvider.notifier).state = false;
        return;
      }

      // 3. Получение authentication
      print('[Google Sign-In] Получение authentication...');
      final googleAuth = await googleUser.authentication;
      print('[Google Sign-In] googleAuth: ${googleAuth == null ? "null" : "ok"}');
      
      if (googleAuth == null) {
        throw Exception('Не удалось получить Google authentication');
      }
      
      // 4. Проверка токенов
      final idToken = googleAuth.idToken;
      print('[Google Sign-In] idToken: ${idToken == null ? "null" : "ok"}');
      print('[Google Sign-In] accessToken: ${googleAuth.accessToken == null ? "null (OK для веба)" : "ok"}');

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Не удалось получить ID токен Google');
      }

      // 5. Создание credential
      print('[Google Sign-In] Создание GoogleAuthProvider.credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, // nullable — OK для веба
        idToken: idToken,
      );

      // 6. Вход через Firebase
      print('[Google Sign-In] Вызов signInWithCredential...');
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      print('[Google Sign-In] userCredential.user: ${userCredential.user == null ? "null" : "ok"}');
      
      if (userCredential.user == null) {
        throw Exception('Пользователь не авторизован после signInWithCredential');
      }
      
      final backendIdToken = await userCredential.user!.getIdToken();
      print('[Google Sign-In] backendIdToken: ${backendIdToken == null ? "null" : "ok"}');

      if (backendIdToken == null) {
        throw Exception('Не удалось получить токен для backend');
      }

      // 7. Отправка на backend
      print('[Google Sign-In] Отправка токена на backend...');
      final authRepo = ref.read(authRepositoryProvider);
      final apiClient = ref.read(apiClientProvider);

      final response = await apiClient.raw.post(
        '/api/v1/auth/google',
        data: {'id_token': backendIdToken},
      );
      
      print('[Google Sign-In] Ответ backend: status=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        print('[Google Sign-In] Данные ответа: ${data.keys.join(", ")}');
        
        final tokensData = data['tokens'] as Map<String, dynamic>?;
        if (tokensData == null) {
          print('[Google Sign-In] ОШИБКА: tokensData null');
          throw Exception('Неверный формат ответа от сервера: отсутствуют токены');
        }
        
        final tokenPair = TokenPair.fromJson(tokensData);
        print('[Google Sign-In] Токены получены');
        
        await authRepo.authStorage.writeTokenPair(tokenPair);
        print('[Google Sign-In] Сессия сохранена');

        // Обновляем состояние авторизации
        final authStateNotifier = ref.read(authStateProvider.notifier);
        await authStateNotifier.checkAuth();

        // Уведомляем роутер
        final refreshStream = ref.read(goRouterRefreshProvider);
        refreshStream.notifyAuthChanged();

        if (mounted) {
          print('[Google Sign-In] Переход на /home');
          context.go('/home');
        }
      } else {
        final errorData = response.data as Map<String, dynamic>?;
        print('[Google Sign-In] ОШИБКА backend: ${errorData?['message']}');
        throw Exception(errorData?['message'] ?? 'Ошибка аутентификации на сервере');
      }
    } catch (e, stackTrace) {
      print('[Google Sign-In] ❌ ОШИБКА: $e');
      print('[Google Sign-In] Stack trace: $stackTrace');
      if (mounted) {
        ref.read(authErrorProvider.notifier).state = e.toString();
      }
    } finally {
      if (mounted) {
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final name = _nameController.text.trim();
      final authRepo = ref.read(authRepositoryProvider);

      bool success;
      if (_isLogin) {
        success = await authRepo.login(email, password);
      } else {
        success = await authRepo.register(email, password, name);
      }

      if (!success) {
        throw Exception('Не удалось выполнить операцию');
      }

      // Обновляем состояние авторизации в роутере
      final authStateNotifier = ref.read(authStateProvider.notifier);
      await authStateNotifier.checkAuth();

      // Уведомляем роутер об изменении
      final refreshStream = ref.read(goRouterRefreshProvider);
      refreshStream.notifyAuthChanged();

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ref.read(authErrorProvider.notifier).state =
          e.toString().replaceAll('Exception: ', '');
      }
    } finally {
      if (mounted) {
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final error = ref.watch(authErrorProvider);
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: isWide ? 400 : double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // Логотип
                const AppAvatar(
                  radius: 50,
                  placeholderText: 'OS',
                ),
                const SizedBox(height: 24),
                
                // Заголовок
                Text(
                  'OutfitStyle',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? 'С возвращением!' : 'Создать аккаунт',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Форма
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Имя (только для регистрации)
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Имя',
                            prefixIcon: const Icon(Icons.person_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите имя';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите email';
                          }
                          if (!value.contains('@')) {
                            return 'Некорректный email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Пароль
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите пароль';
                          }
                          // Security: минимум 8 символов (соответствует backend)
                          if (value.length < 8) {
                            return 'Минимум 8 символов';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                // Ошибка
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.onErrorContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error,
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Кнопка входа/регистрации
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : _submit,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(_isLogin ? Icons.login : Icons.person_add),
                    label: Text(
                      isLoading ? 'Загрузка...' : (_isLogin ? 'Войти' : 'Зарегистрироваться'),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Переключатель вход/регистрация
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      ref.read(authErrorProvider.notifier).state = null;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Нет аккаунта? Зарегистрироваться'
                        : 'Уже есть аккаунт? Войти',
                  ),
                ),

                // Забыли пароль?
                if (_isLogin)
                  TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Забыли пароль?'),
                  ),

                const SizedBox(height: 32),

                // Разделитель
                Row(
                  children: [
                    Expanded(child: Divider(color: theme.dividerColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'или',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(child: Divider(color: theme.dividerColor)),
                  ],
                ),

                const SizedBox(height: 24),

                // Кнопка Google
                OutlinedButton.icon(
                  onPressed: isLoading ? null : _signInWithGoogle,
                  icon: Icon(
                    Icons.g_mobiledata,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                  label: const Text('Продолжить с Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
