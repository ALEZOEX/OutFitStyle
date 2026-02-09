import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// DAO imports
part 'app_database.g.dart';

LazyDatabase connect() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'outfitstyle_db.sqlite'));
    return VmDatabase(file, logStatements: true);
  });
}

@DriftDatabase(
  tables: [
    Users,
    WardrobeItems,
    WeatherData,
    OutfitRecommendations,
    AppSettings,
    Achievements,
    AchievementProgress,
    SubscriptionPlans,
    UserSubscriptions,
    PaymentMethods,
    Purchases,
    SyncOutbox,
    Settings,
  ],
  daos: [
    UserDAO,
    WardrobeDAO,
    WeatherDAO,
    RecommendationsDAO,
    SettingsDAO,
    AchievementsDAO,
    MonetizationDAO,
    SyncDAO,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connect());

  @override
  int get schemaVersion => 1;
}

// Таблицы
@DataClassName('User')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get bio => text().nullable()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get occupation => text().nullable()();
  TextColumn get company => text().nullable()();
  TextColumn get website => text().nullable()();
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();
  TextColumn get subscriptionStatus => text().nullable()();
  DateTimeColumn get joinedAt => dateTime()();
  DateTimeColumn get lastActiveAt => dateTime().nullable()();
  TextColumn get preferences => text().map(const JsonTypeConverter<Map<String, dynamic>>())();
  TextColumn get interests => text().map(const JsonTypeConverter<List<String>>())();
  TextColumn get profileVisibility => text().withDefault(const Constant('public'))();
  TextColumn get notificationSettings => text().nullable()();
  TextColumn get privacySettings => text().nullable()();
  TextColumn get socialLinks => text().nullable()();
  TextColumn get referralCode => text().nullable()();
  IntColumn get points => integer().withDefault(const Constant(0))();
  TextColumn get level => text().withDefault(const Constant('beginner'))();
  TextColumn get status => text().withDefault(const Constant('active'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WardrobeDbEntity')
class WardrobeItems extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get clothingItemId => text()();
  TextColumn get customName => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get tags => text().map(const JsonTypeConverter<List<String>>())();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  RealColumn get purchasePrice => real().nullable()();
  TextColumn get purchaseCurrency => text().nullable()();
  IntColumn get wearCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastWornAt => dateTime().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get condition => text().withDefault(const Constant('good'))();
  BoolColumn get rainOk => boolean().withDefault(const Constant(false))();
  BoolColumn get snowOk => boolean().withDefault(const Constant(false))();
  BoolColumn get windOk => boolean().withDefault(const Constant(false))();
  IntColumn get minTemp => integer().nullable()();
  IntColumn get maxTemp => integer().nullable()();
  IntColumn get warmthLevel => integer().nullable()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get subcategory => text()();
  TextColumn get style => text()();
  TextColumn get iconEmoji => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get blurHash => text().nullable()();
  TextColumn get usage => text().nullable()();
  TextColumn get materials => text().nullable()();
  TextColumn get season => text().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get fit => text().nullable()();
  TextColumn get pattern => text().nullable()();
  TextColumn get localImagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WeatherDatum')
class WeatherData extends Table {
  TextColumn get id => text()();
  RealColumn get temperature => real()();
  RealColumn get feelsLike => real()();
  IntColumn get humidity => integer()();
  RealColumn get windSpeed => real()();
  TextColumn get weatherCondition => text()();
  TextColumn get description => text()();
  RealColumn get pressure => real()();
  RealColumn get visibility => real()();
  RealColumn get uvIndex => real()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get minTemperature => real()();
  RealColumn get maxTemperature => real()();
  TextColumn get locationName => text()();
  TextColumn get userId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OutfitRecommendation')
class OutfitRecommendations extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get occasion => text()();
  TextColumn get items => text().map(const JsonTypeConverter<List<Map<String, dynamic>>>())();
  RealColumn get confidenceScore => real()();
  TextColumn get metadata => text().map(const JsonTypeConverter<Map<String, dynamic>>())();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get temperatureRange => text().map(const JsonTypeConverter<List<double>>())();
  TextColumn get weatherCondition => text()();
  TextColumn get season => text()();
  TextColumn get style => text()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get id => text().withDefault(const Constant('app_settings'))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get locationEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get analyticsEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get darkMode => boolean().withDefault(const Constant(false))();
  TextColumn get temperatureUnit => text().withDefault(const Constant('celsius'))();
  TextColumn get distanceUnit => text().withDefault(const Constant('metric'))();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  TextColumn get language => text().withDefault(const Constant('en'))();
  BoolColumn get autoSync => boolean().withDefault(const Constant(true))();
  IntColumn get syncInterval => integer().withDefault(const Constant(30))();
  BoolColumn get premiumFeatures => boolean().withDefault(const Constant(false))();
  TextColumn get theme => text().withDefault(const Constant('light'))();
  BoolColumn get hapticFeedback => boolean().withDefault(const Constant(true))();
  BoolColumn get soundEffects => boolean().withDefault(const Constant(true))();
  TextColumn get lastSync => text().nullable()();
  BoolColumn get showWeatherOnHome => boolean().withDefault(const Constant(true))();
  BoolColumn get showRecommendationsOnHome => boolean().withDefault(const Constant(true))();
  BoolColumn get autoRefreshWeather => boolean().withDefault(const Constant(true))();
  IntColumn get weatherRefreshInterval => integer().withDefault(const Constant(60))();
  BoolColumn get enableOfflineMode => boolean().withDefault(const Constant(false))();
  BoolColumn get allowPersonalizedAds => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Achievement')
class Achievements extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get icon => text()();
  TextColumn get category => text()();
  IntColumn get points => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  IntColumn get target => integer()();
  TextColumn get reward => text().nullable()();
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get userId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AchievementProgres')
class AchievementProgress extends Table {
  TextColumn get achievementId => text()();
  TextColumn get userId => text()();
  IntColumn get currentProgress => integer().withDefault(const Constant(0))();
  IntColumn get targetProgress => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {achievementId, userId};
}

@DataClassName('SubscriptionPlan')
class SubscriptionPlans extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get priceMonthly => real()();
  RealColumn get priceYearly => real()();
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();
  TextColumn get billingCycle => text()();
  TextColumn get features => text().map(const JsonTypeConverter<List<String>>())();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserSubscription')
class UserSubscriptions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get planId => text()();
  TextColumn get status => text().withDefault(const Constant('inactive'))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  BoolColumn get isAutoRenew => boolean().withDefault(const Constant(true))();
  TextColumn get paymentMethod => text().nullable()();
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PaymentMethod')
class PaymentMethods extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()();
  TextColumn get cardNumber => text().nullable()();
  TextColumn get expiryDate => text().nullable()();
  TextColumn get cvv => text().nullable()();
  TextColumn get cardholderName => text().nullable()();
  TextColumn get billingAddress => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Purchase')
class Purchases extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get productId => text()();
  TextColumn get transactionId => text()();
  TextColumn get receipt => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  DateTimeColumn get purchaseDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SyncOutboxItem')
class SyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get dataType => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()(); // 'create', 'update', 'delete'
  TextColumn get payload => text().map(const JsonTypeConverter<Map<String, dynamic>>())();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Setting')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  TextColumn get valueType => text().withDefault(const Constant('string'))();

  @override
  Set<Column> get primaryKey => {key};
}

// DAO-классы
@DriftAccessor(tables: [Users])
class UserDAO extends DatabaseAccessor<AppDatabase> with _$UserDAOMixin {
  UserDAO(AppDatabase db) : super(db);

  Future<User?> getUser(String userId) => 
    (select(users)..where((tbl) => tbl.id.equals(userId))).getSingleOrNull();

  Future<void> insertUser(User user) => 
    into(users).insert(user, mode: InsertMode.insertOrReplace);

  Future<void> updateUser(User user) => 
    update(users).replace(user);

  Future<void> deleteUser(String userId) => 
    (delete(users)..where((tbl) => tbl.id.equals(userId))).go();
}

@DriftAccessor(tables: [WardrobeItems])
class WardrobeDAO extends DatabaseAccessor<AppDatabase> with _$WardrobeDAOMixin {
  WardrobeDAO(AppDatabase db) : super(db);

  Future<List<WardrobeDbEntity>> getAllWardrobeItems([String? userId]) async {
    var query = select(wardrobeItems);
    if (userId != null) {
      query = query..where((tbl) => tbl.userId.equals(userId));
    }
    return await query.get();
  }

  Future<WardrobeDbEntity?> getWardrobeItem(String id) =>
    (select(wardrobeItems)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<String> insertWardrobeItem(WardrobeDbEntity item) =>
    into(wardrobeItems).insert(item);

  Future<void> updateWardrobeItem(WardrobeDbEntity item) =>
    update(wardrobeItems).replace(item);

  Future<void> deleteWardrobeItem(String id) =>
    (delete(wardrobeItems)..where((tbl) => tbl.id.equals(id))).go();

  Future<List<WardrobeDbEntity>> filterWardrobeItems({
    String? category,
    String? subcategory,
    String? color,
    String? season,
    String? style,
    bool? isFavorite,
    bool? isArchived,
    String? userId,
  }) {
    var query = select(wardrobeItems);

    if (category != null) query = query..where((tbl) => tbl.category.equals(category));
    if (subcategory != null) query = query..where((tbl) => tbl.subcategory.equals(subcategory));
    if (color != null) query = query..where((tbl) => tbl.color.equals(color));
    if (season != null) query = query..where((tbl) => tbl.season.equals(season));
    if (style != null) query = query..where((tbl) => tbl.style.equals(style));
    if (isFavorite != null) query = query..where((tbl) => tbl.isFavorite.equals(isFavorite));
    if (isArchived != null) query = query..where((tbl) => tbl.isArchived.equals(isArchived));
    if (userId != null) query = query..where((tbl) => tbl.userId.equals(userId));

    return query.get();
  }

  Stream<List<WardrobeDbEntity>> watchAllWardrobeItems([String? userId]) {
    var query = select(wardrobeItems);
    if (userId != null) {
      query = query..where((tbl) => tbl.userId.equals(userId));
    }
    return query.watch();
  }

  Stream<WardrobeDbEntity?> watchWardrobeItem(String id) {
    return (select(wardrobeItems)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }
}

@DriftAccessor(tables: [WeatherData])
class WeatherDAO extends DatabaseAccessor<AppDatabase> with _$WeatherDAOMixin {
  WeatherDAO(AppDatabase db) : super(db);

  Future<List<WeatherDatum>> getWeatherByLocation(double latitude, double longitude) =>
    (select(weatherData)
          ..where((tbl) => tbl.latitude.equals(latitude) & tbl.longitude.equals(longitude))
          ..orderBy([(u) => OrderingTerm.desc(u.timestamp)]))
        .get();

  Future<WeatherDatum?> getCurrentWeather(double latitude, double longitude) =>
    (select(weatherData)
          ..where((tbl) => tbl.latitude.equals(latitude) & tbl.longitude.equals(longitude))
          ..orderBy([(u) => OrderingTerm.desc(u.timestamp)])
          ..limit(1))
        .getSingleOrNull();

  Future<void> insertWeatherData(WeatherDatum data) =>
    into(weatherData).insert(data, mode: InsertMode.insertOrReplace);

  Future<void> updateWeatherData(WeatherDatum data) =>
    update(weatherData).replace(data);

  Future<void> deleteWeatherData(String id) =>
    (delete(weatherData)..where((tbl) => tbl.id.equals(id))).go();
}

@DriftAccessor(tables: [OutfitRecommendations])
class RecommendationsDAO extends DatabaseAccessor<AppDatabase> with _$RecommendationsDAOMixin {
  RecommendationsDAO(AppDatabase db) : super(db);

  Future<List<OutfitRecommendation>> getRecommendationsByUser(String userId) =>
    (select(outfitRecommendations)..where((tbl) => tbl.userId.equals(userId))).get();

  Future<OutfitRecommendation?> getRecommendationById(String id) =>
    (select(outfitRecommendations)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<String> insertRecommendation(OutfitRecommendation recommendation) =>
    into(outfitRecommendations).insert(recommendation);

  Future<void> updateRecommendation(OutfitRecommendation recommendation) =>
    update(outfitRecommendations).replace(recommendation);

  Future<void> deleteRecommendation(String id) =>
    (delete(outfitRecommendations)..where((tbl) => tbl.id.equals(id))).go();

  Future<List<OutfitRecommendation>> getRecommendationsHistory(String userId, {DateTime? fromDate, DateTime? toDate}) {
    var query = select(outfitRecommendations)..where((tbl) => tbl.userId.equals(userId));
    
    if (fromDate != null) {
      query = query..where((tbl) => tbl.createdAt.isBiggerOrEqualValue(fromDate));
    }
    if (toDate != null) {
      query = query..where((tbl) => tbl.createdAt.isSmallerOrEqualValue(toDate));
    }
    
    return query.get();
  }
}

@DriftAccessor(tables: [AppSettings])
class SettingsDAO extends DatabaseAccessor<AppDatabase> with _$SettingsDAOMixin {
  SettingsDAO(AppDatabase db) : super(db);

  Future<AppSetting> getAppSettings() async {
    final settings = await (select(appSettings)..limit(1)).getSingleOrNull();
    return settings ?? AppSetting(
      id: 'app_settings',
      notificationsEnabled: true,
      locationEnabled: true,
      analyticsEnabled: true,
      darkMode: false,
      temperatureUnit: 'celsius',
      distanceUnit: 'metric',
      currency: 'USD',
      language: 'en',
      autoSync: true,
      syncInterval: 30,
      premiumFeatures: false,
      theme: 'light',
      hapticFeedback: true,
      soundEffects: true,
      lastSync: null,
      showWeatherOnHome: true,
      showRecommendationsOnHome: true,
      autoRefreshWeather: true,
      weatherRefreshInterval: 60,
      enableOfflineMode: false,
      allowPersonalizedAds: true,
    );
  }

  Future<void> updateAppSettings(AppSetting settings) async {
    await (update(appSettings)..where((tbl) => tbl.id.equals(settings.id))).write(settings);
  }

  Future<void> resetToDefaults() async {
    await updateAppSettings(AppSetting(
      id: 'app_settings',
      notificationsEnabled: true,
      locationEnabled: true,
      analyticsEnabled: true,
      darkMode: false,
      temperatureUnit: 'celsius',
      distanceUnit: 'metric',
      currency: 'USD',
      language: 'en',
      autoSync: true,
      syncInterval: 30,
      premiumFeatures: false,
      theme: 'light',
      hapticFeedback: true,
      soundEffects: true,
      lastSync: null,
      showWeatherOnHome: true,
      showRecommendationsOnHome: true,
      autoRefreshWeather: true,
      weatherRefreshInterval: 60,
      enableOfflineMode: false,
      allowPersonalizedAds: true,
    ));
  }
}

@DriftAccessor(tables: [Achievements, AchievementProgress])
class AchievementsDAO extends DatabaseAccessor<AppDatabase> with _$AchievementsDAOMixin {
  AchievementsDAO(AppDatabase db) : super(db);

  Future<List<Achievement>> getUserAchievements(String userId) =>
    (select(achievements)..where((tbl) => tbl.userId.equals(userId))).get();

  Future<Achievement?> getAchievement(String achievementId) =>
    (select(achievements)..where((tbl) => tbl.id.equals(achievementId))).getSingleOrNull();

  Future<void> insertAchievement(Achievement achievement) =>
    into(achievements).insert(achievement, mode: InsertMode.insertOrReplace);

  Future<void> updateAchievement(Achievement achievement) =>
    update(achievements).replace(achievement);

  Future<void> deleteAchievement(String achievementId) =>
    (delete(achievements)..where((tbl) => tbl.id.equals(achievementId))).go();

  Future<AchievementProgres?> getAchievementProgress(String achievementId, String userId) =>
    (select(achievementProgress)
          ..where((tbl) => tbl.achievementId.equals(achievementId) & tbl.userId.equals(userId)))
        .getSingleOrNull();

  Future<void> updateAchievementProgress(AchievementProgres progress) async {
    final existing = await getAchievementProgress(progress.achievementId, progress.userId);
    if (existing != null) {
      await update(achievementProgress).replace(progress);
    } else {
      await into(achievementProgress).insert(progress);
    }
  }
}

@DriftAccessor(tables: [SubscriptionPlans, UserSubscriptions, PaymentMethods, Purchases])
class MonetizationDAO extends DatabaseAccessor<AppDatabase> with _$MonetizationDAOMixin {
  MonetizationDAO(AppDatabase db) : super(db);

  // Subscription Plans
  Future<List<SubscriptionPlan>> getAllSubscriptionPlans() =>
    (select(subscriptionPlans)..where((tbl) => tbl.isActive.equals(true))).get();

  Future<SubscriptionPlan?> getSubscriptionPlan(String planId) =>
    (select(subscriptionPlans)..where((tbl) => tbl.id.equals(planId))).getSingleOrNull();

  Future<void> insertSubscriptionPlan(SubscriptionPlan plan) =>
    into(subscriptionPlans).insert(plan, mode: InsertMode.insertOrReplace);

  // User Subscriptions
  Future<UserSubscription?> getUserSubscription(String userId) =>
    (select(userSubscriptions)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(u) => OrderingTerm.desc(u.startDate)])
          ..limit(1))
        .getSingleOrNull();

  Future<void> insertUserSubscription(UserSubscription subscription) =>
    into(userSubscriptions).insert(subscription, mode: InsertMode.insertOrReplace);

  Future<void> updateUserSubscription(UserSubscription subscription) =>
    update(userSubscriptions).replace(subscription);

  // Payment Methods
  Future<List<PaymentMethod>> getUserPaymentMethods(String userId) =>
    (select(paymentMethods)..where((tbl) => tbl.userId.equals(userId))).get();

  Future<PaymentMethod?> getDefaultPaymentMethod(String userId) =>
    (select(paymentMethods)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.isDefault.equals(true)))
        .getSingleOrNull();

  Future<void> insertPaymentMethod(PaymentMethod method) =>
    into(paymentMethods).insert(method);

  Future<void> updatePaymentMethod(PaymentMethod method) =>
    update(paymentMethods).replace(method);

  // Purchases
  Future<List<Purchase>> getUserPurchases(String userId) =>
    (select(purchases)..where((tbl) => tbl.userId.equals(userId))).get();

  Future<void> insertPurchase(Purchase purchase) =>
    into(purchases).insert(purchase);
}

@DriftAccessor(tables: [SyncOutbox])
class SyncDAO extends DatabaseAccessor<AppDatabase> with _$SyncDAOMixin {
  SyncDAO(AppDatabase db) : super(db);

  Future<List<SyncOutboxItem>> getUnsyncedItems() =>
    (select(syncOutbox)..where((tbl) => tbl.isSynced.equals(false))).get();

  Future<SyncOutboxItem?> getSyncItem(String id) =>
    (select(syncOutbox)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<String> insertSyncItem(SyncOutboxItem item) =>
    into(syncOutbox).insert(item);

  Future<void> markAsSynced(String id, DateTime syncedAt) async {
    await (update(syncOutbox)..where((tbl) => tbl.id.equals(id))).write(
      SyncOutboxItem(
        id: id,
        dataType: '', // Will be ignored due to where clause
        recordId: '',
        operation: '',
        payload: {},
        createdAt: DateTime.now(),
        syncedAt: syncedAt,
        isSynced: true,
      ),
    );
  }

  Future<void> deleteSyncItem(String id) =>
    (delete(syncOutbox)..where((tbl) => tbl.id.equals(id))).go();

  Future<void> clearSyncedItems() =>
    (delete(syncOutbox)..where((tbl) => tbl.isSynced.equals(true))).go();
}