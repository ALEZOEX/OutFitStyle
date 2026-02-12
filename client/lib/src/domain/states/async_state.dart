// УСТАРЕЛО: Этот файл содержит пользовательские типы AsyncState, которые были заменены
// на стандартные AsyncValue из flutter_riverpod.
// Не используйте эти типы в новых компонентах.
// Они остаются здесь только для обеспечения обратной совместимости до полного перехода.

sealed class AsyncState<T> {
  const AsyncState();
}

class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();
}

class AsyncEmpty<T> extends AsyncState<T> {
  const AsyncEmpty();
}

class AsyncError<T> extends AsyncState<T> {
  final String? message;
  const AsyncError([this.message]);
}

class AsyncData<T> extends AsyncState<T> {
  final T value;
  const AsyncData(this.value);
}

class AsyncSuccess<T> extends AsyncState<T> {
  final T data;
  const AsyncSuccess(this.data);
}

class AsyncIdle<T> extends AsyncState<T> {
  const AsyncIdle();
}

extension AsyncStateX<T> on AsyncState<T> {
  bool get isLoading => this is AsyncLoading<T>;
  bool get isEmpty => this is AsyncEmpty<T>;
  bool get isError => this is AsyncError<T>;
  bool get isData => this is AsyncData<T>;
  bool get isSuccess => this is AsyncSuccess<T>;

  T? get dataOrNull {
    if (this is AsyncData<T>) {
      return (this as AsyncData<T>).value;
    }
    if (this is AsyncSuccess<T>) {
      return (this as AsyncSuccess<T>).data;
    }
    return null;
  }

  String? get errorOrNull {
    if (this is AsyncError<T>) {
      return (this as AsyncError<T>).message;
    }
    return null;
  }
}
