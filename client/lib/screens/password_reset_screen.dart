import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../exceptions/api_exceptions.dart';
import '../services/auth_service.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showTokenStep = false; // после отправки email показываем ввод токена

  String _mapAuthError(Object e) {
    final msg = e.toString().toLowerCase();

    // Сеть
    if (msg.contains('timeout') ||
        msg.contains('hostlookup') ||
        msg.contains('socketexception') ||
        msg.contains('connection refused')) {
      return 'Проблема с подключением к серверу';
    }

    // Общий fallback
    return 'Ошибка: ${e.toString()}';
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

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Запрос на восстановление пароля
  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final email = _emailController.text.trim();

    setState(() => _isLoading = true);
    try {
      await authService.requestPasswordReset(email);

      if (!mounted) return;
      
      setState(() {
        _showTokenStep = true;
      });
      
      _showSuccess('Письмо с инструкциями отправлено на $email');
    } catch (e) {
      if (e is ApiException && e.errorMessage != null) {
        _showError('Ошибка: ${e.errorMessage}');
      } else {
        _showError(_mapAuthError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Подтверждение сброса пароля
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final token = _tokenController.text.trim();
    final newPassword = _newPasswordController.text;

    setState(() => _isLoading = true);
    try {
      await authService.resetPassword(token: token, newPassword: newPassword);

      if (!mounted) return;
      
      _showSuccess('Пароль успешно изменен!');
      
      // Возвращаемся на экран аутентификации
      Navigator.pop(context);
    } catch (e) {
      if (e is ApiException && e.errorMessage != null) {
        _showError('Ошибка: ${e.errorMessage}');
      } else {
        _showError(_mapAuthError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      appBar: AppBar(
        title: Text(_showTokenStep ? 'Сброс пароля' : 'Восстановление пароля'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_showTokenStep) {
              setState(() {
                _showTokenStep = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              child: Card(
                color: theme.cardColor.withOpacity(0.98),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Восстановление пароля',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _showTokenStep
                              ? 'Введите токен из письма и новый пароль'
                              : 'Введите email, связанный с вашим аккаунтом',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (!_showTokenStep)
                          TextFormField(
                            controller: _emailController,
                            decoration: _fieldDecoration('Email', Icons.email),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
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
                          )
                        else ...[
                          TextFormField(
                            controller: _tokenController,
                            decoration: _fieldDecoration('Токен', Icons.key),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return 'Введите токен';
                              if (v.length < 6) return 'Токен должен содержать минимум 6 символов';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _newPasswordController,
                            decoration: _fieldDecoration('Новый пароль', Icons.lock),
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите новый пароль';
                              }
                              if (value.length < 8) {
                                return 'Пароль должен содержать минимум 8 символов';
                              }
                              // Проверка сложности пароля
                              final hasDigit = RegExp(r'[0-9]').hasMatch(value);
                              final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
                              if (!hasDigit) return 'Пароль должен содержать хотя бы одну цифру';
                              if (!hasSpecial) return 'Пароль должен содержать хотя бы один специальный символ';
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 20),
                        if (_isLoading) const LinearProgressIndicator(),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (!_showTokenStep) {
                                      _requestPasswordReset();
                                    } else {
                                      _resetPassword();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              _showTokenStep ? 'Сбросить пароль' : 'Отправить инструкции',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showTokenStep = !_showTokenStep;
                              if (!_showTokenStep) {
                                _tokenController.clear();
                                _newPasswordController.clear();
                              }
                            });
                          },
                          child: Text(
                            _showTokenStep
                                ? 'Вернуться к email'
                                : 'Уже получили токен?',
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}