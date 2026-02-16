import '../entities/outfit_recommendation.dart';
import '../repositories/i_recommendations_repository.dart';

abstract class GetRecommendationsByUserUsecase {
  Future<List<OutfitRecommendation>> call(String userId);
}

class GetRecommendationsByUserUsecaseImpl implements GetRecommendationsByUserUsecase {
  final IRecommendationsRepository _repository;

  GetRecommendationsByUserUsecaseImpl(this._repository);

  @override
  Future<List<OutfitRecommendation>> call(String userId) async {
    return await _repository.getUserRecommendations(userId);
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
  Future<void> call(OutfitRecommendation recommendation);
}

class SaveRecommendationUsecaseImpl implements SaveRecommendationUsecase {
  final IRecommendationsRepository _repository;

  SaveRecommendationUsecaseImpl(this._repository);

  @override
  Future<void> call(OutfitRecommendation recommendation) async {
    return await _repository.saveRecommendation(recommendation);
  }
}

abstract class UpdateRecommendationUsecase {
  Future<void> call(OutfitRecommendation recommendation);
}

class UpdateRecommendationUsecaseImpl implements UpdateRecommendationUsecase {
  final IRecommendationsRepository _repository;

  UpdateRecommendationUsecaseImpl(this._repository);

  @override
  Future<void> call(OutfitRecommendation recommendation) async {
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