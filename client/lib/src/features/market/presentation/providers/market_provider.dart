import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../data/market_api_client.dart';
import '../data/market_repository.dart';
import '../data/models/product.dart';

/// Market API client provider
final marketApiClientProvider = Provider<MarketApiClient>((ref) {
  final authService = ref.watch(authServiceProvider);
  final client = MarketApiClient(baseUrl: 'http://localhost:8001');
  
  // Set user ID from auth
  final userId = authService.currentUserId;
  if (userId != null) {
    client.setUserId(userId);
  }
  
  return client;
});

/// Market repository provider
final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final apiClient = ref.watch(marketApiClientProvider);
  return MarketRepository(apiClient: apiClient);
});

/// Products state notifier
class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final MarketRepository _repository;

  ProductsNotifier(this._repository) : super(const AsyncValue.data([]));

  Future<void> loadProducts({
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
    state = const AsyncValue.loading();
    try {
      final products = await _repository.getProducts(
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
      state = AsyncValue.data(products);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadProduct(String productId) async {
    // For single product, we could add a separate state
    state = const AsyncValue.loading();
    try {
      final product = await _repository.getProduct(productId);
      state = AsyncValue.data([product]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Products provider
final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final repository = ref.watch(marketRepositoryProvider);
  return ProductsNotifier(repository);
});

/// Categories provider
final categoriesProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final repository = ref.watch(marketRepositoryProvider);
  return repository.getCategories();
});

/// Product detail provider
final productDetailProvider = FutureProvider<Product>((ref, String productId) async {
  final repository = ref.watch(marketRepositoryProvider);
  return repository.getProduct(productId);
});
