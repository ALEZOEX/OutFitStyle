/// Состояние профиля
abstract class ProfileState {
  const ProfileState();
}

/// Начальное состояние
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Профиль загружен
class ProfileLoaded extends ProfileState {
  final String? userId;
  final String? email;
  final String? name;
  final String? avatarUrl;

  const ProfileLoaded({
    this.userId,
    this.email,
    this.name,
    this.avatarUrl,
  });
}

/// Ошибка загрузки профиля
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);
}
