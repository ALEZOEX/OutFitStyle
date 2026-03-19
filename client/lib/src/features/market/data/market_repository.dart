import 'package:flutter/foundation.dart';
import 'market_api_client.dart';
import 'models/product.dart';
import 'models/cart.dart';
import 'models/order.dart';

/// Repository for market data
class MarketRepository {
  final MarketApiClient _apiClient;

  MarketRepository({required MarketApiClient apiClient})
    : _apiClient = apiClient;

  // ═══════════════════════════════════════════
  // PRODUCTS
  // ═══════════════════════════════════════════

  Future<List<Product>> getProducts({
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    String? style,
    bool? inStock,
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    try {
      return await _apiClient.getProducts(
        category: category,
        brand: brand,
        minPrice: minPrice,
        maxPrice: maxPrice,
        style: style,
        inStock: inStock,
        page: page,
        pageSize: pageSize,
        search: search,
      );
    } catch (e) {
      debugPrint('Error getting products: $e');
      rethrow;
    }
  }

  Future<Product> getProduct(String productId) async {
    try {
      return await _apiClient.getProduct(productId);
    } catch (e) {
      debugPrint('Error getting product: $e');
      rethrow;
    }
  }

  Future<List<Map<String, String>>> getCategories() async {
    try {
      return await _apiClient.getCategories();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════
  // CART
  // ═══════════════════════════════════════════

  Future<Cart> getCart() async {
    try {
      return await _apiClient.getCart();
    } catch (e) {
      debugPrint('Error getting cart: $e');
      rethrow;
    }
  }

  Future<Cart> addToCart(AddToCartRequest request) async {
    try {
      return await _apiClient.addToCart(request);
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<Cart> updateCartItem(
    String productId, {
    String? size,
    String? color,
    required int quantity,
  }) async {
    try {
      return await _apiClient.updateCartItem(
        productId,
        size: size,
        color: color,
        quantity: quantity,
      );
    } catch (e) {
      debugPrint('Error updating cart item: $e');
      rethrow;
    }
  }

  Future<Cart> removeFromCart(
    String productId, {
    String? size,
    String? color,
  }) async {
    try {
      return await _apiClient.removeFromCart(
        productId,
        size: size,
        color: color,
      );
    } catch (e) {
      debugPrint('Error removing from cart: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await _apiClient.clearCart();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════
  // ORDERS
  // ═══════════════════════════════════════════

  Future<Order> createOrder(CreateOrderRequest request) async {
    try {
      return await _apiClient.createOrder(request);
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  Future<List<Order>> getOrders({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await _apiClient.getOrders(
        status: status,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      debugPrint('Error getting orders: $e');
      rethrow;
    }
  }

  Future<Order> getOrder(String orderId) async {
    try {
      return await _apiClient.getOrder(orderId);
    } catch (e) {
      debugPrint('Error getting order: $e');
      rethrow;
    }
  }

  Future<Order> cancelOrder(String orderId) async {
    try {
      return await _apiClient.cancelOrder(orderId);
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════
  // RECOMMENDATIONS
  // ═══════════════════════════════════════════

  Future<List<Product>> getRecommendations({
    int limit = 10,
    double? temperature,
    double? humidity,
    String? weatherCondition,
    String? style,
  }) async {
    try {
      return await _apiClient.getRecommendations(
        limit: limit,
        temperature: temperature,
        humidity: humidity,
        weatherCondition: weatherCondition,
        style: style,
      );
    } catch (e) {
      debugPrint('Error getting recommendations: $e');
      rethrow;
    }
  }

  Future<List<Product>> getSimilarProducts(
    String productId, {
    int limit = 5,
  }) async {
    try {
      return await _apiClient.getSimilarProducts(productId, limit: limit);
    } catch (e) {
      debugPrint('Error getting similar products: $e');
      rethrow;
    }
  }
}
