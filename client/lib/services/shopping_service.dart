import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/product.dart';
import '../models/shopping_item.dart';

class ShoppingService {
  final String _baseUrl;
  final http.Client _client;

  ShoppingService({
    String? baseUrl,
    http.Client? client,
  })  : _baseUrl = baseUrl ?? AppConfig.shoppingApiUrl,
        _client = client ?? http.Client();

  /// GET /wishlist?user_id={id}
  Future<List<ShoppingItem>> getShoppingWishlist({required int userId}) async {
    final uri = Uri.parse('$_baseUrl/wishlist?user_id=$userId');

    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: AppConfig.requestTimeout),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
        json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map(ShoppingItem.fromJson)
            .toList();
      } else {
        throw Exception('Failed to load wishlist: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Timeout while loading wishlist');
    } catch (e) {
      throw Exception('Error fetching wishlist: $e');
    }
  }

  /// GET /categories/{categoryId}/products
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final uri = Uri.parse('$_baseUrl/categories/$categoryId/products');

    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: AppConfig.requestTimeout),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
        json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map(Product.fromJson)
            .toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Timeout while loading products');
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  /// GET /products/search?q={query}
  Future<List<Product>> searchProducts(String query) async {
    final uri = Uri.parse('$_baseUrl/products/search?q=$query');

    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: AppConfig.requestTimeout),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
        json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map(Product.fromJson)
            .toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Timeout while searching products');
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }

  /// GET /products/{productId}
  Future<Product> getProductById(int productId) async {
    final uri = Uri.parse('$_baseUrl/products/$productId');

    try {
      final response = await _client.get(uri).timeout(
        const Duration(seconds: AppConfig.requestTimeout),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        json.decode(utf8.decode(response.bodyBytes))
        as Map<String, dynamic>;
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Timeout while loading product');
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  /// POST /recommendations
  Future<List<Product>> getProductRecommendations(
      List<int> outfitItemIds) async {
    final uri = Uri.parse('$_baseUrl/recommendations');

    try {
      final response = await _client
          .post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'outfit_item_ids': outfitItemIds}),
      )
          .timeout(
        const Duration(seconds: AppConfig.requestTimeout),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
        json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map(Product.fromJson)
            .toList();
      } else {
        throw Exception(
          'Failed to load recommendations: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw Exception('Timeout while loading recommendations');
    } catch (e) {
      throw Exception('Error fetching recommendations: $e');
    }
  }
}