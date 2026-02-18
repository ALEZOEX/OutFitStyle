// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wardrobe_database.dart';

// ignore_for_file: type=lint
class $ClothingItemsTable extends ClothingItems
    with TableInfo<$ClothingItemsTable, DbClothingItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClothingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _materialMeta = const VerificationMeta(
    'material',
  );
  @override
  late final GeneratedColumn<String> material = GeneratedColumn<String>(
    'material',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonsMeta = const VerificationMeta(
    'seasons',
  );
  @override
  late final GeneratedColumn<String> seasons = GeneratedColumn<String>(
    'seasons',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _weatherConditionsMeta = const VerificationMeta(
    'weatherConditions',
  );
  @override
  late final GeneratedColumn<String> weatherConditions =
      GeneratedColumn<String>(
        'weather_conditions',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _occasionsMeta = const VerificationMeta(
    'occasions',
  );
  @override
  late final GeneratedColumn<String> occasions = GeneratedColumn<String>(
    'occasions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timesWornMeta = const VerificationMeta(
    'timesWorn',
  );
  @override
  late final GeneratedColumn<int> timesWorn = GeneratedColumn<int>(
    'times_worn',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _comfortRatingMeta = const VerificationMeta(
    'comfortRating',
  );
  @override
  late final GeneratedColumn<double> comfortRating = GeneratedColumn<double>(
    'comfort_rating',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _addedDateMeta = const VerificationMeta(
    'addedDate',
  );
  @override
  late final GeneratedColumn<int> addedDate = GeneratedColumn<int>(
    'added_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastWornDateMeta = const VerificationMeta(
    'lastWornDate',
  );
  @override
  late final GeneratedColumn<int> lastWornDate = GeneratedColumn<int>(
    'last_worn_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<String> size = GeneratedColumn<String>(
    'size',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usageCountMeta = const VerificationMeta(
    'usageCount',
  );
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
    'usage_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    externalId,
    name,
    description,
    imageUrl,
    category,
    tags,
    color,
    brand,
    material,
    seasons,
    weatherConditions,
    occasions,
    isFavorite,
    isArchived,
    timesWorn,
    comfortRating,
    addedDate,
    createdAt,
    updatedAt,
    lastWornDate,
    price,
    size,
    usageCount,
    serverId,
    dirty,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clothing_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbClothingItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('material')) {
      context.handle(
        _materialMeta,
        material.isAcceptableOrUnknown(data['material']!, _materialMeta),
      );
    }
    if (data.containsKey('seasons')) {
      context.handle(
        _seasonsMeta,
        seasons.isAcceptableOrUnknown(data['seasons']!, _seasonsMeta),
      );
    }
    if (data.containsKey('weather_conditions')) {
      context.handle(
        _weatherConditionsMeta,
        weatherConditions.isAcceptableOrUnknown(
          data['weather_conditions']!,
          _weatherConditionsMeta,
        ),
      );
    }
    if (data.containsKey('occasions')) {
      context.handle(
        _occasionsMeta,
        occasions.isAcceptableOrUnknown(data['occasions']!, _occasionsMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('times_worn')) {
      context.handle(
        _timesWornMeta,
        timesWorn.isAcceptableOrUnknown(data['times_worn']!, _timesWornMeta),
      );
    }
    if (data.containsKey('comfort_rating')) {
      context.handle(
        _comfortRatingMeta,
        comfortRating.isAcceptableOrUnknown(
          data['comfort_rating']!,
          _comfortRatingMeta,
        ),
      );
    }
    if (data.containsKey('added_date')) {
      context.handle(
        _addedDateMeta,
        addedDate.isAcceptableOrUnknown(data['added_date']!, _addedDateMeta),
      );
    } else if (isInserting) {
      context.missing(_addedDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_worn_date')) {
      context.handle(
        _lastWornDateMeta,
        lastWornDate.isAcceptableOrUnknown(
          data['last_worn_date']!,
          _lastWornDateMeta,
        ),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('usage_count')) {
      context.handle(
        _usageCountMeta,
        usageCount.isAcceptableOrUnknown(data['usage_count']!, _usageCountMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbClothingItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbClothingItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      material: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material'],
      ),
      seasons: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seasons'],
      )!,
      weatherConditions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather_conditions'],
      )!,
      occasions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occasions'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      timesWorn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_worn'],
      )!,
      comfortRating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}comfort_rating'],
      )!,
      addedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      lastWornDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_worn_date'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      ),
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size'],
      ),
      usageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_count'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $ClothingItemsTable createAlias(String alias) {
    return $ClothingItemsTable(attachedDatabase, alias);
  }
}

class DbClothingItem extends DataClass implements Insertable<DbClothingItem> {
  final int id;
  final String? externalId;
  final String name;
  final String? description;
  final String? imageUrl;
  final String category;
  final String tags;
  final String? color;
  final String? brand;
  final String? material;
  final String seasons;
  final String weatherConditions;
  final String occasions;
  final bool isFavorite;
  final bool isArchived;
  final int timesWorn;
  final double comfortRating;
  final int addedDate;
  final int createdAt;
  final int updatedAt;
  final int? lastWornDate;
  final double? price;
  final String? size;
  final int usageCount;
  final String? serverId;
  final bool dirty;
  final int? lastSyncedAt;
  const DbClothingItem({
    required this.id,
    this.externalId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.category,
    required this.tags,
    this.color,
    this.brand,
    this.material,
    required this.seasons,
    required this.weatherConditions,
    required this.occasions,
    required this.isFavorite,
    required this.isArchived,
    required this.timesWorn,
    required this.comfortRating,
    required this.addedDate,
    required this.createdAt,
    required this.updatedAt,
    this.lastWornDate,
    this.price,
    this.size,
    required this.usageCount,
    this.serverId,
    required this.dirty,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['category'] = Variable<String>(category);
    map['tags'] = Variable<String>(tags);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || material != null) {
      map['material'] = Variable<String>(material);
    }
    map['seasons'] = Variable<String>(seasons);
    map['weather_conditions'] = Variable<String>(weatherConditions);
    map['occasions'] = Variable<String>(occasions);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_archived'] = Variable<bool>(isArchived);
    map['times_worn'] = Variable<int>(timesWorn);
    map['comfort_rating'] = Variable<double>(comfortRating);
    map['added_date'] = Variable<int>(addedDate);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || lastWornDate != null) {
      map['last_worn_date'] = Variable<int>(lastWornDate);
    }
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<double>(price);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<String>(size);
    }
    map['usage_count'] = Variable<int>(usageCount);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  ClothingItemsCompanion toCompanion(bool nullToAbsent) {
    return ClothingItemsCompanion(
      id: Value(id),
      externalId: externalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      category: Value(category),
      tags: Value(tags),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      material: material == null && nullToAbsent
          ? const Value.absent()
          : Value(material),
      seasons: Value(seasons),
      weatherConditions: Value(weatherConditions),
      occasions: Value(occasions),
      isFavorite: Value(isFavorite),
      isArchived: Value(isArchived),
      timesWorn: Value(timesWorn),
      comfortRating: Value(comfortRating),
      addedDate: Value(addedDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastWornDate: lastWornDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWornDate),
      price: price == null && nullToAbsent
          ? const Value.absent()
          : Value(price),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      usageCount: Value(usageCount),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      dirty: Value(dirty),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory DbClothingItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbClothingItem(
      id: serializer.fromJson<int>(json['id']),
      externalId: serializer.fromJson<String?>(json['externalId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      category: serializer.fromJson<String>(json['category']),
      tags: serializer.fromJson<String>(json['tags']),
      color: serializer.fromJson<String?>(json['color']),
      brand: serializer.fromJson<String?>(json['brand']),
      material: serializer.fromJson<String?>(json['material']),
      seasons: serializer.fromJson<String>(json['seasons']),
      weatherConditions: serializer.fromJson<String>(json['weatherConditions']),
      occasions: serializer.fromJson<String>(json['occasions']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      timesWorn: serializer.fromJson<int>(json['timesWorn']),
      comfortRating: serializer.fromJson<double>(json['comfortRating']),
      addedDate: serializer.fromJson<int>(json['addedDate']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      lastWornDate: serializer.fromJson<int?>(json['lastWornDate']),
      price: serializer.fromJson<double?>(json['price']),
      size: serializer.fromJson<String?>(json['size']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      lastSyncedAt: serializer.fromJson<int?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'externalId': serializer.toJson<String?>(externalId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'category': serializer.toJson<String>(category),
      'tags': serializer.toJson<String>(tags),
      'color': serializer.toJson<String?>(color),
      'brand': serializer.toJson<String?>(brand),
      'material': serializer.toJson<String?>(material),
      'seasons': serializer.toJson<String>(seasons),
      'weatherConditions': serializer.toJson<String>(weatherConditions),
      'occasions': serializer.toJson<String>(occasions),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isArchived': serializer.toJson<bool>(isArchived),
      'timesWorn': serializer.toJson<int>(timesWorn),
      'comfortRating': serializer.toJson<double>(comfortRating),
      'addedDate': serializer.toJson<int>(addedDate),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'lastWornDate': serializer.toJson<int?>(lastWornDate),
      'price': serializer.toJson<double?>(price),
      'size': serializer.toJson<String?>(size),
      'usageCount': serializer.toJson<int>(usageCount),
      'serverId': serializer.toJson<String?>(serverId),
      'dirty': serializer.toJson<bool>(dirty),
      'lastSyncedAt': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  DbClothingItem copyWith({
    int? id,
    Value<String?> externalId = const Value.absent(),
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    String? category,
    String? tags,
    Value<String?> color = const Value.absent(),
    Value<String?> brand = const Value.absent(),
    Value<String?> material = const Value.absent(),
    String? seasons,
    String? weatherConditions,
    String? occasions,
    bool? isFavorite,
    bool? isArchived,
    int? timesWorn,
    double? comfortRating,
    int? addedDate,
    int? createdAt,
    int? updatedAt,
    Value<int?> lastWornDate = const Value.absent(),
    Value<double?> price = const Value.absent(),
    Value<String?> size = const Value.absent(),
    int? usageCount,
    Value<String?> serverId = const Value.absent(),
    bool? dirty,
    Value<int?> lastSyncedAt = const Value.absent(),
  }) => DbClothingItem(
    id: id ?? this.id,
    externalId: externalId.present ? externalId.value : this.externalId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    category: category ?? this.category,
    tags: tags ?? this.tags,
    color: color.present ? color.value : this.color,
    brand: brand.present ? brand.value : this.brand,
    material: material.present ? material.value : this.material,
    seasons: seasons ?? this.seasons,
    weatherConditions: weatherConditions ?? this.weatherConditions,
    occasions: occasions ?? this.occasions,
    isFavorite: isFavorite ?? this.isFavorite,
    isArchived: isArchived ?? this.isArchived,
    timesWorn: timesWorn ?? this.timesWorn,
    comfortRating: comfortRating ?? this.comfortRating,
    addedDate: addedDate ?? this.addedDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastWornDate: lastWornDate.present ? lastWornDate.value : this.lastWornDate,
    price: price.present ? price.value : this.price,
    size: size.present ? size.value : this.size,
    usageCount: usageCount ?? this.usageCount,
    serverId: serverId.present ? serverId.value : this.serverId,
    dirty: dirty ?? this.dirty,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  DbClothingItem copyWithCompanion(ClothingItemsCompanion data) {
    return DbClothingItem(
      id: data.id.present ? data.id.value : this.id,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      category: data.category.present ? data.category.value : this.category,
      tags: data.tags.present ? data.tags.value : this.tags,
      color: data.color.present ? data.color.value : this.color,
      brand: data.brand.present ? data.brand.value : this.brand,
      material: data.material.present ? data.material.value : this.material,
      seasons: data.seasons.present ? data.seasons.value : this.seasons,
      weatherConditions: data.weatherConditions.present
          ? data.weatherConditions.value
          : this.weatherConditions,
      occasions: data.occasions.present ? data.occasions.value : this.occasions,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      timesWorn: data.timesWorn.present ? data.timesWorn.value : this.timesWorn,
      comfortRating: data.comfortRating.present
          ? data.comfortRating.value
          : this.comfortRating,
      addedDate: data.addedDate.present ? data.addedDate.value : this.addedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastWornDate: data.lastWornDate.present
          ? data.lastWornDate.value
          : this.lastWornDate,
      price: data.price.present ? data.price.value : this.price,
      size: data.size.present ? data.size.value : this.size,
      usageCount: data.usageCount.present
          ? data.usageCount.value
          : this.usageCount,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbClothingItem(')
          ..write('id: $id, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('category: $category, ')
          ..write('tags: $tags, ')
          ..write('color: $color, ')
          ..write('brand: $brand, ')
          ..write('material: $material, ')
          ..write('seasons: $seasons, ')
          ..write('weatherConditions: $weatherConditions, ')
          ..write('occasions: $occasions, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('timesWorn: $timesWorn, ')
          ..write('comfortRating: $comfortRating, ')
          ..write('addedDate: $addedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastWornDate: $lastWornDate, ')
          ..write('price: $price, ')
          ..write('size: $size, ')
          ..write('usageCount: $usageCount, ')
          ..write('serverId: $serverId, ')
          ..write('dirty: $dirty, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    externalId,
    name,
    description,
    imageUrl,
    category,
    tags,
    color,
    brand,
    material,
    seasons,
    weatherConditions,
    occasions,
    isFavorite,
    isArchived,
    timesWorn,
    comfortRating,
    addedDate,
    createdAt,
    updatedAt,
    lastWornDate,
    price,
    size,
    usageCount,
    serverId,
    dirty,
    lastSyncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbClothingItem &&
          other.id == this.id &&
          other.externalId == this.externalId &&
          other.name == this.name &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.category == this.category &&
          other.tags == this.tags &&
          other.color == this.color &&
          other.brand == this.brand &&
          other.material == this.material &&
          other.seasons == this.seasons &&
          other.weatherConditions == this.weatherConditions &&
          other.occasions == this.occasions &&
          other.isFavorite == this.isFavorite &&
          other.isArchived == this.isArchived &&
          other.timesWorn == this.timesWorn &&
          other.comfortRating == this.comfortRating &&
          other.addedDate == this.addedDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastWornDate == this.lastWornDate &&
          other.price == this.price &&
          other.size == this.size &&
          other.usageCount == this.usageCount &&
          other.serverId == this.serverId &&
          other.dirty == this.dirty &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ClothingItemsCompanion extends UpdateCompanion<DbClothingItem> {
  final Value<int> id;
  final Value<String?> externalId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> imageUrl;
  final Value<String> category;
  final Value<String> tags;
  final Value<String?> color;
  final Value<String?> brand;
  final Value<String?> material;
  final Value<String> seasons;
  final Value<String> weatherConditions;
  final Value<String> occasions;
  final Value<bool> isFavorite;
  final Value<bool> isArchived;
  final Value<int> timesWorn;
  final Value<double> comfortRating;
  final Value<int> addedDate;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> lastWornDate;
  final Value<double?> price;
  final Value<String?> size;
  final Value<int> usageCount;
  final Value<String?> serverId;
  final Value<bool> dirty;
  final Value<int?> lastSyncedAt;
  const ClothingItemsCompanion({
    this.id = const Value.absent(),
    this.externalId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.category = const Value.absent(),
    this.tags = const Value.absent(),
    this.color = const Value.absent(),
    this.brand = const Value.absent(),
    this.material = const Value.absent(),
    this.seasons = const Value.absent(),
    this.weatherConditions = const Value.absent(),
    this.occasions = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.timesWorn = const Value.absent(),
    this.comfortRating = const Value.absent(),
    this.addedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastWornDate = const Value.absent(),
    this.price = const Value.absent(),
    this.size = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.serverId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  ClothingItemsCompanion.insert({
    this.id = const Value.absent(),
    this.externalId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    required String category,
    this.tags = const Value.absent(),
    this.color = const Value.absent(),
    this.brand = const Value.absent(),
    this.material = const Value.absent(),
    this.seasons = const Value.absent(),
    this.weatherConditions = const Value.absent(),
    this.occasions = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.timesWorn = const Value.absent(),
    this.comfortRating = const Value.absent(),
    required int addedDate,
    required int createdAt,
    required int updatedAt,
    this.lastWornDate = const Value.absent(),
    this.price = const Value.absent(),
    this.size = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.serverId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  }) : name = Value(name),
       category = Value(category),
       addedDate = Value(addedDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DbClothingItem> custom({
    Expression<int>? id,
    Expression<String>? externalId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<String>? category,
    Expression<String>? tags,
    Expression<String>? color,
    Expression<String>? brand,
    Expression<String>? material,
    Expression<String>? seasons,
    Expression<String>? weatherConditions,
    Expression<String>? occasions,
    Expression<bool>? isFavorite,
    Expression<bool>? isArchived,
    Expression<int>? timesWorn,
    Expression<double>? comfortRating,
    Expression<int>? addedDate,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? lastWornDate,
    Expression<double>? price,
    Expression<String>? size,
    Expression<int>? usageCount,
    Expression<String>? serverId,
    Expression<bool>? dirty,
    Expression<int>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (externalId != null) 'external_id': externalId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags,
      if (color != null) 'color': color,
      if (brand != null) 'brand': brand,
      if (material != null) 'material': material,
      if (seasons != null) 'seasons': seasons,
      if (weatherConditions != null) 'weather_conditions': weatherConditions,
      if (occasions != null) 'occasions': occasions,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isArchived != null) 'is_archived': isArchived,
      if (timesWorn != null) 'times_worn': timesWorn,
      if (comfortRating != null) 'comfort_rating': comfortRating,
      if (addedDate != null) 'added_date': addedDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastWornDate != null) 'last_worn_date': lastWornDate,
      if (price != null) 'price': price,
      if (size != null) 'size': size,
      if (usageCount != null) 'usage_count': usageCount,
      if (serverId != null) 'server_id': serverId,
      if (dirty != null) 'dirty': dirty,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  ClothingItemsCompanion copyWith({
    Value<int>? id,
    Value<String?>? externalId,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? imageUrl,
    Value<String>? category,
    Value<String>? tags,
    Value<String?>? color,
    Value<String?>? brand,
    Value<String?>? material,
    Value<String>? seasons,
    Value<String>? weatherConditions,
    Value<String>? occasions,
    Value<bool>? isFavorite,
    Value<bool>? isArchived,
    Value<int>? timesWorn,
    Value<double>? comfortRating,
    Value<int>? addedDate,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? lastWornDate,
    Value<double?>? price,
    Value<String?>? size,
    Value<int>? usageCount,
    Value<String?>? serverId,
    Value<bool>? dirty,
    Value<int?>? lastSyncedAt,
  }) {
    return ClothingItemsCompanion(
      id: id ?? this.id,
      externalId: externalId ?? this.externalId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      brand: brand ?? this.brand,
      material: material ?? this.material,
      seasons: seasons ?? this.seasons,
      weatherConditions: weatherConditions ?? this.weatherConditions,
      occasions: occasions ?? this.occasions,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      timesWorn: timesWorn ?? this.timesWorn,
      comfortRating: comfortRating ?? this.comfortRating,
      addedDate: addedDate ?? this.addedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastWornDate: lastWornDate ?? this.lastWornDate,
      price: price ?? this.price,
      size: size ?? this.size,
      usageCount: usageCount ?? this.usageCount,
      serverId: serverId ?? this.serverId,
      dirty: dirty ?? this.dirty,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (material.present) {
      map['material'] = Variable<String>(material.value);
    }
    if (seasons.present) {
      map['seasons'] = Variable<String>(seasons.value);
    }
    if (weatherConditions.present) {
      map['weather_conditions'] = Variable<String>(weatherConditions.value);
    }
    if (occasions.present) {
      map['occasions'] = Variable<String>(occasions.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (timesWorn.present) {
      map['times_worn'] = Variable<int>(timesWorn.value);
    }
    if (comfortRating.present) {
      map['comfort_rating'] = Variable<double>(comfortRating.value);
    }
    if (addedDate.present) {
      map['added_date'] = Variable<int>(addedDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (lastWornDate.present) {
      map['last_worn_date'] = Variable<int>(lastWornDate.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClothingItemsCompanion(')
          ..write('id: $id, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('category: $category, ')
          ..write('tags: $tags, ')
          ..write('color: $color, ')
          ..write('brand: $brand, ')
          ..write('material: $material, ')
          ..write('seasons: $seasons, ')
          ..write('weatherConditions: $weatherConditions, ')
          ..write('occasions: $occasions, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('timesWorn: $timesWorn, ')
          ..write('comfortRating: $comfortRating, ')
          ..write('addedDate: $addedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastWornDate: $lastWornDate, ')
          ..write('price: $price, ')
          ..write('size: $size, ')
          ..write('usageCount: $usageCount, ')
          ..write('serverId: $serverId, ')
          ..write('dirty: $dirty, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $OutfitsTable extends Outfits with TableInfo<$OutfitsTable, DbOutfit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clothingItemIdsMeta = const VerificationMeta(
    'clothingItemIds',
  );
  @override
  late final GeneratedColumn<String> clothingItemIds = GeneratedColumn<String>(
    'clothing_item_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timesWornMeta = const VerificationMeta(
    'timesWorn',
  );
  @override
  late final GeneratedColumn<int> timesWorn = GeneratedColumn<int>(
    'times_worn',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _comfortRatingMeta = const VerificationMeta(
    'comfortRating',
  );
  @override
  late final GeneratedColumn<double> comfortRating = GeneratedColumn<double>(
    'comfort_rating',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _occasionsMeta = const VerificationMeta(
    'occasions',
  );
  @override
  late final GeneratedColumn<String> occasions = GeneratedColumn<String>(
    'occasions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _weatherConditionsMeta = const VerificationMeta(
    'weatherConditions',
  );
  @override
  late final GeneratedColumn<String> weatherConditions =
      GeneratedColumn<String>(
        'weather_conditions',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _seasonsMeta = const VerificationMeta(
    'seasons',
  );
  @override
  late final GeneratedColumn<String> seasons = GeneratedColumn<String>(
    'seasons',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _addedDateMeta = const VerificationMeta(
    'addedDate',
  );
  @override
  late final GeneratedColumn<int> addedDate = GeneratedColumn<int>(
    'added_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    externalId,
    name,
    description,
    imageUrl,
    clothingItemIds,
    isFavorite,
    timesWorn,
    comfortRating,
    tags,
    occasions,
    weatherConditions,
    seasons,
    addedDate,
    createdAt,
    updatedAt,
    serverId,
    dirty,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outfits';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbOutfit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('clothing_item_ids')) {
      context.handle(
        _clothingItemIdsMeta,
        clothingItemIds.isAcceptableOrUnknown(
          data['clothing_item_ids']!,
          _clothingItemIdsMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('times_worn')) {
      context.handle(
        _timesWornMeta,
        timesWorn.isAcceptableOrUnknown(data['times_worn']!, _timesWornMeta),
      );
    }
    if (data.containsKey('comfort_rating')) {
      context.handle(
        _comfortRatingMeta,
        comfortRating.isAcceptableOrUnknown(
          data['comfort_rating']!,
          _comfortRatingMeta,
        ),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('occasions')) {
      context.handle(
        _occasionsMeta,
        occasions.isAcceptableOrUnknown(data['occasions']!, _occasionsMeta),
      );
    }
    if (data.containsKey('weather_conditions')) {
      context.handle(
        _weatherConditionsMeta,
        weatherConditions.isAcceptableOrUnknown(
          data['weather_conditions']!,
          _weatherConditionsMeta,
        ),
      );
    }
    if (data.containsKey('seasons')) {
      context.handle(
        _seasonsMeta,
        seasons.isAcceptableOrUnknown(data['seasons']!, _seasonsMeta),
      );
    }
    if (data.containsKey('added_date')) {
      context.handle(
        _addedDateMeta,
        addedDate.isAcceptableOrUnknown(data['added_date']!, _addedDateMeta),
      );
    } else if (isInserting) {
      context.missing(_addedDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbOutfit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbOutfit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      clothingItemIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clothing_item_ids'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      timesWorn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_worn'],
      )!,
      comfortRating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}comfort_rating'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      occasions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occasions'],
      )!,
      weatherConditions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather_conditions'],
      )!,
      seasons: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seasons'],
      )!,
      addedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $OutfitsTable createAlias(String alias) {
    return $OutfitsTable(attachedDatabase, alias);
  }
}

class DbOutfit extends DataClass implements Insertable<DbOutfit> {
  final int id;
  final String? externalId;
  final String name;
  final String? description;
  final String? imageUrl;
  final String clothingItemIds;
  final bool isFavorite;
  final int timesWorn;
  final double comfortRating;
  final String tags;
  final String occasions;
  final String weatherConditions;
  final String seasons;
  final int addedDate;
  final int createdAt;
  final int updatedAt;
  final String? serverId;
  final bool dirty;
  final int? lastSyncedAt;
  const DbOutfit({
    required this.id,
    this.externalId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.clothingItemIds,
    required this.isFavorite,
    required this.timesWorn,
    required this.comfortRating,
    required this.tags,
    required this.occasions,
    required this.weatherConditions,
    required this.seasons,
    required this.addedDate,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    required this.dirty,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['clothing_item_ids'] = Variable<String>(clothingItemIds);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['times_worn'] = Variable<int>(timesWorn);
    map['comfort_rating'] = Variable<double>(comfortRating);
    map['tags'] = Variable<String>(tags);
    map['occasions'] = Variable<String>(occasions);
    map['weather_conditions'] = Variable<String>(weatherConditions);
    map['seasons'] = Variable<String>(seasons);
    map['added_date'] = Variable<int>(addedDate);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  OutfitsCompanion toCompanion(bool nullToAbsent) {
    return OutfitsCompanion(
      id: Value(id),
      externalId: externalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      clothingItemIds: Value(clothingItemIds),
      isFavorite: Value(isFavorite),
      timesWorn: Value(timesWorn),
      comfortRating: Value(comfortRating),
      tags: Value(tags),
      occasions: Value(occasions),
      weatherConditions: Value(weatherConditions),
      seasons: Value(seasons),
      addedDate: Value(addedDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      dirty: Value(dirty),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory DbOutfit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbOutfit(
      id: serializer.fromJson<int>(json['id']),
      externalId: serializer.fromJson<String?>(json['externalId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      clothingItemIds: serializer.fromJson<String>(json['clothingItemIds']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      timesWorn: serializer.fromJson<int>(json['timesWorn']),
      comfortRating: serializer.fromJson<double>(json['comfortRating']),
      tags: serializer.fromJson<String>(json['tags']),
      occasions: serializer.fromJson<String>(json['occasions']),
      weatherConditions: serializer.fromJson<String>(json['weatherConditions']),
      seasons: serializer.fromJson<String>(json['seasons']),
      addedDate: serializer.fromJson<int>(json['addedDate']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      lastSyncedAt: serializer.fromJson<int?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'externalId': serializer.toJson<String?>(externalId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'clothingItemIds': serializer.toJson<String>(clothingItemIds),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'timesWorn': serializer.toJson<int>(timesWorn),
      'comfortRating': serializer.toJson<double>(comfortRating),
      'tags': serializer.toJson<String>(tags),
      'occasions': serializer.toJson<String>(occasions),
      'weatherConditions': serializer.toJson<String>(weatherConditions),
      'seasons': serializer.toJson<String>(seasons),
      'addedDate': serializer.toJson<int>(addedDate),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'serverId': serializer.toJson<String?>(serverId),
      'dirty': serializer.toJson<bool>(dirty),
      'lastSyncedAt': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  DbOutfit copyWith({
    int? id,
    Value<String?> externalId = const Value.absent(),
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    String? clothingItemIds,
    bool? isFavorite,
    int? timesWorn,
    double? comfortRating,
    String? tags,
    String? occasions,
    String? weatherConditions,
    String? seasons,
    int? addedDate,
    int? createdAt,
    int? updatedAt,
    Value<String?> serverId = const Value.absent(),
    bool? dirty,
    Value<int?> lastSyncedAt = const Value.absent(),
  }) => DbOutfit(
    id: id ?? this.id,
    externalId: externalId.present ? externalId.value : this.externalId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    clothingItemIds: clothingItemIds ?? this.clothingItemIds,
    isFavorite: isFavorite ?? this.isFavorite,
    timesWorn: timesWorn ?? this.timesWorn,
    comfortRating: comfortRating ?? this.comfortRating,
    tags: tags ?? this.tags,
    occasions: occasions ?? this.occasions,
    weatherConditions: weatherConditions ?? this.weatherConditions,
    seasons: seasons ?? this.seasons,
    addedDate: addedDate ?? this.addedDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverId: serverId.present ? serverId.value : this.serverId,
    dirty: dirty ?? this.dirty,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  DbOutfit copyWithCompanion(OutfitsCompanion data) {
    return DbOutfit(
      id: data.id.present ? data.id.value : this.id,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      clothingItemIds: data.clothingItemIds.present
          ? data.clothingItemIds.value
          : this.clothingItemIds,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      timesWorn: data.timesWorn.present ? data.timesWorn.value : this.timesWorn,
      comfortRating: data.comfortRating.present
          ? data.comfortRating.value
          : this.comfortRating,
      tags: data.tags.present ? data.tags.value : this.tags,
      occasions: data.occasions.present ? data.occasions.value : this.occasions,
      weatherConditions: data.weatherConditions.present
          ? data.weatherConditions.value
          : this.weatherConditions,
      seasons: data.seasons.present ? data.seasons.value : this.seasons,
      addedDate: data.addedDate.present ? data.addedDate.value : this.addedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbOutfit(')
          ..write('id: $id, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('clothingItemIds: $clothingItemIds, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('timesWorn: $timesWorn, ')
          ..write('comfortRating: $comfortRating, ')
          ..write('tags: $tags, ')
          ..write('occasions: $occasions, ')
          ..write('weatherConditions: $weatherConditions, ')
          ..write('seasons: $seasons, ')
          ..write('addedDate: $addedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverId: $serverId, ')
          ..write('dirty: $dirty, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    externalId,
    name,
    description,
    imageUrl,
    clothingItemIds,
    isFavorite,
    timesWorn,
    comfortRating,
    tags,
    occasions,
    weatherConditions,
    seasons,
    addedDate,
    createdAt,
    updatedAt,
    serverId,
    dirty,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbOutfit &&
          other.id == this.id &&
          other.externalId == this.externalId &&
          other.name == this.name &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.clothingItemIds == this.clothingItemIds &&
          other.isFavorite == this.isFavorite &&
          other.timesWorn == this.timesWorn &&
          other.comfortRating == this.comfortRating &&
          other.tags == this.tags &&
          other.occasions == this.occasions &&
          other.weatherConditions == this.weatherConditions &&
          other.seasons == this.seasons &&
          other.addedDate == this.addedDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverId == this.serverId &&
          other.dirty == this.dirty &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class OutfitsCompanion extends UpdateCompanion<DbOutfit> {
  final Value<int> id;
  final Value<String?> externalId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> imageUrl;
  final Value<String> clothingItemIds;
  final Value<bool> isFavorite;
  final Value<int> timesWorn;
  final Value<double> comfortRating;
  final Value<String> tags;
  final Value<String> occasions;
  final Value<String> weatherConditions;
  final Value<String> seasons;
  final Value<int> addedDate;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String?> serverId;
  final Value<bool> dirty;
  final Value<int?> lastSyncedAt;
  const OutfitsCompanion({
    this.id = const Value.absent(),
    this.externalId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.clothingItemIds = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.timesWorn = const Value.absent(),
    this.comfortRating = const Value.absent(),
    this.tags = const Value.absent(),
    this.occasions = const Value.absent(),
    this.weatherConditions = const Value.absent(),
    this.seasons = const Value.absent(),
    this.addedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  OutfitsCompanion.insert({
    this.id = const Value.absent(),
    this.externalId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.clothingItemIds = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.timesWorn = const Value.absent(),
    this.comfortRating = const Value.absent(),
    this.tags = const Value.absent(),
    this.occasions = const Value.absent(),
    this.weatherConditions = const Value.absent(),
    this.seasons = const Value.absent(),
    required int addedDate,
    required int createdAt,
    required int updatedAt,
    this.serverId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  }) : name = Value(name),
       addedDate = Value(addedDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DbOutfit> custom({
    Expression<int>? id,
    Expression<String>? externalId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<String>? clothingItemIds,
    Expression<bool>? isFavorite,
    Expression<int>? timesWorn,
    Expression<double>? comfortRating,
    Expression<String>? tags,
    Expression<String>? occasions,
    Expression<String>? weatherConditions,
    Expression<String>? seasons,
    Expression<int>? addedDate,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? serverId,
    Expression<bool>? dirty,
    Expression<int>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (externalId != null) 'external_id': externalId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (clothingItemIds != null) 'clothing_item_ids': clothingItemIds,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (timesWorn != null) 'times_worn': timesWorn,
      if (comfortRating != null) 'comfort_rating': comfortRating,
      if (tags != null) 'tags': tags,
      if (occasions != null) 'occasions': occasions,
      if (weatherConditions != null) 'weather_conditions': weatherConditions,
      if (seasons != null) 'seasons': seasons,
      if (addedDate != null) 'added_date': addedDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverId != null) 'server_id': serverId,
      if (dirty != null) 'dirty': dirty,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  OutfitsCompanion copyWith({
    Value<int>? id,
    Value<String?>? externalId,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? imageUrl,
    Value<String>? clothingItemIds,
    Value<bool>? isFavorite,
    Value<int>? timesWorn,
    Value<double>? comfortRating,
    Value<String>? tags,
    Value<String>? occasions,
    Value<String>? weatherConditions,
    Value<String>? seasons,
    Value<int>? addedDate,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String?>? serverId,
    Value<bool>? dirty,
    Value<int?>? lastSyncedAt,
  }) {
    return OutfitsCompanion(
      id: id ?? this.id,
      externalId: externalId ?? this.externalId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      clothingItemIds: clothingItemIds ?? this.clothingItemIds,
      isFavorite: isFavorite ?? this.isFavorite,
      timesWorn: timesWorn ?? this.timesWorn,
      comfortRating: comfortRating ?? this.comfortRating,
      tags: tags ?? this.tags,
      occasions: occasions ?? this.occasions,
      weatherConditions: weatherConditions ?? this.weatherConditions,
      seasons: seasons ?? this.seasons,
      addedDate: addedDate ?? this.addedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      dirty: dirty ?? this.dirty,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (clothingItemIds.present) {
      map['clothing_item_ids'] = Variable<String>(clothingItemIds.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (timesWorn.present) {
      map['times_worn'] = Variable<int>(timesWorn.value);
    }
    if (comfortRating.present) {
      map['comfort_rating'] = Variable<double>(comfortRating.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (occasions.present) {
      map['occasions'] = Variable<String>(occasions.value);
    }
    if (weatherConditions.present) {
      map['weather_conditions'] = Variable<String>(weatherConditions.value);
    }
    if (seasons.present) {
      map['seasons'] = Variable<String>(seasons.value);
    }
    if (addedDate.present) {
      map['added_date'] = Variable<int>(addedDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutfitsCompanion(')
          ..write('id: $id, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('clothingItemIds: $clothingItemIds, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('timesWorn: $timesWorn, ')
          ..write('comfortRating: $comfortRating, ')
          ..write('tags: $tags, ')
          ..write('occasions: $occasions, ')
          ..write('weatherConditions: $weatherConditions, ')
          ..write('seasons: $seasons, ')
          ..write('addedDate: $addedDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverId: $serverId, ')
          ..write('dirty: $dirty, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $OutfitItemsTable extends OutfitItems
    with TableInfo<$OutfitItemsTable, DbOutfitItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _outfitIdMeta = const VerificationMeta(
    'outfitId',
  );
  @override
  late final GeneratedColumn<int> outfitId = GeneratedColumn<int>(
    'outfit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clothingItemIdMeta = const VerificationMeta(
    'clothingItemId',
  );
  @override
  late final GeneratedColumn<int> clothingItemId = GeneratedColumn<int>(
    'clothing_item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    outfitId,
    clothingItemId,
    sortOrder,
    isPrimary,
    metadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outfit_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbOutfitItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('outfit_id')) {
      context.handle(
        _outfitIdMeta,
        outfitId.isAcceptableOrUnknown(data['outfit_id']!, _outfitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_outfitIdMeta);
    }
    if (data.containsKey('clothing_item_id')) {
      context.handle(
        _clothingItemIdMeta,
        clothingItemId.isAcceptableOrUnknown(
          data['clothing_item_id']!,
          _clothingItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clothingItemIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbOutfitItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbOutfitItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      outfitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}outfit_id'],
      )!,
      clothingItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clothing_item_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      )!,
    );
  }

  @override
  $OutfitItemsTable createAlias(String alias) {
    return $OutfitItemsTable(attachedDatabase, alias);
  }
}

class DbOutfitItem extends DataClass implements Insertable<DbOutfitItem> {
  final int id;
  final int outfitId;
  final int clothingItemId;
  final int sortOrder;
  final bool isPrimary;
  final String metadata;
  const DbOutfitItem({
    required this.id,
    required this.outfitId,
    required this.clothingItemId,
    required this.sortOrder,
    required this.isPrimary,
    required this.metadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['outfit_id'] = Variable<int>(outfitId);
    map['clothing_item_id'] = Variable<int>(clothingItemId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['metadata'] = Variable<String>(metadata);
    return map;
  }

  OutfitItemsCompanion toCompanion(bool nullToAbsent) {
    return OutfitItemsCompanion(
      id: Value(id),
      outfitId: Value(outfitId),
      clothingItemId: Value(clothingItemId),
      sortOrder: Value(sortOrder),
      isPrimary: Value(isPrimary),
      metadata: Value(metadata),
    );
  }

  factory DbOutfitItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbOutfitItem(
      id: serializer.fromJson<int>(json['id']),
      outfitId: serializer.fromJson<int>(json['outfitId']),
      clothingItemId: serializer.fromJson<int>(json['clothingItemId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      metadata: serializer.fromJson<String>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'outfitId': serializer.toJson<int>(outfitId),
      'clothingItemId': serializer.toJson<int>(clothingItemId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'metadata': serializer.toJson<String>(metadata),
    };
  }

  DbOutfitItem copyWith({
    int? id,
    int? outfitId,
    int? clothingItemId,
    int? sortOrder,
    bool? isPrimary,
    String? metadata,
  }) => DbOutfitItem(
    id: id ?? this.id,
    outfitId: outfitId ?? this.outfitId,
    clothingItemId: clothingItemId ?? this.clothingItemId,
    sortOrder: sortOrder ?? this.sortOrder,
    isPrimary: isPrimary ?? this.isPrimary,
    metadata: metadata ?? this.metadata,
  );
  DbOutfitItem copyWithCompanion(OutfitItemsCompanion data) {
    return DbOutfitItem(
      id: data.id.present ? data.id.value : this.id,
      outfitId: data.outfitId.present ? data.outfitId.value : this.outfitId,
      clothingItemId: data.clothingItemId.present
          ? data.clothingItemId.value
          : this.clothingItemId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbOutfitItem(')
          ..write('id: $id, ')
          ..write('outfitId: $outfitId, ')
          ..write('clothingItemId: $clothingItemId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, outfitId, clothingItemId, sortOrder, isPrimary, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbOutfitItem &&
          other.id == this.id &&
          other.outfitId == this.outfitId &&
          other.clothingItemId == this.clothingItemId &&
          other.sortOrder == this.sortOrder &&
          other.isPrimary == this.isPrimary &&
          other.metadata == this.metadata);
}

class OutfitItemsCompanion extends UpdateCompanion<DbOutfitItem> {
  final Value<int> id;
  final Value<int> outfitId;
  final Value<int> clothingItemId;
  final Value<int> sortOrder;
  final Value<bool> isPrimary;
  final Value<String> metadata;
  const OutfitItemsCompanion({
    this.id = const Value.absent(),
    this.outfitId = const Value.absent(),
    this.clothingItemId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.metadata = const Value.absent(),
  });
  OutfitItemsCompanion.insert({
    this.id = const Value.absent(),
    required int outfitId,
    required int clothingItemId,
    this.sortOrder = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.metadata = const Value.absent(),
  }) : outfitId = Value(outfitId),
       clothingItemId = Value(clothingItemId);
  static Insertable<DbOutfitItem> custom({
    Expression<int>? id,
    Expression<int>? outfitId,
    Expression<int>? clothingItemId,
    Expression<int>? sortOrder,
    Expression<bool>? isPrimary,
    Expression<String>? metadata,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (outfitId != null) 'outfit_id': outfitId,
      if (clothingItemId != null) 'clothing_item_id': clothingItemId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (metadata != null) 'metadata': metadata,
    });
  }

  OutfitItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? outfitId,
    Value<int>? clothingItemId,
    Value<int>? sortOrder,
    Value<bool>? isPrimary,
    Value<String>? metadata,
  }) {
    return OutfitItemsCompanion(
      id: id ?? this.id,
      outfitId: outfitId ?? this.outfitId,
      clothingItemId: clothingItemId ?? this.clothingItemId,
      sortOrder: sortOrder ?? this.sortOrder,
      isPrimary: isPrimary ?? this.isPrimary,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (outfitId.present) {
      map['outfit_id'] = Variable<int>(outfitId.value);
    }
    if (clothingItemId.present) {
      map['clothing_item_id'] = Variable<int>(clothingItemId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutfitItemsCompanion(')
          ..write('id: $id, ')
          ..write('outfitId: $outfitId, ')
          ..write('clothingItemId: $clothingItemId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }
}

abstract class _$WardrobeDatabase extends GeneratedDatabase {
  _$WardrobeDatabase(QueryExecutor e) : super(e);
  $WardrobeDatabaseManager get managers => $WardrobeDatabaseManager(this);
  late final $ClothingItemsTable clothingItems = $ClothingItemsTable(this);
  late final $OutfitsTable outfits = $OutfitsTable(this);
  late final $OutfitItemsTable outfitItems = $OutfitItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clothingItems,
    outfits,
    outfitItems,
  ];
}

typedef $$ClothingItemsTableCreateCompanionBuilder =
    ClothingItemsCompanion Function({
      Value<int> id,
      Value<String?> externalId,
      required String name,
      Value<String?> description,
      Value<String?> imageUrl,
      required String category,
      Value<String> tags,
      Value<String?> color,
      Value<String?> brand,
      Value<String?> material,
      Value<String> seasons,
      Value<String> weatherConditions,
      Value<String> occasions,
      Value<bool> isFavorite,
      Value<bool> isArchived,
      Value<int> timesWorn,
      Value<double> comfortRating,
      required int addedDate,
      required int createdAt,
      required int updatedAt,
      Value<int?> lastWornDate,
      Value<double?> price,
      Value<String?> size,
      Value<int> usageCount,
      Value<String?> serverId,
      Value<bool> dirty,
      Value<int?> lastSyncedAt,
    });
typedef $$ClothingItemsTableUpdateCompanionBuilder =
    ClothingItemsCompanion Function({
      Value<int> id,
      Value<String?> externalId,
      Value<String> name,
      Value<String?> description,
      Value<String?> imageUrl,
      Value<String> category,
      Value<String> tags,
      Value<String?> color,
      Value<String?> brand,
      Value<String?> material,
      Value<String> seasons,
      Value<String> weatherConditions,
      Value<String> occasions,
      Value<bool> isFavorite,
      Value<bool> isArchived,
      Value<int> timesWorn,
      Value<double> comfortRating,
      Value<int> addedDate,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> lastWornDate,
      Value<double?> price,
      Value<String?> size,
      Value<int> usageCount,
      Value<String?> serverId,
      Value<bool> dirty,
      Value<int?> lastSyncedAt,
    });

class $$ClothingItemsTableFilterComposer
    extends Composer<_$WardrobeDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seasons => $composableBuilder(
    column: $table.seasons,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherConditions => $composableBuilder(
    column: $table.weatherConditions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occasions => $composableBuilder(
    column: $table.occasions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesWorn => $composableBuilder(
    column: $table.timesWorn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get comfortRating => $composableBuilder(
    column: $table.comfortRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastWornDate => $composableBuilder(
    column: $table.lastWornDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClothingItemsTableOrderingComposer
    extends Composer<_$WardrobeDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seasons => $composableBuilder(
    column: $table.seasons,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherConditions => $composableBuilder(
    column: $table.weatherConditions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occasions => $composableBuilder(
    column: $table.occasions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesWorn => $composableBuilder(
    column: $table.timesWorn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get comfortRating => $composableBuilder(
    column: $table.comfortRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastWornDate => $composableBuilder(
    column: $table.lastWornDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClothingItemsTableAnnotationComposer
    extends Composer<_$WardrobeDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get material =>
      $composableBuilder(column: $table.material, builder: (column) => column);

  GeneratedColumn<String> get seasons =>
      $composableBuilder(column: $table.seasons, builder: (column) => column);

  GeneratedColumn<String> get weatherConditions => $composableBuilder(
    column: $table.weatherConditions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get occasions =>
      $composableBuilder(column: $table.occasions, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timesWorn =>
      $composableBuilder(column: $table.timesWorn, builder: (column) => column);

  GeneratedColumn<double> get comfortRating => $composableBuilder(
    column: $table.comfortRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get addedDate =>
      $composableBuilder(column: $table.addedDate, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get lastWornDate => $composableBuilder(
    column: $table.lastWornDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$ClothingItemsTableTableManager
    extends
        RootTableManager<
          _$WardrobeDatabase,
          $ClothingItemsTable,
          DbClothingItem,
          $$ClothingItemsTableFilterComposer,
          $$ClothingItemsTableOrderingComposer,
          $$ClothingItemsTableAnnotationComposer,
          $$ClothingItemsTableCreateCompanionBuilder,
          $$ClothingItemsTableUpdateCompanionBuilder,
          (
            DbClothingItem,
            BaseReferences<
              _$WardrobeDatabase,
              $ClothingItemsTable,
              DbClothingItem
            >,
          ),
          DbClothingItem,
          PrefetchHooks Function()
        > {
  $$ClothingItemsTableTableManager(
    _$WardrobeDatabase db,
    $ClothingItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClothingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClothingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClothingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> material = const Value.absent(),
                Value<String> seasons = const Value.absent(),
                Value<String> weatherConditions = const Value.absent(),
                Value<String> occasions = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> timesWorn = const Value.absent(),
                Value<double> comfortRating = const Value.absent(),
                Value<int> addedDate = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> lastWornDate = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
              }) => ClothingItemsCompanion(
                id: id,
                externalId: externalId,
                name: name,
                description: description,
                imageUrl: imageUrl,
                category: category,
                tags: tags,
                color: color,
                brand: brand,
                material: material,
                seasons: seasons,
                weatherConditions: weatherConditions,
                occasions: occasions,
                isFavorite: isFavorite,
                isArchived: isArchived,
                timesWorn: timesWorn,
                comfortRating: comfortRating,
                addedDate: addedDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastWornDate: lastWornDate,
                price: price,
                size: size,
                usageCount: usageCount,
                serverId: serverId,
                dirty: dirty,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                required String category,
                Value<String> tags = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> material = const Value.absent(),
                Value<String> seasons = const Value.absent(),
                Value<String> weatherConditions = const Value.absent(),
                Value<String> occasions = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> timesWorn = const Value.absent(),
                Value<double> comfortRating = const Value.absent(),
                required int addedDate,
                required int createdAt,
                required int updatedAt,
                Value<int?> lastWornDate = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
              }) => ClothingItemsCompanion.insert(
                id: id,
                externalId: externalId,
                name: name,
                description: description,
                imageUrl: imageUrl,
                category: category,
                tags: tags,
                color: color,
                brand: brand,
                material: material,
                seasons: seasons,
                weatherConditions: weatherConditions,
                occasions: occasions,
                isFavorite: isFavorite,
                isArchived: isArchived,
                timesWorn: timesWorn,
                comfortRating: comfortRating,
                addedDate: addedDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastWornDate: lastWornDate,
                price: price,
                size: size,
                usageCount: usageCount,
                serverId: serverId,
                dirty: dirty,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClothingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$WardrobeDatabase,
      $ClothingItemsTable,
      DbClothingItem,
      $$ClothingItemsTableFilterComposer,
      $$ClothingItemsTableOrderingComposer,
      $$ClothingItemsTableAnnotationComposer,
      $$ClothingItemsTableCreateCompanionBuilder,
      $$ClothingItemsTableUpdateCompanionBuilder,
      (
        DbClothingItem,
        BaseReferences<_$WardrobeDatabase, $ClothingItemsTable, DbClothingItem>,
      ),
      DbClothingItem,
      PrefetchHooks Function()
    >;
typedef $$OutfitsTableCreateCompanionBuilder =
    OutfitsCompanion Function({
      Value<int> id,
      Value<String?> externalId,
      required String name,
      Value<String?> description,
      Value<String?> imageUrl,
      Value<String> clothingItemIds,
      Value<bool> isFavorite,
      Value<int> timesWorn,
      Value<double> comfortRating,
      Value<String> tags,
      Value<String> occasions,
      Value<String> weatherConditions,
      Value<String> seasons,
      required int addedDate,
      required int createdAt,
      required int updatedAt,
      Value<String?> serverId,
      Value<bool> dirty,
      Value<int?> lastSyncedAt,
    });
typedef $$OutfitsTableUpdateCompanionBuilder =
    OutfitsCompanion Function({
      Value<int> id,
      Value<String?> externalId,
      Value<String> name,
      Value<String?> description,
      Value<String?> imageUrl,
      Value<String> clothingItemIds,
      Value<bool> isFavorite,
      Value<int> timesWorn,
      Value<double> comfortRating,
      Value<String> tags,
      Value<String> occasions,
      Value<String> weatherConditions,
      Value<String> seasons,
      Value<int> addedDate,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String?> serverId,
      Value<bool> dirty,
      Value<int?> lastSyncedAt,
    });

class $$OutfitsTableFilterComposer
    extends Composer<_$WardrobeDatabase, $OutfitsTable> {
  $$OutfitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clothingItemIds => $composableBuilder(
    column: $table.clothingItemIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesWorn => $composableBuilder(
    column: $table.timesWorn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get comfortRating => $composableBuilder(
    column: $table.comfortRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occasions => $composableBuilder(
    column: $table.occasions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherConditions => $composableBuilder(
    column: $table.weatherConditions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seasons => $composableBuilder(
    column: $table.seasons,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutfitsTableOrderingComposer
    extends Composer<_$WardrobeDatabase, $OutfitsTable> {
  $$OutfitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clothingItemIds => $composableBuilder(
    column: $table.clothingItemIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesWorn => $composableBuilder(
    column: $table.timesWorn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get comfortRating => $composableBuilder(
    column: $table.comfortRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occasions => $composableBuilder(
    column: $table.occasions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherConditions => $composableBuilder(
    column: $table.weatherConditions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seasons => $composableBuilder(
    column: $table.seasons,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutfitsTableAnnotationComposer
    extends Composer<_$WardrobeDatabase, $OutfitsTable> {
  $$OutfitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get clothingItemIds => $composableBuilder(
    column: $table.clothingItemIds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timesWorn =>
      $composableBuilder(column: $table.timesWorn, builder: (column) => column);

  GeneratedColumn<double> get comfortRating => $composableBuilder(
    column: $table.comfortRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get occasions =>
      $composableBuilder(column: $table.occasions, builder: (column) => column);

  GeneratedColumn<String> get weatherConditions => $composableBuilder(
    column: $table.weatherConditions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seasons =>
      $composableBuilder(column: $table.seasons, builder: (column) => column);

  GeneratedColumn<int> get addedDate =>
      $composableBuilder(column: $table.addedDate, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$OutfitsTableTableManager
    extends
        RootTableManager<
          _$WardrobeDatabase,
          $OutfitsTable,
          DbOutfit,
          $$OutfitsTableFilterComposer,
          $$OutfitsTableOrderingComposer,
          $$OutfitsTableAnnotationComposer,
          $$OutfitsTableCreateCompanionBuilder,
          $$OutfitsTableUpdateCompanionBuilder,
          (
            DbOutfit,
            BaseReferences<_$WardrobeDatabase, $OutfitsTable, DbOutfit>,
          ),
          DbOutfit,
          PrefetchHooks Function()
        > {
  $$OutfitsTableTableManager(_$WardrobeDatabase db, $OutfitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutfitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutfitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutfitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String> clothingItemIds = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> timesWorn = const Value.absent(),
                Value<double> comfortRating = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> occasions = const Value.absent(),
                Value<String> weatherConditions = const Value.absent(),
                Value<String> seasons = const Value.absent(),
                Value<int> addedDate = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
              }) => OutfitsCompanion(
                id: id,
                externalId: externalId,
                name: name,
                description: description,
                imageUrl: imageUrl,
                clothingItemIds: clothingItemIds,
                isFavorite: isFavorite,
                timesWorn: timesWorn,
                comfortRating: comfortRating,
                tags: tags,
                occasions: occasions,
                weatherConditions: weatherConditions,
                seasons: seasons,
                addedDate: addedDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverId: serverId,
                dirty: dirty,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String> clothingItemIds = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> timesWorn = const Value.absent(),
                Value<double> comfortRating = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> occasions = const Value.absent(),
                Value<String> weatherConditions = const Value.absent(),
                Value<String> seasons = const Value.absent(),
                required int addedDate,
                required int createdAt,
                required int updatedAt,
                Value<String?> serverId = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
              }) => OutfitsCompanion.insert(
                id: id,
                externalId: externalId,
                name: name,
                description: description,
                imageUrl: imageUrl,
                clothingItemIds: clothingItemIds,
                isFavorite: isFavorite,
                timesWorn: timesWorn,
                comfortRating: comfortRating,
                tags: tags,
                occasions: occasions,
                weatherConditions: weatherConditions,
                seasons: seasons,
                addedDate: addedDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverId: serverId,
                dirty: dirty,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutfitsTableProcessedTableManager =
    ProcessedTableManager<
      _$WardrobeDatabase,
      $OutfitsTable,
      DbOutfit,
      $$OutfitsTableFilterComposer,
      $$OutfitsTableOrderingComposer,
      $$OutfitsTableAnnotationComposer,
      $$OutfitsTableCreateCompanionBuilder,
      $$OutfitsTableUpdateCompanionBuilder,
      (DbOutfit, BaseReferences<_$WardrobeDatabase, $OutfitsTable, DbOutfit>),
      DbOutfit,
      PrefetchHooks Function()
    >;
typedef $$OutfitItemsTableCreateCompanionBuilder =
    OutfitItemsCompanion Function({
      Value<int> id,
      required int outfitId,
      required int clothingItemId,
      Value<int> sortOrder,
      Value<bool> isPrimary,
      Value<String> metadata,
    });
typedef $$OutfitItemsTableUpdateCompanionBuilder =
    OutfitItemsCompanion Function({
      Value<int> id,
      Value<int> outfitId,
      Value<int> clothingItemId,
      Value<int> sortOrder,
      Value<bool> isPrimary,
      Value<String> metadata,
    });

class $$OutfitItemsTableFilterComposer
    extends Composer<_$WardrobeDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get outfitId => $composableBuilder(
    column: $table.outfitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clothingItemId => $composableBuilder(
    column: $table.clothingItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutfitItemsTableOrderingComposer
    extends Composer<_$WardrobeDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outfitId => $composableBuilder(
    column: $table.outfitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clothingItemId => $composableBuilder(
    column: $table.clothingItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutfitItemsTableAnnotationComposer
    extends Composer<_$WardrobeDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get outfitId =>
      $composableBuilder(column: $table.outfitId, builder: (column) => column);

  GeneratedColumn<int> get clothingItemId => $composableBuilder(
    column: $table.clothingItemId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);
}

class $$OutfitItemsTableTableManager
    extends
        RootTableManager<
          _$WardrobeDatabase,
          $OutfitItemsTable,
          DbOutfitItem,
          $$OutfitItemsTableFilterComposer,
          $$OutfitItemsTableOrderingComposer,
          $$OutfitItemsTableAnnotationComposer,
          $$OutfitItemsTableCreateCompanionBuilder,
          $$OutfitItemsTableUpdateCompanionBuilder,
          (
            DbOutfitItem,
            BaseReferences<_$WardrobeDatabase, $OutfitItemsTable, DbOutfitItem>,
          ),
          DbOutfitItem,
          PrefetchHooks Function()
        > {
  $$OutfitItemsTableTableManager(_$WardrobeDatabase db, $OutfitItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutfitItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutfitItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutfitItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> outfitId = const Value.absent(),
                Value<int> clothingItemId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<String> metadata = const Value.absent(),
              }) => OutfitItemsCompanion(
                id: id,
                outfitId: outfitId,
                clothingItemId: clothingItemId,
                sortOrder: sortOrder,
                isPrimary: isPrimary,
                metadata: metadata,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int outfitId,
                required int clothingItemId,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<String> metadata = const Value.absent(),
              }) => OutfitItemsCompanion.insert(
                id: id,
                outfitId: outfitId,
                clothingItemId: clothingItemId,
                sortOrder: sortOrder,
                isPrimary: isPrimary,
                metadata: metadata,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutfitItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$WardrobeDatabase,
      $OutfitItemsTable,
      DbOutfitItem,
      $$OutfitItemsTableFilterComposer,
      $$OutfitItemsTableOrderingComposer,
      $$OutfitItemsTableAnnotationComposer,
      $$OutfitItemsTableCreateCompanionBuilder,
      $$OutfitItemsTableUpdateCompanionBuilder,
      (
        DbOutfitItem,
        BaseReferences<_$WardrobeDatabase, $OutfitItemsTable, DbOutfitItem>,
      ),
      DbOutfitItem,
      PrefetchHooks Function()
    >;

class $WardrobeDatabaseManager {
  final _$WardrobeDatabase _db;
  $WardrobeDatabaseManager(this._db);
  $$ClothingItemsTableTableManager get clothingItems =>
      $$ClothingItemsTableTableManager(_db, _db.clothingItems);
  $$OutfitsTableTableManager get outfits =>
      $$OutfitsTableTableManager(_db, _db.outfits);
  $$OutfitItemsTableTableManager get outfitItems =>
      $$OutfitItemsTableTableManager(_db, _db.outfitItems);
}
