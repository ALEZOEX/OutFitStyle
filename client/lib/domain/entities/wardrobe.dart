import 'package:equatable/equatable.dart';

/// Unified WardrobeItem domain entity following Clean Architecture principles
/// This represents the core business entity for wardrobe items
class WardrobeItem extends Equatable {
  final String id;
  final String? serverId; // Server identifier for sync purposes
  final String userId;
  final String clothingItemId; // References the clothing catalog item

  // User-customizable fields
  final String? customName;
  final String? notes;
  final List<String> tags;
  
  // Purchase information
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String? purchaseCurrency;
  
  // Usage tracking
  final int wearCount;
  final DateTime? lastWornAt;
  
  // Status flags
  final bool isFavorite;
  final bool isArchived;
  final String condition; // e.g., "excellent", "good", "fair", "poor"
  
  // Weather/resistance properties
  final bool rainOk;
  final bool snowOk;
  final bool windOk;
  final int? minTemp; // Minimum comfortable temperature in Celsius
  final int? maxTemp; // Maximum comfortable temperature in Celsius
  final int? warmthLevel; // Warmth level from 1-5
  
  // Category and style info (copied from clothing item but customizable)
  final String name;
  final String category;
  final String subcategory;
  final String style;
  final String? iconEmoji;
  final String? imageUrl;
  final String? blurHash;
  final String? usage; // e.g., "casual", "formal", "sport"
  final String? materials;
  final String? season; // e.g., "summer", "winter", "spring", "fall", "all"
  final String? gender; // e.g., "male", "female", "unisex"
  final String? fit; // e.g., "tight", "regular", "loose"
  final String? pattern; // e.g., "solid", "striped", "floral"
  final String? localImagePath;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool dirty; // For sync purposes

  const WardrobeItem({
    required this.id,
    this.serverId,
    required this.userId,
    required this.clothingItemId,
    this.customName,
    this.notes,
    required this.tags,
    this.purchaseDate,
    this.purchasePrice,
    this.purchaseCurrency,
    required this.wearCount,
    this.lastWornAt,
    required this.isFavorite,
    required this.isArchived,
    required this.condition,
    required this.rainOk,
    required this.snowOk,
    required this.windOk,
    this.minTemp,
    this.maxTemp,
    this.warmthLevel,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.style,
    this.iconEmoji,
    this.imageUrl,
    this.blurHash,
    this.usage,
    this.materials,
    this.season,
    this.gender,
    this.fit,
    this.pattern,
    this.localImagePath,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    required this.dirty,
  });

  @override
  List<Object?> get props => [
        id,
        serverId,
        userId,
        clothingItemId,
        customName,
        notes,
        tags,
        purchaseDate,
        purchasePrice,
        purchaseCurrency,
        wearCount,
        lastWornAt,
        isFavorite,
        isArchived,
        condition,
        rainOk,
        snowOk,
        windOk,
        minTemp,
        maxTemp,
        warmthLevel,
        name,
        category,
        subcategory,
        style,
        iconEmoji,
        imageUrl,
        blurHash,
        usage,
        materials,
        season,
        gender,
        fit,
        pattern,
        localImagePath,
        createdAt,
        updatedAt,
        lastSyncedAt,
        dirty,
      ];

  WardrobeItem copyWith({
    String? id,
    String? serverId,
    String? userId,
    String? clothingItemId,
    String? customName,
    String? notes,
    List<String>? tags,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? purchaseCurrency,
    int? wearCount,
    DateTime? lastWornAt,
    bool? isFavorite,
    bool? isArchived,
    String? condition,
    bool? rainOk,
    bool? snowOk,
    bool? windOk,
    int? minTemp,
    int? maxTemp,
    int? warmthLevel,
    String? name,
    String? category,
    String? subcategory,
    String? style,
    String? iconEmoji,
    String? imageUrl,
    String? blurHash,
    String? usage,
    String? materials,
    String? season,
    String? gender,
    String? fit,
    String? pattern,
    String? localImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? dirty,
  }) {
    return WardrobeItem(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      userId: userId ?? this.userId,
      clothingItemId: clothingItemId ?? this.clothingItemId,
      customName: customName ?? this.customName,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseCurrency: purchaseCurrency ?? this.purchaseCurrency,
      wearCount: wearCount ?? this.wearCount,
      lastWornAt: lastWornAt ?? this.lastWornAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      condition: condition ?? this.condition,
      rainOk: rainOk ?? this.rainOk,
      snowOk: snowOk ?? this.snowOk,
      windOk: windOk ?? this.windOk,
      minTemp: minTemp ?? this.minTemp,
      maxTemp: maxTemp ?? this.maxTemp,
      warmthLevel: warmthLevel ?? this.warmthLevel,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      style: style ?? this.style,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      imageUrl: imageUrl ?? this.imageUrl,
      blurHash: blurHash ?? this.blurHash,
      usage: usage ?? this.usage,
      materials: materials ?? this.materials,
      season: season ?? this.season,
      gender: gender ?? this.gender,
      fit: fit ?? this.fit,
      pattern: pattern ?? this.pattern,
      localImagePath: localImagePath ?? this.localImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      dirty: dirty ?? this.dirty,
    );
  }

  // Business logic methods
  bool fitsWeather(double temperature, String weatherCondition) {
    final tempInRange =
        (minTemp == null || temperature >= minTemp!) &&
        (maxTemp == null || temperature <= maxTemp!);

    final weatherOk =
        (weatherCondition.toLowerCase().contains('rain') ? rainOk : true) &&
        (weatherCondition.toLowerCase().contains('snow') ? snowOk : true) &&
        (weatherCondition.toLowerCase().contains('wind') ? windOk : true);

    return tempInRange && weatherOk;
  }

  bool isSuitableForSeason(String season) {
    return this.season?.toLowerCase() == season.toLowerCase() || 
           this.season?.toLowerCase() == 'all';
  }

  bool isRecentAddition([int days = 7]) {
    final cutoffDate = DateTime.now().subtract(const Duration(days: days));
    return createdAt.isAfter(cutoffDate);
  }

  double get wearFrequency {
    final daysSinceAdded = DateTime.now().difference(createdAt).inDays;
    if (daysSinceAdded <= 0) return 0.0;
    return wearCount / daysSinceAdded;
  }

  bool needsAttention() {
    return condition == 'poor' || needsRepair;
  }

  bool get needsRepair => condition == 'poor';
}