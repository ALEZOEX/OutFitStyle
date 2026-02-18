import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../services/auth_storage.dart';
import '../../data/repositories/wardrobe_repository.dart';

/// Провайдер для WardrobeRepository
final _authStorageProvider = Provider<AuthStorage>((ref) {
  throw UnimplementedError('AuthStorage должен быть предоставлен');
});

final _apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(_authStorageProvider);
  return ApiClient(storage: storage);
});

/// Провайдер репозитория гардероба
final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  final apiClient = ref.watch(_apiClientProvider);
  return WardrobeRepository(apiClient: apiClient);
});

/// Провайдер для загрузки элементов гардероба
final wardrobeItemsProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(wardrobeRepositoryProvider);
  return repository.getWardrobeItems();
});

/// Провайдер для загрузки элемента по ID
final wardrobeItemProvider = FutureProvider.autoDispose.family<WardrobeItem, String>((ref, id) async {
  final repository = ref.watch(wardrobeRepositoryProvider);
  return repository.getWardrobeItem(id);
});
