import 'package:dio/dio.dart';
import '../models/product.dart';
import '../models/cart.dart';
import '../models/order.dart';

/// API client for market service
class MarketApiClient {
  final Dio _dio;
  final String baseUrl;

  MarketApiClient({
    required String baseUrl,
    Dio? dio,
  })  : baseUrl = baseUrl,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {
                'Content-Type': 'application/json',
              },
            })) {
    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  /// Set user ID header
  void setUserId(int userId) {
    _dio.options.headers['X-User-Id'] = userId.toString();
  }

  /// Set auth token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // ═══════════════════════════════════════════
  // PRODUCTS
  // ═══════════════════════════════════════════

  /// Get products catalog with filters
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
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };

    if (category != null) queryParams['category'] = category;
    if (brand != null) queryParams['brand'] = brand;
    if (minPrice != null) queryParams['min_price'] = minPrice;
    if (maxPrice != null) queryParams['max_price'] = maxPrice;
    if (style != null) queryParams['style'] = style;
    if (inStock != null) queryParams['in_stock'] = inStock;
    if (search != null) queryParams['search'] = search;

    final response = await _dio.get(
      '/api/v1/market/products',
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;

    return items.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Get product by ID
  Future<Product> getProduct(String productId) async {
    final response = await _dio.get('/api/v1/market/products/$productId');
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get categories
  Future<List<Map<String, String>>> getCategories() async {
    final response = await _dio.get('/api/v1/market/products/categories');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => Map<String, String>.from(item as Map))
        .toList();
  }

  // ═══════════════════════════════════════════
  // CART
  // ═══════════════════════════════════════════

  /// Get user cart
  Future<Cart> getCart() async {
    final response = await _dio.get('/api/v1/market/cart');
    return Cart.fromJson(response.data as Map<String, dynamic>);
  }

  /// Add item to cart
  Future<Cart> addToCart(AddToCartRequest request) async {
    final response = await _dio.post(
      '/api/v1/market/cart/items',
      data: request.toJson(),
    );
    return Cart.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update cart item quantity
  Future<Cart> updateCartItem(
    String productId, {
    String? size,
    String? color,
    required int quantity,
  }) async {
    final response = await _dio.patch(
      '/api/v1/market/cart/items/$productId',
      data: {'quantity': quantity},
    );
    return Cart.fromJson(response.data as Map<String, dynamic>);
  }

  /// Remove item from cart
  Future<Cart> removeFromCart(
    String productId, {
    String? size,
    String? color,
  }) async {
    final response = await _dio.delete(
      '/api/v1/market/cart/items/$productId',
      queryParameters: {
        if (size != null) 'size': size,
        if (color != null) 'color': color,
      },
    );
    return Cart.fromJson(response.data as Map<String, dynamic>);
  }

  /// Clear cart
  Future<void> clearCart() async {
    await _dio.delete('/api/v1/market/cart');
  }

  // ═══════════════════════════════════════════
  // ORDERS
  // ═══════════════════════════════════════════

  /// Create order from cart
  Future<Order> createOrder(CreateOrderRequest request) async {
    final response = await _dio.post(
      '/api/v1/market/orders',
      data: request.toJson(),
    );
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get user orders
  Future<List<Order>> getOrders({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (status != null) 'status': status,
    };

    final response = await _dio.get(
      '/api/v1/market/orders',
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;

    return items.map((item) => Order.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Get order by ID
  Future<Order> getOrder(String orderId) async {
    final response = await _dio.get('/api/v1/market/orders/$orderId');
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  /// Cancel order
  Future<Order> cancelOrder(String orderId) async {
    final response = await _dio.post('/api/v1/market/orders/$orderId/cancel');
    return Order.fromJson(response.data as Map<String, dynamic>);
  }

  // ═══════════════════════════════════════════
  // RECOMMENDATIONS
  // ═══════════════════════════════════════════

  /// Get product recommendations
  Future<List<Product>> getRecommendations({
    int limit = 10,
    double? temperature,
    double? humidity,
    String? weatherCondition,
    String? style,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (temperature != null) 'temperature': temperature,
      if (humidity != null) 'humidity': humidity,
      if (weatherCondition != null) 'weather_condition': weatherCondition,
      if (style != null) 'style': style,
    };

    final response = await _dio.get(
      '/api/v1/market/recommendations',
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    final recommendations = data['recommendations'] as List<dynamic>;

    return recommendations
        .map((rec) => Product.fromJson((rec as Map<String, dynamic>)['product'] as Map<String, dynamic>))
        .toList();
  }

  /// Get similar products
  Future<List<Product>> getSimilarProducts(
    String productId, {
    int limit = 5,
  }) async {
    final response = await _dio.get(
      '/api/v1/market/recommendations/similar/$productId',
      queryParameters: {'limit': limit},
    );

    final data = response.data as List<dynamic>;
    return data.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
  }

  // ═══════════════════════════════════════════
  // PRODUCT IMPORT
  // ═══════════════════════════════════════════

  /// Import product from marketplace URL (WB/Ozon)
  /// Returns a map with status, product, message, and remaining_imports
  Future<Map<String, dynamic>> importProductFromUrl(String url) async {
    final response = await _dio.post(
      '/api/v1/market/products/import',
      data: {'url': url},
    );

    return Map<String, dynamic>.from(response.data);
  }
}
