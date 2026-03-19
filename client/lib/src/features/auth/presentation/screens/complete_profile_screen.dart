import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../presentation/providers/session_provider.dart';
import '../../../../storage/profile_storage.dart';
import '../../../../storage/local_storage.dart';
import '../../../settings/data/repositories/profile_repository.dart';
import '../../../../utils/logger.dart';

/// Провайдер для ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient: apiClient);
});

/// Провайдер для ProfileStorage
final profileStorageProvider = Provider<ProfileStorage>((ref) {
  return ProfileStorage(LocalStorage.prefs);
});

/// Состояние экрана заполнения профиля
enum CompleteProfileState { initial, loading, success, error }

/// Экран заполнения профиля после регистрации через Google
class CompleteProfileScreen extends ConsumerStatefulWidget {
  final String email;
  final String? googleName;

  const CompleteProfileScreen({
    super.key,
    required this.email,
    this.googleName,
  });

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  File? _photoFile;
  String? _photoPath;
  CompleteProfileState _state = CompleteProfileState.initial;
  String? _errorMessage;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Устанавливаем имя из Google, если доступно
    if (widget.googleName != null && widget.googleName!.isNotEmpty) {
      _nameController.text = widget.googleName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Выбрать фото из галереи
  Future<void> _pickImage() async {
    // Сохраняем тему до всех await
    final theme = Theme.of(context);

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Обрезаем изображение
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Выберите фото',
            toolbarColor: theme.colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Выберите фото',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _photoFile = File(croppedFile.path);
          _photoPath = croppedFile.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Ошибка при выборе фото: $e');
    }
  }

  /// Удалить выбранное фото
  void _clearPhoto() {
    setState(() {
      _photoFile = null;
      _photoPath = null;
    });
  }

  /// Сохранить профиль
  Future<void> _saveProfile() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      _state = CompleteProfileState.loading;
      _errorMessage = null;
    });

    try {
      final profileRepository = ref.read(profileRepositoryProvider);
      final profileStorage = ref.read(profileStorageProvider);

      final displayName = _nameController.text.trim();
      final email = widget.email;

      // 1. Обновляем профиль на сервере
      try {
        await profileRepository.updateProfile(name: displayName, email: email);
      } catch (e) {
        AppLogger.error('Error updating profile', e);
      }

      // 2. Загружаем фото, если выбрано
      if (_photoFile != null) {
        try {
          await profileRepository.uploadAvatarFile(_photoFile!);
        } catch (e) {
          AppLogger.error('Error uploading photo', e);
        }
      }

      // 3. Сохраняем локально
      final profileData = CompleteProfileData(
        displayName: displayName,
        email: email,
        photoPath: _photoPath,
      );
      await profileStorage.saveProfileData(profileData);
      await profileStorage.setProfileComplete(true);

      // 4. Получаем userId из SessionManager и сохраняем
      final sessionManager = ref.read(sessionManagerProvider);
      final userId = sessionManager.currentUserId;
      if (userId != null) {
        await profileStorage.saveUserId(userId);
      }

      if (mounted) {
        setState(() {
          _state = CompleteProfileState.success;
        });

        // Переходим на главную
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        _showError('Ошибка при сохранении: $e');
        setState(() {
          _state = CompleteProfileState.error;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = _state == CompleteProfileState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Заполните профиль'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Заголовок
                Text(
                  'Давайте познакомимся!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Заполните информацию о себе для персонализированных рекомендаций',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Фото профиля
                Center(
                  child: GestureDetector(
                    onTap: isLoading ? null : _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                          width: 2,
                        ),
                      ),
                      child:
                          _photoFile != null
                              ? Stack(
                                children: [
                                  ClipOval(
                                    child: Image.file(
                                      _photoFile!,
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                    ),
                                  ),
                                  // Кнопка удаления
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: GestureDetector(
                                      onTap: isLoading ? null : _clearPhoto,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.error,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: theme.colorScheme.surface,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: theme.colorScheme.onError,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 40,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Добавить фото',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: isLoading ? null : _pickImage,
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Выбрать из галереи'),
                ),
                const SizedBox(height: 24),

                // Email (только для просмотра)
                TextFormField(
                  initialValue: widget.email,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),

                // Имя (обязательно)
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.done,
                  autofocus:
                      widget.googleName == null || widget.googleName!.isEmpty,
                  decoration: InputDecoration(
                    labelText: 'Имя *',
                    prefixIcon: const Icon(Icons.person_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: 'Как к вам обращаться?',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите имя';
                    }
                    if (value.trim().length < 2) {
                      return 'Минимум 2 символа';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Ошибка
                if (_errorMessage != null) ...[
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
                            _errorMessage!,
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Кнопка сохранения
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : _saveProfile,
                    icon:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.check_circle_outline),
                    label: Text(
                      isLoading ? 'Сохранение...' : 'Сохранить и продолжить',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Подсказка
                Text(
                  'Вы сможете изменить эти данные в настройках профиля',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
