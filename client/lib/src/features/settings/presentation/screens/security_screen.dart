import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:outfitstyle_client/src/ui/widgets/max_width_container.dart';
import '../../../../core/api/api_client.dart';
import 'package:outfitstyle_client/src/services/auth_storage.dart';
import '../../data/repositories/sessions_repository.dart';
import '../../data/models/session_device.dart';

/// Провайдер API клиента
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(storage: AuthStorage());
});

/// Провайдер репозитория сессий
final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SessionsRepository(apiClient: apiClient);
});

/// Состояние загрузчика сессий
class SessionsState {
  final List<SessionDevice> sessions;
  final bool isLoading;
  final String? error;
  final String? deletingSessionId;

  const SessionsState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
    this.deletingSessionId,
  });

  SessionsState copyWith({
    List<SessionDevice>? sessions,
    bool? isLoading,
    String? error,
    String? deletingSessionId,
  }) {
    return SessionsState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      deletingSessionId: deletingSessionId ?? this.deletingSessionId,
    );
  }
}

/// Нотификер сессий
class SessionsNotifier extends StateNotifier<SessionsState> {
  final SessionsRepository _repository;

  SessionsNotifier({required SessionsRepository repository})
    : _repository = repository,
      super(const SessionsState()) {
    loadSessions();
  }

