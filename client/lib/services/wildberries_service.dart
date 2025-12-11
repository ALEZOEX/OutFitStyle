import'dart:convert';
import 'package:http/http.dart' as http;

class WildberriesProduct {
  final int id;
  final String name;
  final String brand;
  final int price;
  final int salePrice;
  final String imageUrl;
  final double rating;
  final int feedbackCount;
  final String url;

  WildberriesProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.salePrice,
    required this.imageUrl,
    required this.rating,
    required this.feedbackCount,
    required this.url,
  });

  factory WildberriesProduct.fromJson(Map<String, dynamic> json) {
    return WildberriesProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      price: json['price'] ?? 0,
      salePrice: json['salePrice'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      feedbackCount: json['feedbacks'] ?? 0,
      url: json['url'] ?? '',
    );
  }
}

class WildberriesService {
  static const String _baseUrl= 'https://search.wb.ru';
  
  // Search for products on Wildberries
  Future<List<WildberriesProduct>> searchProducts({
    required String query,
    int limit = 20,
  }) async {
    try {
      // This is a simplified example - in reality, you would need touse
      // the actual Wildberries API or scrape the data
      final url = Uri.parse(
          '$_baseUrl/exactmatch/ru/common/v4/search?appType=1&couponsGeo=12,3,18,15,21&dest=-1029256,-102269,-1278703,-1255563&emp=0&lang=ru&limit=$limit&listType=1&locale=ru&pricemarginCoeff=1.0&query=$query&reg=0&regions=68,64,83,4,38,80,33,70,82,86,75,30,69,22,66,31,40,1,48&resultset=catalog&sort=popular&spp=0&suppressSpellcheck=false');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['data']['products'] as List;
        return products
            .map((product)=> WildberriesProduct.fromJson(product))
            .toList();
      }
      return [];
    } catch (e) {
      //print('Error searching Wildberries products: $e');
      // In production, use a proper logging framework instead
      return [];
    }
  }

 // Get product details by ID
  Future<WildberriesProduct?> getProductDetails(int productId) async {
    try {
      // This is a simplified example - in reality, you would need to use
      // the actual Wildberries API or scrape the data
      final url = Uri.parse('https://card.wb.ru/cards/detail?appType=1&curr=rub&dest=-1257786&spp=30&nm=$productId');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['data']['products'] as List?;
        if (products != null && products.isNotEmpty) {
          final productData = products[0];
          return WildberriesProduct.fromJson(productData);
        }
        return null;
      }
      return null;
    } catch (e) {
      //print('Error getting Wildberries product details: $e');
      // In production, use a proper logging framework instead
      return null;
    }
  }
}