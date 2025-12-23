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
  final String message;
  const AsyncError(this.message);
}

class AsyncSuccess<T> extends AsyncState<T> {
  final T data;
  const AsyncSuccess(this.data);
}