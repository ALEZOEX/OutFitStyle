import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Favorite products notifier
class FavoriteNotifier extends StateNotifier<Set<String>> {
  FavoriteNotifier() : super({});

  /// Toggle favorite status
  void toggleFavorite(String productId) {
    if (state.contains(productId)) {
      state = state..remove(productId);
    } else {
      state = {...state, productId};
    }
  }

  /// Add to favorites
  void addFavorite(String productId) {
    state = {...state, productId};
  }

  /// Remove from favorites
  void removeFavorite(String productId) {
    state = state..remove(productId);
  }

  /// Check if product is favorite
  bool isFavorite(String productId) => state.contains(productId);

  /// Get favorite count
  int get count => state.length;

  /// Clear all favorites
  void clear() => state = {};
}

/// Favorite products provider
final favoriteProvider = StateNotifierProvider<FavoriteNotifier, Set<String>>((ref) {
  return FavoriteNotifier();
});

/// Favorite count provider
final favoriteCountProvider = Provider<int>((ref) {
  return ref.watch(favoriteProvider).length;
});
