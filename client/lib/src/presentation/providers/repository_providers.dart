// lib/src/presentation/providers/repository_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/wardrobe_item.dart';

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'http://localhost:8080',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
});

// Provider для списка WardrobeItem
final wardrobeItemProvider = StateNotifierProvider<WardrobeItemListNotifier, List<WardrobeItem>>((ref) {
  return WardrobeItemListNotifier();
});

class WardrobeItemListNotifier extends StateNotifier<List<WardrobeItem>> {
  WardrobeItemListNotifier() : super([]);

  void setItems(List<WardrobeItem> items) {
    state = items;
  }

  void addItem(WardrobeItem item) {
    state = [...state, item];
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void updateItem(WardrobeItem item) {
    state = state.map((i) => i.id == item.id ? item : i).toList();
  }
}
