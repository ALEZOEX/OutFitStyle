import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/routing/router.dart';
import '../../../ui/misc/app_avatar.dart';
import '../../../services/auth_service.dart' as auth_service;

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
  /// Для Web используется Firebase Auth signInWithPopup (не требует redirect_uri)
  Future<void> _signInWithGoogle() async {
    print('[Google Sign-In] Начало входа через Firebase Auth...');
    
    // Показываем модальное окно ожидания
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false, // Нельзя закрыть кликом вне
      builder: (context) => PopScope(
        canPop: false, // Нельзя закрыть кнопкой назад
        child: AlertDialog(
          title: const Text('Вход через Google'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Откройте окно Google для входа...'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
          ],
        ),
      ),
    );

    try {
      // Используем AuthService который корректно работает на Web
      final authService = auth_service.AuthService(
        apiBase: 'https://app.outfitstyle.ru',
        authStorage: ref.read(authRepositoryProvider).authStorage,
      );

      print('[Google Sign-In] Вызов loginWithGoogle()...');
      final tokenPair = await authService.loginWithGoogle();
      print('[Google Sign-In] Токены получены успешно');

      // Закрываем модальное окно
      if (mounted) Navigator.of(context).pop(true);

      // Обновляем состояние авторизации
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.authStorage.writeTokenPair(tokenPair);

      final authStateNotifier = ref.read(authStateProvider.notifier);
      await authStateNotifier.checkAuth();

      // Уведомляем роутер
      final refreshStream = ref.read(goRouterRefreshProvider);
      refreshStream.notifyAuthChanged();

      if (mounted) {
        print('[Google Sign-In] Переход на /home');
        context.go('/home');
      }
    } catch (e, stackTrace) {
      print('[Google Sign-In] ❌ ОШИБКА: $e');
      print('[Google Sign-In] Stack trace: $stackTrace');
      
      // Закрываем модальное окно
      if (mounted) Navigator.of(context).pop(false);
      
      // Показываем ошибку
      if (mounted) {
        ref.read(authErrorProvider.notifier).state = e.toString();
        
        // Показываем диалог с ошибкой
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ошибка входа'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
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
