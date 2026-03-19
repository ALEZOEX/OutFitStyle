import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/src/features/market/data/market_repository.dart';
import 'package:outfitstyle_client/src/features/market/data/models/cart.dart';
import 'package:outfitstyle_client/src/features/market/presentation/providers/market_provider.dart';

/// Cart state notifier
class CartNotifier extends StateNotifier<AsyncValue<Cart>> {
  final MarketRepository _repository;

  CartNotifier(this._repository)
    : super(
        AsyncValue.data(
          Cart(userId: 0, items: [], totalAmount: 0, updatedAt: DateTime.now()),
        ),
      );

  /// Set user ID for cart operations
  void setUserId(int userId) {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(userId: userId));
    }
  }

  /// Load cart from server
  Future<void> loadCart() async {
    state = const AsyncValue.loading();
    try {
      final cart = await _repository.getCart();
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add item to cart
  Future<void> addToCart(AddToCartRequest request) async {
    try {
      final cart = await _repository.addToCart(request);
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update cart item quantity
  Future<void> updateItemQuantity(
    String productId, {
    String? size,
    String? color,
    required int quantity,
  }) async {
    try {
      final cart = await _repository.updateCartItem(
        productId,
        size: size,
        color: color,
        quantity: quantity,
      );
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Remove item from cart
  Future<void> removeItem(
    String productId, {
    String? size,
    String? color,
  }) async {
    try {
      final cart = await _repository.removeFromCart(
        productId,
        size: size,
        color: color,
      );
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Clear cart
  Future<void> clear() async {
    try {
      await _repository.clearCart();
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(items: [], totalAmount: 0),
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Get cart item count
  int get itemCount => state.value?.itemCount ?? 0;

  /// Get cart total
  double get totalAmount => state.value?.totalAmount ?? 0;

  /// Check if cart is empty
  bool get isEmpty => state.value?.isEmpty ?? true;
}

/// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<Cart>>((
  ref,
) {
  final repository = ref.watch(marketRepositoryProvider);
  return CartNotifier(repository);
});

/// Cart item count provider
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.value?.itemCount ?? 0;
});

/// Cart total provider
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.value?.totalAmount ?? 0;
});
