import 'package:dartz/dartz.dart';
import '../entities/clothing_item.dart';
import '../entities/outfit.dart';
import '../enums/clothing_category.dart';
import '../enums/clothing_season.dart';
import '../enums/clothing_weather.dart';
import '../enums/outfit_occasion.dart';
import '../enums/outfit_weather.dart';
import '../enums/outfit_season.dart';

abstract class WardrobeRepository {
  Future<Either<String, List<ClothingItem>>> getClothingItems({
    List<ClothingCategory>? categories,
    List<ClothingSeason>? seasons,
    List<ClothingWeather>? weatherConditions,
  });

  Future<Either<String, ClothingItem>> addClothingItem(ClothingItem item);

  Future<Either<String, ClothingItem>> updateClothingItem(ClothingItem item);

  Future<Either<String, void>> deleteClothingItem(int id);

  Future<Either<String, List<Outfit>>> getOutfits({
    List<OutfitOccasion>? occasions,
    List<OutfitWeather>? weatherConditions,
    List<OutfitSeason>? seasons,
  });

  Future<Either<String, Outfit>> createOutfit(Outfit outfit);

  Future<Either<String, Outfit>> updateOutfit(Outfit outfit);

  Future<Either<String, void>> deleteOutfit(int id);
}
