// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wardrobe_database.dart';

// ignore_for_file: type=lint
class $ClothingItemsTable extends ClothingItems
    with drift.TableInfo<$ClothingItemsTable, DbClothingItem> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClothingItemsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
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
  static const drift.VerificationMeta _externalIdMeta =
      const drift.VerificationMeta('externalId');
  @override
  late final drift.GeneratedColumn<String> externalId =
      drift.GeneratedColumn<String>(
        'external_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _nameMeta = const drift.VerificationMeta(
    'name',
  );
  @override
  late final drift.GeneratedColumn<String> name = drift.GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _descriptionMeta =
      const drift.VerificationMeta('description');
  @override
  late final drift.GeneratedColumn<String> description =
      drift.GeneratedColumn<String>(
        'description',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _imageUrlMeta =
      const drift.VerificationMeta('imageUrl');
  @override
  late final drift.GeneratedColumn<String> imageUrl =
      drift.GeneratedColumn<String>(
        'image_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _categoryMeta =
      const drift.VerificationMeta('category');
  @override
  late final drift.GeneratedColumn<String> category =
      drift.GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _tagsMeta = const drift.VerificationMeta(
    'tags',
  );
  @override
  late final drift.GeneratedColumn<String> tags = drift.GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const drift.Constant('[]'),
  );
  static const drift.VerificationMeta _colorMeta = const drift.VerificationMeta(
    'color',
  );
  @override
  late final drift.GeneratedColumn<String> color =
      drift.GeneratedColumn<String>(
        'color',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _brandMeta = const drift.VerificationMeta(
    'brand',
  );
  @override
  late final drift.GeneratedColumn<String> brand =
      drift.GeneratedColumn<String>(
        'brand',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _materialMeta =
      const drift.VerificationMeta('material');
  @override
  late final drift.GeneratedColumn<String> material =
      drift.GeneratedColumn<String>(
        'material',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _seasonsMeta =
      const drift.VerificationMeta('seasons');
  @override
  late final drift.GeneratedColumn<String> seasons =
      drift.GeneratedColumn<String>(
        'seasons',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const drift.Constant('[]'),
      );
  static const drift.VerificationMeta _weatherConditionsMeta =
      const drift.VerificationMeta('weatherConditions');
  @override
  late final drift.GeneratedColumn<String> weatherConditions =
      drift.GeneratedColumn<String>(
        'weather_conditions',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const drift.Constant('[]'),
      );
  static const drift.VerificationMeta _occasionsMeta =
      const drift.VerificationMeta('occasions');
  @override
  late final drift.GeneratedColumn<String> occasions =
      drift.GeneratedColumn<String>(
        'occasions',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const drift.Constant('[]'),
      );
  static const drift.VerificationMeta _isFavoriteMeta =
      const drift.VerificationMeta('isFavorite');
  @override
  late final drift.GeneratedColumn<bool> isFavorite =
      drift.GeneratedColumn<bool>(
        'is_favorite',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_favorite" IN (0, 1))',
        ),
        defaultValue: const drift.Constant(false),
      );
  static const drift.VerificationMeta _isArchivedMeta =
      const drift.VerificationMeta('isArchived');
  @override
  late final drift.GeneratedColumn<bool> isArchived =
      drift.GeneratedColumn<bool>(
        'is_archived',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_archived" IN (0, 1))',
        ),
        defaultValue: const drift.Constant(false),
      );
  static const drift.VerificationMeta _timesWornMeta =
      const drift.VerificationMeta('timesWorn');
  @override
  late final drift.GeneratedColumn<int> timesWorn = drift.GeneratedColumn<int>(
    'times_worn',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const drift.Constant(0),
  );
  static const drift.VerificationMeta _comfortRatingMeta =
      const drift.VerificationMeta('comfortRating');
  @override
  late final drift.GeneratedColumn<double> comfortRating =
      drift.GeneratedColumn<double>(
        'comfort_rating',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const drift.Constant(0.0),
      );
  static const drift.VerificationMeta _addedDateMeta =
      const drift.VerificationMeta('addedDate');
  @override
  late final drift.GeneratedColumn<int> addedDate = drift.GeneratedColumn<int>(
    'added_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _createdAtMeta =
      const drift.VerificationMeta('createdAt');
  @override
  late final drift.GeneratedColumn<int> createdAt = drift.GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _updatedAtMeta =
      const drift.VerificationMeta('updatedAt');
  @override
  late final drift.GeneratedColumn<int> updatedAt = drift.GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _lastWornDateMeta =
      const drift.VerificationMeta('lastWornDate');
  @override
  late final drift.GeneratedColumn<int> lastWornDate =
      drift.GeneratedColumn<int>(
        'last_worn_date',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _priceMeta = const drift.VerificationMeta(
    'price',
  );
  @override
  late final drift.GeneratedColumn<double> price =
      drift.GeneratedColumn<double>(
        'price',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _sizeMeta = const drift.VerificationMeta(
    'size',
  );
  @override
  late final drift.GeneratedColumn<String> size = drift.GeneratedColumn<String>(
    'size',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const drift.VerificationMeta _usageCountMeta =
      const drift.VerificationMeta('usageCount');
  @override
  late final drift.GeneratedColumn<int> usageCount = drift.GeneratedColumn<int>(
    'usage_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const drift.Constant(0),
  );
  static const drift.VerificationMeta _serverIdMeta =
      const drift.VerificationMeta('serverId');
  @override
  late final drift.GeneratedColumn<String> serverId =
      drift.GeneratedColumn<String>(
        'server_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _dirtyMeta = const drift.VerificationMeta(
    'dirty',
  );
  @override
  late final drift.GeneratedColumn<bool> dirty = drift.GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const drift.Constant(false),
  );
  static const drift.VerificationMeta _lastSyncedAtMeta =
      const drift.VerificationMeta('lastSyncedAt');
  @override
  late final drift.GeneratedColumn<int> lastSyncedAt =
      drift.GeneratedColumn<int>(
        'last_synced_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<drift.GeneratedColumn> get $columns => [
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
  drift.VerificationContext validateIntegrity(
    drift.Insertable<DbClothingItem> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
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
  Set<drift.GeneratedColumn> get $primaryKey => {id};
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

class DbClothingItem extends drift.DataClass
    implements drift.Insertable<DbClothingItem> {
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
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = drift.Variable<String>(externalId);
    }
    map['name'] = drift.Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = drift.Variable<String>(description);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = drift.Variable<String>(imageUrl);
    }
    map['category'] = drift.Variable<String>(category);
    map['tags'] = drift.Variable<String>(tags);
    if (!nullToAbsent || color != null) {
      map['color'] = drift.Variable<String>(color);
    }
    if (!nullToAbsent || brand != null) {
      map['brand'] = drift.Variable<String>(brand);
    }
    if (!nullToAbsent || material != null) {
      map['material'] = drift.Variable<String>(material);
    }
    map['seasons'] = drift.Variable<String>(seasons);
    map['weather_conditions'] = drift.Variable<String>(weatherConditions);
    map['occasions'] = drift.Variable<String>(occasions);
    map['is_favorite'] = drift.Variable<bool>(isFavorite);
    map['is_archived'] = drift.Variable<bool>(isArchived);
    map['times_worn'] = drift.Variable<int>(timesWorn);
    map['comfort_rating'] = drift.Variable<double>(comfortRating);
    map['added_date'] = drift.Variable<int>(addedDate);
    map['created_at'] = drift.Variable<int>(createdAt);
    map['updated_at'] = drift.Variable<int>(updatedAt);
    if (!nullToAbsent || lastWornDate != null) {
      map['last_worn_date'] = drift.Variable<int>(lastWornDate);
    }
    if (!nullToAbsent || price != null) {
      map['price'] = drift.Variable<double>(price);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = drift.Variable<String>(size);
    }
    map['usage_count'] = drift.Variable<int>(usageCount);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = drift.Variable<String>(serverId);
    }
    map['dirty'] = drift.Variable<bool>(dirty);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = drift.Variable<int>(lastSyncedAt);
    }
    return map;
  }

  ClothingItemsCompanion toCompanion(bool nullToAbsent) {
    return ClothingItemsCompanion(
      id: drift.Value(id),
      externalId: externalId == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(externalId),
      name: drift.Value(name),
      description: description == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(description),
      imageUrl: imageUrl == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(imageUrl),
      category: drift.Value(category),
      tags: drift.Value(tags),
      color: color == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(color),
      brand: brand == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(brand),
      material: material == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(material),
      seasons: drift.Value(seasons),
      weatherConditions: drift.Value(weatherConditions),
      occasions: drift.Value(occasions),
      isFavorite: drift.Value(isFavorite),
      isArchived: drift.Value(isArchived),
      timesWorn: drift.Value(timesWorn),
      comfortRating: drift.Value(comfortRating),
      addedDate: drift.Value(addedDate),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
      lastWornDate: lastWornDate == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(lastWornDate),
      price: price == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(price),
      size: size == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(size),
      usageCount: drift.Value(usageCount),
      serverId: serverId == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(serverId),
      dirty: drift.Value(dirty),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(lastSyncedAt),
    );
  }

  factory DbClothingItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
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
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
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
    drift.Value<String?> externalId = const drift.Value.absent(),
    String? name,
    drift.Value<String?> description = const drift.Value.absent(),
    drift.Value<String?> imageUrl = const drift.Value.absent(),
    String? category,
    String? tags,
    drift.Value<String?> color = const drift.Value.absent(),
    drift.Value<String?> brand = const drift.Value.absent(),
    drift.Value<String?> material = const drift.Value.absent(),
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
    drift.Value<int?> lastWornDate = const drift.Value.absent(),
    drift.Value<double?> price = const drift.Value.absent(),
    drift.Value<String?> size = const drift.Value.absent(),
    int? usageCount,
    drift.Value<String?> serverId = const drift.Value.absent(),
    bool? dirty,
    drift.Value<int?> lastSyncedAt = const drift.Value.absent(),
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

class ClothingItemsCompanion extends drift.UpdateCompanion<DbClothingItem> {
  final drift.Value<int> id;
  final drift.Value<String?> externalId;
  final drift.Value<String> name;
  final drift.Value<String?> description;
  final drift.Value<String?> imageUrl;
  final drift.Value<String> category;
  final drift.Value<String> tags;
  final drift.Value<String?> color;
  final drift.Value<String?> brand;
  final drift.Value<String?> material;
  final drift.Value<String> seasons;
  final drift.Value<String> weatherConditions;
  final drift.Value<String> occasions;
  final drift.Value<bool> isFavorite;
  final drift.Value<bool> isArchived;
  final drift.Value<int> timesWorn;
  final drift.Value<double> comfortRating;
  final drift.Value<int> addedDate;
  final drift.Value<int> createdAt;
  final drift.Value<int> updatedAt;
  final drift.Value<int?> lastWornDate;
  final drift.Value<double?> price;
  final drift.Value<String?> size;
  final drift.Value<int> usageCount;
  final drift.Value<String?> serverId;
  final drift.Value<bool> dirty;
  final drift.Value<int?> lastSyncedAt;
  const ClothingItemsCompanion({
    this.id = const drift.Value.absent(),
    this.externalId = const drift.Value.absent(),
    this.name = const drift.Value.absent(),
    this.description = const drift.Value.absent(),
    this.imageUrl = const drift.Value.absent(),
    this.category = const drift.Value.absent(),
    this.tags = const drift.Value.absent(),
    this.color = const drift.Value.absent(),
    this.brand = const drift.Value.absent(),
    this.material = const drift.Value.absent(),
    this.seasons = const drift.Value.absent(),
    this.weatherConditions = const drift.Value.absent(),
    this.occasions = const drift.Value.absent(),
    this.isFavorite = const drift.Value.absent(),
    this.isArchived = const drift.Value.absent(),
    this.timesWorn = const drift.Value.absent(),
    this.comfortRating = const drift.Value.absent(),
    this.addedDate = const drift.Value.absent(),
    this.createdAt = const drift.Value.absent(),
    this.updatedAt = const drift.Value.absent(),
    this.lastWornDate = const drift.Value.absent(),
    this.price = const drift.Value.absent(),
    this.size = const drift.Value.absent(),
    this.usageCount = const drift.Value.absent(),
    this.serverId = const drift.Value.absent(),
    this.dirty = const drift.Value.absent(),
    this.lastSyncedAt = const drift.Value.absent(),
  });
  ClothingItemsCompanion.insert({
    this.id = const drift.Value.absent(),
    this.externalId = const drift.Value.absent(),
    required String name,
    this.description = const drift.Value.absent(),
    this.imageUrl = const drift.Value.absent(),
    required String category,
    this.tags = const drift.Value.absent(),
    this.color = const drift.Value.absent(),
    this.brand = const drift.Value.absent(),
    this.material = const drift.Value.absent(),
    this.seasons = const drift.Value.absent(),
    this.weatherConditions = const drift.Value.absent(),
    this.occasions = const drift.Value.absent(),
    this.isFavorite = const drift.Value.absent(),
    this.isArchived = const drift.Value.absent(),
    this.timesWorn = const drift.Value.absent(),
    this.comfortRating = const drift.Value.absent(),
    required int addedDate,
    required int createdAt,
    required int updatedAt,
    this.lastWornDate = const drift.Value.absent(),
    this.price = const drift.Value.absent(),
    this.size = const drift.Value.absent(),
    this.usageCount = const drift.Value.absent(),
    this.serverId = const drift.Value.absent(),
    this.dirty = const drift.Value.absent(),
    this.lastSyncedAt = const drift.Value.absent(),
  }) : name = drift.Value(name),
       category = drift.Value(category),
       addedDate = drift.Value(addedDate),
       createdAt = drift.Value(createdAt),
       updatedAt = drift.Value(updatedAt);
  static drift.Insertable<DbClothingItem> custom({
    drift.Expression<int>? id,
    drift.Expression<String>? externalId,
    drift.Expression<String>? name,
    drift.Expression<String>? description,
    drift.Expression<String>? imageUrl,
    drift.Expression<String>? category,
    drift.Expression<String>? tags,
    drift.Expression<String>? color,
    drift.Expression<String>? brand,
    drift.Expression<String>? material,
    drift.Expression<String>? seasons,
    drift.Expression<String>? weatherConditions,
    drift.Expression<String>? occasions,
    drift.Expression<bool>? isFavorite,
    drift.Expression<bool>? isArchived,
    drift.Expression<int>? timesWorn,
    drift.Expression<double>? comfortRating,
    drift.Expression<int>? addedDate,
    drift.Expression<int>? createdAt,
    drift.Expression<int>? updatedAt,
    drift.Expression<int>? lastWornDate,
    drift.Expression<double>? price,
    drift.Expression<String>? size,
    drift.Expression<int>? usageCount,
    drift.Expression<String>? serverId,
    drift.Expression<bool>? dirty,
    drift.Expression<int>? lastSyncedAt,
  }) {
    return drift.RawValuesInsertable({
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
    drift.Value<int>? id,
    drift.Value<String?>? externalId,
    drift.Value<String>? name,
    drift.Value<String?>? description,
    drift.Value<String?>? imageUrl,
    drift.Value<String>? category,
    drift.Value<String>? tags,
    drift.Value<String?>? color,
    drift.Value<String?>? brand,
    drift.Value<String?>? material,
    drift.Value<String>? seasons,
    drift.Value<String>? weatherConditions,
    drift.Value<String>? occasions,
    drift.Value<bool>? isFavorite,
    drift.Value<bool>? isArchived,
    drift.Value<int>? timesWorn,
    drift.Value<double>? comfortRating,
    drift.Value<int>? addedDate,
    drift.Value<int>? createdAt,
    drift.Value<int>? updatedAt,
    drift.Value<int?>? lastWornDate,
    drift.Value<double?>? price,
    drift.Value<String?>? size,
    drift.Value<int>? usageCount,
    drift.Value<String?>? serverId,
    drift.Value<bool>? dirty,
    drift.Value<int?>? lastSyncedAt,
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
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (externalId.present) {
      map['external_id'] = drift.Variable<String>(externalId.value);
    }
    if (name.present) {
      map['name'] = drift.Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = drift.Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = drift.Variable<String>(imageUrl.value);
    }
    if (category.present) {
      map['category'] = drift.Variable<String>(category.value);
    }
    if (tags.present) {
      map['tags'] = drift.Variable<String>(tags.value);
    }
    if (color.present) {
      map['color'] = drift.Variable<String>(color.value);
    }
    if (brand.present) {
      map['brand'] = drift.Variable<String>(brand.value);
    }
    if (material.present) {
      map['material'] = drift.Variable<String>(material.value);
    }
    if (seasons.present) {
      map['seasons'] = drift.Variable<String>(seasons.value);
    }
    if (weatherConditions.present) {
      map['weather_conditions'] = drift.Variable<String>(
        weatherConditions.value,
      );
    }
    if (occasions.present) {
      map['occasions'] = drift.Variable<String>(occasions.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = drift.Variable<bool>(isFavorite.value);
    }
    if (isArchived.present) {
      map['is_archived'] = drift.Variable<bool>(isArchived.value);
    }
    if (timesWorn.present) {
      map['times_worn'] = drift.Variable<int>(timesWorn.value);
    }
    if (comfortRating.present) {
      map['comfort_rating'] = drift.Variable<double>(comfortRating.value);
    }
    if (addedDate.present) {
      map['added_date'] = drift.Variable<int>(addedDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = drift.Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = drift.Variable<int>(updatedAt.value);
    }
    if (lastWornDate.present) {
      map['last_worn_date'] = drift.Variable<int>(lastWornDate.value);
    }
    if (price.present) {
      map['price'] = drift.Variable<double>(price.value);
    }
    if (size.present) {
      map['size'] = drift.Variable<String>(size.value);
    }
    if (usageCount.present) {
      map['usage_count'] = drift.Variable<int>(usageCount.value);
    }
    if (serverId.present) {
      map['server_id'] = drift.Variable<String>(serverId.value);
    }
    if (dirty.present) {
      map['dirty'] = drift.Variable<bool>(dirty.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = drift.Variable<int>(lastSyncedAt.value);
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

class $OutfitsTable extends Outfits
    with drift.TableInfo<$OutfitsTable, DbOutfit> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
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
  static const drift.VerificationMeta _externalIdMeta =
      const drift.VerificationMeta('externalId');
  @override
  late final drift.GeneratedColumn<String> externalId =
      drift.GeneratedColumn<String>(
        'external_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _nameMeta = const drift.VerificationMeta(
    'name',
  );
  @override
  late final drift.GeneratedColumn<String> name = drift.GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _descriptionMeta =
      const drift.VerificationMeta('description');
  @override
  late final drift.GeneratedColumn<String> description =
      drift.GeneratedColumn<String>(
        'description',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _imageUrlMeta =
      const drift.VerificationMeta('imageUrl');
  @override
  late final drift.GeneratedColumn<String> imageUrl =
      drift.GeneratedColumn<String>(
        'image_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _clothingItemIdsMeta =
      const drift.VerificationMeta('clothingItemIds');
  @override
  late final drift.GeneratedColumn<String> clothingItemIds =
      drift.GeneratedColumn<String>(
        'clothing_item_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const drift.Constant('[]'),
      );
  static const drift.VerificationMeta _isFavoriteMeta =
      const drift.VerificationMeta('isFavorite');
  @override
  late final drift.GeneratedColumn<bool> isFavorite =
      drift.GeneratedColumn<bool>(
        'is_favorite',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_favorite" IN (0, 1))',
        ),
        defaultValue: const drift.Constant(false),
      );
  static const drift.VerificationMeta _timesWornMeta =
      const drift.VerificationMeta('timesWorn');
  @override
  late final drift.GeneratedColumn<int> timesWorn = drift.GeneratedColumn<int>(
    'times_worn',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const drift.Constant(0),
  );
  static const drift.VerificationMeta _comfortRatingMeta =
      const drift.VerificationMeta('comfortRating');
  @override
  late final drift.GeneratedColumn<double> comfortRating =
      drift.GeneratedColumn<double>(
        'comfort_rating',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const drift.Constant(0.0),
      );
  static const drift.VerificationMeta _tagsMeta = const drift.VerificationMeta(
    'tags',
  );
  @override
  late final drift.GeneratedColumn<String> tags = drift.GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const drift.Constant('[]'),
  );
  static const drift.VerificationMeta _occasionsMeta =
      const drift.VerificationMeta('occasions');
  @override
  late final drift.GeneratedColumn<String> occasions =
      drift.GeneratedColumn<String>(
        'occasions',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const drift.Constant('[]'),
      );
  static const drift.VerificationMeta _weatherConditionsMeta =
      const drift.VerificationMeta('weatherConditions');
  @override
  late final drift.GeneratedColumn<String> weatherConditions =
      drift.GeneratedColumn<String>(
        'weather_conditions',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const drift.Constant('[]'),
      );
  static const drift.VerificationMeta _seasonsMeta =
      const drift.VerificationMeta('seasons');
  @override
  late final drift.GeneratedColumn<String> seasons =
      drift.GeneratedColumn<String>(
        'seasons',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const drift.Constant('[]'),
      );
  static const drift.VerificationMeta _addedDateMeta =
      const drift.VerificationMeta('addedDate');
  @override
  late final drift.GeneratedColumn<int> addedDate = drift.GeneratedColumn<int>(
    'added_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _createdAtMeta =
      const drift.VerificationMeta('createdAt');
  @override
  late final drift.GeneratedColumn<int> createdAt = drift.GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _updatedAtMeta =
      const drift.VerificationMeta('updatedAt');
  @override
  late final drift.GeneratedColumn<int> updatedAt = drift.GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _serverIdMeta =
      const drift.VerificationMeta('serverId');
  @override
  late final drift.GeneratedColumn<String> serverId =
      drift.GeneratedColumn<String>(
        'server_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const drift.VerificationMeta _dirtyMeta = const drift.VerificationMeta(
    'dirty',
  );
  @override
  late final drift.GeneratedColumn<bool> dirty = drift.GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const drift.Constant(false),
  );
  static const drift.VerificationMeta _lastSyncedAtMeta =
      const drift.VerificationMeta('lastSyncedAt');
  @override
  late final drift.GeneratedColumn<int> lastSyncedAt =
      drift.GeneratedColumn<int>(
        'last_synced_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<drift.GeneratedColumn> get $columns => [
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
  drift.VerificationContext validateIntegrity(
    drift.Insertable<DbOutfit> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
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
  Set<drift.GeneratedColumn> get $primaryKey => {id};
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

class DbOutfit extends drift.DataClass implements drift.Insertable<DbOutfit> {
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
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = drift.Variable<String>(externalId);
    }
    map['name'] = drift.Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = drift.Variable<String>(description);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = drift.Variable<String>(imageUrl);
    }
    map['clothing_item_ids'] = drift.Variable<String>(clothingItemIds);
    map['is_favorite'] = drift.Variable<bool>(isFavorite);
    map['times_worn'] = drift.Variable<int>(timesWorn);
    map['comfort_rating'] = drift.Variable<double>(comfortRating);
    map['tags'] = drift.Variable<String>(tags);
    map['occasions'] = drift.Variable<String>(occasions);
    map['weather_conditions'] = drift.Variable<String>(weatherConditions);
    map['seasons'] = drift.Variable<String>(seasons);
    map['added_date'] = drift.Variable<int>(addedDate);
    map['created_at'] = drift.Variable<int>(createdAt);
    map['updated_at'] = drift.Variable<int>(updatedAt);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = drift.Variable<String>(serverId);
    }
    map['dirty'] = drift.Variable<bool>(dirty);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = drift.Variable<int>(lastSyncedAt);
    }
    return map;
  }

  OutfitsCompanion toCompanion(bool nullToAbsent) {
    return OutfitsCompanion(
      id: drift.Value(id),
      externalId: externalId == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(externalId),
      name: drift.Value(name),
      description: description == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(description),
      imageUrl: imageUrl == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(imageUrl),
      clothingItemIds: drift.Value(clothingItemIds),
      isFavorite: drift.Value(isFavorite),
      timesWorn: drift.Value(timesWorn),
      comfortRating: drift.Value(comfortRating),
      tags: drift.Value(tags),
      occasions: drift.Value(occasions),
      weatherConditions: drift.Value(weatherConditions),
      seasons: drift.Value(seasons),
      addedDate: drift.Value(addedDate),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
      serverId: serverId == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(serverId),
      dirty: drift.Value(dirty),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const drift.Value.absent()
          : drift.Value(lastSyncedAt),
    );
  }

  factory DbOutfit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
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
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
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
    drift.Value<String?> externalId = const drift.Value.absent(),
    String? name,
    drift.Value<String?> description = const drift.Value.absent(),
    drift.Value<String?> imageUrl = const drift.Value.absent(),
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
    drift.Value<String?> serverId = const drift.Value.absent(),
    bool? dirty,
    drift.Value<int?> lastSyncedAt = const drift.Value.absent(),
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

class OutfitsCompanion extends drift.UpdateCompanion<DbOutfit> {
  final drift.Value<int> id;
  final drift.Value<String?> externalId;
  final drift.Value<String> name;
  final drift.Value<String?> description;
  final drift.Value<String?> imageUrl;
  final drift.Value<String> clothingItemIds;
  final drift.Value<bool> isFavorite;
  final drift.Value<int> timesWorn;
  final drift.Value<double> comfortRating;
  final drift.Value<String> tags;
  final drift.Value<String> occasions;
  final drift.Value<String> weatherConditions;
  final drift.Value<String> seasons;
  final drift.Value<int> addedDate;
  final drift.Value<int> createdAt;
  final drift.Value<int> updatedAt;
  final drift.Value<String?> serverId;
  final drift.Value<bool> dirty;
  final drift.Value<int?> lastSyncedAt;
  const OutfitsCompanion({
    this.id = const drift.Value.absent(),
    this.externalId = const drift.Value.absent(),
    this.name = const drift.Value.absent(),
    this.description = const drift.Value.absent(),
    this.imageUrl = const drift.Value.absent(),
    this.clothingItemIds = const drift.Value.absent(),
    this.isFavorite = const drift.Value.absent(),
    this.timesWorn = const drift.Value.absent(),
    this.comfortRating = const drift.Value.absent(),
    this.tags = const drift.Value.absent(),
    this.occasions = const drift.Value.absent(),
    this.weatherConditions = const drift.Value.absent(),
    this.seasons = const drift.Value.absent(),
    this.addedDate = const drift.Value.absent(),
    this.createdAt = const drift.Value.absent(),
    this.updatedAt = const drift.Value.absent(),
    this.serverId = const drift.Value.absent(),
    this.dirty = const drift.Value.absent(),
    this.lastSyncedAt = const drift.Value.absent(),
  });
  OutfitsCompanion.insert({
    this.id = const drift.Value.absent(),
    this.externalId = const drift.Value.absent(),
    required String name,
    this.description = const drift.Value.absent(),
    this.imageUrl = const drift.Value.absent(),
    this.clothingItemIds = const drift.Value.absent(),
    this.isFavorite = const drift.Value.absent(),
    this.timesWorn = const drift.Value.absent(),
    this.comfortRating = const drift.Value.absent(),
    this.tags = const drift.Value.absent(),
    this.occasions = const drift.Value.absent(),
    this.weatherConditions = const drift.Value.absent(),
    this.seasons = const drift.Value.absent(),
    required int addedDate,
    required int createdAt,
    required int updatedAt,
    this.serverId = const drift.Value.absent(),
    this.dirty = const drift.Value.absent(),
    this.lastSyncedAt = const drift.Value.absent(),
  }) : name = drift.Value(name),
       addedDate = drift.Value(addedDate),
       createdAt = drift.Value(createdAt),
       updatedAt = drift.Value(updatedAt);
  static drift.Insertable<DbOutfit> custom({
    drift.Expression<int>? id,
    drift.Expression<String>? externalId,
    drift.Expression<String>? name,
    drift.Expression<String>? description,
    drift.Expression<String>? imageUrl,
    drift.Expression<String>? clothingItemIds,
    drift.Expression<bool>? isFavorite,
    drift.Expression<int>? timesWorn,
    drift.Expression<double>? comfortRating,
    drift.Expression<String>? tags,
    drift.Expression<String>? occasions,
    drift.Expression<String>? weatherConditions,
    drift.Expression<String>? seasons,
    drift.Expression<int>? addedDate,
    drift.Expression<int>? createdAt,
    drift.Expression<int>? updatedAt,
    drift.Expression<String>? serverId,
    drift.Expression<bool>? dirty,
    drift.Expression<int>? lastSyncedAt,
  }) {
    return drift.RawValuesInsertable({
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
    drift.Value<int>? id,
    drift.Value<String?>? externalId,
    drift.Value<String>? name,
    drift.Value<String?>? description,
    drift.Value<String?>? imageUrl,
    drift.Value<String>? clothingItemIds,
    drift.Value<bool>? isFavorite,
    drift.Value<int>? timesWorn,
    drift.Value<double>? comfortRating,
    drift.Value<String>? tags,
    drift.Value<String>? occasions,
    drift.Value<String>? weatherConditions,
    drift.Value<String>? seasons,
    drift.Value<int>? addedDate,
    drift.Value<int>? createdAt,
    drift.Value<int>? updatedAt,
    drift.Value<String?>? serverId,
    drift.Value<bool>? dirty,
    drift.Value<int?>? lastSyncedAt,
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
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (externalId.present) {
      map['external_id'] = drift.Variable<String>(externalId.value);
    }
    if (name.present) {
      map['name'] = drift.Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = drift.Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = drift.Variable<String>(imageUrl.value);
    }
    if (clothingItemIds.present) {
      map['clothing_item_ids'] = drift.Variable<String>(clothingItemIds.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = drift.Variable<bool>(isFavorite.value);
    }
    if (timesWorn.present) {
      map['times_worn'] = drift.Variable<int>(timesWorn.value);
    }
    if (comfortRating.present) {
      map['comfort_rating'] = drift.Variable<double>(comfortRating.value);
    }
    if (tags.present) {
      map['tags'] = drift.Variable<String>(tags.value);
    }
    if (occasions.present) {
      map['occasions'] = drift.Variable<String>(occasions.value);
    }
    if (weatherConditions.present) {
      map['weather_conditions'] = drift.Variable<String>(
        weatherConditions.value,
      );
    }
    if (seasons.present) {
      map['seasons'] = drift.Variable<String>(seasons.value);
    }
    if (addedDate.present) {
      map['added_date'] = drift.Variable<int>(addedDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = drift.Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = drift.Variable<int>(updatedAt.value);
    }
    if (serverId.present) {
      map['server_id'] = drift.Variable<String>(serverId.value);
    }
    if (dirty.present) {
      map['dirty'] = drift.Variable<bool>(dirty.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = drift.Variable<int>(lastSyncedAt.value);
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
    with drift.TableInfo<$OutfitItemsTable, DbOutfitItem> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitItemsTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta = const drift.VerificationMeta(
    'id',
  );
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
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
  static const drift.VerificationMeta _outfitIdMeta =
      const drift.VerificationMeta('outfitId');
  @override
  late final drift.GeneratedColumn<int> outfitId = drift.GeneratedColumn<int>(
    'outfit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const drift.VerificationMeta _clothingItemIdMeta =
      const drift.VerificationMeta('clothingItemId');
  @override
  late final drift.GeneratedColumn<int> clothingItemId =
      drift.GeneratedColumn<int>(
        'clothing_item_id',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const drift.VerificationMeta _sortOrderMeta =
      const drift.VerificationMeta('sortOrder');
  @override
  late final drift.GeneratedColumn<int> sortOrder = drift.GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const drift.Constant(0),
  );
  static const drift.VerificationMeta _isPrimaryMeta =
      const drift.VerificationMeta('isPrimary');
  @override
  late final drift.GeneratedColumn<bool> isPrimary =
      drift.GeneratedColumn<bool>(
        'is_primary',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_primary" IN (0, 1))',
        ),
        defaultValue: const drift.Constant(false),
      );
  static const drift.VerificationMeta _metadataMeta =
      const drift.VerificationMeta('metadata');
  @override
  late final drift.GeneratedColumn<String> metadata =
      drift.GeneratedColumn<String>(
        'metadata',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const drift.Constant('{}'),
      );
  @override
  List<drift.GeneratedColumn> get $columns => [
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
  drift.VerificationContext validateIntegrity(
    drift.Insertable<DbOutfitItem> instance, {
    bool isInserting = false,
  }) {
    final context = drift.VerificationContext();
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
  Set<drift.GeneratedColumn> get $primaryKey => {id};
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

class DbOutfitItem extends drift.DataClass
    implements drift.Insertable<DbOutfitItem> {
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
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    map['outfit_id'] = drift.Variable<int>(outfitId);
    map['clothing_item_id'] = drift.Variable<int>(clothingItemId);
    map['sort_order'] = drift.Variable<int>(sortOrder);
    map['is_primary'] = drift.Variable<bool>(isPrimary);
    map['metadata'] = drift.Variable<String>(metadata);
    return map;
  }

  OutfitItemsCompanion toCompanion(bool nullToAbsent) {
    return OutfitItemsCompanion(
      id: drift.Value(id),
      outfitId: drift.Value(outfitId),
      clothingItemId: drift.Value(clothingItemId),
      sortOrder: drift.Value(sortOrder),
      isPrimary: drift.Value(isPrimary),
      metadata: drift.Value(metadata),
    );
  }

  factory DbOutfitItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
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
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
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

class OutfitItemsCompanion extends drift.UpdateCompanion<DbOutfitItem> {
  final drift.Value<int> id;
  final drift.Value<int> outfitId;
  final drift.Value<int> clothingItemId;
  final drift.Value<int> sortOrder;
  final drift.Value<bool> isPrimary;
  final drift.Value<String> metadata;
  const OutfitItemsCompanion({
    this.id = const drift.Value.absent(),
    this.outfitId = const drift.Value.absent(),
    this.clothingItemId = const drift.Value.absent(),
    this.sortOrder = const drift.Value.absent(),
    this.isPrimary = const drift.Value.absent(),
    this.metadata = const drift.Value.absent(),
  });
  OutfitItemsCompanion.insert({
    this.id = const drift.Value.absent(),
    required int outfitId,
    required int clothingItemId,
    this.sortOrder = const drift.Value.absent(),
    this.isPrimary = const drift.Value.absent(),
    this.metadata = const drift.Value.absent(),
  }) : outfitId = drift.Value(outfitId),
       clothingItemId = drift.Value(clothingItemId);
  static drift.Insertable<DbOutfitItem> custom({
    drift.Expression<int>? id,
    drift.Expression<int>? outfitId,
    drift.Expression<int>? clothingItemId,
    drift.Expression<int>? sortOrder,
    drift.Expression<bool>? isPrimary,
    drift.Expression<String>? metadata,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (outfitId != null) 'outfit_id': outfitId,
      if (clothingItemId != null) 'clothing_item_id': clothingItemId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (metadata != null) 'metadata': metadata,
    });
  }

  OutfitItemsCompanion copyWith({
    drift.Value<int>? id,
    drift.Value<int>? outfitId,
    drift.Value<int>? clothingItemId,
    drift.Value<int>? sortOrder,
    drift.Value<bool>? isPrimary,
    drift.Value<String>? metadata,
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
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (outfitId.present) {
      map['outfit_id'] = drift.Variable<int>(outfitId.value);
    }
    if (clothingItemId.present) {
      map['clothing_item_id'] = drift.Variable<int>(clothingItemId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = drift.Variable<int>(sortOrder.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = drift.Variable<bool>(isPrimary.value);
    }
    if (metadata.present) {
      map['metadata'] = drift.Variable<String>(metadata.value);
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

abstract class _$WardrobeDatabase extends drift.GeneratedDatabase {
  _$WardrobeDatabase(QueryExecutor e) : super(e);
  $WardrobeDatabaseManager get managers => $WardrobeDatabaseManager(this);
  late final $ClothingItemsTable clothingItems = $ClothingItemsTable(this);
  late final $OutfitsTable outfits = $OutfitsTable(this);
  late final $OutfitItemsTable outfitItems = $OutfitItemsTable(this);
  @override
  Iterable<drift.TableInfo<drift.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<drift.TableInfo<drift.Table, Object?>>();
  @override
  List<drift.DatabaseSchemaEntity> get allSchemaEntities => [
    clothingItems,
    outfits,
    outfitItems,
  ];
}

typedef $$ClothingItemsTableCreateCompanionBuilder =
    ClothingItemsCompanion Function({
      drift.Value<int> id,
      drift.Value<String?> externalId,
      required String name,
      drift.Value<String?> description,
      drift.Value<String?> imageUrl,
      required String category,
      drift.Value<String> tags,
      drift.Value<String?> color,
      drift.Value<String?> brand,
      drift.Value<String?> material,
      drift.Value<String> seasons,
      drift.Value<String> weatherConditions,
      drift.Value<String> occasions,
      drift.Value<bool> isFavorite,
      drift.Value<bool> isArchived,
      drift.Value<int> timesWorn,
      drift.Value<double> comfortRating,
      required int addedDate,
      required int createdAt,
      required int updatedAt,
      drift.Value<int?> lastWornDate,
      drift.Value<double?> price,
      drift.Value<String?> size,
      drift.Value<int> usageCount,
      drift.Value<String?> serverId,
      drift.Value<bool> dirty,
      drift.Value<int?> lastSyncedAt,
    });
typedef $$ClothingItemsTableUpdateCompanionBuilder =
    ClothingItemsCompanion Function({
      drift.Value<int> id,
      drift.Value<String?> externalId,
      drift.Value<String> name,
      drift.Value<String?> description,
      drift.Value<String?> imageUrl,
      drift.Value<String> category,
      drift.Value<String> tags,
      drift.Value<String?> color,
      drift.Value<String?> brand,
      drift.Value<String?> material,
      drift.Value<String> seasons,
      drift.Value<String> weatherConditions,
      drift.Value<String> occasions,
      drift.Value<bool> isFavorite,
      drift.Value<bool> isArchived,
      drift.Value<int> timesWorn,
      drift.Value<double> comfortRating,
      drift.Value<int> addedDate,
      drift.Value<int> createdAt,
      drift.Value<int> updatedAt,
      drift.Value<int?> lastWornDate,
      drift.Value<double?> price,
      drift.Value<String?> size,
      drift.Value<int> usageCount,
      drift.Value<String?> serverId,
      drift.Value<bool> dirty,
      drift.Value<int?> lastSyncedAt,
    });

class $$ClothingItemsTableFilterComposer
    extends drift.Composer<_$WardrobeDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get seasons => $composableBuilder(
    column: $table.seasons,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get weatherConditions => $composableBuilder(
    column: $table.weatherConditions,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get occasions => $composableBuilder(
    column: $table.occasions,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get timesWorn => $composableBuilder(
    column: $table.timesWorn,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<double> get comfortRating => $composableBuilder(
    column: $table.comfortRating,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get lastWornDate => $composableBuilder(
    column: $table.lastWornDate,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => drift.ColumnFilters(column),
  );
}

class $$ClothingItemsTableOrderingComposer
    extends drift.Composer<_$WardrobeDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get seasons => $composableBuilder(
    column: $table.seasons,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get weatherConditions => $composableBuilder(
    column: $table.weatherConditions,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get occasions => $composableBuilder(
    column: $table.occasions,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get timesWorn => $composableBuilder(
    column: $table.timesWorn,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<double> get comfortRating => $composableBuilder(
    column: $table.comfortRating,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get lastWornDate => $composableBuilder(
    column: $table.lastWornDate,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$ClothingItemsTableAnnotationComposer
    extends drift.Composer<_$WardrobeDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  drift.GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  drift.GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  drift.GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  drift.GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  drift.GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  drift.GeneratedColumn<String> get material =>
      $composableBuilder(column: $table.material, builder: (column) => column);

  drift.GeneratedColumn<String> get seasons =>
      $composableBuilder(column: $table.seasons, builder: (column) => column);

  drift.GeneratedColumn<String> get weatherConditions => $composableBuilder(
    column: $table.weatherConditions,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get occasions =>
      $composableBuilder(column: $table.occasions, builder: (column) => column);

  drift.GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  drift.GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  drift.GeneratedColumn<int> get timesWorn =>
      $composableBuilder(column: $table.timesWorn, builder: (column) => column);

  drift.GeneratedColumn<double> get comfortRating => $composableBuilder(
    column: $table.comfortRating,
    builder: (column) => column,
  );

  drift.GeneratedColumn<int> get addedDate =>
      $composableBuilder(column: $table.addedDate, builder: (column) => column);

  drift.GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  drift.GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  drift.GeneratedColumn<int> get lastWornDate => $composableBuilder(
    column: $table.lastWornDate,
    builder: (column) => column,
  );

  drift.GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  drift.GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  drift.GeneratedColumn<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  drift.GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  drift.GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$ClothingItemsTableTableManager
    extends
        drift.RootTableManager<
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
            drift.BaseReferences<
              _$WardrobeDatabase,
              $ClothingItemsTable,
              DbClothingItem
            >,
          ),
          DbClothingItem,
          drift.PrefetchHooks Function()
        > {
  $$ClothingItemsTableTableManager(
    _$WardrobeDatabase db,
    $ClothingItemsTable table,
  ) : super(
        drift.TableManagerState(
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
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<String?> externalId = const drift.Value.absent(),
                drift.Value<String> name = const drift.Value.absent(),
                drift.Value<String?> description = const drift.Value.absent(),
                drift.Value<String?> imageUrl = const drift.Value.absent(),
                drift.Value<String> category = const drift.Value.absent(),
                drift.Value<String> tags = const drift.Value.absent(),
                drift.Value<String?> color = const drift.Value.absent(),
                drift.Value<String?> brand = const drift.Value.absent(),
                drift.Value<String?> material = const drift.Value.absent(),
                drift.Value<String> seasons = const drift.Value.absent(),
                drift.Value<String> weatherConditions =
                    const drift.Value.absent(),
                drift.Value<String> occasions = const drift.Value.absent(),
                drift.Value<bool> isFavorite = const drift.Value.absent(),
                drift.Value<bool> isArchived = const drift.Value.absent(),
                drift.Value<int> timesWorn = const drift.Value.absent(),
                drift.Value<double> comfortRating = const drift.Value.absent(),
                drift.Value<int> addedDate = const drift.Value.absent(),
                drift.Value<int> createdAt = const drift.Value.absent(),
                drift.Value<int> updatedAt = const drift.Value.absent(),
                drift.Value<int?> lastWornDate = const drift.Value.absent(),
                drift.Value<double?> price = const drift.Value.absent(),
                drift.Value<String?> size = const drift.Value.absent(),
                drift.Value<int> usageCount = const drift.Value.absent(),
                drift.Value<String?> serverId = const drift.Value.absent(),
                drift.Value<bool> dirty = const drift.Value.absent(),
                drift.Value<int?> lastSyncedAt = const drift.Value.absent(),
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
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<String?> externalId = const drift.Value.absent(),
                required String name,
                drift.Value<String?> description = const drift.Value.absent(),
                drift.Value<String?> imageUrl = const drift.Value.absent(),
                required String category,
                drift.Value<String> tags = const drift.Value.absent(),
                drift.Value<String?> color = const drift.Value.absent(),
                drift.Value<String?> brand = const drift.Value.absent(),
                drift.Value<String?> material = const drift.Value.absent(),
                drift.Value<String> seasons = const drift.Value.absent(),
                drift.Value<String> weatherConditions =
                    const drift.Value.absent(),
                drift.Value<String> occasions = const drift.Value.absent(),
                drift.Value<bool> isFavorite = const drift.Value.absent(),
                drift.Value<bool> isArchived = const drift.Value.absent(),
                drift.Value<int> timesWorn = const drift.Value.absent(),
                drift.Value<double> comfortRating = const drift.Value.absent(),
                required int addedDate,
                required int createdAt,
                required int updatedAt,
                drift.Value<int?> lastWornDate = const drift.Value.absent(),
                drift.Value<double?> price = const drift.Value.absent(),
                drift.Value<String?> size = const drift.Value.absent(),
                drift.Value<int> usageCount = const drift.Value.absent(),
                drift.Value<String?> serverId = const drift.Value.absent(),
                drift.Value<bool> dirty = const drift.Value.absent(),
                drift.Value<int?> lastSyncedAt = const drift.Value.absent(),
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
              .map(
                (e) => (e.readTable(table), drift.BaseReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClothingItemsTableProcessedTableManager =
    drift.ProcessedTableManager<
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
        drift.BaseReferences<
          _$WardrobeDatabase,
          $ClothingItemsTable,
          DbClothingItem
        >,
      ),
      DbClothingItem,
      drift.PrefetchHooks Function()
    >;
typedef $$OutfitsTableCreateCompanionBuilder =
    OutfitsCompanion Function({
      drift.Value<int> id,
      drift.Value<String?> externalId,
      required String name,
      drift.Value<String?> description,
      drift.Value<String?> imageUrl,
      drift.Value<String> clothingItemIds,
      drift.Value<bool> isFavorite,
      drift.Value<int> timesWorn,
      drift.Value<double> comfortRating,
      drift.Value<String> tags,
      drift.Value<String> occasions,
      drift.Value<String> weatherConditions,
      drift.Value<String> seasons,
      required int addedDate,
      required int createdAt,
      required int updatedAt,
      drift.Value<String?> serverId,
      drift.Value<bool> dirty,
      drift.Value<int?> lastSyncedAt,
    });
typedef $$OutfitsTableUpdateCompanionBuilder =
    OutfitsCompanion Function({
      drift.Value<int> id,
      drift.Value<String?> externalId,
      drift.Value<String> name,
      drift.Value<String?> description,
      drift.Value<String?> imageUrl,
      drift.Value<String> clothingItemIds,
      drift.Value<bool> isFavorite,
      drift.Value<int> timesWorn,
      drift.Value<double> comfortRating,
      drift.Value<String> tags,
      drift.Value<String> occasions,
      drift.Value<String> weatherConditions,
      drift.Value<String> seasons,
      drift.Value<int> addedDate,
      drift.Value<int> createdAt,
      drift.Value<int> updatedAt,
      drift.Value<String?> serverId,
      drift.Value<bool> dirty,
      drift.Value<int?> lastSyncedAt,
    });

class $$OutfitsTableFilterComposer
    extends drift.Composer<_$WardrobeDatabase, $OutfitsTable> {
  $$OutfitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get clothingItemIds => $composableBuilder(
    column: $table.clothingItemIds,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get timesWorn => $composableBuilder(
    column: $table.timesWorn,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<double> get comfortRating => $composableBuilder(
    column: $table.comfortRating,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get occasions => $composableBuilder(
    column: $table.occasions,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get weatherConditions => $composableBuilder(
    column: $table.weatherConditions,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get seasons => $composableBuilder(
    column: $table.seasons,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => drift.ColumnFilters(column),
  );
}

class $$OutfitsTableOrderingComposer
    extends drift.Composer<_$WardrobeDatabase, $OutfitsTable> {
  $$OutfitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get clothingItemIds => $composableBuilder(
    column: $table.clothingItemIds,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get timesWorn => $composableBuilder(
    column: $table.timesWorn,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<double> get comfortRating => $composableBuilder(
    column: $table.comfortRating,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get occasions => $composableBuilder(
    column: $table.occasions,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get weatherConditions => $composableBuilder(
    column: $table.weatherConditions,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get seasons => $composableBuilder(
    column: $table.seasons,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get addedDate => $composableBuilder(
    column: $table.addedDate,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$OutfitsTableAnnotationComposer
    extends drift.Composer<_$WardrobeDatabase, $OutfitsTable> {
  $$OutfitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  drift.GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  drift.GeneratedColumn<String> get clothingItemIds => $composableBuilder(
    column: $table.clothingItemIds,
    builder: (column) => column,
  );

  drift.GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  drift.GeneratedColumn<int> get timesWorn =>
      $composableBuilder(column: $table.timesWorn, builder: (column) => column);

  drift.GeneratedColumn<double> get comfortRating => $composableBuilder(
    column: $table.comfortRating,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  drift.GeneratedColumn<String> get occasions =>
      $composableBuilder(column: $table.occasions, builder: (column) => column);

  drift.GeneratedColumn<String> get weatherConditions => $composableBuilder(
    column: $table.weatherConditions,
    builder: (column) => column,
  );

  drift.GeneratedColumn<String> get seasons =>
      $composableBuilder(column: $table.seasons, builder: (column) => column);

  drift.GeneratedColumn<int> get addedDate =>
      $composableBuilder(column: $table.addedDate, builder: (column) => column);

  drift.GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  drift.GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  drift.GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  drift.GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  drift.GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$OutfitsTableTableManager
    extends
        drift.RootTableManager<
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
            drift.BaseReferences<_$WardrobeDatabase, $OutfitsTable, DbOutfit>,
          ),
          DbOutfit,
          drift.PrefetchHooks Function()
        > {
  $$OutfitsTableTableManager(_$WardrobeDatabase db, $OutfitsTable table)
    : super(
        drift.TableManagerState(
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
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<String?> externalId = const drift.Value.absent(),
                drift.Value<String> name = const drift.Value.absent(),
                drift.Value<String?> description = const drift.Value.absent(),
                drift.Value<String?> imageUrl = const drift.Value.absent(),
                drift.Value<String> clothingItemIds =
                    const drift.Value.absent(),
                drift.Value<bool> isFavorite = const drift.Value.absent(),
                drift.Value<int> timesWorn = const drift.Value.absent(),
                drift.Value<double> comfortRating = const drift.Value.absent(),
                drift.Value<String> tags = const drift.Value.absent(),
                drift.Value<String> occasions = const drift.Value.absent(),
                drift.Value<String> weatherConditions =
                    const drift.Value.absent(),
                drift.Value<String> seasons = const drift.Value.absent(),
                drift.Value<int> addedDate = const drift.Value.absent(),
                drift.Value<int> createdAt = const drift.Value.absent(),
                drift.Value<int> updatedAt = const drift.Value.absent(),
                drift.Value<String?> serverId = const drift.Value.absent(),
                drift.Value<bool> dirty = const drift.Value.absent(),
                drift.Value<int?> lastSyncedAt = const drift.Value.absent(),
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
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<String?> externalId = const drift.Value.absent(),
                required String name,
                drift.Value<String?> description = const drift.Value.absent(),
                drift.Value<String?> imageUrl = const drift.Value.absent(),
                drift.Value<String> clothingItemIds =
                    const drift.Value.absent(),
                drift.Value<bool> isFavorite = const drift.Value.absent(),
                drift.Value<int> timesWorn = const drift.Value.absent(),
                drift.Value<double> comfortRating = const drift.Value.absent(),
                drift.Value<String> tags = const drift.Value.absent(),
                drift.Value<String> occasions = const drift.Value.absent(),
                drift.Value<String> weatherConditions =
                    const drift.Value.absent(),
                drift.Value<String> seasons = const drift.Value.absent(),
                required int addedDate,
                required int createdAt,
                required int updatedAt,
                drift.Value<String?> serverId = const drift.Value.absent(),
                drift.Value<bool> dirty = const drift.Value.absent(),
                drift.Value<int?> lastSyncedAt = const drift.Value.absent(),
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
              .map(
                (e) => (e.readTable(table), drift.BaseReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutfitsTableProcessedTableManager =
    drift.ProcessedTableManager<
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
        drift.BaseReferences<_$WardrobeDatabase, $OutfitsTable, DbOutfit>,
      ),
      DbOutfit,
      drift.PrefetchHooks Function()
    >;
typedef $$OutfitItemsTableCreateCompanionBuilder =
    OutfitItemsCompanion Function({
      drift.Value<int> id,
      required int outfitId,
      required int clothingItemId,
      drift.Value<int> sortOrder,
      drift.Value<bool> isPrimary,
      drift.Value<String> metadata,
    });
typedef $$OutfitItemsTableUpdateCompanionBuilder =
    OutfitItemsCompanion Function({
      drift.Value<int> id,
      drift.Value<int> outfitId,
      drift.Value<int> clothingItemId,
      drift.Value<int> sortOrder,
      drift.Value<bool> isPrimary,
      drift.Value<String> metadata,
    });

class $$OutfitItemsTableFilterComposer
    extends drift.Composer<_$WardrobeDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get outfitId => $composableBuilder(
    column: $table.outfitId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get clothingItemId => $composableBuilder(
    column: $table.clothingItemId,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => drift.ColumnFilters(column),
  );

  drift.ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => drift.ColumnFilters(column),
  );
}

class $$OutfitItemsTableOrderingComposer
    extends drift.Composer<_$WardrobeDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get outfitId => $composableBuilder(
    column: $table.outfitId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get clothingItemId => $composableBuilder(
    column: $table.clothingItemId,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => drift.ColumnOrderings(column),
  );

  drift.ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => drift.ColumnOrderings(column),
  );
}

class $$OutfitItemsTableAnnotationComposer
    extends drift.Composer<_$WardrobeDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  drift.GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  drift.GeneratedColumn<int> get outfitId =>
      $composableBuilder(column: $table.outfitId, builder: (column) => column);

  drift.GeneratedColumn<int> get clothingItemId => $composableBuilder(
    column: $table.clothingItemId,
    builder: (column) => column,
  );

  drift.GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  drift.GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  drift.GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);
}

class $$OutfitItemsTableTableManager
    extends
        drift.RootTableManager<
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
            drift.BaseReferences<
              _$WardrobeDatabase,
              $OutfitItemsTable,
              DbOutfitItem
            >,
          ),
          DbOutfitItem,
          drift.PrefetchHooks Function()
        > {
  $$OutfitItemsTableTableManager(_$WardrobeDatabase db, $OutfitItemsTable table)
    : super(
        drift.TableManagerState(
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
                drift.Value<int> id = const drift.Value.absent(),
                drift.Value<int> outfitId = const drift.Value.absent(),
                drift.Value<int> clothingItemId = const drift.Value.absent(),
                drift.Value<int> sortOrder = const drift.Value.absent(),
                drift.Value<bool> isPrimary = const drift.Value.absent(),
                drift.Value<String> metadata = const drift.Value.absent(),
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
                drift.Value<int> id = const drift.Value.absent(),
                required int outfitId,
                required int clothingItemId,
                drift.Value<int> sortOrder = const drift.Value.absent(),
                drift.Value<bool> isPrimary = const drift.Value.absent(),
                drift.Value<String> metadata = const drift.Value.absent(),
              }) => OutfitItemsCompanion.insert(
                id: id,
                outfitId: outfitId,
                clothingItemId: clothingItemId,
                sortOrder: sortOrder,
                isPrimary: isPrimary,
                metadata: metadata,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable(table), drift.BaseReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutfitItemsTableProcessedTableManager =
    drift.ProcessedTableManager<
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
        drift.BaseReferences<
          _$WardrobeDatabase,
          $OutfitItemsTable,
          DbOutfitItem
        >,
      ),
      DbOutfitItem,
      drift.PrefetchHooks Function()
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
