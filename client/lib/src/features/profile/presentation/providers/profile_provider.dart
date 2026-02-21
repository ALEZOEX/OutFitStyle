import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../presentation/routing/router.dart';
import '../../../wardrobe/presentation/providers/wardrobe_provider.dart';

/// Состояние профиля пользователя
enum ProfileLoadStatus {
  initial,
  loading,
  success,
  error,
}

/// Данные профиля пользователя
class ProfileData {
  final String userId;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime? createdAt;

  const ProfileData({
    required this.userId,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.createdAt,
  });

  /// Создать из [Map<String, dynamic>]
  factory ProfileData.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw const ProfileException('Данные профиля недоступны');
    }

    // Извлекаем имя: displayName или name или email
    final name = data['display_name'] as String? ??
                 data['name'] as String? ??
                 data['email'] as String? ??
                 'Пользователь';

    // Извлекаем email
    final email = data['email'] as String? ?? '';

    // Извлекаем фото
    final photoUrl = data['photo_url'] as String? ??
                     data['avatar_url'] as String?;

    // Дата создания аккаунта
    DateTime? createdAt;
    final createdAtStr = data['created_at'] as String?;
    if (createdAtStr != null) {
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (_) {
        // Игнорируем ошибку парсинга
      }
    }

    return ProfileData(
      userId: data['id'] as String? ?? data['user_id'] as String? ?? '',
      displayName: name,
      email: email,
      photoUrl: photoUrl,
      createdAt: createdAt,
    );
  }

  /// Первая буква имени для аватара
  String get firstLetter {
    if (displayName.isEmpty) return 'U';
    return displayName[0].toUpperCase();
  }

  /// Количество дней в приложении
  int get daysInApp {
    if (createdAt == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    return difference.inDays;
  }
}

/// Статистика пользователя из гардероба
class ProfileStats {
  final int totalCount;
  final int categoriesCount;
  final int favoritesCount;

  const ProfileStats({
    required this.totalCount,
    required this.categoriesCount,
    required this.favoritesCount,
  });

  /// Создать из состояния гардероба
  factory ProfileStats.fromWardrobeState(WardrobeState state) {
    return ProfileStats(
      totalCount: state.totalCount,
      categoriesCount: state.categoryCounts.length,
      favoritesCount: state.favoritesCount,
    );
  }
}

/// Провайдер данных профиля
final profileDataProvider = StateNotifierProvider<ProfileDataNotifier, AsyncValue<ProfileData>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ProfileDataNotifier(authRepository: authRepository);
});

/// Провайдер статистики профиля
final profileStatsProvider = Provider<ProfileStats>((ref) {
  final wardrobeState = ref.watch(wardrobeProvider);
  return ProfileStats.fromWardrobeState(wardrobeState);
});

class ProfileDataNotifier extends StateNotifier<AsyncValue<ProfileData>> {
  final AuthRepository _authRepository;

  ProfileDataNotifier({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AsyncValue.loading()) {
    _loadProfile();
  }

  /// Загрузить данные профиля
  Future<void> _loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final userData = await _authRepository.getCurrentUser();
      if (userData != null) {
        final profileData = ProfileData.fromMap(userData);
        state = AsyncValue.data(profileData);
      } else {
        state = AsyncValue.error(
          ProfileException('Не удалось загрузить данные профиля'),
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(
        ProfileException('Ошибка загрузки профиля: $e'),
        st,
      );
    }
  }

  /// Обновить данные профиля
  Future<void> refresh() async {
    await _loadProfile();
  }
}

/// Исключение профиля
class ProfileException implements Exception {
  final String message;

  const ProfileException(this.message);

  @override
  String toString() => 'ProfileException: $message';
}

/// Провайдер для получения имени пользователя (displayName или email)
final userDisplayNameProvider = Provider<String>((ref) {
  final profileState = ref.watch(profileDataProvider);
  return profileState.when(
    data: (data) => data.displayName,
    loading: () => 'Загрузка...',
    error: (_, __) => 'Пользователь',
  );
});

/// Провайдер для получения email пользователя
final userEmailProvider = Provider<String>((ref) {
  final profileState = ref.watch(profileDataProvider);
  return profileState.when(
    data: (data) => data.email,
    loading: () => '',
    error: (_, __) => '',
  );
});

/// Провайдер для получения фото пользователя
final userPhotoUrlProvider = Provider<String?>((ref) {
  final profileState = ref.watch(profileDataProvider);
  return profileState.when(
    data: (data) => data.photoUrl,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Провайдер для получения первой буквы имени
final userFirstLetterProvider = Provider<String>((ref) {
  final profileState = ref.watch(profileDataProvider);
  return profileState.when(
    data: (data) => data.firstLetter,
    loading: () => 'U',
    error: (_, __) => 'U',
  );
});
