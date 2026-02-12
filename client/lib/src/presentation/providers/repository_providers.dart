// lib/src/presentation/providers/repository_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../../domain/repositories/achievement_repository.dart';

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://api.outfitstyle.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

// TODO: проверить конструкторы Impl классов и исправить параметры
final recommendationRepositoryProvider = Provider<RecommendationRepository>(
  (ref) => throw UnimplementedError('Fix constructor'),
);

final wardrobeRepositoryProvider = Provider<WardrobeRepository>(
  (ref) => throw UnimplementedError('Fix constructor'),
);

final achievementRepositoryProvider = Provider<AchievementRepository>(
  (ref) => throw UnimplementedError('Fix constructor'),
);
