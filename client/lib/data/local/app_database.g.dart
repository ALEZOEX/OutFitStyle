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
      'subcategory', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>(
      'style', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _iconEmojiMeta =
      const VerificationMeta('iconEmoji');
  @override
  late final GeneratedColumn<String> iconEmoji = GeneratedColumn<String>(
      'icon_emoji', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('👕'));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _wearCountMeta =
      const VerificationMeta('wearCount');
  @override
  late final GeneratedColumn<int> wearCount = GeneratedColumn<int>(
      'wear_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
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
  static const VerificationMeta _blurHashMeta =
      const VerificationMeta('blurHash');
  @override
  late final GeneratedColumn<String> blurHash = GeneratedColumn<String>(
      'blur_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        subcategory,
        style,
        iconEmoji,
        isFavorite,
        isArchived,
        wearCount,
        imageUrl,
        localImagePath,
        blurHash,
        updatedAt,
        dirty,
        lastSyncedAt
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
    }
    if (data.containsKey('style')) {
      context.handle(
          _styleMeta, style.isAcceptableOrUnknown(data['style']!, _styleMeta));
    }
    if (data.containsKey('icon_emoji')) {
      context.handle(_iconEmojiMeta,
          iconEmoji.isAcceptableOrUnknown(data['icon_emoji']!, _iconEmojiMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('wear_count')) {
      context.handle(_wearCountMeta,
          wearCount.isAcceptableOrUnknown(data['wear_count']!, _wearCountMeta));
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
    if (data.containsKey('blur_hash')) {
      context.handle(_blurHashMeta,
          blurHash.isAcceptableOrUnknown(data['blur_hash']!, _blurHashMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
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
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      subcategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subcategory']),
      style: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}style'])!,
      iconEmoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_emoji'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      wearCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wear_count'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      localImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_image_path']),
      blurHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}blur_hash']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $WardrobeEntriesTable createAlias(String alias) {
    return $WardrobeEntriesTable(attachedDatabase, alias);
  }
}

class WardrobeEntry extends DataClass implements Insertable<WardrobeEntry> {
  final String id;
  final String name;
  final String category;
  final String? subcategory;
  final String style;
  final String iconEmoji;
  final bool isFavorite;
  final bool isArchived;
  final int wearCount;
  final String? imageUrl;
  final String? localImagePath;
  final String? blurHash;
  final DateTime updatedAt;
  final bool dirty;
  final DateTime? lastSyncedAt;
  const WardrobeEntry(
      {required this.id,
      required this.name,
      required this.category,
      this.subcategory,
      required this.style,
      required this.iconEmoji,
      required this.isFavorite,
      required this.isArchived,
      required this.wearCount,
      this.imageUrl,
      this.localImagePath,
      this.blurHash,
      required this.updatedAt,
      required this.dirty,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || subcategory != null) {
      map['subcategory'] = Variable<String>(subcategory);
    }
    map['style'] = Variable<String>(style);
    map['icon_emoji'] = Variable<String>(iconEmoji);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_archived'] = Variable<bool>(isArchived);
    map['wear_count'] = Variable<int>(wearCount);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || localImagePath != null) {
      map['local_image_path'] = Variable<String>(localImagePath);
    }
    if (!nullToAbsent || blurHash != null) {
      map['blur_hash'] = Variable<String>(blurHash);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  WardrobeEntriesCompanion toCompanion(bool nullToAbsent) {
    return WardrobeEntriesCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      subcategory: subcategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategory),
      style: Value(style),
      iconEmoji: Value(iconEmoji),
      isFavorite: Value(isFavorite),
      isArchived: Value(isArchived),
      wearCount: Value(wearCount),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      localImagePath: localImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localImagePath),
      blurHash: blurHash == null && nullToAbsent
          ? const Value.absent()
          : Value(blurHash),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory WardrobeEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WardrobeEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      subcategory: serializer.fromJson<String?>(json['subcategory']),
      style: serializer.fromJson<String>(json['style']),
      iconEmoji: serializer.fromJson<String>(json['iconEmoji']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      wearCount: serializer.fromJson<int>(json['wearCount']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      localImagePath: serializer.fromJson<String?>(json['localImagePath']),
      blurHash: serializer.fromJson<String?>(json['blurHash']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'subcategory': serializer.toJson<String?>(subcategory),
      'style': serializer.toJson<String>(style),
      'iconEmoji': serializer.toJson<String>(iconEmoji),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isArchived': serializer.toJson<bool>(isArchived),
      'wearCount': serializer.toJson<int>(wearCount),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'localImagePath': serializer.toJson<String?>(localImagePath),
      'blurHash': serializer.toJson<String?>(blurHash),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  WardrobeEntry copyWith(
          {String? id,
          String? name,
          String? category,
          Value<String?> subcategory = const Value.absent(),
          String? style,
          String? iconEmoji,
          bool? isFavorite,
          bool? isArchived,
          int? wearCount,
          Value<String?> imageUrl = const Value.absent(),
          Value<String?> localImagePath = const Value.absent(),
          Value<String?> blurHash = const Value.absent(),
          DateTime? updatedAt,
          bool? dirty,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      WardrobeEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        subcategory: subcategory.present ? subcategory.value : this.subcategory,
        style: style ?? this.style,
        iconEmoji: iconEmoji ?? this.iconEmoji,
        isFavorite: isFavorite ?? this.isFavorite,
        isArchived: isArchived ?? this.isArchived,
        wearCount: wearCount ?? this.wearCount,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        localImagePath:
            localImagePath.present ? localImagePath.value : this.localImagePath,
        blurHash: blurHash.present ? blurHash.value : this.blurHash,
        updatedAt: updatedAt ?? this.updatedAt,
        dirty: dirty ?? this.dirty,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  WardrobeEntry copyWithCompanion(WardrobeEntriesCompanion data) {
    return WardrobeEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      subcategory:
          data.subcategory.present ? data.subcategory.value : this.subcategory,
      style: data.style.present ? data.style.value : this.style,
      iconEmoji: data.iconEmoji.present ? data.iconEmoji.value : this.iconEmoji,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      wearCount: data.wearCount.present ? data.wearCount.value : this.wearCount,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      localImagePath: data.localImagePath.present
          ? data.localImagePath.value
          : this.localImagePath,
      blurHash: data.blurHash.present ? data.blurHash.value : this.blurHash,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WardrobeEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('style: $style, ')
          ..write('iconEmoji: $iconEmoji, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('wearCount: $wearCount, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('blurHash: $blurHash, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      category,
      subcategory,
      style,
      iconEmoji,
      isFavorite,
      isArchived,
      wearCount,
      imageUrl,
      localImagePath,
      blurHash,
      updatedAt,
      dirty,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WardrobeEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.subcategory == this.subcategory &&
          other.style == this.style &&
          other.iconEmoji == this.iconEmoji &&
          other.isFavorite == this.isFavorite &&
          other.isArchived == this.isArchived &&
          other.wearCount == this.wearCount &&
          other.imageUrl == this.imageUrl &&
          other.localImagePath == this.localImagePath &&
          other.blurHash == this.blurHash &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class WardrobeEntriesCompanion extends UpdateCompanion<WardrobeEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String?> subcategory;
  final Value<String> style;
  final Value<String> iconEmoji;
  final Value<bool> isFavorite;
  final Value<bool> isArchived;
  final Value<int> wearCount;
  final Value<String?> imageUrl;
  final Value<String?> localImagePath;
  final Value<String?> blurHash;
  final Value<DateTime> updatedAt;
  final Value<bool> dirty;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const WardrobeEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.style = const Value.absent(),
    this.iconEmoji = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.wearCount = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.blurHash = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WardrobeEntriesCompanion.insert({
    required String id,
    required String name,
    required String category,
    this.subcategory = const Value.absent(),
    this.style = const Value.absent(),
    this.iconEmoji = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.wearCount = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.blurHash = const Value.absent(),
    required DateTime updatedAt,
    this.dirty = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        category = Value(category),
        updatedAt = Value(updatedAt);
  static Insertable<WardrobeEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<String>? style,
    Expression<String>? iconEmoji,
    Expression<bool>? isFavorite,
    Expression<bool>? isArchived,
    Expression<int>? wearCount,
    Expression<String>? imageUrl,
    Expression<String>? localImagePath,
    Expression<String>? blurHash,
    Expression<DateTime>? updatedAt,
    Expression<bool>? dirty,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (style != null) 'style': style,
      if (iconEmoji != null) 'icon_emoji': iconEmoji,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isArchived != null) 'is_archived': isArchived,
      if (wearCount != null) 'wear_count': wearCount,
      if (imageUrl != null) 'image_url': imageUrl,
      if (localImagePath != null) 'local_image_path': localImagePath,
      if (blurHash != null) 'blur_hash': blurHash,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WardrobeEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? category,
      Value<String?>? subcategory,
      Value<String>? style,
      Value<String>? iconEmoji,
      Value<bool>? isFavorite,
      Value<bool>? isArchived,
      Value<int>? wearCount,
      Value<String?>? imageUrl,
      Value<String?>? localImagePath,
      Value<String?>? blurHash,
      Value<DateTime>? updatedAt,
      Value<bool>? dirty,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return WardrobeEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      style: style ?? this.style,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      wearCount: wearCount ?? this.wearCount,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      blurHash: blurHash ?? this.blurHash,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (wearCount.present) {
      map['wear_count'] = Variable<int>(wearCount.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (localImagePath.present) {
      map['local_image_path'] = Variable<String>(localImagePath.value);
    }
    if (blurHash.present) {
      map['blur_hash'] = Variable<String>(blurHash.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
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
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('style: $style, ')
          ..write('iconEmoji: $iconEmoji, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('wearCount: $wearCount, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('blurHash: $blurHash, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecommendationsTable extends Recommendations
    with TableInfo<$RecommendationsTable, RecommendationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecommendationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
      'origin', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('server'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
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
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _publishedAtMeta =
      const VerificationMeta('publishedAt');
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
      'published_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        origin,
        serverId,
        createdAt,
        isFavorite,
        outfitDataJson,
        weatherDataJson,
        updatedAt,
        dirty,
        lastSyncedAt,
        publishedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recommendations';
  @override
  VerificationContext validateIntegrity(Insertable<RecommendationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(_originMeta,
          origin.isAcceptableOrUnknown(data['origin']!, _originMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
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
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('published_at')) {
      context.handle(
          _publishedAtMeta,
          publishedAt.isAcceptableOrUnknown(
              data['published_at']!, _publishedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecommendationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecommendationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      origin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      outfitDataJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}outfit_data_json'])!,
      weatherDataJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}weather_data_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      publishedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}published_at']),
    );
  }

  @override
  $RecommendationsTable createAlias(String alias) {
    return $RecommendationsTable(attachedDatabase, alias);
  }
}

class RecommendationRow extends DataClass
    implements Insertable<RecommendationRow> {
  final String id;
  final String origin;
  final String? serverId;
  final DateTime createdAt;
  final bool isFavorite;
  final String outfitDataJson;
  final String weatherDataJson;
  final DateTime updatedAt;
  final bool dirty;
  final DateTime? lastSyncedAt;
  final DateTime? publishedAt;
  const RecommendationRow(
      {required this.id,
      required this.origin,
      this.serverId,
      required this.createdAt,
      required this.isFavorite,
      required this.outfitDataJson,
      required this.weatherDataJson,
      required this.updatedAt,
      required this.dirty,
      this.lastSyncedAt,
      this.publishedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['origin'] = Variable<String>(origin);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['outfit_data_json'] = Variable<String>(outfitDataJson);
    map['weather_data_json'] = Variable<String>(weatherDataJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    return map;
  }

  RecommendationsCompanion toCompanion(bool nullToAbsent) {
    return RecommendationsCompanion(
      id: Value(id),
      origin: Value(origin),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      createdAt: Value(createdAt),
      isFavorite: Value(isFavorite),
      outfitDataJson: Value(outfitDataJson),
      weatherDataJson: Value(weatherDataJson),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
    );
  }

  factory RecommendationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecommendationRow(
      id: serializer.fromJson<String>(json['id']),
      origin: serializer.fromJson<String>(json['origin']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      outfitDataJson: serializer.fromJson<String>(json['outfitDataJson']),
      weatherDataJson: serializer.fromJson<String>(json['weatherDataJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'origin': serializer.toJson<String>(origin),
      'serverId': serializer.toJson<String?>(serverId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'outfitDataJson': serializer.toJson<String>(outfitDataJson),
      'weatherDataJson': serializer.toJson<String>(weatherDataJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
    };
  }

  RecommendationRow copyWith(
          {String? id,
          String? origin,
          Value<String?> serverId = const Value.absent(),
          DateTime? createdAt,
          bool? isFavorite,
          String? outfitDataJson,
          String? weatherDataJson,
          DateTime? updatedAt,
          bool? dirty,
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          Value<DateTime?> publishedAt = const Value.absent()}) =>
      RecommendationRow(
        id: id ?? this.id,
        origin: origin ?? this.origin,
        serverId: serverId.present ? serverId.value : this.serverId,
        createdAt: createdAt ?? this.createdAt,
        isFavorite: isFavorite ?? this.isFavorite,
        outfitDataJson: outfitDataJson ?? this.outfitDataJson,
        weatherDataJson: weatherDataJson ?? this.weatherDataJson,
        updatedAt: updatedAt ?? this.updatedAt,
        dirty: dirty ?? this.dirty,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
      );
  RecommendationRow copyWithCompanion(RecommendationsCompanion data) {
    return RecommendationRow(
      id: data.id.present ? data.id.value : this.id,
      origin: data.origin.present ? data.origin.value : this.origin,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      outfitDataJson: data.outfitDataJson.present
          ? data.outfitDataJson.value
          : this.outfitDataJson,
      weatherDataJson: data.weatherDataJson.present
          ? data.weatherDataJson.value
          : this.weatherDataJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      publishedAt:
          data.publishedAt.present ? data.publishedAt.value : this.publishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationRow(')
          ..write('id: $id, ')
          ..write('origin: $origin, ')
          ..write('serverId: $serverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('outfitDataJson: $outfitDataJson, ')
          ..write('weatherDataJson: $weatherDataJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('publishedAt: $publishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      origin,
      serverId,
      createdAt,
      isFavorite,
      outfitDataJson,
      weatherDataJson,
      updatedAt,
      dirty,
      lastSyncedAt,
      publishedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecommendationRow &&
          other.id == this.id &&
          other.origin == this.origin &&
          other.serverId == this.serverId &&
          other.createdAt == this.createdAt &&
          other.isFavorite == this.isFavorite &&
          other.outfitDataJson == this.outfitDataJson &&
          other.weatherDataJson == this.weatherDataJson &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.publishedAt == this.publishedAt);
}

class RecommendationsCompanion extends UpdateCompanion<RecommendationRow> {
  final Value<String> id;
  final Value<String> origin;
  final Value<String?> serverId;
  final Value<DateTime> createdAt;
  final Value<bool> isFavorite;
  final Value<String> outfitDataJson;
  final Value<String> weatherDataJson;
  final Value<DateTime> updatedAt;
  final Value<bool> dirty;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime?> publishedAt;
  final Value<int> rowid;
  const RecommendationsCompanion({
    this.id = const Value.absent(),
    this.origin = const Value.absent(),
    this.serverId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.outfitDataJson = const Value.absent(),
    this.weatherDataJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecommendationsCompanion.insert({
    required String id,
    this.origin = const Value.absent(),
    this.serverId = const Value.absent(),
    required DateTime createdAt,
    this.isFavorite = const Value.absent(),
    required String outfitDataJson,
    required String weatherDataJson,
    required DateTime updatedAt,
    this.dirty = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        outfitDataJson = Value(outfitDataJson),
        weatherDataJson = Value(weatherDataJson),
        updatedAt = Value(updatedAt);
  static Insertable<RecommendationRow> custom({
    Expression<String>? id,
    Expression<String>? origin,
    Expression<String>? serverId,
    Expression<DateTime>? createdAt,
    Expression<bool>? isFavorite,
    Expression<String>? outfitDataJson,
    Expression<String>? weatherDataJson,
    Expression<DateTime>? updatedAt,
    Expression<bool>? dirty,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? publishedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (origin != null) 'origin': origin,
      if (serverId != null) 'server_id': serverId,
      if (createdAt != null) 'created_at': createdAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (outfitDataJson != null) 'outfit_data_json': outfitDataJson,
      if (weatherDataJson != null) 'weather_data_json': weatherDataJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (publishedAt != null) 'published_at': publishedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecommendationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? origin,
      Value<String?>? serverId,
      Value<DateTime>? createdAt,
      Value<bool>? isFavorite,
      Value<String>? outfitDataJson,
      Value<String>? weatherDataJson,
      Value<DateTime>? updatedAt,
      Value<bool>? dirty,
      Value<DateTime?>? lastSyncedAt,
      Value<DateTime?>? publishedAt,
      Value<int>? rowid}) {
    return RecommendationsCompanion(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      outfitDataJson: outfitDataJson ?? this.outfitDataJson,
      weatherDataJson: weatherDataJson ?? this.weatherDataJson,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (outfitDataJson.present) {
      map['outfit_data_json'] = Variable<String>(outfitDataJson.value);
    }
    if (weatherDataJson.present) {
      map['weather_data_json'] = Variable<String>(weatherDataJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
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
          ..write('origin: $origin, ')
          ..write('serverId: $serverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('outfitDataJson: $outfitDataJson, ')
          ..write('weatherDataJson: $weatherDataJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
      'local_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _nextAttemptAtMeta =
      const VerificationMeta('nextAttemptAt');
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>('next_attempt_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        type,
        entityId,
        payloadJson,
        attempts,
        createdAt,
        nextAttemptAt,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(Insertable<SyncOutboxRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
          _nextAttemptAtMeta,
          nextAttemptAt.isAcceptableOrUnknown(
              data['next_attempt_at']!, _nextAttemptAtMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  SyncOutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxRow(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id']),
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_attempt_at'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxRow extends DataClass implements Insertable<SyncOutboxRow> {
  final int localId;

  /// тип операции: wardrobe_set_favorite, wardrobe_set_archived, wardrobe_worn, rec_set_favorite, ...
  final String type;

  /// например id вещи/рекомендации (удобно для дедупликации и диагностики)
  final String? entityId;

  /// payload как JSON string (минимально необходимое)
  final String payloadJson;
  final int attempts;
  final DateTime createdAt;
  final DateTime nextAttemptAt;
  final String? lastError;
  const SyncOutboxRow(
      {required this.localId,
      required this.type,
      this.entityId,
      required this.payloadJson,
      required this.attempts,
      required this.createdAt,
      required this.nextAttemptAt,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      localId: Value(localId),
      type: Value(type),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      payloadJson: Value(payloadJson),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
      nextAttemptAt: Value(nextAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncOutboxRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxRow(
      localId: serializer.fromJson<int>(json['localId']),
      type: serializer.fromJson<String>(json['type']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      nextAttemptAt: serializer.fromJson<DateTime>(json['nextAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'type': serializer.toJson<String>(type),
      'entityId': serializer.toJson<String?>(entityId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'nextAttemptAt': serializer.toJson<DateTime>(nextAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncOutboxRow copyWith(
          {int? localId,
          String? type,
          Value<String?> entityId = const Value.absent(),
          String? payloadJson,
          int? attempts,
          DateTime? createdAt,
          DateTime? nextAttemptAt,
          Value<String?> lastError = const Value.absent()}) =>
      SyncOutboxRow(
        localId: localId ?? this.localId,
        type: type ?? this.type,
        entityId: entityId.present ? entityId.value : this.entityId,
        payloadJson: payloadJson ?? this.payloadJson,
        attempts: attempts ?? this.attempts,
        createdAt: createdAt ?? this.createdAt,
        nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  SyncOutboxRow copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxRow(
      localId: data.localId.present ? data.localId.value : this.localId,
      type: data.type.present ? data.type.value : this.type,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxRow(')
          ..write('localId: $localId, ')
          ..write('type: $type, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localId, type, entityId, payloadJson,
      attempts, createdAt, nextAttemptAt, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxRow &&
          other.localId == this.localId &&
          other.type == this.type &&
          other.entityId == this.entityId &&
          other.payloadJson == this.payloadJson &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastError == this.lastError);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxRow> {
  final Value<int> localId;
  final Value<String> type;
  final Value<String?> entityId;
  final Value<String> payloadJson;
  final Value<int> attempts;
  final Value<DateTime> createdAt;
  final Value<DateTime> nextAttemptAt;
  final Value<String?> lastError;
  const SyncOutboxCompanion({
    this.localId = const Value.absent(),
    this.type = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.localId = const Value.absent(),
    required String type,
    this.entityId = const Value.absent(),
    required String payloadJson,
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
  })  : type = Value(type),
        payloadJson = Value(payloadJson);
  static Insertable<SyncOutboxRow> custom({
    Expression<int>? localId,
    Expression<String>? type,
    Expression<String>? entityId,
    Expression<String>? payloadJson,
    Expression<int>? attempts,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (type != null) 'type': type,
      if (entityId != null) 'entity_id': entityId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SyncOutboxCompanion copyWith(
      {Value<int>? localId,
      Value<String>? type,
      Value<String?>? entityId,
      Value<String>? payloadJson,
      Value<int>? attempts,
      Value<DateTime>? createdAt,
      Value<DateTime>? nextAttemptAt,
      Value<String?>? lastError}) {
    return SyncOutboxCompanion(
      localId: localId ?? this.localId,
      type: type ?? this.type,
      entityId: entityId ?? this.entityId,
      payloadJson: payloadJson ?? this.payloadJson,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('localId: $localId, ')
          ..write('type: $type, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError')
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
  late final WardrobeDao wardrobeDao = WardrobeDao(this as AppDatabase);
  late final RecommendationDao recommendationDao =
      RecommendationDao(this as AppDatabase);
  late final SyncOutboxDao syncOutboxDao = SyncOutboxDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [wardrobeEntries, recommendations, syncOutbox];
}

typedef $$WardrobeEntriesTableCreateCompanionBuilder = WardrobeEntriesCompanion
    Function({
  required String id,
  required String name,
  required String category,
  Value<String?> subcategory,
  Value<String> style,
  Value<String> iconEmoji,
  Value<bool> isFavorite,
  Value<bool> isArchived,
  Value<int> wearCount,
  Value<String?> imageUrl,
  Value<String?> localImagePath,
  Value<String?> blurHash,
  required DateTime updatedAt,
  Value<bool> dirty,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$WardrobeEntriesTableUpdateCompanionBuilder = WardrobeEntriesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> category,
  Value<String?> subcategory,
  Value<String> style,
  Value<String> iconEmoji,
  Value<bool> isFavorite,
  Value<bool> isArchived,
  Value<int> wearCount,
  Value<String?> imageUrl,
  Value<String?> localImagePath,
  Value<String?> blurHash,
  Value<DateTime> updatedAt,
  Value<bool> dirty,
  Value<DateTime?> lastSyncedAt,
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

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wearCount => $composableBuilder(
      column: $table.wearCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get blurHash => $composableBuilder(
      column: $table.blurHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wearCount => $composableBuilder(
      column: $table.wearCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get blurHash => $composableBuilder(
      column: $table.blurHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
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

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<int> get wearCount =>
      $composableBuilder(column: $table.wearCount, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath, builder: (column) => column);

  GeneratedColumn<String> get blurHash =>
      $composableBuilder(column: $table.blurHash, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
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
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> subcategory = const Value.absent(),
            Value<String> style = const Value.absent(),
            Value<String> iconEmoji = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> wearCount = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> localImagePath = const Value.absent(),
            Value<String?> blurHash = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WardrobeEntriesCompanion(
            id: id,
            name: name,
            category: category,
            subcategory: subcategory,
            style: style,
            iconEmoji: iconEmoji,
            isFavorite: isFavorite,
            isArchived: isArchived,
            wearCount: wearCount,
            imageUrl: imageUrl,
            localImagePath: localImagePath,
            blurHash: blurHash,
            updatedAt: updatedAt,
            dirty: dirty,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String category,
            Value<String?> subcategory = const Value.absent(),
            Value<String> style = const Value.absent(),
            Value<String> iconEmoji = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<int> wearCount = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> localImagePath = const Value.absent(),
            Value<String?> blurHash = const Value.absent(),
            required DateTime updatedAt,
            Value<bool> dirty = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WardrobeEntriesCompanion.insert(
            id: id,
            name: name,
            category: category,
            subcategory: subcategory,
            style: style,
            iconEmoji: iconEmoji,
            isFavorite: isFavorite,
            isArchived: isArchived,
            wearCount: wearCount,
            imageUrl: imageUrl,
            localImagePath: localImagePath,
            blurHash: blurHash,
            updatedAt: updatedAt,
            dirty: dirty,
            lastSyncedAt: lastSyncedAt,
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
  Value<String> origin,
  Value<String?> serverId,
  required DateTime createdAt,
  Value<bool> isFavorite,
  required String outfitDataJson,
  required String weatherDataJson,
  required DateTime updatedAt,
  Value<bool> dirty,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime?> publishedAt,
  Value<int> rowid,
});
typedef $$RecommendationsTableUpdateCompanionBuilder = RecommendationsCompanion
    Function({
  Value<String> id,
  Value<String> origin,
  Value<String?> serverId,
  Value<DateTime> createdAt,
  Value<bool> isFavorite,
  Value<String> outfitDataJson,
  Value<String> weatherDataJson,
  Value<DateTime> updatedAt,
  Value<bool> dirty,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime?> publishedAt,
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

  ColumnFilters<String> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outfitDataJson => $composableBuilder(
      column: $table.outfitDataJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weatherDataJson => $composableBuilder(
      column: $table.weatherDataJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
      column: $table.publishedAt, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outfitDataJson => $composableBuilder(
      column: $table.outfitDataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weatherDataJson => $composableBuilder(
      column: $table.weatherDataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
      column: $table.publishedAt, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<String> get outfitDataJson => $composableBuilder(
      column: $table.outfitDataJson, builder: (column) => column);

  GeneratedColumn<String> get weatherDataJson => $composableBuilder(
      column: $table.weatherDataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
      column: $table.publishedAt, builder: (column) => column);
}

class $$RecommendationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecommendationsTable,
    RecommendationRow,
    $$RecommendationsTableFilterComposer,
    $$RecommendationsTableOrderingComposer,
    $$RecommendationsTableAnnotationComposer,
    $$RecommendationsTableCreateCompanionBuilder,
    $$RecommendationsTableUpdateCompanionBuilder,
    (
      RecommendationRow,
      BaseReferences<_$AppDatabase, $RecommendationsTable, RecommendationRow>
    ),
    RecommendationRow,
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
            Value<String> origin = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<String> outfitDataJson = const Value.absent(),
            Value<String> weatherDataJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<DateTime?> publishedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecommendationsCompanion(
            id: id,
            origin: origin,
            serverId: serverId,
            createdAt: createdAt,
            isFavorite: isFavorite,
            outfitDataJson: outfitDataJson,
            weatherDataJson: weatherDataJson,
            updatedAt: updatedAt,
            dirty: dirty,
            lastSyncedAt: lastSyncedAt,
            publishedAt: publishedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> origin = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            required DateTime createdAt,
            Value<bool> isFavorite = const Value.absent(),
            required String outfitDataJson,
            required String weatherDataJson,
            required DateTime updatedAt,
            Value<bool> dirty = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<DateTime?> publishedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecommendationsCompanion.insert(
            id: id,
            origin: origin,
            serverId: serverId,
            createdAt: createdAt,
            isFavorite: isFavorite,
            outfitDataJson: outfitDataJson,
            weatherDataJson: weatherDataJson,
            updatedAt: updatedAt,
            dirty: dirty,
            lastSyncedAt: lastSyncedAt,
            publishedAt: publishedAt,
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
    RecommendationRow,
    $$RecommendationsTableFilterComposer,
    $$RecommendationsTableOrderingComposer,
    $$RecommendationsTableAnnotationComposer,
    $$RecommendationsTableCreateCompanionBuilder,
    $$RecommendationsTableUpdateCompanionBuilder,
    (
      RecommendationRow,
      BaseReferences<_$AppDatabase, $RecommendationsTable, RecommendationRow>
    ),
    RecommendationRow,
    PrefetchHooks Function()>;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> localId,
  required String type,
  Value<String?> entityId,
  required String payloadJson,
  Value<int> attempts,
  Value<DateTime> createdAt,
  Value<DateTime> nextAttemptAt,
  Value<String?> lastError,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<int> localId,
  Value<String> type,
  Value<String?> entityId,
  Value<String> payloadJson,
  Value<int> attempts,
  Value<DateTime> createdAt,
  Value<DateTime> nextAttemptAt,
  Value<String?> lastError,
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
  ColumnFilters<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
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
  ColumnOrderings<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
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
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncOutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncOutboxTable,
    SyncOutboxRow,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (
      SyncOutboxRow,
      BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxRow>
    ),
    SyncOutboxRow,
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
            Value<int> localId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> entityId = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> nextAttemptAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              SyncOutboxCompanion(
            localId: localId,
            type: type,
            entityId: entityId,
            payloadJson: payloadJson,
            attempts: attempts,
            createdAt: createdAt,
            nextAttemptAt: nextAttemptAt,
            lastError: lastError,
          ),
          createCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            required String type,
            Value<String?> entityId = const Value.absent(),
            required String payloadJson,
            Value<int> attempts = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> nextAttemptAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              SyncOutboxCompanion.insert(
            localId: localId,
            type: type,
            entityId: entityId,
            payloadJson: payloadJson,
            attempts: attempts,
            createdAt: createdAt,
            nextAttemptAt: nextAttemptAt,
            lastError: lastError,
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
    SyncOutboxRow,
    $$SyncOutboxTableFilterComposer,
    $$SyncOutboxTableOrderingComposer,
    $$SyncOutboxTableAnnotationComposer,
    $$SyncOutboxTableCreateCompanionBuilder,
    $$SyncOutboxTableUpdateCompanionBuilder,
    (
      SyncOutboxRow,
      BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxRow>
    ),
    SyncOutboxRow,
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
}
