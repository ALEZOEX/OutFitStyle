/// Extension methods to enhance Dart collections
extension ListExtensions<T> on List<T> {
  /// Returns the first element that satisfies the given predicate or null if none found
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}