import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../presentation/providers/session_provider.dart';
import '../../../utils/auth_utils.dart';
import '../../../theme/app_theme.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authStateProvider);
      authState.whenData((isLoggedIn) {
        if (isLoggedIn) {
          // GoRouter redirect обработает
        }
      });
    });
  }

  void _handleAuthSuccess() {
    final uri = GoRouterState.of(context).uri;
    final redirect = uri.queryParameters['redirect'];

    if (redirect != null && redirect.isNotEmpty) {
      context.go(redirect);
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Вход через Google'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.lg),
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
      final sessionManager = ref.read(sessionManagerProvider);
      final success = await sessionManager.signInWithGoogle();

      if (mounted) Navigator.of(context).pop(success);

      if (!success) {
        if (mounted) {
          ref.read(authErrorProvider.notifier).state =
              'Не удалось войти через Google';
        }
      } else {
        if (mounted) _handleAuthSuccess();
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(false);

      if (mounted) {
        final errorMsg = AuthUtils.extractAuthError(e);
        ref.read(authErrorProvider.notifier).state = errorMsg;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ошибка входа'),
            content: Text(errorMsg),
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
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final name = _nameController.text.trim();

      final sessionManager = ref.read(sessionManagerProvider);

      bool success;
      if (_isLogin) {
        success = await sessionManager.signIn(email: email, password: password);
      } else {
        success = await sessionManager.signUp(
          email,
          password,
          displayName: name.isNotEmpty ? name : null,
        );
      }

      if (!success) throw Exception('Не удалось выполнить операцию');

      if (mounted) _handleAuthSuccess();
    } catch (e) {
      if (mounted) {
        ref.read(authErrorProvider.notifier).state = AuthUtils.extractAuthError(
          e,
        );
      }
    } finally {
      if (mounted) ref.read(authLoadingProvider.notifier).state = false;
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
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: SizedBox(
              width: isWide ? 400 : double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Градиентный аватар с логотипом
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'OS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Заголовок
                  Text(
                    'OutfitStyle',
                    style: AppTypography.headlineLarge(
                      context,
                    ).copyWith(color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _isLogin ? 'С возвращением!' : 'Создать аккаунт',
                    style: AppTypography.bodyLarge(
                      context,
                    ).copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Форма
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Имя',
                              prefixIcon: Icon(Icons.person_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите имя';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
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
                        const SizedBox(height: AppSpacing.lg),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: const InputDecoration(
                            labelText: 'Пароль',
                            prefixIcon: Icon(Icons.lock_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите пароль';
                            }
                            if (value.length < 12) {
                              return 'Минимум 12 символов';
                            }
                            if (value.length > 72) {
                              return 'Максимум 72 символа';
                            }
                            if (!RegExp(r'[A-Z]').hasMatch(value)) {
                              return 'Нужна хотя бы одна заглавная буква';
                            }
                            if (!RegExp(r'[a-z]').hasMatch(value)) {
                              return 'Нужна хотя бы одна строчная буква';
                            }
                            if (!RegExp(r'[0-9]').hasMatch(value)) {
                              return 'Нужна хотя бы одна цифра';
                            }
                            if (!RegExp(
                              r'[!@#$%^&*()\-_=+\[\]{}|;:<>?,./~`\\]',
                            ).hasMatch(value)) {
                              return 'Нужен хотя бы один спецсимвол';
                            }
                            return null;
                          },
                        ),

                        if (!_isLogin) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Мин. 12 символов: A-Z, a-z, 0-9, спецсимвол',
                            style: AppTypography.bodySmall(context),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Ошибка
                  if (error != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: AppRadius.radiusSm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.onErrorContainer,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
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

                  const SizedBox(height: AppSpacing.xxl),

                  // Кнопка входа/регистрации — gradient style
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: isLoading ? null : AppGradients.heroButton,
                        color: isLoading
                            ? theme.colorScheme.surfaceContainerHighest
                            : null,
                        borderRadius: AppRadius.radiusPill,
                        boxShadow: isLoading
                            ? null
                            : [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isLoading ? null : _submit,
                          borderRadius: AppRadius.radiusPill,
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isLogin
                                            ? Icons.login
                                            : Icons.person_add,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(
                                        _isLogin
                                            ? 'Войти'
                                            : 'Зарегистрироваться',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

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

                  if (_isLogin)
                    TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text('Забыли пароль?'),
                    ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Разделитель
                  Row(
                    children: [
                      Expanded(child: Divider(color: theme.dividerTheme.color)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Text(
                          'или',
                          style: AppTypography.bodySmall(context),
                        ),
                      ),
                      Expanded(child: Divider(color: theme.dividerTheme.color)),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),

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
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
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
