import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../exceptions/api_exceptions.dart';
import '../services/auth_service.dart';
import '../services/auth_storage.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Регистрация
  final _regFormKey = GlobalKey<FormState>();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regUsernameController = TextEditingController();

  // Логин
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Код подтверждения
  final _codeFormKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  bool _isLoading = false;
  bool _awaitingCode = false; // шаг 2 – ввод кода
  String _currentEmailForCode = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regUsernameController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String _mapAuthError(Object e, {required bool isRegister}) {
    final msg = e.toString().toLowerCase();

    // Логин: неверные данные
    if (msg.contains('invalid credentials') ||
        msg.contains('неверный email или пароль')) {
      return 'Неверный email или пароль';
    }

    // Регистрация: занято
    if (msg.contains('email already exists') ||
        msg.contains('users_email_key') ||
        msg.contains('duplicate key')) {
      return 'Пользователь с таким email уже зарегистрирован';
    }

    // Сеть
    if (msg.contains('timeout') ||
        msg.contains('hostlookup') ||
        msg.contains('socketexception') ||
        msg.contains('connection refused')) {
      return 'Проблема с подключением к серверу';
    }

    // Общий fallback без длинного текста исключения
    return isRegister
        ? 'Не удалось завершить регистрацию. Попробуйте позже.'
        : 'Не удалось выполнить вход. Попробуйте позже.';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // -------------------- Регистрация --------------------

  Future<void> _handleRegister() async {
    if (!_regFormKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text;
    final username = _regUsernameController.text.trim();

    setState(() => _isLoading = true);
    try {
      await authService.register(
        email: email,
        password: password,
        username: username,
      );

      setState(() {
        _awaitingCode = true;
        _currentEmailForCode = email;
        _codeController.clear();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Код подтверждения отправлен на email'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (e is ApiException && e.errorMessage != null) {
        _showError('Ошибка регистрации: ${e.errorMessage}');
      } else {
        _showError(_mapAuthError(e, isRegister: true));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // -------------------- Логин --------------------

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    setState(() => _isLoading = true);
    try {
      await authService.login(email: email, password: password);

      setState(() {
        _awaitingCode = true;
        _currentEmailForCode = email;
        _codeController.clear();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Код отправлен на email, введите его ниже'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (e is ApiException && e.errorMessage != null) {
        _showError('Ошибка входа: ${e.errorMessage}');
      } else {
        _showError(_mapAuthError(e, isRegister: false));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // -------------------- Подтверждение кода --------------------

  Future<void> _handleVerifyCode() async {
    if (!_codeFormKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final authStorage = context.read<AuthStorage>();

    final code = _codeController.text.trim();

    setState(() => _isLoading = true);
    try {
      final result = await authService.verifyCode(code);
      final accessToken = result['accessToken'] as String?;
      final user = result['user'] as Map<String, dynamic>?;

      if (accessToken == null || user == null) {
        throw Exception('Некорректный ответ сервера');
      }

      final userId = (user['id'] as num).toInt();
      await authStorage.saveSession(
        userId: userId,
        accessToken: accessToken,
      );

      if (!mounted) return;

      setState(() {
        _awaitingCode = false;
        _codeController.clear();
      });

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (e is ApiException && e.errorMessage != null) {
        _showError('Ошибка подтверждения кода: ${e.errorMessage}');
      } else {
        _showError(_mapAuthError(e, isRegister: false));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // -------------------- Google Login --------------------

  Future<void> _handleGoogleLogin() async {
    final authService = context.read<AuthService>();
    final authStorage = context.read<AuthStorage>();

    setState(() => _isLoading = true);
    try {
      final result = await authService.signInWithGoogleAndBackend();
      if (result == null) {
        // пользователь отменил вход
        return;
      }
      final accessToken = result['accessToken'] as String?;
      final user = result['user'] as Map<String, dynamic>?;

      if (accessToken == null || user == null) {
        throw Exception('Некорректный ответ сервера');
      }

      final userId = (user['id'] as num).toInt();
      await authStorage.saveSession(
        userId: userId,
        accessToken: accessToken,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on UnsupportedError {
      _showError('Вход через Google недоступен на этой платформе');
    } catch (e) {
      if (e is ApiException && e.errorMessage != null) {
        _showError('Ошибка входа через Google: ${e.errorMessage}');
      } else {
        _showError(_mapAuthError(e, isRegister: false));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // -------------------- UI helpers --------------------

  InputDecoration _fieldDecoration(String label, IconData icon) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: theme.cardColor.withOpacity(0.98),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1F2937),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 480 : 520,
                  ),
                  child: Card(
                    color: theme.cardColor.withOpacity(0.98),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'OutfitStyle',
                              style:
                              theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _awaitingCode
                                  ? 'Шаг 2 из 2: подтвердите вход'
                                  : 'Подберите образ под любую погоду',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                              theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 24),

                            if (_awaitingCode)
                              _buildCodeStep(theme)
                            else
                              _buildAuthTabs(theme),

                            const SizedBox(height: 12),
                            if (_isLoading) const LinearProgressIndicator(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthTabs(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true, // чтобы текст вкладок не вылезал
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor:
          theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          indicatorColor: theme.colorScheme.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Вход'),
            Tab(text: 'Регистрация'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          // фиксированная, но достаточная высота, + скролл внутри вкладки
          height: 340,
          child: TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 4),
                child: _buildLoginForm(),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 4),
                child: _buildRegisterForm(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _loginEmailController,
            decoration: _fieldDecoration('Email', Icons.email),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Введите email';
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(email)) {
                return 'Некорректный email';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _loginPasswordController,
            decoration: _fieldDecoration('Пароль', Icons.lock),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            autofillHints: const [AutofillHints.password],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Введите пароль';
              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Войти'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _handleGoogleLogin,
              icon: const Icon(Icons.login),
              label: const Text(
                'Войти через Google',
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _regFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _regUsernameController,
            decoration: _fieldDecoration('Имя пользователя', Icons.person),
            textInputAction: TextInputAction.next,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Введите имя пользователя';
              if (v.length < 3) return 'Минимум 3 символа';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _regEmailController,
            decoration: _fieldDecoration('Email', Icons.email),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Введите email';
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(email)) return 'Некорректный email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _regPasswordController,
            decoration: _fieldDecoration('Пароль', Icons.lock),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleRegister(),
            autofillHints: const [AutofillHints.newPassword],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите пароль';
              }
              if (value.length < 8) {
                return 'Минимум 8 символов';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Создать аккаунт'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Введите код подтверждения',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Мы отправили код на $_currentEmailForCode',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _codeFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextFormField(
            controller: _codeController,
            decoration: _fieldDecoration('Код из письма', Icons.verified),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleVerifyCode(),
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Введите код';
              if (v.length < 4) return 'Код слишком короткий';
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleVerifyCode,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Подтвердить код'),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () {
              setState(() {
                _awaitingCode = false;
                _codeController.clear();
              });
            },
            child: const Text(
              'Изменить email или пароль',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}