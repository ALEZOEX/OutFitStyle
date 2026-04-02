/// Состояние гардероба
abstract class WardrobeState {
  const WardrobeState();
}

/// Начальное состояние
class WardrobeInitial extends WardrobeState {
  const WardrobeInitial();
}

/// Гардероб загружен
class WardrobeLoaded extends WardrobeState {
  final List<dynamic> items;

  const WardrobeLoaded(this.items);
}

/// Ошибка загрузки гардероба
class WardrobeError extends WardrobeState {
  final String message;

  const WardrobeError(this.message);
}
