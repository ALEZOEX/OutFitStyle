import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../ui/widgets/max_width_container.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/upload_service.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../data/repositories/profile_repository.dart';

/// Провайдер для состояния профиля
/// Web-версия (без dart:io)
class ProfileState {
  final String? avatarUrl;
  final Uint8List? avatarBytes;
  final String name;
  final String email;
  final String userId;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.avatarUrl,
    this.avatarBytes,
    this.name = '',
    this.email = '',
    this.userId = '',
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    String? avatarUrl,
    Uint8List? avatarBytes,
    String? name,
    String? email,
    String? userId,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarBytes: avatarBytes ?? this.avatarBytes,
      name: name ?? this.name,
      email: email ?? this.email,
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Создать из [Map<String, dynamic>]
  factory ProfileState.fromMap(Map<String, dynamic> data) {
    return ProfileState(
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      avatarUrl: data['avatar_url'] as String?,
      userId: data['id'] as String? ?? '',
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final UploadService _uploadService;

  ProfileNotifier({
    required ProfileRepository repository,
    required UploadService uploadService,
  }) : _repository = repository,
       _uploadService = uploadService,
       super(const ProfileState()) {
    _loadProfile();
  }

  /// Загрузить профиль с сервера
  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userData = await _repository.getProfile();
      state = ProfileState.fromMap(userData).copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Загрузить аватар и сохранить на сервере
  /// Web-версия принимает XFile
  Future<bool> uploadAvatar(XFile imageFile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Web-версия: передаем XFile напрямую (uploadService конвертирует)
      final imageUrl = await _uploadService.uploadImage(imageFile);
      final userData = await _repository.uploadAvatar(imageUrl);

      state = ProfileState.fromMap(userData).copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка загрузки аватара: $e',
      );
      return false;
    }
  }

  /// Обновить имя пользователя
  Future<bool> updateName(String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userData = await _repository.updateProfile(name: name);
      state = ProfileState.fromMap(userData).copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка обновления имени: $e',
      );
      return false;
    }
  }

  /// Обновить email пользователя
  Future<bool> updateEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userData = await _repository.updateProfile(email: email);
      state = ProfileState.fromMap(userData).copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка обновления email: $e',
      );
      return false;
    }
  }

  /// Обновить профиль (имя и email одним запросом)
  Future<bool> updateProfile({String? name, String? email}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userData = await _repository.updateProfile(
        name: name,
        email: email,
      );
      state = ProfileState.fromMap(userData).copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка обновления профиля: $e',
      );
      return false;
    }
  }

  /// Удалить аккаунт
  Future<bool> deleteAccount({
    required String password,
    String? reason,
    String? feedback,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteAccount(
        password: password,
        reason: reason,
        feedback: feedback,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка удаления аккаунта: $e',
      );
      return false;
    }
  }

  /// Обновить состояние ошибки
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Провайдеры для создания зависимостей (используют глобальные провайдеры из router.dart)
final _apiClientProvider = Provider<ApiClient>((ref) {
  return ref.watch(apiClientProvider);
});

final _uploadServiceProvider = Provider<UploadService>((ref) {
  return UploadService();
});

final _profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(_apiClientProvider);
  return ProfileRepository(apiClient: apiClient);
});

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  final repository = ref.watch(_profileRepositoryProvider);
  final uploadService = ref.watch(_uploadServiceProvider);
  return ProfileNotifier(repository: repository, uploadService: uploadService);
});

/// Экран настроек профиля
/// Web-версия (без dart:io)
class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _picker = ImagePicker();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(profileProvider);
      _nameController.text = state.name;
      _emailController.text = state.email;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        // Web-версия: используем XFile напрямую (uploadService конвертирует)
        final success = await ref
            .read(profileProvider.notifier)
            .uploadAvatar(image);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Аватар успешно обновлен'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            final state = ref.read(profileProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Ошибка загрузки аватара'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Сделать фото'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Выбрать из галереи'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите имя'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите корректный email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await ref
          .read(profileProvider.notifier)
          .updateProfile(name: name, email: email);

      if (!success) {
        throw Exception(
          ref.read(profileProvider).error ?? 'Ошибка обновления профиля',
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Профиль успешно обновлен'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
              'Это действие необратимо. Все ваши данные будут удалены.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _deleteAccount();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Удалить'),
              ),
            ],
            actionsPadding: const EdgeInsets.all(16),
          ),
    );
  }

  Future<void> _deleteAccount() async {
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Это действие необратимо. Все ваши данные будут удалены.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Введите пароль для подтверждения',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Удалить'),
              ),
            ],
            actionsPadding: const EdgeInsets.all(16),
          ),
    );

    if (confirmed != true || passwordController.text.isEmpty) {
      return;
    }

    if (!mounted) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    navigator.push(
      MaterialPageRoute(
        builder:
            (dialogContext) => PopScope(
              canPop: false,
              child: const Center(child: CircularProgressIndicator()),
            ),
      ),
    );

    try {
      final success = await ref
          .read(profileProvider.notifier)
          .deleteAccount(
            password: passwordController.text,
            reason: 'Пользователь удалил аккаунт через приложение',
          );

      if (navigator.mounted) {
        navigator.pop();
      }

      if (!mounted) return;

      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Аккаунт успешно удален'),
            backgroundColor: Colors.green,
          ),
        );
        if (mounted) {
          navigator.pushNamedAndRemoveUntil('/auth', (route) => false);
        }
      } else {
        final state = ref.read(profileProvider);
        messenger.showSnackBar(
          SnackBar(
            content: Text(state.error ?? 'Ошибка при удалении аккаунта'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Редактировать',
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _isEditing = false);
                _nameController.text = state.name;
                _emailController.text = state.email;
              },
              tooltip: 'Отмена',
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
              tooltip: 'Сохранить',
            ),
          ],
        ],
      ),
      body:
          state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ResponsiveMaxWidthContainer(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _isEditing ? _showImageSourceDialog : null,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              backgroundImage: _getAvatarImageProvider(state),
                              child:
                                  state.avatarUrl == null &&
                                          state.avatarBytes == null
                                      ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color:
                                            theme
                                                .colorScheme
                                                .onPrimaryContainer,
                                      )
                                      : null,
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 3,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Имя',
                      icon: Icons.person_outline,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      enabled: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 32),
                    Divider(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    _buildDangerZone(context),
                  ],
                ),
              ),
    );
  }

  ImageProvider? _getAvatarImageProvider(ProfileState state) {
    if (state.avatarUrl == null && state.avatarBytes == null) {
      return null;
    }

    // Если есть bytes (локальное изображение)
    if (state.avatarBytes != null) {
      return MemoryImage(state.avatarBytes!);
    }

    // Если URL начинается с http, используем CachedNetworkImage
    final avatarUrl = state.avatarUrl;
    if (avatarUrl != null && avatarUrl.startsWith('http')) {
      return CachedNetworkImageProvider(avatarUrl);
    }

    // Иначе пробуем как network image
    return avatarUrl != null ? NetworkImage(avatarUrl) : null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text(
                'Опасная зона',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Удаление аккаунта необратимо удалит все ваши данные',
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
