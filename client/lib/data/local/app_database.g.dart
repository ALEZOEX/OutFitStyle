// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WardrobeEntriesTable extends WardrobeEntries
    with TableInfo<$WardrobeEntriesTable, WardrobeEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WardrobeEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subcategoryMeta =
      const VerificationMeta('subcategory');
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
      'subcategory', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>(
      'style', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconEmojiMeta =
      const VerificationMeta('iconEmoji');
  @override
  late final GeneratedColumn<String> iconEmoji = GeneratedColumn<String>(
      'icon_emoji', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _blurHashMeta =
      const VerificationMeta('blurHash');
  @override
  late final GeneratedColumn<String> blurHash = GeneratedColumn<String>(
      'blur_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _minTempMeta =
      const VerificationMeta('minTemp');
  @override
  late final GeneratedColumn<int> minTemp = GeneratedColumn<int>(
      'min_temp', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _maxTempMeta =
      const VerificationMeta('maxTemp');
  @override
  late final GeneratedColumn<int> maxTemp = GeneratedColumn<int>(
      'max_temp', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _warmthLevelMeta =
      const VerificationMeta('warmthLevel');
  @override
  late final GeneratedColumn<int> warmthLevel = GeneratedColumn<int>(
      'warmth_level', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _rainOkMeta = const VerificationMeta('rainOk');
  @override
  late final GeneratedColumn<bool> rainOk = GeneratedColumn<bool>(
      'rain_ok', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("rain_ok" IN (0, 1))'));
  static const VerificationMeta _snowOkMeta = const VerificationMeta('snowOk');
  @override
  late final GeneratedColumn<bool> snowOk = GeneratedColumn<bool>(
      'snow_ok', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("snow_ok" IN (0, 1))'));
  static const VerificationMeta _windOkMeta = const VerificationMeta('windOk');
  @override
  late final GeneratedColumn<bool> windOk = GeneratedColumn<bool>(
      'wind_ok', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("wind_ok" IN (0, 1))'));
  static const VerificationMeta _usageMeta = const VerificationMeta('usage');
  @override
  late final GeneratedColumn<String> usage = GeneratedColumn<String>(
      'usage', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _materialsMeta =
      const VerificationMeta('materials');
  @override
  late final GeneratedColumn<String> materials = GeneratedColumn<String>(
      'materials', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wearCountMeta =
      const VerificationMeta('wearCount');
  @override
  late final GeneratedColumn<int> wearCount = GeneratedColumn<int>(
      'wear_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastWornAtMeta =
      const VerificationMeta('lastWornAt');
  @override
  late final GeneratedColumn<DateTime> lastWornAt = GeneratedColumn<DateTime>(
      'last_worn_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_favorite" IN (0, 1))'));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_archived" IN (0, 1))'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'));
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
      'season', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fitMeta = const VerificationMeta('fit');
  @override
  late final GeneratedColumn<String> fit = GeneratedColumn<String>(
      'fit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _patternMeta =
      const VerificationMeta('pattern');
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
      'pattern', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localImagePathMeta =
      const VerificationMeta('localImagePath');
  @override
  late final GeneratedColumn<String> localImagePath = GeneratedColumn<String>(
      'local_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        name,
        category,
        subcategory,
        style,
        iconEmoji,
        imageUrl,
        blurHash,
        minTemp,
        maxTemp,
        warmthLevel,
        rainOk,
        snowOk,
        windOk,
        usage,
        materials,
        wearCount,
        lastWornAt,
        isFavorite,
        isArchived,
        createdAt,
        updatedAt,
        lastSyncedAt,
        dirty,
        season,
        gender,
        fit,
        pattern,
        localImagePath
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wardrobe_entries';
  @override
  VerificationContext validateIntegrity(Insertable<WardrobeEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(
          _subcategoryMeta,
          subcategory.isAcceptableOrUnknown(
              data['subcategory']!, _subcategoryMeta));
    } else if (isInserting) {
      context.missing(_subcategoryMeta);
    }
    if (data.containsKey('style')) {
      context.handle(
          _styleMeta, style.isAcceptableOrUnknown(data['style']!, _styleMeta));
    } else if (isInserting) {
      context.missing(_styleMeta);
    }
    if (data.containsKey('icon_emoji')) {
      context.handle(_iconEmojiMeta,
          iconEmoji.isAcceptableOrUnknown(data['icon_emoji']!, _iconEmojiMeta));
    } else if (isInserting) {
      context.missing(_iconEmojiMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('blur_hash')) {
      context.handle(_blurHashMeta,
          blurHash.isAcceptableOrUnknown(data['blur_hash']!, _blurHashMeta));
    }
    if (data.containsKey('min_temp')) {
      context.handle(_minTempMeta,
          minTemp.isAcceptableOrUnknown(data['min_temp']!, _minTempMeta));
    }
    if (data.containsKey('max_temp')) {
      context.handle(_maxTempMeta,
          maxTemp.isAcceptableOrUnknown(data['max_temp']!, _maxTempMeta));
    }
    if (data.containsKey('warmth_level')) {
      context.handle(
          _warmthLevelMeta,
          warmthLevel.isAcceptableOrUnknown(
              data['warmth_level']!, _warmthLevelMeta));
    }
    if (data.containsKey('rain_ok')) {
      context.handle(_rainOkMeta,
          rainOk.isAcceptableOrUnknown(data['rain_ok']!, _rainOkMeta));
    } else if (isInserting) {
      context.missing(_rainOkMeta);
    }
    if (data.containsKey('snow_ok')) {
      context.handle(_snowOkMeta,
          snowOk.isAcceptableOrUnknown(data['snow_ok']!, _snowOkMeta));
    } else if (isInserting) {
      context.missing(_snowOkMeta);
    }
    if (data.containsKey('wind_ok')) {
      context.handle(_windOkMeta,
          windOk.isAcceptableOrUnknown(data['wind_ok']!, _windOkMeta));
    } else if (isInserting) {
      context.missing(_windOkMeta);
    }
    if (data.containsKey('usage')) {
      context.handle(
          _usageMeta, usage.isAcceptableOrUnknown(data['usage']!, _usageMeta));
    }
    if (data.containsKey('materials')) {
      context.handle(_materialsMeta,
          materials.isAcceptableOrUnknown(data['materials']!, _materialsMeta));
    }
    if (data.containsKey('wear_count')) {
      context.handle(_wearCountMeta,
          wearCount.isAcceptableOrUnknown(data['wear_count']!, _wearCountMeta));
    } else if (isInserting) {
      context.missing(_wearCountMeta);
    }
    if (data.containsKey('last_worn_at')) {
      context.handle(
          _lastWornAtMeta,
          lastWornAt.isAcceptableOrUnknown(
              data['last_worn_at']!, _lastWornAtMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    } else if (isInserting) {
      context.missing(_isFavoriteMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    } else if (isInserting) {
      context.missing(_isArchivedMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    } else if (isInserting) {
      context.missing(_dirtyMeta);
    }
    if (data.containsKey('season')) {
      context.handle(_seasonMeta,
          season.isAcceptableOrUnknown(data['season']!, _seasonMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('fit')) {
      context.handle(
          _fitMeta, fit.isAcceptableOrUnknown(data['fit']!, _fitMeta));
    }
    if (data.containsKey('pattern')) {
      context.handle(_patternMeta,
          pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta));
    }
    if (data.containsKey('local_image_path')) {
      context.handle(
          _localImagePathMeta,
          localImagePath.isAcceptableOrUnknown(
              data['local_image_path']!, _localImagePathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WardrobeEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WardrobeEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      subcategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subcategory'])!,
      style: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}style'])!,
      iconEmoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_emoji'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      blurHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}blur_hash']),
      minTemp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}min_temp']),
      maxTemp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_temp']),
      warmthLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}warmth_level']),
      rainOk: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}rain_ok'])!,
      snowOk: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}snow_ok'])!,
      windOk: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}wind_ok'])!,
      usage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}usage']),
      materials: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}materials']),
      wearCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wear_count'])!,
      lastWornAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_worn_at']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      season: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}season']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
      fit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fit']),
      pattern: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pattern']),
      localImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_image_path']),
    );
  }

  @override
  $WardrobeEntriesTable createAlias(String alias) {
    return $WardrobeEntriesTable(attachedDatabase, alias);
  }
}

class WardrobeEntry extends DataClass implements Insertable<WardrobeEntry> {
  final String id;
  final String? serverId;
  final String name;
  final String category;
  final String subcategory;
  final String style;
  final String iconEmoji;
  final String? imageUrl;
  final String? blurHash;
  final int? minTemp;
  final int? maxTemp;
  final int? warmthLevel;
  final bool rainOk;
  final bool snowOk;
  final bool windOk;
  final String? usage;
  final String? materials;
  final int wearCount;
  final DateTime? lastWornAt;
  final bool isFavorite;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool dirty;
  final String? season;
  final String? gender;
  final String? fit;
  final String? pattern;
  final String? localImagePath;
  const WardrobeEntry(
      {required this.id,
      this.serverId,
      required this.name,
      required this.category,
      required this.subcategory,
      required this.style,
      required this.iconEmoji,
      this.imageUrl,
      this.blurHash,
      this.minTemp,
      this.maxTemp,
      this.warmthLevel,
      required this.rainOk,
      required this.snowOk,
      required this.windOk,
      this.usage,
      this.materials,
      required this.wearCount,
      this.lastWornAt,
      required this.isFavorite,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt,
      this.lastSyncedAt,
      required this.dirty,
      this.season,
      this.gender,
      this.fit,
      this.pattern,
      this.localImagePath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['subcategory'] = Variable<String>(subcategory);
    map['style'] = Variable<String>(style);
    map['icon_emoji'] = Variable<String>(iconEmoji);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || blurHash != null) {
      map['blur_hash'] = Variable<String>(blurHash);
    }
    if (!nullToAbsent || minTemp != null) {
      map['min_temp'] = Variable<int>(minTemp);
    }
    if (!nullToAbsent || maxTemp != null) {
      map['max_temp'] = Variable<int>(maxTemp);
    }
    if (!nullToAbsent || warmthLevel != null) {
      map['warmth_level'] = Variable<int>(warmthLevel);
    }
    map['rain_ok'] = Variable<bool>(rainOk);
    map['snow_ok'] = Variable<bool>(snowOk);
    map['wind_ok'] = Variable<bool>(windOk);
    if (!nullToAbsent || usage != null) {
      map['usage'] = Variable<String>(usage);
    }
    if (!nullToAbsent || materials != null) {
      map['materials'] = Variable<String>(materials);
    }
    map['wear_count'] = Variable<int>(wearCount);
    if (!nullToAbsent || lastWornAt != null) {
      map['last_worn_at'] = Variable<DateTime>(lastWornAt);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || season != null) {
      map['season'] = Variable<String>(season);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || fit != null) {
      map['fit'] = Variable<String>(fit);
    }
    if (!nullToAbsent || pattern != null) {
      map['pattern'] = Variable<String>(pattern);
    }
    if (!nullToAbsent || localImagePath != null) {
      map['local_image_path'] = Variable<String>(localImagePath);
    }
    return map;
  }

  WardrobeEntriesCompanion toCompanion(bool nullToAbsent) {
    return WardrobeEntriesCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      name: Value(name),
      category: Value(category),
      subcategory: Value(subcategory),
      style: Value(style),
      iconEmoji: Value(iconEmoji),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      blurHash: blurHash == null && nullToAbsent
          ? const Value.absent()
          : Value(blurHash),
      minTemp: minTemp == null && nullToAbsent
          ? const Value.absent()
          : Value(minTemp),
      maxTemp: maxTemp == null && nullToAbsent
          ? const Value.absent()
          : Value(maxTemp),
      warmthLevel: warmthLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(warmthLevel),
      rainOk: Value(rainOk),
      snowOk: Value(snowOk),
      windOk: Value(windOk),
      usage:
          usage == null && nullToAbsent ? const Value.absent() : Value(usage),
      materials: materials == null && nullToAbsent
          ? const Value.absent()
          : Value(materials),
      wearCount: Value(wearCount),
      lastWornAt: lastWornAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWornAt),
      isFavorite: Value(isFavorite),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      dirty: Value(dirty),
      season:
          season == null && nullToAbsent ? const Value.absent() : Value(season),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      fit: fit == null && nullToAbsent ? const Value.absent() : Value(fit),
      pattern: pattern == null && nullToAbsent
          ? const Value.absent()
          : Value(pattern),
      localImagePath: localImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localImagePath),
    );
  }

  factory WardrobeEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WardrobeEntry(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      subcategory: serializer.fromJson<String>(json['subcategory']),
      style: serializer.fromJson<String>(json['style']),
      iconEmoji: serializer.fromJson<String>(json['iconEmoji']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      blurHash: serializer.fromJson<String?>(json['blurHash']),
      minTemp: serializer.fromJson<int?>(json['minTemp']),
      maxTemp: serializer.fromJson<int?>(json['maxTemp']),
      warmthLevel: serializer.fromJson<int?>(json['warmthLevel']),
      rainOk: serializer.fromJson<bool>(json['rainOk']),
      snowOk: serializer.fromJson<bool>(json['snowOk']),
      windOk: serializer.fromJson<bool>(json['windOk']),
      usage: serializer.fromJson<String?>(json['usage']),
      materials: serializer.fromJson<String?>(json['materials']),
      wearCount: serializer.fromJson<int>(json['wearCount']),
      lastWornAt: serializer.fromJson<DateTime?>(json['lastWornAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      season: serializer.fromJson<String?>(json['season']),
      gender: serializer.fromJson<String?>(json['gender']),
      fit: serializer.fromJson<String?>(json['fit']),
      pattern: serializer.fromJson<String?>(json['pattern']),
      localImagePath: serializer.fromJson<String?>(json['localImagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'subcategory': serializer.toJson<String>(subcategory),
      'style': serializer.toJson<String>(style),
      'iconEmoji': serializer.toJson<String>(iconEmoji),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'blurHash': serializer.toJson<String?>(blurHash),
      'minTemp': serializer.toJson<int?>(minTemp),
      'maxTemp': serializer.toJson<int?>(maxTemp),
      'warmthLevel': serializer.toJson<int?>(warmthLevel),
      'rainOk': serializer.toJson<bool>(rainOk),
      'snowOk': serializer.toJson<bool>(snowOk),
      'windOk': serializer.toJson<bool>(windOk),
      'usage': serializer.toJson<String?>(usage),
      'materials': serializer.toJson<String?>(materials),
      'wearCount': serializer.toJson<int>(wearCount),
      'lastWornAt': serializer.toJson<DateTime?>(lastWornAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'season': serializer.toJson<String?>(season),
      'gender': serializer.toJson<String?>(gender),
      'fit': serializer.toJson<String?>(fit),
      'pattern': serializer.toJson<String?>(pattern),
      'localImagePath': serializer.toJson<String?>(localImagePath),
    };
  }

  WardrobeEntry copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? name,
          String? category,
          String? subcategory,
          String? style,
          String? iconEmoji,
          Value<String?> imageUrl = const Value.absent(),
          Value<String?> blurHash = const Value.absent(),
          Value<int?> minTemp = const Value.absent(),
          Value<int?> maxTemp = const Value.absent(),
          Value<int?> warmthLevel = const Value.absent(),
          bool? rainOk,
          bool? snowOk,
          bool? windOk,
          Value<String?> usage = const Value.absent(),
          Value<String?> materials = const Value.absent(),
          int? wearCount,
          Value<DateTime?> lastWornAt = const Value.absent(),
          bool? isFavorite,
          bool? isArchived,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          bool? dirty,
          Value<String?> season = const Value.absent(),
          Value<String?> gender = const Value.absent(),
          Value<String?> fit = const Value.absent(),
          Value<String?> pattern = const Value.absent(),
          Value<String?> localImagePath = const Value.absent()}) =>
      WardrobeEntry(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        name: name ?? this.name,
        category: category ?? this.category,
        subcategory: subcategory ?? this.subcategory,
        style: style ?? this.style,
        iconEmoji: iconEmoji ?? this.iconEmoji,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        blurHash: blurHash.present ? blurHash.value : this.blurHash,
        minTemp: minTemp.present ? minTemp.value : this.minTemp,
        maxTemp: maxTemp.present ? maxTemp.value : this.maxTemp,
        warmthLevel: warmthLevel.present ? warmthLevel.value : this.warmthLevel,
        rainOk: rainOk ?? this.rainOk,
        snowOk: snowOk ?? this.snowOk,
        windOk: windOk ?? this.windOk,
        usage: usage.present ? usage.value : this.usage,
        materials: materials.present ? materials.value : this.materials,
        wearCount: wearCount ?? this.wearCount,
        lastWornAt: lastWornAt.present ? lastWornAt.value : this.lastWornAt,
        isFavorite: isFavorite ?? this.isFavorite,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        dirty: dirty ?? this.dirty,
        season: season.present ? season.value : this.season,
        gender: gender.present ? gender.value : this.gender,
        fit: fit.present ? fit.value : this.fit,
        pattern: pattern.present ? pattern.value : this.pattern,
        localImagePath:
            localImagePath.present ? localImagePath.value : this.localImagePath,
      );
  WardrobeEntry copyWithCompanion(WardrobeEntriesCompanion data) {
    return WardrobeEntry(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      subcategory:
          data.subcategory.present ? data.subcategory.value : this.subcategory,
      style: data.style.present ? data.style.value : this.style,
      iconEmoji: data.iconEmoji.present ? data.iconEmoji.value : this.iconEmoji,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      blurHash: data.blurHash.present ? data.blurHash.value : this.blurHash,
      minTemp: data.minTemp.present ? data.minTemp.value : this.minTemp,
      maxTemp: data.maxTemp.present ? data.maxTemp.value : this.maxTemp,
      warmthLevel:
          data.warmthLevel.present ? data.warmthLevel.value : this.warmthLevel,
      rainOk: data.rainOk.present ? data.rainOk.value : this.rainOk,
      snowOk: data.snowOk.present ? data.snowOk.value : this.snowOk,
      windOk: data.windOk.present ? data.windOk.value : this.windOk,
      usage: data.usage.present ? data.usage.value : this.usage,
      materials: data.materials.present ? data.materials.value : this.materials,
      wearCount: data.wearCount.present ? data.wearCount.value : this.wearCount,
      lastWornAt:
          data.lastWornAt.present ? data.lastWornAt.value : this.lastWornAt,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      season: data.season.present ? data.season.value : this.season,
      gender: data.gender.present ? data.gender.value : this.gender,
      fit: data.fit.present ? data.fit.value : this.fit,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      localImagePath: data.localImagePath.present
          ? data.localImagePath.value
          : this.localImagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WardrobeEntry(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('style: $style, ')
          ..write('iconEmoji: $iconEmoji, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('blurHash: $blurHash, ')
          ..write('minTemp: $minTemp, ')
          ..write('maxTemp: $maxTemp, ')
          ..write('warmthLevel: $warmthLevel, ')
          ..write('rainOk: $rainOk, ')
          ..write('snowOk: $snowOk, ')
          ..write('windOk: $windOk, ')
          ..write('usage: $usage, ')
          ..write('materials: $materials, ')
          ..write('wearCount: $wearCount, ')
          ..write('lastWornAt: $lastWornAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('dirty: $dirty, ')
          ..write('season: $season, ')
          ..write('gender: $gender, ')
          ..write('fit: $fit, ')
          ..write('pattern: $pattern, ')
          ..write('localImagePath: $localImagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        serverId,
        name,
        category,
        subcategory,
        style,
        iconEmoji,
        imageUrl,
        blurHash,
        minTemp,
        maxTemp,
        warmthLevel,
        rainOk,
        snowOk,
        windOk,
        usage,
        materials,
        wearCount,
        lastWornAt,
        isFavorite,
        isArchived,
        createdAt,
        updatedAt,
        lastSyncedAt,
        dirty,
        season,
        gender,
        fit,
        pattern,
        localImagePath
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WardrobeEntry &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.name == this.name &&
          other.category == this.category &&
          other.subcategory == this.subcategory &&
          other.style == this.style &&
          other.iconEmoji == this.iconEmoji &&
          other.imageUrl == this.imageUrl &&
          other.blurHash == this.blurHash &&
          other.minTemp == this.minTemp &&
          other.maxTemp == this.maxTemp &&
          other.warmthLevel == this.warmthLevel &&
          other.rainOk == this.rainOk &&
          other.snowOk == this.snowOk &&
          other.windOk == this.windOk &&
          other.usage == this.usage &&
          other.materials == this.materials &&
          other.wearCount == this.wearCount &&
          other.lastWornAt == this.lastWornAt &&
          other.isFavorite == this.isFavorite &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.dirty == this.dirty &&
          other.season == this.season &&
          other.gender == this.gender &&
          other.fit == this.fit &&
          other.pattern == this.pattern &&
          other.localImagePath == this.localImagePath);
}

class WardrobeEntriesCompanion extends UpdateCompanion<WardrobeEntry> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> name;
  final Value<String> category;
  final Value<String> subcategory;
  final Value<String> style;
  final Value<String> iconEmoji;
  final Value<String?> imageUrl;
  final Value<String?> blurHash;
  final Value<int?> minTemp;
  final Value<int?> maxTemp;
  final Value<int?> warmthLevel;
  final Value<bool> rainOk;
  final Value<bool> snowOk;
  final Value<bool> windOk;
  final Value<String?> usage;
  final Value<String?> materials;
  final Value<int> wearCount;
  final Value<DateTime?> lastWornAt;
  final Value<bool> isFavorite;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> dirty;
  final Value<String?> season;
  final Value<String?> gender;
  final Value<String?> fit;
  final Value<String?> pattern;
  final Value<String?> localImagePath;
  final Value<int> rowid;
  const WardrobeEntriesCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.style = const Value.absent(),
    this.iconEmoji = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.blurHash = const Value.absent(),
    this.minTemp = const Value.absent(),
    this.maxTemp = const Value.absent(),
    this.warmthLevel = const Value.absent(),
    this.rainOk = const Value.absent(),
    this.snowOk = const Value.absent(),
    this.windOk = const Value.absent(),
    this.usage = const Value.absent(),
    this.materials = const Value.absent(),
    this.wearCount = const Value.absent(),
    this.lastWornAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.season = const Value.absent(),
    this.gender = const Value.absent(),
    this.fit = const Value.absent(),
    this.pattern = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WardrobeEntriesCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required String name,
    required String category,
    required String subcategory,
    required String style,
    required String iconEmoji,
    this.imageUrl = const Value.absent(),
    this.blurHash = const Value.absent(),
    this.minTemp = const Value.absent(),
    this.maxTemp = const Value.absent(),
    this.warmthLevel = const Value.absent(),
    required bool rainOk,
    required bool snowOk,
    required bool windOk,
    this.usage = const Value.absent(),
    this.materials = const Value.absent(),
    required int wearCount,
    this.lastWornAt = const Value.absent(),
    required bool isFavorite,
    required bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastSyncedAt = const Value.absent(),
    required bool dirty,
    this.season = const Value.absent(),
    this.gender = const Value.absent(),
    this.fit = const Value.absent(),
    this.pattern = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        category = Value(category),
        subcategory = Value(subcategory),
        style = Value(style),
        iconEmoji = Value(iconEmoji),
        rainOk = Value(rainOk),
        snowOk = Value(snowOk),
        windOk = Value(windOk),
        wearCount = Value(wearCount),
        isFavorite = Value(isFavorite),
        isArchived = Value(isArchived),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        dirty = Value(dirty);
  static Insertable<WardrobeEntry> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<String>? style,
    Expression<String>? iconEmoji,
    Expression<String>? imageUrl,
    Expression<String>? blurHash,
    Expression<int>? minTemp,
    Expression<int>? maxTemp,
    Expression<int>? warmthLevel,
    Expression<bool>? rainOk,
    Expression<bool>? snowOk,
    Expression<bool>? windOk,
    Expression<String>? usage,
    Expression<String>? materials,
    Expression<int>? wearCount,
    Expression<DateTime>? lastWornAt,
    Expression<bool>? isFavorite,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? dirty,
    Expression<String>? season,
    Expression<String>? gender,
    Expression<String>? fit,
    Expression<String>? pattern,
    Expression<String>? localImagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (style != null) 'style': style,
      if (iconEmoji != null) 'icon_emoji': iconEmoji,
      if (imageUrl != null) 'image_url': imageUrl,
      if (blurHash != null) 'blur_hash': blurHash,
      if (minTemp != null) 'min_temp': minTemp,
      if (maxTemp != null) 'max_temp': maxTemp,
      if (warmthLevel != null) 'warmth_level': warmthLevel,
      if (rainOk != null) 'rain_ok': rainOk,
      if (snowOk != null) 'snow_ok': snowOk,
      if (windOk != null) 'wind_ok': windOk,
      if (usage != null) 'usage': usage,
      if (materials != null) 'materials': materials,
      if (wearCount != null) 'wear_count': wearCount,
      if (lastWornAt != null) 'last_worn_at': lastWornAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (dirty != null) 'dirty': dirty,
      if (season != null) 'season': season,
      if (gender != null) 'gender': gender,
      if (fit != null) 'fit': fit,
      if (pattern != null) 'pattern': pattern,
      if (localImagePath != null) 'local_image_path': localImagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WardrobeEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? name,
      Value<String>? category,
      Value<String>? subcategory,
      Value<String>? style,
      Value<String>? iconEmoji,
      Value<String?>? imageUrl,
      Value<String?>? blurHash,
      Value<int?>? minTemp,
      Value<int?>? maxTemp,
      Value<int?>? warmthLevel,
      Value<bool>? rainOk,
      Value<bool>? snowOk,
      Value<bool>? windOk,
      Value<String?>? usage,
      Value<String?>? materials,
      Value<int>? wearCount,
      Value<DateTime?>? lastWornAt,
      Value<bool>? isFavorite,
      Value<bool>? isArchived,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? lastSyncedAt,
      Value<bool>? dirty,
      Value<String?>? season,
      Value<String?>? gender,
      Value<String?>? fit,
      Value<String?>? pattern,
      Value<String?>? localImagePath,
      Value<int>? rowid}) {
    return WardrobeEntriesCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      style: style ?? this.style,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      imageUrl: imageUrl ?? this.imageUrl,
      blurHash: blurHash ?? this.blurHash,
      minTemp: minTemp ?? this.minTemp,
      maxTemp: maxTemp ?? this.maxTemp,
      warmthLevel: warmthLevel ?? this.warmthLevel,
      rainOk: rainOk ?? this.rainOk,
      snowOk: snowOk ?? this.snowOk,
      windOk: windOk ?? this.windOk,
      usage: usage ?? this.usage,
      materials: materials ?? this.materials,
      wearCount: wearCount ?? this.wearCount,
      lastWornAt: lastWornAt ?? this.lastWornAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      dirty: dirty ?? this.dirty,
      season: season ?? this.season,
      gender: gender ?? this.gender,
      fit: fit ?? this.fit,
      pattern: pattern ?? this.pattern,
      localImagePath: localImagePath ?? this.localImagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (style.present) {
      map['style'] = Variable<String>(style.value);
    }
    if (iconEmoji.present) {
      map['icon_emoji'] = Variable<String>(iconEmoji.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (blurHash.present) {
      map['blur_hash'] = Variable<String>(blurHash.value);
    }
    if (minTemp.present) {
      map['min_temp'] = Variable<int>(minTemp.value);
    }
    if (maxTemp.present) {
      map['max_temp'] = Variable<int>(maxTemp.value);
    }
    if (warmthLevel.present) {
      map['warmth_level'] = Variable<int>(warmthLevel.value);
    }
    if (rainOk.present) {
      map['rain_ok'] = Variable<bool>(rainOk.value);
    }
    if (snowOk.present) {
      map['snow_ok'] = Variable<bool>(snowOk.value);
    }
    if (windOk.present) {
      map['wind_ok'] = Variable<bool>(windOk.value);
    }
    if (usage.present) {
      map['usage'] = Variable<String>(usage.value);
    }
    if (materials.present) {
      map['materials'] = Variable<String>(materials.value);
    }
    if (wearCount.present) {
      map['wear_count'] = Variable<int>(wearCount.value);
    }
    if (lastWornAt.present) {
      map['last_worn_at'] = Variable<DateTime>(lastWornAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (fit.present) {
      map['fit'] = Variable<String>(fit.value);
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (localImagePath.present) {
      map['local_image_path'] = Variable<String>(localImagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WardrobeEntriesCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('style: $style, ')
          ..write('iconEmoji: $iconEmoji, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('blurHash: $blurHash, ')
          ..write('minTemp: $minTemp, ')
          ..write('maxTemp: $maxTemp, ')
          ..write('warmthLevel: $warmthLevel, ')
          ..write('rainOk: $rainOk, ')
          ..write('snowOk: $snowOk, ')
          ..write('windOk: $windOk, ')
          ..write('usage: $usage, ')
          ..write('materials: $materials, ')
          ..write('wearCount: $wearCount, ')
          ..write('lastWornAt: $lastWornAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('dirty: $dirty, ')
          ..write('season: $season, ')
          ..write('gender: $gender, ')
          ..write('fit: $fit, ')
          ..write('pattern: $pattern, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecommendationsTable extends Recommendations
    with TableInfo<$RecommendationsTable, Recommendation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecommendationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
      'origin', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _outfitDataJsonMeta =
      const VerificationMeta('outfitDataJson');
  @override
  late final GeneratedColumn<String> outfitDataJson = GeneratedColumn<String>(
      'outfit_data_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weatherDataJsonMeta =
      const VerificationMeta('weatherDataJson');
  @override
  late final GeneratedColumn<String> weatherDataJson = GeneratedColumn<String>(
      'weather_data_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_favorite" IN (0, 1))'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'));
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localImagePathMeta =
      const VerificationMeta('localImagePath');
  @override
  late final GeneratedColumn<String> localImagePath = GeneratedColumn<String>(
      'local_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        origin,
        outfitDataJson,
        weatherDataJson,
        isFavorite,
        createdAt,
        updatedAt,
        lastSyncedAt,
        dirty,
        imageUrl,
        localImagePath
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recommendations';
  @override
  VerificationContext validateIntegrity(Insertable<Recommendation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('origin')) {
      context.handle(_originMeta,
          origin.isAcceptableOrUnknown(data['origin']!, _originMeta));
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('outfit_data_json')) {
      context.handle(
          _outfitDataJsonMeta,
          outfitDataJson.isAcceptableOrUnknown(
              data['outfit_data_json']!, _outfitDataJsonMeta));
    } else if (isInserting) {
      context.missing(_outfitDataJsonMeta);
    }
    if (data.containsKey('weather_data_json')) {
      context.handle(
          _weatherDataJsonMeta,
          weatherDataJson.isAcceptableOrUnknown(
              data['weather_data_json']!, _weatherDataJsonMeta));
    } else if (isInserting) {
      context.missing(_weatherDataJsonMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    } else if (isInserting) {
      context.missing(_isFavoriteMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    } else if (isInserting) {
      context.missing(_dirtyMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('local_image_path')) {
      context.handle(
          _localImagePathMeta,
          localImagePath.isAcceptableOrUnknown(
              data['local_image_path']!, _localImagePathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recommendation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recommendation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      origin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin'])!,
      outfitDataJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}outfit_data_json'])!,
      weatherDataJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}weather_data_json'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      localImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_image_path']),
    );
  }

  @override
  $RecommendationsTable createAlias(String alias) {
    return $RecommendationsTable(attachedDatabase, alias);
  }
}

class Recommendation extends DataClass implements Insertable<Recommendation> {
  final String id;
  final String? serverId;
  final String origin;
  final String outfitDataJson;
  final String weatherDataJson;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool dirty;
  final String? imageUrl;
  final String? localImagePath;
  const Recommendation(
      {required this.id,
      this.serverId,
      required this.origin,
      required this.outfitDataJson,
      required this.weatherDataJson,
      required this.isFavorite,
      required this.createdAt,
      required this.updatedAt,
      this.lastSyncedAt,
      required this.dirty,
      this.imageUrl,
      this.localImagePath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['origin'] = Variable<String>(origin);
    map['outfit_data_json'] = Variable<String>(outfitDataJson);
    map['weather_data_json'] = Variable<String>(weatherDataJson);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || localImagePath != null) {
      map['local_image_path'] = Variable<String>(localImagePath);
    }
    return map;
  }

  RecommendationsCompanion toCompanion(bool nullToAbsent) {
    return RecommendationsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      origin: Value(origin),
      outfitDataJson: Value(outfitDataJson),
      weatherDataJson: Value(weatherDataJson),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      dirty: Value(dirty),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      localImagePath: localImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localImagePath),
    );
  }

  factory Recommendation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recommendation(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      origin: serializer.fromJson<String>(json['origin']),
      outfitDataJson: serializer.fromJson<String>(json['outfitDataJson']),
      weatherDataJson: serializer.fromJson<String>(json['weatherDataJson']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      localImagePath: serializer.fromJson<String?>(json['localImagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'origin': serializer.toJson<String>(origin),
      'outfitDataJson': serializer.toJson<String>(outfitDataJson),
      'weatherDataJson': serializer.toJson<String>(weatherDataJson),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'localImagePath': serializer.toJson<String?>(localImagePath),
    };
  }

  Recommendation copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? origin,
          String? outfitDataJson,
          String? weatherDataJson,
          bool? isFavorite,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          bool? dirty,
          Value<String?> imageUrl = const Value.absent(),
          Value<String?> localImagePath = const Value.absent()}) =>
      Recommendation(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        origin: origin ?? this.origin,
        outfitDataJson: outfitDataJson ?? this.outfitDataJson,
        weatherDataJson: weatherDataJson ?? this.weatherDataJson,
        isFavorite: isFavorite ?? this.isFavorite,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        dirty: dirty ?? this.dirty,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        localImagePath:
            localImagePath.present ? localImagePath.value : this.localImagePath,
      );
  Recommendation copyWithCompanion(RecommendationsCompanion data) {
    return Recommendation(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      origin: data.origin.present ? data.origin.value : this.origin,
      outfitDataJson: data.outfitDataJson.present
          ? data.outfitDataJson.value
          : this.outfitDataJson,
      weatherDataJson: data.weatherDataJson.present
          ? data.weatherDataJson.value
          : this.weatherDataJson,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      localImagePath: data.localImagePath.present
          ? data.localImagePath.value
          : this.localImagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recommendation(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('origin: $origin, ')
          ..write('outfitDataJson: $outfitDataJson, ')
          ..write('weatherDataJson: $weatherDataJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('dirty: $dirty, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('localImagePath: $localImagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      origin,
      outfitDataJson,
      weatherDataJson,
      isFavorite,
      createdAt,
      updatedAt,
      lastSyncedAt,
      dirty,
      imageUrl,
      localImagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recommendation &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.origin == this.origin &&
          other.outfitDataJson == this.outfitDataJson &&
          other.weatherDataJson == this.weatherDataJson &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.dirty == this.dirty &&
          other.imageUrl == this.imageUrl &&
          other.localImagePath == this.localImagePath);
}

class RecommendationsCompanion extends UpdateCompanion<Recommendation> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> origin;
  final Value<String> outfitDataJson;
  final Value<String> weatherDataJson;
  final Value<bool> isFavorite;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> dirty;
  final Value<String?> imageUrl;
  final Value<String?> localImagePath;
  final Value<int> rowid;
  const RecommendationsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.origin = const Value.absent(),
    this.outfitDataJson = const Value.absent(),
    this.weatherDataJson = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecommendationsCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required String origin,
    required String outfitDataJson,
    required String weatherDataJson,
    required bool isFavorite,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastSyncedAt = const Value.absent(),
    required bool dirty,
    this.imageUrl = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        origin = Value(origin),
        outfitDataJson = Value(outfitDataJson),
        weatherDataJson = Value(weatherDataJson),
        isFavorite = Value(isFavorite),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        dirty = Value(dirty);
  static Insertable<Recommendation> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? origin,
    Expression<String>? outfitDataJson,
    Expression<String>? weatherDataJson,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? dirty,
    Expression<String>? imageUrl,
    Expression<String>? localImagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (origin != null) 'origin': origin,
      if (outfitDataJson != null) 'outfit_data_json': outfitDataJson,
      if (weatherDataJson != null) 'weather_data_json': weatherDataJson,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (dirty != null) 'dirty': dirty,
      if (imageUrl != null) 'image_url': imageUrl,
      if (localImagePath != null) 'local_image_path': localImagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecommendationsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? origin,
      Value<String>? outfitDataJson,
      Value<String>? weatherDataJson,
      Value<bool>? isFavorite,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? lastSyncedAt,
      Value<bool>? dirty,
      Value<String?>? imageUrl,
      Value<String?>? localImagePath,
      Value<int>? rowid}) {
    return RecommendationsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      origin: origin ?? this.origin,
      outfitDataJson: outfitDataJson ?? this.outfitDataJson,
      weatherDataJson: weatherDataJson ?? this.weatherDataJson,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      dirty: dirty ?? this.dirty,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (outfitDataJson.present) {
      map['outfit_data_json'] = Variable<String>(outfitDataJson.value);
    }
    if (weatherDataJson.present) {
      map['weather_data_json'] = Variable<String>(weatherDataJson.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (localImagePath.present) {
      map['local_image_path'] = Variable<String>(localImagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('origin: $origin, ')
          ..write('outfitDataJson: $outfitDataJson, ')
          ..write('weatherDataJson: $weatherDataJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('dirty: $dirty, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, action, entityType, entityId, payload, createdAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(Insertable<SyncOutboxData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    } else if (isInserting) {
      context.missing(_syncedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final int id;
  final String action;
  final String entityType;
  final String entityId;
  final String payload;
  final DateTime createdAt;
  final bool synced;
  const SyncOutboxData(
      {required this.id,
      required this.action,
      required this.entityType,
      required this.entityId,
      required this.payload,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      action: Value(action),
      entityType: Value(entityType),
      entityId: Value(entityId),
      payload: Value(payload),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory SyncOutboxData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      id: serializer.fromJson<int>(json['id']),
      action: serializer.fromJson<String>(json['action']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'action': serializer.toJson<String>(action),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  SyncOutboxData copyWith(
          {int? id,
          String? action,
          String? entityType,
          String? entityId,
          String? payload,
          DateTime? createdAt,
          bool? synced}) =>
      SyncOutboxData(
        id: id ?? this.id,
        action: action ?? this.action,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      action: data.action.present ? data.action.value : this.action,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, action, entityType, entityId, payload, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.id == this.id &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<int> id;
  final Value<String> action;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.id = const Value.absent(),
    required String action,
    required String entityType,
    required String entityId,
    required String payload,
    required DateTime createdAt,
    required bool synced,
  })  : action = Value(action),
        entityType = Value(entityType),
        entityId = Value(entityId),
        payload = Value(payload),
        createdAt = Value(createdAt),
        synced = Value(synced);
  static Insertable<SyncOutboxData> custom({
    Expression<int>? id,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
    });
  }

  SyncOutboxCompanion copyWith(
      {Value<int>? id,
      Value<String>? action,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<bool>? synced}) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) => Setting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WardrobeEntriesTable wardrobeEntries =
      $WardrobeEntriesTable(this);
  late final $RecommendationsTable recommendations =
      $RecommendationsTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final WardrobeDao wardrobeDao = WardrobeDao(this as AppDatabase);
  late final RecommendationDao recommendationDao =
      RecommendationDao(this as AppDatabase);
  late final SyncOutboxDao syncOutboxDao = SyncOutboxDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [wardrobeEntries, recommendations, syncOutbox, settings];
}

typedef $$WardrobeEntriesTableCreateCompanionBuilder = WardrobeEntriesCompanion
    Function({
  required String id,
  Value<String?> serverId,
  required String name,
  required String category,
  required String subcategory,
  required String style,
  required String iconEmoji,
  Value<String?> imageUrl,
  Value<String?> blurHash,
  Value<int?> minTemp,
  Value<int?> maxTemp,
  Value<int?> warmthLevel,
  required bool rainOk,
  required bool snowOk,
  required bool windOk,
  Value<String?> usage,
  Value<String?> materials,
  required int wearCount,
  Value<DateTime?> lastWornAt,
  required bool isFavorite,
  required bool isArchived,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> lastSyncedAt,
  required bool dirty,
  Value<String?> season,
  Value<String?> gender,
  Value<String?> fit,
  Value<String?> pattern,
  Value<String?> localImagePath,
  Value<int> rowid,
});
typedef $$WardrobeEntriesTableUpdateCompanionBuilder = WardrobeEntriesCompanion
    Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> name,
  Value<String> category,
  Value<String> subcategory,
  Value<String> style,
  Value<String> iconEmoji,
  Value<String?> imageUrl,
  Value<String?> blurHash,
  Value<int?> minTemp,
  Value<int?> maxTemp,
  Value<int?> warmthLevel,
  Value<bool> rainOk,
  Value<bool> snowOk,
  Value<bool> windOk,
  Value<String?> usage,
  Value<String?> materials,
  Value<int> wearCount,
  Value<DateTime?> lastWornAt,
  Value<bool> isFavorite,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> lastSyncedAt,
  Value<bool> dirty,
  Value<String?> season,
  Value<String?> gender,
  Value<String?> fit,
  Value<String?> pattern,
  Value<String?> localImagePath,
  Value<int> rowid,
});

class $$WardrobeEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WardrobeEntriesTable> {
  $$WardrobeEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subcategory => $composableBuilder(
      column: $table.subcategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get style => $composableBuilder(
      column: $table.style, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconEmoji => $composableBuilder(
      column: $table.iconEmoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get blurHash => $composableBuilder(
      column: $table.blurHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minTemp => $composableBuilder(
      column: $table.minTemp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxTemp => $composableBuilder(
      column: $table.maxTemp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get warmthLevel => $composableBuilder(
      column: $table.warmthLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get rainOk => $composableBuilder(
      column: $table.rainOk, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get snowOk => $composableBuilder(
      column: $table.snowOk, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get windOk => $composableBuilder(
      column: $table.windOk, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get usage => $composableBuilder(
      column: $table.usage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get materials => $composableBuilder(
      column: $table.materials, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wearCount => $composableBuilder(
      column: $table.wearCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastWornAt => $composableBuilder(
      column: $table.lastWornAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fit => $composableBuilder(
      column: $table.fit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pattern => $composableBuilder(
      column: $table.pattern, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnFilters(column));
}

class $$WardrobeEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WardrobeEntriesTable> {
  $$WardrobeEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subcategory => $composableBuilder(
      column: $table.subcategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get style => $composableBuilder(
      column: $table.style, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconEmoji => $composableBuilder(
      column: $table.iconEmoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get blurHash => $composableBuilder(
      column: $table.blurHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minTemp => $composableBuilder(
      column: $table.minTemp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxTemp => $composableBuilder(
      column: $table.maxTemp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get warmthLevel => $composableBuilder(
      column: $table.warmthLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get rainOk => $composableBuilder(
      column: $table.rainOk, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get snowOk => $composableBuilder(
      column: $table.snowOk, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get windOk => $composableBuilder(
      column: $table.windOk, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get usage => $composableBuilder(
      column: $table.usage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get materials => $composableBuilder(
      column: $table.materials, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wearCount => $composableBuilder(
      column: $table.wearCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastWornAt => $composableBuilder(
      column: $table.lastWornAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fit => $composableBuilder(
      column: $table.fit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pattern => $composableBuilder(
      column: $table.pattern, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnOrderings(column));
}

class $$WardrobeEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WardrobeEntriesTable> {
  $$WardrobeEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
      column: $table.subcategory, builder: (column) => column);

  GeneratedColumn<String> get style =>
      $composableBuilder(column: $table.style, builder: (column) => column);

  GeneratedColumn<String> get iconEmoji =>
      $composableBuilder(column: $table.iconEmoji, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get blurHash =>
      $composableBuilder(column: $table.blurHash, builder: (column) => column);

  GeneratedColumn<int> get minTemp =>
      $composableBuilder(column: $table.minTemp, builder: (column) => column);

  GeneratedColumn<int> get maxTemp =>
      $composableBuilder(column: $table.maxTemp, builder: (column) => column);

  GeneratedColumn<int> get warmthLevel => $composableBuilder(
      column: $table.warmthLevel, builder: (column) => column);

  GeneratedColumn<bool> get rainOk =>
      $composableBuilder(column: $table.rainOk, builder: (column) => column);

  GeneratedColumn<bool> get snowOk =>
      $composableBuilder(column: $table.snowOk, builder: (column) => column);

  GeneratedColumn<bool> get windOk =>
      $composableBuilder(column: $table.windOk, builder: (column) => column);

  GeneratedColumn<String> get usage =>
      $composableBuilder(column: $table.usage, builder: (column) => column);

  GeneratedColumn<String> get materials =>
      $composableBuilder(column: $table.materials, builder: (column) => column);

  GeneratedColumn<int> get wearCount =>
      $composableBuilder(column: $table.wearCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastWornAt => $composableBuilder(
      column: $table.lastWornAt, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get fit =>
      $composableBuilder(column: $table.fit, builder: (column) => column);

  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath, builder: (column) => column);
}

class $$WardrobeEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WardrobeEntriesTable,
    WardrobeEntry,
    $$WardrobeEntriesTableFilterComposer,
    $$WardrobeEntriesTableOrderingComposer,
    $$WardrobeEntriesTableAnnotationComposer,
    $$WardrobeEntriesTableCreateCompanionBuilder,
    $$WardrobeEntriesTableUpdateCompanionBuilder,
    (
      WardrobeEntry,
      BaseReferences<_$AppDatabase, $WardrobeEntriesTable, WardrobeEntry>
    ),
    WardrobeEntry,
    PrefetchHooks Function()> {
  $$WardrobeEntriesTableTableManager(
      _$AppDatabase db, $WardrobeEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WardrobeEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WardrobeEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WardrobeEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> subcategory = const Value.absent(),
            Value<String> style = const Value.absent(),
            Value<String> iconEmoji = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> blurHash = const Value.absent(),
            Value<int?> minTemp = const Value.absent(),
            Value<int?> maxTemp = const Value.absent(),
            Value<int?> warmthLevel = const Value.absent(),
            Value<bool> rainOk = const Value.absent(),
            Value<bool> snowOk = const Value.absent(),
            Value<bool> windOk = const Value.absent(),
            Value<String?> usage = const Value.absent(),
            Value<String?> materials = const Value.absent(),
            Value<int> wearCount = const Value.absent(),
            Value<DateTime?> lastWornAt = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<String?> season = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<String?> fit = const Value.absent(),
            Value<String?> pattern = const Value.absent(),
            Value<String?> localImagePath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WardrobeEntriesCompanion(
            id: id,
            serverId: serverId,
            name: name,
            category: category,
            subcategory: subcategory,
            style: style,
            iconEmoji: iconEmoji,
            imageUrl: imageUrl,
            blurHash: blurHash,
            minTemp: minTemp,
            maxTemp: maxTemp,
            warmthLevel: warmthLevel,
            rainOk: rainOk,
            snowOk: snowOk,
            windOk: windOk,
            usage: usage,
            materials: materials,
            wearCount: wearCount,
            lastWornAt: lastWornAt,
            isFavorite: isFavorite,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastSyncedAt: lastSyncedAt,
            dirty: dirty,
            season: season,
            gender: gender,
            fit: fit,
            pattern: pattern,
            localImagePath: localImagePath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            required String name,
            required String category,
            required String subcategory,
            required String style,
            required String iconEmoji,
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> blurHash = const Value.absent(),
            Value<int?> minTemp = const Value.absent(),
            Value<int?> maxTemp = const Value.absent(),
            Value<int?> warmthLevel = const Value.absent(),
            required bool rainOk,
            required bool snowOk,
            required bool windOk,
            Value<String?> usage = const Value.absent(),
            Value<String?> materials = const Value.absent(),
            required int wearCount,
            Value<DateTime?> lastWornAt = const Value.absent(),
            required bool isFavorite,
            required bool isArchived,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            required bool dirty,
            Value<String?> season = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<String?> fit = const Value.absent(),
            Value<String?> pattern = const Value.absent(),
            Value<String?> localImagePath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WardrobeEntriesCompanion.insert(
            id: id,
            serverId: serverId,
            name: name,
            category: category,
            subcategory: subcategory,
            style: style,
            iconEmoji: iconEmoji,
            imageUrl: imageUrl,
            blurHash: blurHash,
            minTemp: minTemp,
            maxTemp: maxTemp,
            warmthLevel: warmthLevel,
            rainOk: rainOk,
            snowOk: snowOk,
            windOk: windOk,
            usage: usage,
            materials: materials,
            wearCount: wearCount,
            lastWornAt: lastWornAt,
            isFavorite: isFavorite,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastSyncedAt: lastSyncedAt,
            dirty: dirty,
            season: season,
            gender: gender,
            fit: fit,
            pattern: pattern,
            localImagePath: localImagePath,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WardrobeEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WardrobeEntriesTable,
    WardrobeEntry,
    $$WardrobeEntriesTableFilterComposer,
    $$WardrobeEntriesTableOrderingComposer,
    $$WardrobeEntriesTableAnnotationComposer,
    $$WardrobeEntriesTableCreateCompanionBuilder,
    $$WardrobeEntriesTableUpdateCompanionBuilder,
    (
      WardrobeEntry,
      BaseReferences<_$AppDatabase, $WardrobeEntriesTable, WardrobeEntry>
    ),
    WardrobeEntry,
    PrefetchHooks Function()>;
typedef $$RecommendationsTableCreateCompanionBuilder = RecommendationsCompanion
    Function({
  required String id,
  Value<String?> serverId,
  required String origin,
  required String outfitDataJson,
  required String weatherDataJson,
  required bool isFavorite,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> lastSyncedAt,
  required bool dirty,
  Value<String?> imageUrl,
  Value<String?> localImagePath,
  Value<int> rowid,
});
typedef $$RecommendationsTableUpdateCompanionBuilder = RecommendationsCompanion
    Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> origin,
  Value<String> outfitDataJson,
  Value<String> weatherDataJson,
  Value<bool> isFavorite,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> lastSyncedAt,
  Value<bool> dirty,
  Value<String?> imageUrl,
  Value<String?> localImagePath,
  Value<int> rowid,
});

class $$RecommendationsTableFilterComposer
    extends Composer<_$AppDatabase, $RecommendationsTable> {
  $$RecommendationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outfitDataJson => $composableBuilder(
      column: $table.outfitDataJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weatherDataJson => $composableBuilder(
      column: $table.weatherDataJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnFilters(column));
}

class $$RecommendationsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecommendationsTable> {
  $$RecommendationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outfitDataJson => $composableBuilder(
      column: $table.outfitDataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weatherDataJson => $composableBuilder(
      column: $table.weatherDataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnOrderings(column));
}

class $$RecommendationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecommendationsTable> {
  $$RecommendationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get outfitDataJson => $composableBuilder(
      column: $table.outfitDataJson, builder: (column) => column);

  GeneratedColumn<String> get weatherDataJson => $composableBuilder(
      column: $table.weatherDataJson, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath, builder: (column) => column);
}

class $$RecommendationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecommendationsTable,
    Recommendation,
    $$RecommendationsTableFilterComposer,
    $$RecommendationsTableOrderingComposer,
    $$RecommendationsTableAnnotationComposer,
    $$RecommendationsTableCreateCompanionBuilder,
    $$RecommendationsTableUpdateCompanionBuilder,
    (
      Recommendation,
      BaseReferences<_$AppDatabase, $RecommendationsTable, Recommendation>
    ),
    Recommendation,
    PrefetchHooks Function()> {
  $$RecommendationsTableTableManager(
      _$AppDatabase db, $RecommendationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecommendationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecommendationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecommendationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> origin = const Value.absent(),
            Value<String> outfitDataJson = const Value.absent(),
            Value<String> weatherDataJson = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> localImagePath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecommendationsCompanion(
            id: id,
            serverId: serverId,
            origin: origin,
            outfitDataJson: outfitDataJson,
            weatherDataJson: weatherDataJson,
            isFavorite: isFavorite,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastSyncedAt: lastSyncedAt,
            dirty: dirty,
            imageUrl: imageUrl,
            localImagePath: localImagePath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            required String origin,
            required String outfitDataJson,
            required String weatherDataJson,
            required bool isFavorite,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            required bool dirty,
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> localImagePath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecommendationsCompanion.insert(
            id: id,
            serverId: serverId,
            origin: origin,
            outfitDataJson: outfitDataJson,
            weatherDataJson: weatherDataJson,
            isFavorite: isFavorite,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastSyncedAt: lastSyncedAt,
            dirty: dirty,
            imageUrl: imageUrl,
            localImagePath: localImagePath,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecommendationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecommendationsTable,
    Recommendation,
    $$RecommendationsTableFilterComposer,
    $$RecommendationsTableOrderingComposer,
    $$RecommendationsTableAnnotationComposer,
    $$RecommendationsTableCreateCompanionBuilder,
    $$RecommendationsTableUpdateCompanionBuilder,
    (
      Recommendation,
      BaseReferences<_$AppDatabase, $RecommendationsTable, Recommendation>
    ),
    Recommendation,
    PrefetchHooks Function()>;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> id,
  required String action,
  required String entityType,
  required String entityId,
  required String payload,
  required DateTime createdAt,
  required bool synced,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> id,
  Value<String> action,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<bool> synced,
});

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$SyncOutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncOutboxTable,
    SyncOutboxData,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (
      SyncOutboxData,
      BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>
    ),
    SyncOutboxData,
    PrefetchHooks Function()> {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
          }) =>
              SyncOutboxCompanion(
            id: id,
            action: action,
            entityType: entityType,
            entityId: entityId,
            payload: payload,
            createdAt: createdAt,
            synced: synced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String action,
            required String entityType,
            required String entityId,
            required String payload,
            required DateTime createdAt,
            required bool synced,
          }) =>
              SyncOutboxCompanion.insert(
            id: id,
            action: action,
            entityType: entityType,
            entityId: entityId,
            payload: payload,
            createdAt: createdAt,
            synced: synced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncOutboxTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncOutboxTable,
    SyncOutboxData,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (
      SyncOutboxData,
      BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>
    ),
    SyncOutboxData,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WardrobeEntriesTableTableManager get wardrobeEntries =>
      $$WardrobeEntriesTableTableManager(_db, _db.wardrobeEntries);
  $$RecommendationsTableTableManager get recommendations =>
      $$RecommendationsTableTableManager(_db, _db.recommendations);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