  /// Загрузить сессии с сервера
  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessions = await _repository.getSessions();
      // Сортируем: текущая сессия первая, затем по lastUsedAt
      sessions.sort((a, b) {
        if (a.isCurrent) return -1;
        if (b.isCurrent) return 1;
        return b.lastUsedAt.compareTo(a.lastUsedAt);
      });
      state = state.copyWith(sessions: sessions, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка загрузки сессий: $e',
      );
    }
  }

  /// Удалить сессию
  Future<bool> deleteSession(String sessionId) async {
    state = state.copyWith(deletingSessionId: sessionId, error: null);
    try {
      await _repository.deleteSession(sessionId);
      // Обновляем список сессий
      final sessions = state.sessions.where((s) => s.id != sessionId).toList();
      state = state.copyWith(sessions: sessions, deletingSessionId: null);
      return true;
    } catch (e) {
      state = state.copyWith(
        deletingSessionId: null,
        error: 'Ошибка удаления сессии: $e',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final sessionsProvider = StateNotifierProvider<SessionsNotifier, SessionsState>(
  (ref) {
    final repository = ref.watch(sessionsRepositoryProvider);
    return SessionsNotifier(repository: repository);
  },
);

/// Экран настроек безопасности
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  // Смена пароля
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Двухфакторная аутентификация
  bool _twoFactorEnabled = false;

  // История входов (mock, пока нет API)
  final _loginHistory = [
    LoginHistoryItem(
      device: 'iPhone 15 Pro',
      time: 'Сегодня, 14:30',
      isSuccess: true,
      icon: Icons.phone_iphone,
    ),
    LoginHistoryItem(
      device: 'MacBook Pro',
      time: 'Вчера, 09:15',
      isSuccess: true,
      icon: Icons.laptop_mac,
    ),
    LoginHistoryItem(
      device: 'Неизвестное устройство',
      time: '15 фев, 22:45',
      isSuccess: false,
      icon: Icons.device_unknown,
    ),
  ];

  // Привязанные аккаунты
  bool _googleLinked = true;
  bool _appleLinked = false;
  bool _vkLinked = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _twoFactorEnabled = prefs.getBool('two_factor_enabled') ?? false;
      _googleLinked = prefs.getBool('google_linked') ?? true;
      _appleLinked = prefs.getBool('apple_linked') ?? false;
      _vkLinked = prefs.getBool('vk_linked') ?? false;
    });
  }

  Future<void> _saveTwoFactorSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('two_factor_enabled', value);
    setState(() {
      _twoFactorEnabled = value;
    });
  }

  Future<void> _saveSocialLink(String social, bool linked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${social}_linked', linked);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('Смена пароля'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Текущий пароль
                        TextField(
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrentPassword,
                          decoration: InputDecoration(
                            labelText: 'Текущий пароль',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureCurrentPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  _obscureCurrentPassword =
                                      !_obscureCurrentPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Новый пароль
                        TextField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          decoration: InputDecoration(
                            labelText: 'Новый пароль',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Подтверждение пароля
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Подтверждение пароля',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Отмена'),
                    ),
                    FilledButton(
                      onPressed: () {
                        _changePassword();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Сохранить'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar('Заполните все поля', isError: true);
      return;
    }

    if (newPassword.length < 8) {
      _showSnackBar('Пароль должен быть не менее 8 символов', isError: true);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('Пароли не совпадают', isError: true);
      return;
    }

    // Имитация смены пароля (пока нет API)
    await Future.delayed(const Duration(milliseconds: 500));
    _showSnackBar('Пароль успешно изменен');

    // Очистка полей
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _showTwoFactorSetupDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: Icon(
              Icons.security,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text(
              'Двухфакторная аутентификация',
              textAlign: TextAlign.center,
            ),
            content: const Text(
              'Для включения 2FA вам потребуется приложение-аутентификатор '
              '(Google Authenticator, Authy и т.д.)\n\n'
              'После включения при каждом входе нужно будет вводить код из приложения.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () {
                  _saveTwoFactorSetting(true);
                  Navigator.of(context).pop();
                  _showSnackBar('2FA включена');
                },
                child: const Text('Включить'),
              ),
            ],
          ),
    );
  }

  void _showSessionDetails(SessionDevice session) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  _getIconData(session.iconCode),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(session.deviceName)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Тип устройства', session.deviceTypeLabel),
                if (session.ipAddress != null)
                  _buildInfoRow('IP-адрес', session.ipAddress!),
                _buildInfoRow('Последняя активность', session.lastActiveLabel),
                _buildInfoRow(
                  'Статус',
                  session.isCurrent
                      ? 'Текущая сессия'
                      : session.isActive
                      ? 'Активная'
                      : 'Неактивна',
                ),
                if (session.expiresAt != null)
                  _buildInfoRow(
                    'Истекает',
                    _formatExpiresAt(session.expiresAt!),
                  ),
              ],
            ),
            actions: [
              if (!session.isCurrent && session.isActive)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _confirmDeleteSession(session);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Завершить'),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Закрыть'),
              ),
            ],
          ),
    );
  }

  void _confirmDeleteSession(SessionDevice session) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: Icon(
              Icons.logout,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            title: const Text('Завершить сессию?', textAlign: TextAlign.center),
            content: Text(
              'Вы уверены, что хотите завершить сессию на устройстве "${session.deviceName}"?',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteSession(session);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Завершить'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteSession(SessionDevice session) async {
    final success = await ref
        .read(sessionsProvider.notifier)
        .deleteSession(session.id);

    if (mounted) {
      if (success) {
        _showSnackBar('Сессия завершена');
      } else {
        final state = ref.read(sessionsProvider);
        _showSnackBar(state.error ?? 'Ошибка удаления сессии', isError: true);
      }
    }
  }

  IconData _getIconData(String iconCode) {
    // Преобразуем строковый код в IconData
    switch (iconCode) {
      case 'phone_iphone':
        return Icons.phone_iphone;
      case 'tablet_mac':
        return Icons.tablet_mac;
      case 'desktop_mac':
        return Icons.desktop_mac;
      case 'language':
        return Icons.language;
      default:
        return Icons.devices;
    }
  }

  String _formatExpiresAt(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.isNegative) {
      return 'Истекла';
    } else if (difference.inDays < 1) {
      return 'Сегодня в ${expiresAt.hour.toString().padLeft(2, '0')}:${expiresAt.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return 'Через ${difference.inDays} дн.';
    } else {
      final day = expiresAt.day.toString().padLeft(2, '0');
      final month = expiresAt.month.toString().padLeft(2, '0');
      final year = expiresAt.year;
      return '$day.$month.$year';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            title: const Text('Удалить аккаунт?', textAlign: TextAlign.center),
            content: const Text(
              'Это действие необратимо. Все ваши данные будут удалены.\n\n'
              'Перейдите в раздел "Профиль" для удаления аккаунта.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Переход в профиль для удаления
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('В профиль'),
              ),
            ],
          ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionsState = ref.watch(sessionsProvider);

    return Scaffold(
      body: ResponsiveMaxWidthContainer(
        child: CustomScrollView(
          slivers: [
            // Заголовок
            SliverToBoxAdapter(child: _buildHeader(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Смена пароля
            SliverToBoxAdapter(child: _buildPasswordSection(context, theme)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Двухфакторная аутентификация
            SliverToBoxAdapter(child: _buildTwoFactorSection(context, theme)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Активные сессии
            SliverToBoxAdapter(
              child: _buildSessionsSection(context, theme, sessionsState),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // История входов
            SliverToBoxAdapter(
              child: _buildLoginHistorySection(context, theme),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Привязанные аккаунты
            SliverToBoxAdapter(
              child: _buildSocialAccountsSection(context, theme),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Опасная зона
            SliverToBoxAdapter(child: _buildDangerZone(context, theme)),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Text(
        'Безопасность',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildPasswordSection(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Смена пароля',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Регулярно меняйте пароль для безопасности',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _showChangePasswordDialog,
              icon: const Icon(Icons.edit),
              label: const Text('Изменить пароль'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoFactorSection(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              _twoFactorEnabled
                  ? [
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                    theme.colorScheme.secondary.withValues(alpha: 0.1),
                  ]
                  : [
                    theme.colorScheme.surface,
                    theme.colorScheme.surfaceContainerHighest,
                  ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              _twoFactorEnabled
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    _twoFactorEnabled
                        ? [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ]
                        : [Colors.grey.shade400, Colors.grey.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _twoFactorEnabled ? Icons.security : Icons.security_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Двухфакторная аутентификация',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _twoFactorEnabled ? 'Защищено' : 'Не включено',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _twoFactorEnabled,
            onChanged: (value) {
              if (value) {
                _showTwoFactorSetupDialog();
              } else {
                _saveTwoFactorSetting(false);
                _showSnackBar('2FA отключена');
              }
            },
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return theme.colorScheme.primary;
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsSection(
    BuildContext context,
    ThemeData theme,
    SessionsState state,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.devices, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Активные сессии',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (state.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    '${state.sessions.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          // Ошибка загрузки
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(sessionsProvider.notifier).clearError();
                      ref.read(sessionsProvider.notifier).loadSessions();
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          // Список сессий
          if (state.sessions.isEmpty && !state.isLoading && state.error == null)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('Нет активных сессий')),
            )
          else
            ...state.sessions.asMap().entries.map((entry) {
              final index = entry.key;
              final session = entry.value;
              final isDeleting = state.deletingSessionId == session.id;

              return Column(
                children: [
                  if (index > 0)
                    Divider(
                      height: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            session.isCurrent
                                ? theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                )
                                : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          isDeleting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Icon(
                                _getIconData(session.iconCode),
                                color:
                                    session.isCurrent
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                size: 22,
                              ),
                    ),
                    title: Text(
                      session.deviceName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${session.deviceTypeLabel} • ${session.lastActiveLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing:
                        session.isCurrent
                            ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Текущая',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                            : const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                    onTap: () => _showSessionDetails(session),
                  ),
                ],
              );
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLoginHistorySection(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.history, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'История входов',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ..._loginHistory.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (index > 0)
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          item.isSuccess
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item.icon,
                      color:
                          item.isSuccess
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    item.device,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: item.isSuccess ? null : theme.colorScheme.error,
                    ),
                  ),
                  subtitle: Text(
                    item.time,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing:
                      item.isSuccess
                          ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                            size: 20,
                          )
                          : Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                ),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSocialAccountsSection(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.link, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Привязанные аккаунты',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Google
          _buildSocialTile(
            context,
            theme,
            name: 'Google',
            icon: Icons.g_mobiledata,
            isLinked: _googleLinked,
            onToggle: (value) {
              _saveSocialLink('google', value);
              setState(() => _googleLinked = value);
              _showSnackBar(
                value ? 'Google аккаунт привязан' : 'Google аккаунт отвязан',
              );
            },
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          // Apple
          _buildSocialTile(
            context,
            theme,
            name: 'Apple',
            icon: Icons.apple,
            isLinked: _appleLinked,
            onToggle: (value) {
              _saveSocialLink('apple', value);
              setState(() => _appleLinked = value);
              _showSnackBar(
                value ? 'Apple аккаунт привязан' : 'Apple аккаунт отвязан',
              );
            },
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          // VK
          _buildSocialTile(
            context,
            theme,
            name: 'VK',
            icon: Icons.share,
            isLinked: _vkLinked,
            onToggle: (value) {
              _saveSocialLink('vk', value);
              setState(() => _vkLinked = value);
              _showSnackBar(
                value ? 'VK аккаунт привязан' : 'VK аккаунт отвязан',
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSocialTile(
    BuildContext context,
    ThemeData theme, {
    required String name,
    required IconData icon,
    required bool isLinked,
    required ValueChanged<bool> onToggle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isLinked
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color:
              isLinked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
          size: 22,
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        isLinked ? 'Привязан' : 'Не привязан',
        style: theme.textTheme.bodySmall?.copyWith(
          color:
              isLinked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: isLinked,
        onChanged: onToggle,
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return theme.colorScheme.primary;
          }
          return null;
        }),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text(
                'Удаление аккаунта',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Это действие необратимо удалит все ваши данные',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _showDeleteAccountDialog,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Удалить аккаунт'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Модель истории входов
class LoginHistoryItem {
  final String device;
  final String time;
  final bool isSuccess;
  final IconData icon;

  LoginHistoryItem({
    required this.device,
    required this.time,
    required this.isSuccess,
    required this.icon,
  });
}
