import 'package:outfitstyle_client/domain/entities/outfit_recommendation.dart';
import 'package:outfitstyle_client/domain/repositories/i_recommendations_repository.dart';

abstract class GetRecommendationsByUserUsecase {
  Future<List<OutfitRecommendation>> call(String userId, {DateTime? fromDate, DateTime? toDate});
}

class GetRecommendationsByUserUsecaseImpl implements GetRecommendationsByUserUsecase {
  final IRecommendationsRepository _repository;

  GetRecommendationsByUserUsecaseImpl(this._repository);

  @override
  Future<List<OutfitRecommendation>> call(String userId, {DateTime? fromDate, DateTime? toDate}) async {
    return await _repository.getRecommendationsByUser(userId, fromDate: fromDate, toDate: toDate);
  }
}

abstract class GetRecommendationByIdUsecase {
  Future<OutfitRecommendation?> call(String id);
}

class GetRecommendationByIdUsecaseImpl implements GetRecommendationByIdUsecase {
  final IRecommendationsRepository _repository;

  GetRecommendationByIdUsecaseImpl(this._repository);

  @override
  Future<OutfitRecommendation?> call(String id) async {
    return await _repository.getRecommendationById(id);
  }
}

abstract class SaveRecommendationUsecase {
  Future<OutfitRecommendation> call(OutfitRecommendation recommendation);
}

class SaveRecommendationUsecaseImpl implements SaveRecommendationUsecase {
  final IRecommendationsRepository _repository;

  SaveRecommendationUsecaseImpl(this._repository);

  @override
  Future<OutfitRecommendation> call(OutfitRecommendation recommendation) async {
    return await _repository.saveRecommendation(recommendation);
  }
}

abstract class UpdateRecommendationUsecase {
  Future<OutfitRecommendation> call(OutfitRecommendation recommendation);
}

class UpdateRecommendationUsecaseImpl implements UpdateRecommendationUsecase {
  final IRecommendationsRepository _repository;

  UpdateRecommendationUsecaseImpl(this._repository);

  @override
  Future<OutfitRecommendation> call(OutfitRecommendation recommendation) async {
    return await _repository.updateRecommendation(recommendation);
  }
}

abstract class DeleteRecommendationUsecase {
  Future<void> call(String id);
}

class DeleteRecommendationUsecaseImpl implements DeleteRecommendationUsecase {
  final IRecommendationsRepository _repository;

  DeleteRecommendationUsecaseImpl(this._repository);

  @override
  Future<void> call(String id) async {
    return await _repository.deleteRecommendation(id);
  }
}

abstract class RateRecommendationUsecase {
  Future<void> call(String id, double rating);
}

class RateRecommendationUsecaseImpl implements RateRecommendationUsecase {
  final IRecommendationsRepository _repository;

  RateRecommendationUsecaseImpl(this._repository);

  @override
  Future<void> call(String id, double rating) async {
    return await _repository.rateRecommendation(id, rating);
  }
}

abstract class GetRecommendationsHistoryUsecase {
  Future<List<OutfitRecommendation>> call(String userId);
}

class GetRecommendationsHistoryUsecaseImpl implements GetRecommendationsHistoryUsecase {
  final IRecommendationsRepository _repository;

  GetRecommendationsHistoryUsecaseImpl(this._repository);

  @override
  Future<List<OutfitRecommendation>> call(String userId) async {
    return await _repository.getRecommendationsHistory(userId);
  }
}

abstract class GenerateRecommendationUsecase {
  Future<OutfitRecommendation> call({
    required List<String> excludedItems,
    required double latitude,
    required double longitude,
    required String occasion,
    required List<String> preferredStyles,
    required String userId,
  });
}

class GenerateRecommendationUsecaseImpl implements GenerateRecommendationUsecase {
  final IRecommendationsRepository _repository;

  GenerateRecommendationUsecaseImpl(this._repository);

  @override
  Future<OutfitRecommendation> call({
    required List<String> excludedItems,
    required double latitude,
    required double longitude,
    required String occasion,
    required List<String> preferredStyles,
    required String userId,
  }) async {
    return await _repository.generateRecommendation(
      excludedItems: excludedItems,
      latitude: latitude,
      longitude: longitude,
      occasion: occasion,
      preferredStyles: preferredStyles,
      userId: userId,
    );
  }
}

abstract class GetMatchingItemsForRecommendationUsecase {
  Future<OutfitRecommendation> call({
    required String occasion,
    required double temperature,
    required String weatherCondition,
    required String userId,
  });
}

class GetMatchingItemsForRecommendationUsecaseImpl implements GetMatchingItemsForRecommendationUsecase {
  final IRecommendationsRepository _repository;

  GetMatchingItemsForRecommendationUsecaseImpl(this._repository);

  @override
  Future<OutfitRecommendation> call({
    required String occasion,
    required double temperature,
    required String weatherCondition,
    required String userId,
  }) async {
    return await _repository.getMatchingItemsForRecommendation(
      occasion: occasion,
      temperature: temperature,
      weatherCondition: weatherCondition,
      userId: userId,
    );
  }
}