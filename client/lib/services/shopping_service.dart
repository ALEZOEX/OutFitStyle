import 'dart:convert';
import '../models/product.dart';
import '../models/shopping_item.dart';
import '../config/app_config.dart';
import 'api_service.dart';

class ShoppingService {
  final ApiService _apiService = ApiService();

  /// Get user's shopping wishlist
  Future<List<ShoppingItem>> getShoppingWishlist({required int userId}) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.shoppingApiUrl}/wishlist?user_id=$userId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ShoppingItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load wishlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching wishlist: $e');
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.shoppingApiUrl}/categories/$categoryId/products',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  /// Search products by query
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.shoppingApiUrl}/products/search?q=$query',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }

  /// Get product by ID
  Future<Product> getProductById(int productId) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.shoppingApiUrl}/products/$productId',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  /// Get product recommendations
  Future<List<Product>> getProductRecommendations(
      List<int> outfitItemIds) async {
    try {
      final response = await _apiService.post(
        '${AppConfig.shoppingApiUrl}/recommendations',
        {'outfit_item_ids': outfitItemIds},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recommendations: $e');
    }
  }
}
