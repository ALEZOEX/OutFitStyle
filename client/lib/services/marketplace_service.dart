import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class MarketplaceLink {
  final String marketplace;
  final String name;
  final String icon;
  final String url;
  final String commission;

  MarketplaceLink({
    required this.marketplace,
    required this.name,
    required this.icon,
    required this.url,
    required this.commission,
  });

  factory MarketplaceLink.fromJson(Map<String, dynamic> json) {
    return MarketplaceLink(
      marketplace: json['marketplace'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      url: json['url'] ?? '',
      commission: json['commission'] ?? '',
    );
  }
}

class MarketplaceService {
  final String baseUrl = AppConfig.marketplaceServiceUrl;

  Future<List<MarketplaceLink>> getLinksForItem({
    required String itemName,
    required String category,
    String? subcategory,
    String marketplace = 'all',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/match'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'item_name': itemName,
          'category': category,
          'subcategory': subcategory,
          'marketplace': marketplace,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final links = data['links'] as List;
        return links.map((link) => MarketplaceLink.fromJson(link)).toList();
      }
      return [];
    } catch (e) {
      //print('Error getting marketplace links: $e');
      // In production, use a proper logging framework instead
      return [];
    }
  }

  Future<Map<String, List<MarketplaceLink>>> getLinksForOutfit(
    List<Map<String, dynamic>> items, {
    String marketplace = 'all',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/outfit/links'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'items': items,
          'marketplace': marketplace,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final outfitLinks = data['outfit_links'] as List;

        Map<String, List<MarketplaceLink>> result = {};

        for (var item in outfitLinks) {
          final itemName = item['item_name'];
          final links = (item['links'] as List)
              .map((link) => MarketplaceLink.fromJson(link))
              .toList();
          result[itemName] = links;
        }

        return result;
      }
      return {};
    } catch (e) {
      //print('Error getting outfit links: $e');
      // In production, use a proper logging framework instead
      return {};
    }
  }

  Future<void> trackClick({
    required int userId,
    required String itemName,
    required String marketplace,
    required String category,
  }) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/api/affiliate/track'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'item_name': itemName,
          'marketplace': marketplace,
          'category': category,
        }),
      );
    } catch (e) {
      //print('Error tracking click: $e');
      // In production, use a proper logging framework instead
    }
  }
}