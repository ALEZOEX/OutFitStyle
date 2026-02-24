// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $RecommendationTableTable extends RecommendationTable
    with TableInfo<$RecommendationTableTable, RecommendationTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecommendationTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outfitItemsMeta = const VerificationMeta(
    'outfitItems',
  );
  @override
  late final GeneratedColumn<String> outfitItems = GeneratedColumn<String>(
    'outfit_items',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weatherConditionMeta = const VerificationMeta(
    'weatherCondition',
  );
  @override
  late final GeneratedColumn<String> weatherCondition = GeneratedColumn<String>(
    'weather_condition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occasionMeta = const VerificationMeta(
    'occasion',
  );
  @override
  late final GeneratedColumn<String> occasion = GeneratedColumn<String>(
    'occasion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceScoreMeta = const VerificationMeta(
    'confidenceScore',
  );
  @override
  late final GeneratedColumn<double> confidenceScore = GeneratedColumn<double>(
    'confidence_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedbackMeta = const VerificationMeta(
    'feedback',
  );
  @override
  late final GeneratedColumn<String> feedback = GeneratedColumn<String>(
    'feedback',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    outfitItems,
    temperature,
    weatherCondition,
    occasion,
    timestamp,
    confidenceScore,
    feedback,
    rating,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recommendation_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecommendationTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('outfit_items')) {
      context.handle(
        _outfitItemsMeta,
        outfitItems.isAcceptableOrUnknown(
          data['outfit_items']!,
          _outfitItemsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_outfitItemsMeta);
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperatureMeta);
    }
    if (data.containsKey('weather_condition')) {
      context.handle(
        _weatherConditionMeta,
        weatherCondition.isAcceptableOrUnknown(
          data['weather_condition']!,
          _weatherConditionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weatherConditionMeta);
    }
    if (data.containsKey('occasion')) {
      context.handle(
        _occasionMeta,
        occasion.isAcceptableOrUnknown(data['occasion']!, _occasionMeta),
      );
    } else if (isInserting) {
      context.missing(_occasionMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('confidence_score')) {
      context.handle(
        _confidenceScoreMeta,
        confidenceScore.isAcceptableOrUnknown(
          data['confidence_score']!,
          _confidenceScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confidenceScoreMeta);
    }
    if (data.containsKey('feedback')) {
      context.handle(
        _feedbackMeta,
        feedback.isAcceptableOrUnknown(data['feedback']!, _feedbackMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecommendationTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecommendationTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      outfitItems:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}outfit_items'],
          )!,
      temperature:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}temperature'],
          )!,
      weatherCondition:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}weather_condition'],
          )!,
      occasion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}occasion'],
          )!,
      timestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}timestamp'],
          )!,
      confidenceScore:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}confidence_score'],
          )!,
      feedback: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feedback'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
    );
  }

  @override
  $RecommendationTableTable createAlias(String alias) {
    return $RecommendationTableTable(attachedDatabase, alias);
  }
}

class RecommendationTableData extends DataClass
    implements Insertable<RecommendationTableData> {
  final int id;
  final String userId;
  final String outfitItems;
  final double temperature;
  final String weatherCondition;
  final String occasion;
  final int timestamp;
  final double confidenceScore;
  final String? feedback;
  final int? rating;
  const RecommendationTableData({
    required this.id,
    required this.userId,
    required this.outfitItems,
    required this.temperature,
    required this.weatherCondition,
    required this.occasion,
    required this.timestamp,
    required this.confidenceScore,
    this.feedback,
    this.rating,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['outfit_items'] = Variable<String>(outfitItems);
    map['temperature'] = Variable<double>(temperature);
    map['weather_condition'] = Variable<String>(weatherCondition);
    map['occasion'] = Variable<String>(occasion);
    map['timestamp'] = Variable<int>(timestamp);
    map['confidence_score'] = Variable<double>(confidenceScore);
    if (!nullToAbsent || feedback != null) {
      map['feedback'] = Variable<String>(feedback);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    return map;
  }

  RecommendationTableCompanion toCompanion(bool nullToAbsent) {
    return RecommendationTableCompanion(
      id: Value(id),
      userId: Value(userId),
      outfitItems: Value(outfitItems),
      temperature: Value(temperature),
      weatherCondition: Value(weatherCondition),
      occasion: Value(occasion),
      timestamp: Value(timestamp),
      confidenceScore: Value(confidenceScore),
      feedback:
          feedback == null && nullToAbsent
              ? const Value.absent()
              : Value(feedback),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
    );
  }

  factory RecommendationTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecommendationTableData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      outfitItems: serializer.fromJson<String>(json['outfitItems']),
      temperature: serializer.fromJson<double>(json['temperature']),
      weatherCondition: serializer.fromJson<String>(json['weatherCondition']),
      occasion: serializer.fromJson<String>(json['occasion']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      confidenceScore: serializer.fromJson<double>(json['confidenceScore']),
      feedback: serializer.fromJson<String?>(json['feedback']),
      rating: serializer.fromJson<int?>(json['rating']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'outfitItems': serializer.toJson<String>(outfitItems),
      'temperature': serializer.toJson<double>(temperature),
      'weatherCondition': serializer.toJson<String>(weatherCondition),
      'occasion': serializer.toJson<String>(occasion),
      'timestamp': serializer.toJson<int>(timestamp),
      'confidenceScore': serializer.toJson<double>(confidenceScore),
      'feedback': serializer.toJson<String?>(feedback),
      'rating': serializer.toJson<int?>(rating),
    };
  }

  RecommendationTableData copyWith({
    int? id,
    String? userId,
    String? outfitItems,
    double? temperature,
    String? weatherCondition,
    String? occasion,
    int? timestamp,
    double? confidenceScore,
    Value<String?> feedback = const Value.absent(),
    Value<int?> rating = const Value.absent(),
  }) => RecommendationTableData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    outfitItems: outfitItems ?? this.outfitItems,
    temperature: temperature ?? this.temperature,
    weatherCondition: weatherCondition ?? this.weatherCondition,
    occasion: occasion ?? this.occasion,
    timestamp: timestamp ?? this.timestamp,
    confidenceScore: confidenceScore ?? this.confidenceScore,
    feedback: feedback.present ? feedback.value : this.feedback,
    rating: rating.present ? rating.value : this.rating,
  );
  RecommendationTableData copyWithCompanion(RecommendationTableCompanion data) {
    return RecommendationTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      outfitItems:
          data.outfitItems.present ? data.outfitItems.value : this.outfitItems,
      temperature:
          data.temperature.present ? data.temperature.value : this.temperature,
      weatherCondition:
          data.weatherCondition.present
              ? data.weatherCondition.value
              : this.weatherCondition,
      occasion: data.occasion.present ? data.occasion.value : this.occasion,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      confidenceScore:
          data.confidenceScore.present
              ? data.confidenceScore.value
              : this.confidenceScore,
      feedback: data.feedback.present ? data.feedback.value : this.feedback,
      rating: data.rating.present ? data.rating.value : this.rating,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('outfitItems: $outfitItems, ')
          ..write('temperature: $temperature, ')
          ..write('weatherCondition: $weatherCondition, ')
          ..write('occasion: $occasion, ')
          ..write('timestamp: $timestamp, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('feedback: $feedback, ')
          ..write('rating: $rating')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    outfitItems,
    temperature,
    weatherCondition,
    occasion,
    timestamp,
    confidenceScore,
    feedback,
    rating,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecommendationTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.outfitItems == this.outfitItems &&
          other.temperature == this.temperature &&
          other.weatherCondition == this.weatherCondition &&
          other.occasion == this.occasion &&
          other.timestamp == this.timestamp &&
          other.confidenceScore == this.confidenceScore &&
          other.feedback == this.feedback &&
          other.rating == this.rating);
}

class RecommendationTableCompanion
    extends UpdateCompanion<RecommendationTableData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> outfitItems;
  final Value<double> temperature;
  final Value<String> weatherCondition;
  final Value<String> occasion;
  final Value<int> timestamp;
  final Value<double> confidenceScore;
  final Value<String?> feedback;
  final Value<int?> rating;
  const RecommendationTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.outfitItems = const Value.absent(),
    this.temperature = const Value.absent(),
    this.weatherCondition = const Value.absent(),
    this.occasion = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.feedback = const Value.absent(),
    this.rating = const Value.absent(),
  });
  RecommendationTableCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String outfitItems,
    required double temperature,
    required String weatherCondition,
    required String occasion,
    required int timestamp,
    required double confidenceScore,
    this.feedback = const Value.absent(),
    this.rating = const Value.absent(),
  }) : userId = Value(userId),
       outfitItems = Value(outfitItems),
       temperature = Value(temperature),
       weatherCondition = Value(weatherCondition),
       occasion = Value(occasion),
       timestamp = Value(timestamp),
       confidenceScore = Value(confidenceScore);
  static Insertable<RecommendationTableData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? outfitItems,
    Expression<double>? temperature,
    Expression<String>? weatherCondition,
    Expression<String>? occasion,
    Expression<int>? timestamp,
    Expression<double>? confidenceScore,
    Expression<String>? feedback,
    Expression<int>? rating,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (outfitItems != null) 'outfit_items': outfitItems,
      if (temperature != null) 'temperature': temperature,
      if (weatherCondition != null) 'weather_condition': weatherCondition,
      if (occasion != null) 'occasion': occasion,
      if (timestamp != null) 'timestamp': timestamp,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      if (feedback != null) 'feedback': feedback,
      if (rating != null) 'rating': rating,
    });
  }

  RecommendationTableCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? outfitItems,
    Value<double>? temperature,
    Value<String>? weatherCondition,
    Value<String>? occasion,
    Value<int>? timestamp,
    Value<double>? confidenceScore,
    Value<String?>? feedback,
    Value<int?>? rating,
  }) {
    return RecommendationTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      outfitItems: outfitItems ?? this.outfitItems,
      temperature: temperature ?? this.temperature,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      occasion: occasion ?? this.occasion,
      timestamp: timestamp ?? this.timestamp,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      feedback: feedback ?? this.feedback,
      rating: rating ?? this.rating,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (outfitItems.present) {
      map['outfit_items'] = Variable<String>(outfitItems.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (weatherCondition.present) {
      map['weather_condition'] = Variable<String>(weatherCondition.value);
    }
    if (occasion.present) {
      map['occasion'] = Variable<String>(occasion.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (confidenceScore.present) {
      map['confidence_score'] = Variable<double>(confidenceScore.value);
    }
    if (feedback.present) {
      map['feedback'] = Variable<String>(feedback.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('outfitItems: $outfitItems, ')
          ..write('temperature: $temperature, ')
          ..write('weatherCondition: $weatherCondition, ')
          ..write('occasion: $occasion, ')
          ..write('timestamp: $timestamp, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('feedback: $feedback, ')
          ..write('rating: $rating')
          ..write(')'))
        .toString();
  }
}

class $WardrobeTableTable extends WardrobeTable
    with TableInfo<$WardrobeTableTable, WardrobeTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WardrobeTableTable(this.attachedDatabase, [this._alias]);
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weatherConditionMeta = const VerificationMeta(
    'weatherCondition',
  );
  @override
  late final GeneratedColumn<String> weatherCondition = GeneratedColumn<String>(
    'weather_condition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureMinMeta = const VerificationMeta(
    'temperatureMin',
  );
  @override
  late final GeneratedColumn<double> temperatureMin = GeneratedColumn<double>(
    'temperature_min',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureMaxMeta = const VerificationMeta(
    'temperatureMax',
  );
  @override
  late final GeneratedColumn<double> temperatureMax = GeneratedColumn<double>(
    'temperature_max',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
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
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
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
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
  );
  static const VerificationMeta _wearCountMeta = const VerificationMeta(
    'wearCount',
  );
  @override
  late final GeneratedColumn<int> wearCount = GeneratedColumn<int>(
    'wear_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastWornAtMeta = const VerificationMeta(
    'lastWornAt',
  );
  @override
  late final GeneratedColumn<int> lastWornAt = GeneratedColumn<int>(
    'last_worn_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    externalId,
    name,
    imageUrl,
    category,
    season,
    weatherCondition,
    temperatureMin,
    temperatureMax,
    occasions,
    addedAt,
    isActive,
    isFavorite,
    isArchived,
    wearCount,
    lastWornAt,
    isSynced,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wardrobe_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WardrobeTableData> instance, {
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
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('weather_condition')) {
      context.handle(
        _weatherConditionMeta,
        weatherCondition.isAcceptableOrUnknown(
          data['weather_condition']!,
          _weatherConditionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weatherConditionMeta);
    }
    if (data.containsKey('temperature_min')) {
      context.handle(
        _temperatureMinMeta,
        temperatureMin.isAcceptableOrUnknown(
          data['temperature_min']!,
          _temperatureMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperatureMinMeta);
    }
    if (data.containsKey('temperature_max')) {
      context.handle(
        _temperatureMaxMeta,
        temperatureMax.isAcceptableOrUnknown(
          data['temperature_max']!,
          _temperatureMaxMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperatureMaxMeta);
    }
    if (data.containsKey('occasions')) {
      context.handle(
        _occasionsMeta,
        occasions.isAcceptableOrUnknown(data['occasions']!, _occasionsMeta),
      );
    } else if (isInserting) {
      context.missing(_occasionsMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    } else if (isInserting) {
      context.missing(_isFavoriteMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    } else if (isInserting) {
      context.missing(_isArchivedMeta);
    }
    if (data.containsKey('wear_count')) {
      context.handle(
        _wearCountMeta,
        wearCount.isAcceptableOrUnknown(data['wear_count']!, _wearCountMeta),
      );
    } else if (isInserting) {
      context.missing(_wearCountMeta);
    }
    if (data.containsKey('last_worn_at')) {
      context.handle(
        _lastWornAtMeta,
        lastWornAt.isAcceptableOrUnknown(
          data['last_worn_at']!,
          _lastWornAtMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    } else if (isInserting) {
      context.missing(_isSyncedMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WardrobeTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WardrobeTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      externalId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}external_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      imageUrl:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}image_url'],
          )!,
      category:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}category'],
          )!,
      season:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}season'],
          )!,
      weatherCondition:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}weather_condition'],
          )!,
      temperatureMin:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}temperature_min'],
          )!,
      temperatureMax:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}temperature_max'],
          )!,
      occasions:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}occasions'],
          )!,
      addedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}added_at'],
          )!,
      isActive:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_active'],
          )!,
      isFavorite:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_favorite'],
          )!,
      isArchived:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_archived'],
          )!,
      wearCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}wear_count'],
          )!,
      lastWornAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_worn_at'],
      ),
      isSynced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_synced'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $WardrobeTableTable createAlias(String alias) {
    return $WardrobeTableTable(attachedDatabase, alias);
  }
}

class WardrobeTableData extends DataClass
    implements Insertable<WardrobeTableData> {
  final int id;
  final String externalId;
  final String name;
  final String imageUrl;
  final String category;
  final String season;
  final String weatherCondition;
  final double temperatureMin;
  final double temperatureMax;
  final String occasions;
  final int addedAt;
  final bool isActive;
  final bool isFavorite;
  final bool isArchived;
  final int wearCount;
  final int? lastWornAt;
  final bool isSynced;
  final int updatedAt;
  const WardrobeTableData({
    required this.id,
    required this.externalId,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.season,
    required this.weatherCondition,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.occasions,
    required this.addedAt,
    required this.isActive,
    required this.isFavorite,
    required this.isArchived,
    required this.wearCount,
    this.lastWornAt,
    required this.isSynced,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['external_id'] = Variable<String>(externalId);
    map['name'] = Variable<String>(name);
    map['image_url'] = Variable<String>(imageUrl);
    map['category'] = Variable<String>(category);
    map['season'] = Variable<String>(season);
    map['weather_condition'] = Variable<String>(weatherCondition);
    map['temperature_min'] = Variable<double>(temperatureMin);
    map['temperature_max'] = Variable<double>(temperatureMax);
    map['occasions'] = Variable<String>(occasions);
    map['added_at'] = Variable<int>(addedAt);
    map['is_active'] = Variable<bool>(isActive);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_archived'] = Variable<bool>(isArchived);
    map['wear_count'] = Variable<int>(wearCount);
    if (!nullToAbsent || lastWornAt != null) {
      map['last_worn_at'] = Variable<int>(lastWornAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  WardrobeTableCompanion toCompanion(bool nullToAbsent) {
    return WardrobeTableCompanion(
      id: Value(id),
      externalId: Value(externalId),
      name: Value(name),
      imageUrl: Value(imageUrl),
      category: Value(category),
      season: Value(season),
      weatherCondition: Value(weatherCondition),
      temperatureMin: Value(temperatureMin),
      temperatureMax: Value(temperatureMax),
      occasions: Value(occasions),
      addedAt: Value(addedAt),
      isActive: Value(isActive),
      isFavorite: Value(isFavorite),
      isArchived: Value(isArchived),
      wearCount: Value(wearCount),
      lastWornAt:
          lastWornAt == null && nullToAbsent
              ? const Value.absent()
              : Value(lastWornAt),
      isSynced: Value(isSynced),
      updatedAt: Value(updatedAt),
    );
  }

  factory WardrobeTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WardrobeTableData(
      id: serializer.fromJson<int>(json['id']),
      externalId: serializer.fromJson<String>(json['externalId']),
      name: serializer.fromJson<String>(json['name']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      category: serializer.fromJson<String>(json['category']),
      season: serializer.fromJson<String>(json['season']),
      weatherCondition: serializer.fromJson<String>(json['weatherCondition']),
      temperatureMin: serializer.fromJson<double>(json['temperatureMin']),
      temperatureMax: serializer.fromJson<double>(json['temperatureMax']),
      occasions: serializer.fromJson<String>(json['occasions']),
      addedAt: serializer.fromJson<int>(json['addedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      wearCount: serializer.fromJson<int>(json['wearCount']),
      lastWornAt: serializer.fromJson<int?>(json['lastWornAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'externalId': serializer.toJson<String>(externalId),
      'name': serializer.toJson<String>(name),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'category': serializer.toJson<String>(category),
      'season': serializer.toJson<String>(season),
      'weatherCondition': serializer.toJson<String>(weatherCondition),
      'temperatureMin': serializer.toJson<double>(temperatureMin),
      'temperatureMax': serializer.toJson<double>(temperatureMax),
      'occasions': serializer.toJson<String>(occasions),
      'addedAt': serializer.toJson<int>(addedAt),
      'isActive': serializer.toJson<bool>(isActive),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isArchived': serializer.toJson<bool>(isArchived),
      'wearCount': serializer.toJson<int>(wearCount),
      'lastWornAt': serializer.toJson<int?>(lastWornAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  WardrobeTableData copyWith({
    int? id,
    String? externalId,
    String? name,
    String? imageUrl,
    String? category,
    String? season,
    String? weatherCondition,
    double? temperatureMin,
    double? temperatureMax,
    String? occasions,
    int? addedAt,
    bool? isActive,
    bool? isFavorite,
    bool? isArchived,
    int? wearCount,
    Value<int?> lastWornAt = const Value.absent(),
    bool? isSynced,
    int? updatedAt,
  }) => WardrobeTableData(
    id: id ?? this.id,
    externalId: externalId ?? this.externalId,
    name: name ?? this.name,
    imageUrl: imageUrl ?? this.imageUrl,
    category: category ?? this.category,
    season: season ?? this.season,
    weatherCondition: weatherCondition ?? this.weatherCondition,
    temperatureMin: temperatureMin ?? this.temperatureMin,
    temperatureMax: temperatureMax ?? this.temperatureMax,
    occasions: occasions ?? this.occasions,
    addedAt: addedAt ?? this.addedAt,
    isActive: isActive ?? this.isActive,
    isFavorite: isFavorite ?? this.isFavorite,
    isArchived: isArchived ?? this.isArchived,
    wearCount: wearCount ?? this.wearCount,
    lastWornAt: lastWornAt.present ? lastWornAt.value : this.lastWornAt,
    isSynced: isSynced ?? this.isSynced,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WardrobeTableData copyWithCompanion(WardrobeTableCompanion data) {
    return WardrobeTableData(
      id: data.id.present ? data.id.value : this.id,
      externalId:
          data.externalId.present ? data.externalId.value : this.externalId,
      name: data.name.present ? data.name.value : this.name,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      category: data.category.present ? data.category.value : this.category,
      season: data.season.present ? data.season.value : this.season,
      weatherCondition:
          data.weatherCondition.present
              ? data.weatherCondition.value
              : this.weatherCondition,
      temperatureMin:
          data.temperatureMin.present
              ? data.temperatureMin.value
              : this.temperatureMin,
      temperatureMax:
          data.temperatureMax.present
              ? data.temperatureMax.value
              : this.temperatureMax,
      occasions: data.occasions.present ? data.occasions.value : this.occasions,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      wearCount: data.wearCount.present ? data.wearCount.value : this.wearCount,
      lastWornAt:
          data.lastWornAt.present ? data.lastWornAt.value : this.lastWornAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WardrobeTableData(')
          ..write('id: $id, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('category: $category, ')
          ..write('season: $season, ')
          ..write('weatherCondition: $weatherCondition, ')
          ..write('temperatureMin: $temperatureMin, ')
          ..write('temperatureMax: $temperatureMax, ')
          ..write('occasions: $occasions, ')
          ..write('addedAt: $addedAt, ')
          ..write('isActive: $isActive, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('wearCount: $wearCount, ')
          ..write('lastWornAt: $lastWornAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    externalId,
    name,
    imageUrl,
    category,
    season,
    weatherCondition,
    temperatureMin,
    temperatureMax,
    occasions,
    addedAt,
    isActive,
    isFavorite,
    isArchived,
    wearCount,
    lastWornAt,
    isSynced,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WardrobeTableData &&
          other.id == this.id &&
          other.externalId == this.externalId &&
          other.name == this.name &&
          other.imageUrl == this.imageUrl &&
          other.category == this.category &&
          other.season == this.season &&
          other.weatherCondition == this.weatherCondition &&
          other.temperatureMin == this.temperatureMin &&
          other.temperatureMax == this.temperatureMax &&
          other.occasions == this.occasions &&
          other.addedAt == this.addedAt &&
          other.isActive == this.isActive &&
          other.isFavorite == this.isFavorite &&
          other.isArchived == this.isArchived &&
          other.wearCount == this.wearCount &&
          other.lastWornAt == this.lastWornAt &&
          other.isSynced == this.isSynced &&
          other.updatedAt == this.updatedAt);
}

class WardrobeTableCompanion extends UpdateCompanion<WardrobeTableData> {
  final Value<int> id;
  final Value<String> externalId;
  final Value<String> name;
  final Value<String> imageUrl;
  final Value<String> category;
  final Value<String> season;
  final Value<String> weatherCondition;
  final Value<double> temperatureMin;
  final Value<double> temperatureMax;
  final Value<String> occasions;
  final Value<int> addedAt;
  final Value<bool> isActive;
  final Value<bool> isFavorite;
  final Value<bool> isArchived;
  final Value<int> wearCount;
  final Value<int?> lastWornAt;
  final Value<bool> isSynced;
  final Value<int> updatedAt;
  const WardrobeTableCompanion({
    this.id = const Value.absent(),
    this.externalId = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.category = const Value.absent(),
    this.season = const Value.absent(),
    this.weatherCondition = const Value.absent(),
    this.temperatureMin = const Value.absent(),
    this.temperatureMax = const Value.absent(),
    this.occasions = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.wearCount = const Value.absent(),
    this.lastWornAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WardrobeTableCompanion.insert({
    this.id = const Value.absent(),
    required String externalId,
    required String name,
    required String imageUrl,
    required String category,
    required String season,
    required String weatherCondition,
    required double temperatureMin,
    required double temperatureMax,
    required String occasions,
    required int addedAt,
    required bool isActive,
    required bool isFavorite,
    required bool isArchived,
    required int wearCount,
    this.lastWornAt = const Value.absent(),
    required bool isSynced,
    required int updatedAt,
  }) : externalId = Value(externalId),
       name = Value(name),
       imageUrl = Value(imageUrl),
       category = Value(category),
       season = Value(season),
       weatherCondition = Value(weatherCondition),
       temperatureMin = Value(temperatureMin),
       temperatureMax = Value(temperatureMax),
       occasions = Value(occasions),
       addedAt = Value(addedAt),
       isActive = Value(isActive),
       isFavorite = Value(isFavorite),
       isArchived = Value(isArchived),
       wearCount = Value(wearCount),
       isSynced = Value(isSynced),
       updatedAt = Value(updatedAt);
  static Insertable<WardrobeTableData> custom({
    Expression<int>? id,
    Expression<String>? externalId,
    Expression<String>? name,
    Expression<String>? imageUrl,
    Expression<String>? category,
    Expression<String>? season,
    Expression<String>? weatherCondition,
    Expression<double>? temperatureMin,
    Expression<double>? temperatureMax,
    Expression<String>? occasions,
    Expression<int>? addedAt,
    Expression<bool>? isActive,
    Expression<bool>? isFavorite,
    Expression<bool>? isArchived,
    Expression<int>? wearCount,
    Expression<int>? lastWornAt,
    Expression<bool>? isSynced,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (externalId != null) 'external_id': externalId,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (category != null) 'category': category,
      if (season != null) 'season': season,
      if (weatherCondition != null) 'weather_condition': weatherCondition,
      if (temperatureMin != null) 'temperature_min': temperatureMin,
      if (temperatureMax != null) 'temperature_max': temperatureMax,
      if (occasions != null) 'occasions': occasions,
      if (addedAt != null) 'added_at': addedAt,
      if (isActive != null) 'is_active': isActive,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isArchived != null) 'is_archived': isArchived,
      if (wearCount != null) 'wear_count': wearCount,
      if (lastWornAt != null) 'last_worn_at': lastWornAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WardrobeTableCompanion copyWith({
    Value<int>? id,
    Value<String>? externalId,
    Value<String>? name,
    Value<String>? imageUrl,
    Value<String>? category,
    Value<String>? season,
    Value<String>? weatherCondition,
    Value<double>? temperatureMin,
    Value<double>? temperatureMax,
    Value<String>? occasions,
    Value<int>? addedAt,
    Value<bool>? isActive,
    Value<bool>? isFavorite,
    Value<bool>? isArchived,
    Value<int>? wearCount,
    Value<int?>? lastWornAt,
    Value<bool>? isSynced,
    Value<int>? updatedAt,
  }) {
    return WardrobeTableCompanion(
      id: id ?? this.id,
      externalId: externalId ?? this.externalId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      season: season ?? this.season,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      temperatureMin: temperatureMin ?? this.temperatureMin,
      temperatureMax: temperatureMax ?? this.temperatureMax,
      occasions: occasions ?? this.occasions,
      addedAt: addedAt ?? this.addedAt,
      isActive: isActive ?? this.isActive,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      wearCount: wearCount ?? this.wearCount,
      lastWornAt: lastWornAt ?? this.lastWornAt,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (weatherCondition.present) {
      map['weather_condition'] = Variable<String>(weatherCondition.value);
    }
    if (temperatureMin.present) {
      map['temperature_min'] = Variable<double>(temperatureMin.value);
    }
    if (temperatureMax.present) {
      map['temperature_max'] = Variable<double>(temperatureMax.value);
    }
    if (occasions.present) {
      map['occasions'] = Variable<String>(occasions.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    if (lastWornAt.present) {
      map['last_worn_at'] = Variable<int>(lastWornAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WardrobeTableCompanion(')
          ..write('id: $id, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('category: $category, ')
          ..write('season: $season, ')
          ..write('weatherCondition: $weatherCondition, ')
          ..write('temperatureMin: $temperatureMin, ')
          ..write('temperatureMax: $temperatureMax, ')
          ..write('occasions: $occasions, ')
          ..write('addedAt: $addedAt, ')
          ..write('isActive: $isActive, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('wearCount: $wearCount, ')
          ..write('lastWornAt: $lastWornAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WeatherDataTableTable extends WeatherDataTable
    with TableInfo<$WeatherDataTableTable, WeatherDataTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeatherDataTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feelsLikeMeta = const VerificationMeta(
    'feelsLike',
  );
  @override
  late final GeneratedColumn<double> feelsLike = GeneratedColumn<double>(
    'feels_like',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tempMinMeta = const VerificationMeta(
    'tempMin',
  );
  @override
  late final GeneratedColumn<double> tempMin = GeneratedColumn<double>(
    'temp_min',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tempMaxMeta = const VerificationMeta(
    'tempMax',
  );
  @override
  late final GeneratedColumn<double> tempMax = GeneratedColumn<double>(
    'temp_max',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pressureMeta = const VerificationMeta(
    'pressure',
  );
  @override
  late final GeneratedColumn<int> pressure = GeneratedColumn<int>(
    'pressure',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _humidityMeta = const VerificationMeta(
    'humidity',
  );
  @override
  late final GeneratedColumn<int> humidity = GeneratedColumn<int>(
    'humidity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dewPointMeta = const VerificationMeta(
    'dewPoint',
  );
  @override
  late final GeneratedColumn<double> dewPoint = GeneratedColumn<double>(
    'dew_point',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uviMeta = const VerificationMeta('uvi');
  @override
  late final GeneratedColumn<double> uvi = GeneratedColumn<double>(
    'uvi',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cloudsMeta = const VerificationMeta('clouds');
  @override
  late final GeneratedColumn<int> clouds = GeneratedColumn<int>(
    'clouds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<int> visibility = GeneratedColumn<int>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _windSpeedMeta = const VerificationMeta(
    'windSpeed',
  );
  @override
  late final GeneratedColumn<double> windSpeed = GeneratedColumn<double>(
    'wind_speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _windDegMeta = const VerificationMeta(
    'windDeg',
  );
  @override
  late final GeneratedColumn<int> windDeg = GeneratedColumn<int>(
    'wind_deg',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _windGustMeta = const VerificationMeta(
    'windGust',
  );
  @override
  late final GeneratedColumn<double> windGust = GeneratedColumn<double>(
    'wind_gust',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherMainMeta = const VerificationMeta(
    'weatherMain',
  );
  @override
  late final GeneratedColumn<String> weatherMain = GeneratedColumn<String>(
    'weather_main',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weatherDescriptionMeta =
      const VerificationMeta('weatherDescription');
  @override
  late final GeneratedColumn<String> weatherDescription =
      GeneratedColumn<String>(
        'weather_description',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _weatherIconMeta = const VerificationMeta(
    'weatherIcon',
  );
  @override
  late final GeneratedColumn<String> weatherIcon = GeneratedColumn<String>(
    'weather_icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<int> timezone = GeneratedColumn<int>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sunriseMeta = const VerificationMeta(
    'sunrise',
  );
  @override
  late final GeneratedColumn<int> sunrise = GeneratedColumn<int>(
    'sunrise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sunsetMeta = const VerificationMeta('sunset');
  @override
  late final GeneratedColumn<int> sunset = GeneratedColumn<int>(
    'sunset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCurrentMeta = const VerificationMeta(
    'isCurrent',
  );
  @override
  late final GeneratedColumn<bool> isCurrent = GeneratedColumn<bool>(
    'is_current',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_current" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    latitude,
    longitude,
    locationName,
    temperature,
    feelsLike,
    tempMin,
    tempMax,
    pressure,
    humidity,
    dewPoint,
    uvi,
    clouds,
    visibility,
    windSpeed,
    windDeg,
    windGust,
    weatherMain,
    weatherDescription,
    weatherIcon,
    timestamp,
    timezone,
    country,
    sunrise,
    sunset,
    isCurrent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weather_data_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeatherDataTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationNameMeta);
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperatureMeta);
    }
    if (data.containsKey('feels_like')) {
      context.handle(
        _feelsLikeMeta,
        feelsLike.isAcceptableOrUnknown(data['feels_like']!, _feelsLikeMeta),
      );
    } else if (isInserting) {
      context.missing(_feelsLikeMeta);
    }
    if (data.containsKey('temp_min')) {
      context.handle(
        _tempMinMeta,
        tempMin.isAcceptableOrUnknown(data['temp_min']!, _tempMinMeta),
      );
    } else if (isInserting) {
      context.missing(_tempMinMeta);
    }
    if (data.containsKey('temp_max')) {
      context.handle(
        _tempMaxMeta,
        tempMax.isAcceptableOrUnknown(data['temp_max']!, _tempMaxMeta),
      );
    } else if (isInserting) {
      context.missing(_tempMaxMeta);
    }
    if (data.containsKey('pressure')) {
      context.handle(
        _pressureMeta,
        pressure.isAcceptableOrUnknown(data['pressure']!, _pressureMeta),
      );
    } else if (isInserting) {
      context.missing(_pressureMeta);
    }
    if (data.containsKey('humidity')) {
      context.handle(
        _humidityMeta,
        humidity.isAcceptableOrUnknown(data['humidity']!, _humidityMeta),
      );
    } else if (isInserting) {
      context.missing(_humidityMeta);
    }
    if (data.containsKey('dew_point')) {
      context.handle(
        _dewPointMeta,
        dewPoint.isAcceptableOrUnknown(data['dew_point']!, _dewPointMeta),
      );
    } else if (isInserting) {
      context.missing(_dewPointMeta);
    }
    if (data.containsKey('uvi')) {
      context.handle(
        _uviMeta,
        uvi.isAcceptableOrUnknown(data['uvi']!, _uviMeta),
      );
    } else if (isInserting) {
      context.missing(_uviMeta);
    }
    if (data.containsKey('clouds')) {
      context.handle(
        _cloudsMeta,
        clouds.isAcceptableOrUnknown(data['clouds']!, _cloudsMeta),
      );
    } else if (isInserting) {
      context.missing(_cloudsMeta);
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    } else if (isInserting) {
      context.missing(_visibilityMeta);
    }
    if (data.containsKey('wind_speed')) {
      context.handle(
        _windSpeedMeta,
        windSpeed.isAcceptableOrUnknown(data['wind_speed']!, _windSpeedMeta),
      );
    } else if (isInserting) {
      context.missing(_windSpeedMeta);
    }
    if (data.containsKey('wind_deg')) {
      context.handle(
        _windDegMeta,
        windDeg.isAcceptableOrUnknown(data['wind_deg']!, _windDegMeta),
      );
    } else if (isInserting) {
      context.missing(_windDegMeta);
    }
    if (data.containsKey('wind_gust')) {
      context.handle(
        _windGustMeta,
        windGust.isAcceptableOrUnknown(data['wind_gust']!, _windGustMeta),
      );
    }
    if (data.containsKey('weather_main')) {
      context.handle(
        _weatherMainMeta,
        weatherMain.isAcceptableOrUnknown(
          data['weather_main']!,
          _weatherMainMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weatherMainMeta);
    }
    if (data.containsKey('weather_description')) {
      context.handle(
        _weatherDescriptionMeta,
        weatherDescription.isAcceptableOrUnknown(
          data['weather_description']!,
          _weatherDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weatherDescriptionMeta);
    }
    if (data.containsKey('weather_icon')) {
      context.handle(
        _weatherIconMeta,
        weatherIcon.isAcceptableOrUnknown(
          data['weather_icon']!,
          _weatherIconMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weatherIconMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('sunrise')) {
      context.handle(
        _sunriseMeta,
        sunrise.isAcceptableOrUnknown(data['sunrise']!, _sunriseMeta),
      );
    } else if (isInserting) {
      context.missing(_sunriseMeta);
    }
    if (data.containsKey('sunset')) {
      context.handle(
        _sunsetMeta,
        sunset.isAcceptableOrUnknown(data['sunset']!, _sunsetMeta),
      );
    } else if (isInserting) {
      context.missing(_sunsetMeta);
    }
    if (data.containsKey('is_current')) {
      context.handle(
        _isCurrentMeta,
        isCurrent.isAcceptableOrUnknown(data['is_current']!, _isCurrentMeta),
      );
    } else if (isInserting) {
      context.missing(_isCurrentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeatherDataTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeatherDataTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      latitude:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}latitude'],
          )!,
      longitude:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}longitude'],
          )!,
      locationName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}location_name'],
          )!,
      temperature:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}temperature'],
          )!,
      feelsLike:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}feels_like'],
          )!,
      tempMin:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}temp_min'],
          )!,
      tempMax:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}temp_max'],
          )!,
      pressure:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}pressure'],
          )!,
      humidity:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}humidity'],
          )!,
      dewPoint:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}dew_point'],
          )!,
      uvi:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}uvi'],
          )!,
      clouds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}clouds'],
          )!,
      visibility:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}visibility'],
          )!,
      windSpeed:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}wind_speed'],
          )!,
      windDeg:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}wind_deg'],
          )!,
      windGust: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}wind_gust'],
      ),
      weatherMain:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}weather_main'],
          )!,
      weatherDescription:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}weather_description'],
          )!,
      weatherIcon:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}weather_icon'],
          )!,
      timestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}timestamp'],
          )!,
      timezone:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}timezone'],
          )!,
      country:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}country'],
          )!,
      sunrise:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sunrise'],
          )!,
      sunset:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sunset'],
          )!,
      isCurrent:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_current'],
          )!,
    );
  }

  @override
  $WeatherDataTableTable createAlias(String alias) {
    return $WeatherDataTableTable(attachedDatabase, alias);
  }
}

class WeatherDataTableData extends DataClass
    implements Insertable<WeatherDataTableData> {
  final int id;
  final double latitude;
  final double longitude;
  final String locationName;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final double dewPoint;
  final double uvi;
  final int clouds;
  final int visibility;
  final double windSpeed;
  final int windDeg;
  final double? windGust;
  final String weatherMain;
  final String weatherDescription;
  final String weatherIcon;
  final int timestamp;
  final int timezone;
  final String country;
  final int sunrise;
  final int sunset;
  final bool isCurrent;
  const WeatherDataTableData({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.dewPoint,
    required this.uvi,
    required this.clouds,
    required this.visibility,
    required this.windSpeed,
    required this.windDeg,
    this.windGust,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.timestamp,
    required this.timezone,
    required this.country,
    required this.sunrise,
    required this.sunset,
    required this.isCurrent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['location_name'] = Variable<String>(locationName);
    map['temperature'] = Variable<double>(temperature);
    map['feels_like'] = Variable<double>(feelsLike);
    map['temp_min'] = Variable<double>(tempMin);
    map['temp_max'] = Variable<double>(tempMax);
    map['pressure'] = Variable<int>(pressure);
    map['humidity'] = Variable<int>(humidity);
    map['dew_point'] = Variable<double>(dewPoint);
    map['uvi'] = Variable<double>(uvi);
    map['clouds'] = Variable<int>(clouds);
    map['visibility'] = Variable<int>(visibility);
    map['wind_speed'] = Variable<double>(windSpeed);
    map['wind_deg'] = Variable<int>(windDeg);
    if (!nullToAbsent || windGust != null) {
      map['wind_gust'] = Variable<double>(windGust);
    }
    map['weather_main'] = Variable<String>(weatherMain);
    map['weather_description'] = Variable<String>(weatherDescription);
    map['weather_icon'] = Variable<String>(weatherIcon);
    map['timestamp'] = Variable<int>(timestamp);
    map['timezone'] = Variable<int>(timezone);
    map['country'] = Variable<String>(country);
    map['sunrise'] = Variable<int>(sunrise);
    map['sunset'] = Variable<int>(sunset);
    map['is_current'] = Variable<bool>(isCurrent);
    return map;
  }

  WeatherDataTableCompanion toCompanion(bool nullToAbsent) {
    return WeatherDataTableCompanion(
      id: Value(id),
      latitude: Value(latitude),
      longitude: Value(longitude),
      locationName: Value(locationName),
      temperature: Value(temperature),
      feelsLike: Value(feelsLike),
      tempMin: Value(tempMin),
      tempMax: Value(tempMax),
      pressure: Value(pressure),
      humidity: Value(humidity),
      dewPoint: Value(dewPoint),
      uvi: Value(uvi),
      clouds: Value(clouds),
      visibility: Value(visibility),
      windSpeed: Value(windSpeed),
      windDeg: Value(windDeg),
      windGust:
          windGust == null && nullToAbsent
              ? const Value.absent()
              : Value(windGust),
      weatherMain: Value(weatherMain),
      weatherDescription: Value(weatherDescription),
      weatherIcon: Value(weatherIcon),
      timestamp: Value(timestamp),
      timezone: Value(timezone),
      country: Value(country),
      sunrise: Value(sunrise),
      sunset: Value(sunset),
      isCurrent: Value(isCurrent),
    );
  }

  factory WeatherDataTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeatherDataTableData(
      id: serializer.fromJson<int>(json['id']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      locationName: serializer.fromJson<String>(json['locationName']),
      temperature: serializer.fromJson<double>(json['temperature']),
      feelsLike: serializer.fromJson<double>(json['feelsLike']),
      tempMin: serializer.fromJson<double>(json['tempMin']),
      tempMax: serializer.fromJson<double>(json['tempMax']),
      pressure: serializer.fromJson<int>(json['pressure']),
      humidity: serializer.fromJson<int>(json['humidity']),
      dewPoint: serializer.fromJson<double>(json['dewPoint']),
      uvi: serializer.fromJson<double>(json['uvi']),
      clouds: serializer.fromJson<int>(json['clouds']),
      visibility: serializer.fromJson<int>(json['visibility']),
      windSpeed: serializer.fromJson<double>(json['windSpeed']),
      windDeg: serializer.fromJson<int>(json['windDeg']),
      windGust: serializer.fromJson<double?>(json['windGust']),
      weatherMain: serializer.fromJson<String>(json['weatherMain']),
      weatherDescription: serializer.fromJson<String>(
        json['weatherDescription'],
      ),
      weatherIcon: serializer.fromJson<String>(json['weatherIcon']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      timezone: serializer.fromJson<int>(json['timezone']),
      country: serializer.fromJson<String>(json['country']),
      sunrise: serializer.fromJson<int>(json['sunrise']),
      sunset: serializer.fromJson<int>(json['sunset']),
      isCurrent: serializer.fromJson<bool>(json['isCurrent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'locationName': serializer.toJson<String>(locationName),
      'temperature': serializer.toJson<double>(temperature),
      'feelsLike': serializer.toJson<double>(feelsLike),
      'tempMin': serializer.toJson<double>(tempMin),
      'tempMax': serializer.toJson<double>(tempMax),
      'pressure': serializer.toJson<int>(pressure),
      'humidity': serializer.toJson<int>(humidity),
      'dewPoint': serializer.toJson<double>(dewPoint),
      'uvi': serializer.toJson<double>(uvi),
      'clouds': serializer.toJson<int>(clouds),
      'visibility': serializer.toJson<int>(visibility),
      'windSpeed': serializer.toJson<double>(windSpeed),
      'windDeg': serializer.toJson<int>(windDeg),
      'windGust': serializer.toJson<double?>(windGust),
      'weatherMain': serializer.toJson<String>(weatherMain),
      'weatherDescription': serializer.toJson<String>(weatherDescription),
      'weatherIcon': serializer.toJson<String>(weatherIcon),
      'timestamp': serializer.toJson<int>(timestamp),
      'timezone': serializer.toJson<int>(timezone),
      'country': serializer.toJson<String>(country),
      'sunrise': serializer.toJson<int>(sunrise),
      'sunset': serializer.toJson<int>(sunset),
      'isCurrent': serializer.toJson<bool>(isCurrent),
    };
  }

  WeatherDataTableData copyWith({
    int? id,
    double? latitude,
    double? longitude,
    String? locationName,
    double? temperature,
    double? feelsLike,
    double? tempMin,
    double? tempMax,
    int? pressure,
    int? humidity,
    double? dewPoint,
    double? uvi,
    int? clouds,
    int? visibility,
    double? windSpeed,
    int? windDeg,
    Value<double?> windGust = const Value.absent(),
    String? weatherMain,
    String? weatherDescription,
    String? weatherIcon,
    int? timestamp,
    int? timezone,
    String? country,
    int? sunrise,
    int? sunset,
    bool? isCurrent,
  }) => WeatherDataTableData(
    id: id ?? this.id,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    locationName: locationName ?? this.locationName,
    temperature: temperature ?? this.temperature,
    feelsLike: feelsLike ?? this.feelsLike,
    tempMin: tempMin ?? this.tempMin,
    tempMax: tempMax ?? this.tempMax,
    pressure: pressure ?? this.pressure,
    humidity: humidity ?? this.humidity,
    dewPoint: dewPoint ?? this.dewPoint,
    uvi: uvi ?? this.uvi,
    clouds: clouds ?? this.clouds,
    visibility: visibility ?? this.visibility,
    windSpeed: windSpeed ?? this.windSpeed,
    windDeg: windDeg ?? this.windDeg,
    windGust: windGust.present ? windGust.value : this.windGust,
    weatherMain: weatherMain ?? this.weatherMain,
    weatherDescription: weatherDescription ?? this.weatherDescription,
    weatherIcon: weatherIcon ?? this.weatherIcon,
    timestamp: timestamp ?? this.timestamp,
    timezone: timezone ?? this.timezone,
    country: country ?? this.country,
    sunrise: sunrise ?? this.sunrise,
    sunset: sunset ?? this.sunset,
    isCurrent: isCurrent ?? this.isCurrent,
  );
  WeatherDataTableData copyWithCompanion(WeatherDataTableCompanion data) {
    return WeatherDataTableData(
      id: data.id.present ? data.id.value : this.id,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      locationName:
          data.locationName.present
              ? data.locationName.value
              : this.locationName,
      temperature:
          data.temperature.present ? data.temperature.value : this.temperature,
      feelsLike: data.feelsLike.present ? data.feelsLike.value : this.feelsLike,
      tempMin: data.tempMin.present ? data.tempMin.value : this.tempMin,
      tempMax: data.tempMax.present ? data.tempMax.value : this.tempMax,
      pressure: data.pressure.present ? data.pressure.value : this.pressure,
      humidity: data.humidity.present ? data.humidity.value : this.humidity,
      dewPoint: data.dewPoint.present ? data.dewPoint.value : this.dewPoint,
      uvi: data.uvi.present ? data.uvi.value : this.uvi,
      clouds: data.clouds.present ? data.clouds.value : this.clouds,
      visibility:
          data.visibility.present ? data.visibility.value : this.visibility,
      windSpeed: data.windSpeed.present ? data.windSpeed.value : this.windSpeed,
      windDeg: data.windDeg.present ? data.windDeg.value : this.windDeg,
      windGust: data.windGust.present ? data.windGust.value : this.windGust,
      weatherMain:
          data.weatherMain.present ? data.weatherMain.value : this.weatherMain,
      weatherDescription:
          data.weatherDescription.present
              ? data.weatherDescription.value
              : this.weatherDescription,
      weatherIcon:
          data.weatherIcon.present ? data.weatherIcon.value : this.weatherIcon,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      country: data.country.present ? data.country.value : this.country,
      sunrise: data.sunrise.present ? data.sunrise.value : this.sunrise,
      sunset: data.sunset.present ? data.sunset.value : this.sunset,
      isCurrent: data.isCurrent.present ? data.isCurrent.value : this.isCurrent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeatherDataTableData(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationName: $locationName, ')
          ..write('temperature: $temperature, ')
          ..write('feelsLike: $feelsLike, ')
          ..write('tempMin: $tempMin, ')
          ..write('tempMax: $tempMax, ')
          ..write('pressure: $pressure, ')
          ..write('humidity: $humidity, ')
          ..write('dewPoint: $dewPoint, ')
          ..write('uvi: $uvi, ')
          ..write('clouds: $clouds, ')
          ..write('visibility: $visibility, ')
          ..write('windSpeed: $windSpeed, ')
          ..write('windDeg: $windDeg, ')
          ..write('windGust: $windGust, ')
          ..write('weatherMain: $weatherMain, ')
          ..write('weatherDescription: $weatherDescription, ')
          ..write('weatherIcon: $weatherIcon, ')
          ..write('timestamp: $timestamp, ')
          ..write('timezone: $timezone, ')
          ..write('country: $country, ')
          ..write('sunrise: $sunrise, ')
          ..write('sunset: $sunset, ')
          ..write('isCurrent: $isCurrent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    latitude,
    longitude,
    locationName,
    temperature,
    feelsLike,
    tempMin,
    tempMax,
    pressure,
    humidity,
    dewPoint,
    uvi,
    clouds,
    visibility,
    windSpeed,
    windDeg,
    windGust,
    weatherMain,
    weatherDescription,
    weatherIcon,
    timestamp,
    timezone,
    country,
    sunrise,
    sunset,
    isCurrent,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeatherDataTableData &&
          other.id == this.id &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.locationName == this.locationName &&
          other.temperature == this.temperature &&
          other.feelsLike == this.feelsLike &&
          other.tempMin == this.tempMin &&
          other.tempMax == this.tempMax &&
          other.pressure == this.pressure &&
          other.humidity == this.humidity &&
          other.dewPoint == this.dewPoint &&
          other.uvi == this.uvi &&
          other.clouds == this.clouds &&
          other.visibility == this.visibility &&
          other.windSpeed == this.windSpeed &&
          other.windDeg == this.windDeg &&
          other.windGust == this.windGust &&
          other.weatherMain == this.weatherMain &&
          other.weatherDescription == this.weatherDescription &&
          other.weatherIcon == this.weatherIcon &&
          other.timestamp == this.timestamp &&
          other.timezone == this.timezone &&
          other.country == this.country &&
          other.sunrise == this.sunrise &&
          other.sunset == this.sunset &&
          other.isCurrent == this.isCurrent);
}

class WeatherDataTableCompanion extends UpdateCompanion<WeatherDataTableData> {
  final Value<int> id;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> locationName;
  final Value<double> temperature;
  final Value<double> feelsLike;
  final Value<double> tempMin;
  final Value<double> tempMax;
  final Value<int> pressure;
  final Value<int> humidity;
  final Value<double> dewPoint;
  final Value<double> uvi;
  final Value<int> clouds;
  final Value<int> visibility;
  final Value<double> windSpeed;
  final Value<int> windDeg;
  final Value<double?> windGust;
  final Value<String> weatherMain;
  final Value<String> weatherDescription;
  final Value<String> weatherIcon;
  final Value<int> timestamp;
  final Value<int> timezone;
  final Value<String> country;
  final Value<int> sunrise;
  final Value<int> sunset;
  final Value<bool> isCurrent;
  const WeatherDataTableCompanion({
    this.id = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationName = const Value.absent(),
    this.temperature = const Value.absent(),
    this.feelsLike = const Value.absent(),
    this.tempMin = const Value.absent(),
    this.tempMax = const Value.absent(),
    this.pressure = const Value.absent(),
    this.humidity = const Value.absent(),
    this.dewPoint = const Value.absent(),
    this.uvi = const Value.absent(),
    this.clouds = const Value.absent(),
    this.visibility = const Value.absent(),
    this.windSpeed = const Value.absent(),
    this.windDeg = const Value.absent(),
    this.windGust = const Value.absent(),
    this.weatherMain = const Value.absent(),
    this.weatherDescription = const Value.absent(),
    this.weatherIcon = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.timezone = const Value.absent(),
    this.country = const Value.absent(),
    this.sunrise = const Value.absent(),
    this.sunset = const Value.absent(),
    this.isCurrent = const Value.absent(),
  });
  WeatherDataTableCompanion.insert({
    this.id = const Value.absent(),
    required double latitude,
    required double longitude,
    required String locationName,
    required double temperature,
    required double feelsLike,
    required double tempMin,
    required double tempMax,
    required int pressure,
    required int humidity,
    required double dewPoint,
    required double uvi,
    required int clouds,
    required int visibility,
    required double windSpeed,
    required int windDeg,
    this.windGust = const Value.absent(),
    required String weatherMain,
    required String weatherDescription,
    required String weatherIcon,
    required int timestamp,
    required int timezone,
    required String country,
    required int sunrise,
    required int sunset,
    required bool isCurrent,
  }) : latitude = Value(latitude),
       longitude = Value(longitude),
       locationName = Value(locationName),
       temperature = Value(temperature),
       feelsLike = Value(feelsLike),
       tempMin = Value(tempMin),
       tempMax = Value(tempMax),
       pressure = Value(pressure),
       humidity = Value(humidity),
       dewPoint = Value(dewPoint),
       uvi = Value(uvi),
       clouds = Value(clouds),
       visibility = Value(visibility),
       windSpeed = Value(windSpeed),
       windDeg = Value(windDeg),
       weatherMain = Value(weatherMain),
       weatherDescription = Value(weatherDescription),
       weatherIcon = Value(weatherIcon),
       timestamp = Value(timestamp),
       timezone = Value(timezone),
       country = Value(country),
       sunrise = Value(sunrise),
       sunset = Value(sunset),
       isCurrent = Value(isCurrent);
  static Insertable<WeatherDataTableData> custom({
    Expression<int>? id,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? locationName,
    Expression<double>? temperature,
    Expression<double>? feelsLike,
    Expression<double>? tempMin,
    Expression<double>? tempMax,
    Expression<int>? pressure,
    Expression<int>? humidity,
    Expression<double>? dewPoint,
    Expression<double>? uvi,
    Expression<int>? clouds,
    Expression<int>? visibility,
    Expression<double>? windSpeed,
    Expression<int>? windDeg,
    Expression<double>? windGust,
    Expression<String>? weatherMain,
    Expression<String>? weatherDescription,
    Expression<String>? weatherIcon,
    Expression<int>? timestamp,
    Expression<int>? timezone,
    Expression<String>? country,
    Expression<int>? sunrise,
    Expression<int>? sunset,
    Expression<bool>? isCurrent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationName != null) 'location_name': locationName,
      if (temperature != null) 'temperature': temperature,
      if (feelsLike != null) 'feels_like': feelsLike,
      if (tempMin != null) 'temp_min': tempMin,
      if (tempMax != null) 'temp_max': tempMax,
      if (pressure != null) 'pressure': pressure,
      if (humidity != null) 'humidity': humidity,
      if (dewPoint != null) 'dew_point': dewPoint,
      if (uvi != null) 'uvi': uvi,
      if (clouds != null) 'clouds': clouds,
      if (visibility != null) 'visibility': visibility,
      if (windSpeed != null) 'wind_speed': windSpeed,
      if (windDeg != null) 'wind_deg': windDeg,
      if (windGust != null) 'wind_gust': windGust,
      if (weatherMain != null) 'weather_main': weatherMain,
      if (weatherDescription != null) 'weather_description': weatherDescription,
      if (weatherIcon != null) 'weather_icon': weatherIcon,
      if (timestamp != null) 'timestamp': timestamp,
      if (timezone != null) 'timezone': timezone,
      if (country != null) 'country': country,
      if (sunrise != null) 'sunrise': sunrise,
      if (sunset != null) 'sunset': sunset,
      if (isCurrent != null) 'is_current': isCurrent,
    });
  }

  WeatherDataTableCompanion copyWith({
    Value<int>? id,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? locationName,
    Value<double>? temperature,
    Value<double>? feelsLike,
    Value<double>? tempMin,
    Value<double>? tempMax,
    Value<int>? pressure,
    Value<int>? humidity,
    Value<double>? dewPoint,
    Value<double>? uvi,
    Value<int>? clouds,
    Value<int>? visibility,
    Value<double>? windSpeed,
    Value<int>? windDeg,
    Value<double?>? windGust,
    Value<String>? weatherMain,
    Value<String>? weatherDescription,
    Value<String>? weatherIcon,
    Value<int>? timestamp,
    Value<int>? timezone,
    Value<String>? country,
    Value<int>? sunrise,
    Value<int>? sunset,
    Value<bool>? isCurrent,
  }) {
    return WeatherDataTableCompanion(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      tempMin: tempMin ?? this.tempMin,
      tempMax: tempMax ?? this.tempMax,
      pressure: pressure ?? this.pressure,
      humidity: humidity ?? this.humidity,
      dewPoint: dewPoint ?? this.dewPoint,
      uvi: uvi ?? this.uvi,
      clouds: clouds ?? this.clouds,
      visibility: visibility ?? this.visibility,
      windSpeed: windSpeed ?? this.windSpeed,
      windDeg: windDeg ?? this.windDeg,
      windGust: windGust ?? this.windGust,
      weatherMain: weatherMain ?? this.weatherMain,
      weatherDescription: weatherDescription ?? this.weatherDescription,
      weatherIcon: weatherIcon ?? this.weatherIcon,
      timestamp: timestamp ?? this.timestamp,
      timezone: timezone ?? this.timezone,
      country: country ?? this.country,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (feelsLike.present) {
      map['feels_like'] = Variable<double>(feelsLike.value);
    }
    if (tempMin.present) {
      map['temp_min'] = Variable<double>(tempMin.value);
    }
    if (tempMax.present) {
      map['temp_max'] = Variable<double>(tempMax.value);
    }
    if (pressure.present) {
      map['pressure'] = Variable<int>(pressure.value);
    }
    if (humidity.present) {
      map['humidity'] = Variable<int>(humidity.value);
    }
    if (dewPoint.present) {
      map['dew_point'] = Variable<double>(dewPoint.value);
    }
    if (uvi.present) {
      map['uvi'] = Variable<double>(uvi.value);
    }
    if (clouds.present) {
      map['clouds'] = Variable<int>(clouds.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<int>(visibility.value);
    }
    if (windSpeed.present) {
      map['wind_speed'] = Variable<double>(windSpeed.value);
    }
    if (windDeg.present) {
      map['wind_deg'] = Variable<int>(windDeg.value);
    }
    if (windGust.present) {
      map['wind_gust'] = Variable<double>(windGust.value);
    }
    if (weatherMain.present) {
      map['weather_main'] = Variable<String>(weatherMain.value);
    }
    if (weatherDescription.present) {
      map['weather_description'] = Variable<String>(weatherDescription.value);
    }
    if (weatherIcon.present) {
      map['weather_icon'] = Variable<String>(weatherIcon.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<int>(timezone.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (sunrise.present) {
      map['sunrise'] = Variable<int>(sunrise.value);
    }
    if (sunset.present) {
      map['sunset'] = Variable<int>(sunset.value);
    }
    if (isCurrent.present) {
      map['is_current'] = Variable<bool>(isCurrent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeatherDataTableCompanion(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationName: $locationName, ')
          ..write('temperature: $temperature, ')
          ..write('feelsLike: $feelsLike, ')
          ..write('tempMin: $tempMin, ')
          ..write('tempMax: $tempMax, ')
          ..write('pressure: $pressure, ')
          ..write('humidity: $humidity, ')
          ..write('dewPoint: $dewPoint, ')
          ..write('uvi: $uvi, ')
          ..write('clouds: $clouds, ')
          ..write('visibility: $visibility, ')
          ..write('windSpeed: $windSpeed, ')
          ..write('windDeg: $windDeg, ')
          ..write('windGust: $windGust, ')
          ..write('weatherMain: $weatherMain, ')
          ..write('weatherDescription: $weatherDescription, ')
          ..write('weatherIcon: $weatherIcon, ')
          ..write('timestamp: $timestamp, ')
          ..write('timezone: $timezone, ')
          ..write('country: $country, ')
          ..write('sunrise: $sunrise, ')
          ..write('sunset: $sunset, ')
          ..write('isCurrent: $isCurrent')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $RecommendationTableTable recommendationTable =
      $RecommendationTableTable(this);
  late final $WardrobeTableTable wardrobeTable = $WardrobeTableTable(this);
  late final $WeatherDataTableTable weatherDataTable = $WeatherDataTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recommendationTable,
    wardrobeTable,
    weatherDataTable,
  ];
}

typedef $$RecommendationTableTableCreateCompanionBuilder =
    RecommendationTableCompanion Function({
      Value<int> id,
      required String userId,
      required String outfitItems,
      required double temperature,
      required String weatherCondition,
      required String occasion,
      required int timestamp,
      required double confidenceScore,
      Value<String?> feedback,
      Value<int?> rating,
    });
typedef $$RecommendationTableTableUpdateCompanionBuilder =
    RecommendationTableCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> outfitItems,
      Value<double> temperature,
      Value<String> weatherCondition,
      Value<String> occasion,
      Value<int> timestamp,
      Value<double> confidenceScore,
      Value<String?> feedback,
      Value<int?> rating,
    });

class $$RecommendationTableTableFilterComposer
    extends Composer<_$LocalDatabase, $RecommendationTableTable> {
  $$RecommendationTableTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outfitItems => $composableBuilder(
    column: $table.outfitItems,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherCondition => $composableBuilder(
    column: $table.weatherCondition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occasion => $composableBuilder(
    column: $table.occasion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecommendationTableTableOrderingComposer
    extends Composer<_$LocalDatabase, $RecommendationTableTable> {
  $$RecommendationTableTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outfitItems => $composableBuilder(
    column: $table.outfitItems,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherCondition => $composableBuilder(
    column: $table.weatherCondition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occasion => $composableBuilder(
    column: $table.occasion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecommendationTableTableAnnotationComposer
    extends Composer<_$LocalDatabase, $RecommendationTableTable> {
  $$RecommendationTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get outfitItems => $composableBuilder(
    column: $table.outfitItems,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weatherCondition => $composableBuilder(
    column: $table.weatherCondition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get occasion =>
      $composableBuilder(column: $table.occasion, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedback =>
      $composableBuilder(column: $table.feedback, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);
}

class $$RecommendationTableTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $RecommendationTableTable,
          RecommendationTableData,
          $$RecommendationTableTableFilterComposer,
          $$RecommendationTableTableOrderingComposer,
          $$RecommendationTableTableAnnotationComposer,
          $$RecommendationTableTableCreateCompanionBuilder,
          $$RecommendationTableTableUpdateCompanionBuilder,
          (
            RecommendationTableData,
            BaseReferences<
              _$LocalDatabase,
              $RecommendationTableTable,
              RecommendationTableData
            >,
          ),
          RecommendationTableData,
          PrefetchHooks Function()
        > {
  $$RecommendationTableTableTableManager(
    _$LocalDatabase db,
    $RecommendationTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RecommendationTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$RecommendationTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$RecommendationTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> outfitItems = const Value.absent(),
                Value<double> temperature = const Value.absent(),
                Value<String> weatherCondition = const Value.absent(),
                Value<String> occasion = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<double> confidenceScore = const Value.absent(),
                Value<String?> feedback = const Value.absent(),
                Value<int?> rating = const Value.absent(),
              }) => RecommendationTableCompanion(
                id: id,
                userId: userId,
                outfitItems: outfitItems,
                temperature: temperature,
                weatherCondition: weatherCondition,
                occasion: occasion,
                timestamp: timestamp,
                confidenceScore: confidenceScore,
                feedback: feedback,
                rating: rating,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String outfitItems,
                required double temperature,
                required String weatherCondition,
                required String occasion,
                required int timestamp,
                required double confidenceScore,
                Value<String?> feedback = const Value.absent(),
                Value<int?> rating = const Value.absent(),
              }) => RecommendationTableCompanion.insert(
                id: id,
                userId: userId,
                outfitItems: outfitItems,
                temperature: temperature,
                weatherCondition: weatherCondition,
                occasion: occasion,
                timestamp: timestamp,
                confidenceScore: confidenceScore,
                feedback: feedback,
                rating: rating,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecommendationTableTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $RecommendationTableTable,
      RecommendationTableData,
      $$RecommendationTableTableFilterComposer,
      $$RecommendationTableTableOrderingComposer,
      $$RecommendationTableTableAnnotationComposer,
      $$RecommendationTableTableCreateCompanionBuilder,
      $$RecommendationTableTableUpdateCompanionBuilder,
      (
        RecommendationTableData,
        BaseReferences<
          _$LocalDatabase,
          $RecommendationTableTable,
          RecommendationTableData
        >,
      ),
      RecommendationTableData,
      PrefetchHooks Function()
    >;
typedef $$WardrobeTableTableCreateCompanionBuilder =
    WardrobeTableCompanion Function({
      Value<int> id,
      required String externalId,
      required String name,
      required String imageUrl,
      required String category,
      required String season,
      required String weatherCondition,
      required double temperatureMin,
      required double temperatureMax,
      required String occasions,
      required int addedAt,
      required bool isActive,
      required bool isFavorite,
      required bool isArchived,
      required int wearCount,
      Value<int?> lastWornAt,
      required bool isSynced,
      required int updatedAt,
    });
typedef $$WardrobeTableTableUpdateCompanionBuilder =
    WardrobeTableCompanion Function({
      Value<int> id,
      Value<String> externalId,
      Value<String> name,
      Value<String> imageUrl,
      Value<String> category,
      Value<String> season,
      Value<String> weatherCondition,
      Value<double> temperatureMin,
      Value<double> temperatureMax,
      Value<String> occasions,
      Value<int> addedAt,
      Value<bool> isActive,
      Value<bool> isFavorite,
      Value<bool> isArchived,
      Value<int> wearCount,
      Value<int?> lastWornAt,
      Value<bool> isSynced,
      Value<int> updatedAt,
    });

class $$WardrobeTableTableFilterComposer
    extends Composer<_$LocalDatabase, $WardrobeTableTable> {
  $$WardrobeTableTableFilterComposer({
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

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherCondition => $composableBuilder(
    column: $table.weatherCondition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperatureMin => $composableBuilder(
    column: $table.temperatureMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperatureMax => $composableBuilder(
    column: $table.temperatureMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occasions => $composableBuilder(
    column: $table.occasions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  ColumnFilters<int> get wearCount => $composableBuilder(
    column: $table.wearCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastWornAt => $composableBuilder(
    column: $table.lastWornAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WardrobeTableTableOrderingComposer
    extends Composer<_$LocalDatabase, $WardrobeTableTable> {
  $$WardrobeTableTableOrderingComposer({
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

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherCondition => $composableBuilder(
    column: $table.weatherCondition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperatureMin => $composableBuilder(
    column: $table.temperatureMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperatureMax => $composableBuilder(
    column: $table.temperatureMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occasions => $composableBuilder(
    column: $table.occasions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  ColumnOrderings<int> get wearCount => $composableBuilder(
    column: $table.wearCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastWornAt => $composableBuilder(
    column: $table.lastWornAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WardrobeTableTableAnnotationComposer
    extends Composer<_$LocalDatabase, $WardrobeTableTable> {
  $$WardrobeTableTableAnnotationComposer({
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

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<String> get weatherCondition => $composableBuilder(
    column: $table.weatherCondition,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperatureMin => $composableBuilder(
    column: $table.temperatureMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperatureMax => $composableBuilder(
    column: $table.temperatureMax,
    builder: (column) => column,
  );

  GeneratedColumn<String> get occasions =>
      $composableBuilder(column: $table.occasions, builder: (column) => column);

  GeneratedColumn<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wearCount =>
      $composableBuilder(column: $table.wearCount, builder: (column) => column);

  GeneratedColumn<int> get lastWornAt => $composableBuilder(
    column: $table.lastWornAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WardrobeTableTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $WardrobeTableTable,
          WardrobeTableData,
          $$WardrobeTableTableFilterComposer,
          $$WardrobeTableTableOrderingComposer,
          $$WardrobeTableTableAnnotationComposer,
          $$WardrobeTableTableCreateCompanionBuilder,
          $$WardrobeTableTableUpdateCompanionBuilder,
          (
            WardrobeTableData,
            BaseReferences<
              _$LocalDatabase,
              $WardrobeTableTable,
              WardrobeTableData
            >,
          ),
          WardrobeTableData,
          PrefetchHooks Function()
        > {
  $$WardrobeTableTableTableManager(
    _$LocalDatabase db,
    $WardrobeTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$WardrobeTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$WardrobeTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$WardrobeTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<String> weatherCondition = const Value.absent(),
                Value<double> temperatureMin = const Value.absent(),
                Value<double> temperatureMax = const Value.absent(),
                Value<String> occasions = const Value.absent(),
                Value<int> addedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> wearCount = const Value.absent(),
                Value<int?> lastWornAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => WardrobeTableCompanion(
                id: id,
                externalId: externalId,
                name: name,
                imageUrl: imageUrl,
                category: category,
                season: season,
                weatherCondition: weatherCondition,
                temperatureMin: temperatureMin,
                temperatureMax: temperatureMax,
                occasions: occasions,
                addedAt: addedAt,
                isActive: isActive,
                isFavorite: isFavorite,
                isArchived: isArchived,
                wearCount: wearCount,
                lastWornAt: lastWornAt,
                isSynced: isSynced,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String externalId,
                required String name,
                required String imageUrl,
                required String category,
                required String season,
                required String weatherCondition,
                required double temperatureMin,
                required double temperatureMax,
                required String occasions,
                required int addedAt,
                required bool isActive,
                required bool isFavorite,
                required bool isArchived,
                required int wearCount,
                Value<int?> lastWornAt = const Value.absent(),
                required bool isSynced,
                required int updatedAt,
              }) => WardrobeTableCompanion.insert(
                id: id,
                externalId: externalId,
                name: name,
                imageUrl: imageUrl,
                category: category,
                season: season,
                weatherCondition: weatherCondition,
                temperatureMin: temperatureMin,
                temperatureMax: temperatureMax,
                occasions: occasions,
                addedAt: addedAt,
                isActive: isActive,
                isFavorite: isFavorite,
                isArchived: isArchived,
                wearCount: wearCount,
                lastWornAt: lastWornAt,
                isSynced: isSynced,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WardrobeTableTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $WardrobeTableTable,
      WardrobeTableData,
      $$WardrobeTableTableFilterComposer,
      $$WardrobeTableTableOrderingComposer,
      $$WardrobeTableTableAnnotationComposer,
      $$WardrobeTableTableCreateCompanionBuilder,
      $$WardrobeTableTableUpdateCompanionBuilder,
      (
        WardrobeTableData,
        BaseReferences<_$LocalDatabase, $WardrobeTableTable, WardrobeTableData>,
      ),
      WardrobeTableData,
      PrefetchHooks Function()
    >;
typedef $$WeatherDataTableTableCreateCompanionBuilder =
    WeatherDataTableCompanion Function({
      Value<int> id,
      required double latitude,
      required double longitude,
      required String locationName,
      required double temperature,
      required double feelsLike,
      required double tempMin,
      required double tempMax,
      required int pressure,
      required int humidity,
      required double dewPoint,
      required double uvi,
      required int clouds,
      required int visibility,
      required double windSpeed,
      required int windDeg,
      Value<double?> windGust,
      required String weatherMain,
      required String weatherDescription,
      required String weatherIcon,
      required int timestamp,
      required int timezone,
      required String country,
      required int sunrise,
      required int sunset,
      required bool isCurrent,
    });
typedef $$WeatherDataTableTableUpdateCompanionBuilder =
    WeatherDataTableCompanion Function({
      Value<int> id,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> locationName,
      Value<double> temperature,
      Value<double> feelsLike,
      Value<double> tempMin,
      Value<double> tempMax,
      Value<int> pressure,
      Value<int> humidity,
      Value<double> dewPoint,
      Value<double> uvi,
      Value<int> clouds,
      Value<int> visibility,
      Value<double> windSpeed,
      Value<int> windDeg,
      Value<double?> windGust,
      Value<String> weatherMain,
      Value<String> weatherDescription,
      Value<String> weatherIcon,
      Value<int> timestamp,
      Value<int> timezone,
      Value<String> country,
      Value<int> sunrise,
      Value<int> sunset,
      Value<bool> isCurrent,
    });

class $$WeatherDataTableTableFilterComposer
    extends Composer<_$LocalDatabase, $WeatherDataTableTable> {
  $$WeatherDataTableTableFilterComposer({
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

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get feelsLike => $composableBuilder(
    column: $table.feelsLike,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tempMin => $composableBuilder(
    column: $table.tempMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tempMax => $composableBuilder(
    column: $table.tempMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pressure => $composableBuilder(
    column: $table.pressure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get humidity => $composableBuilder(
    column: $table.humidity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dewPoint => $composableBuilder(
    column: $table.dewPoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get uvi => $composableBuilder(
    column: $table.uvi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clouds => $composableBuilder(
    column: $table.clouds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get windSpeed => $composableBuilder(
    column: $table.windSpeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get windDeg => $composableBuilder(
    column: $table.windDeg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get windGust => $composableBuilder(
    column: $table.windGust,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherMain => $composableBuilder(
    column: $table.weatherMain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherDescription => $composableBuilder(
    column: $table.weatherDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherIcon => $composableBuilder(
    column: $table.weatherIcon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sunrise => $composableBuilder(
    column: $table.sunrise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sunset => $composableBuilder(
    column: $table.sunset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeatherDataTableTableOrderingComposer
    extends Composer<_$LocalDatabase, $WeatherDataTableTable> {
  $$WeatherDataTableTableOrderingComposer({
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

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get feelsLike => $composableBuilder(
    column: $table.feelsLike,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tempMin => $composableBuilder(
    column: $table.tempMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tempMax => $composableBuilder(
    column: $table.tempMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pressure => $composableBuilder(
    column: $table.pressure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get humidity => $composableBuilder(
    column: $table.humidity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dewPoint => $composableBuilder(
    column: $table.dewPoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get uvi => $composableBuilder(
    column: $table.uvi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clouds => $composableBuilder(
    column: $table.clouds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get windSpeed => $composableBuilder(
    column: $table.windSpeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get windDeg => $composableBuilder(
    column: $table.windDeg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get windGust => $composableBuilder(
    column: $table.windGust,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherMain => $composableBuilder(
    column: $table.weatherMain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherDescription => $composableBuilder(
    column: $table.weatherDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherIcon => $composableBuilder(
    column: $table.weatherIcon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sunrise => $composableBuilder(
    column: $table.sunrise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sunset => $composableBuilder(
    column: $table.sunset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeatherDataTableTableAnnotationComposer
    extends Composer<_$LocalDatabase, $WeatherDataTableTable> {
  $$WeatherDataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<double> get feelsLike =>
      $composableBuilder(column: $table.feelsLike, builder: (column) => column);

  GeneratedColumn<double> get tempMin =>
      $composableBuilder(column: $table.tempMin, builder: (column) => column);

  GeneratedColumn<double> get tempMax =>
      $composableBuilder(column: $table.tempMax, builder: (column) => column);

  GeneratedColumn<int> get pressure =>
      $composableBuilder(column: $table.pressure, builder: (column) => column);

  GeneratedColumn<int> get humidity =>
      $composableBuilder(column: $table.humidity, builder: (column) => column);

  GeneratedColumn<double> get dewPoint =>
      $composableBuilder(column: $table.dewPoint, builder: (column) => column);

  GeneratedColumn<double> get uvi =>
      $composableBuilder(column: $table.uvi, builder: (column) => column);

  GeneratedColumn<int> get clouds =>
      $composableBuilder(column: $table.clouds, builder: (column) => column);

  GeneratedColumn<int> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<double> get windSpeed =>
      $composableBuilder(column: $table.windSpeed, builder: (column) => column);

  GeneratedColumn<int> get windDeg =>
      $composableBuilder(column: $table.windDeg, builder: (column) => column);

  GeneratedColumn<double> get windGust =>
      $composableBuilder(column: $table.windGust, builder: (column) => column);

  GeneratedColumn<String> get weatherMain => $composableBuilder(
    column: $table.weatherMain,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weatherDescription => $composableBuilder(
    column: $table.weatherDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weatherIcon => $composableBuilder(
    column: $table.weatherIcon,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<int> get sunrise =>
      $composableBuilder(column: $table.sunrise, builder: (column) => column);

  GeneratedColumn<int> get sunset =>
      $composableBuilder(column: $table.sunset, builder: (column) => column);

  GeneratedColumn<bool> get isCurrent =>
      $composableBuilder(column: $table.isCurrent, builder: (column) => column);
}

class $$WeatherDataTableTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $WeatherDataTableTable,
          WeatherDataTableData,
          $$WeatherDataTableTableFilterComposer,
          $$WeatherDataTableTableOrderingComposer,
          $$WeatherDataTableTableAnnotationComposer,
          $$WeatherDataTableTableCreateCompanionBuilder,
          $$WeatherDataTableTableUpdateCompanionBuilder,
          (
            WeatherDataTableData,
            BaseReferences<
              _$LocalDatabase,
              $WeatherDataTableTable,
              WeatherDataTableData
            >,
          ),
          WeatherDataTableData,
          PrefetchHooks Function()
        > {
  $$WeatherDataTableTableTableManager(
    _$LocalDatabase db,
    $WeatherDataTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$WeatherDataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$WeatherDataTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$WeatherDataTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> locationName = const Value.absent(),
                Value<double> temperature = const Value.absent(),
                Value<double> feelsLike = const Value.absent(),
                Value<double> tempMin = const Value.absent(),
                Value<double> tempMax = const Value.absent(),
                Value<int> pressure = const Value.absent(),
                Value<int> humidity = const Value.absent(),
                Value<double> dewPoint = const Value.absent(),
                Value<double> uvi = const Value.absent(),
                Value<int> clouds = const Value.absent(),
                Value<int> visibility = const Value.absent(),
                Value<double> windSpeed = const Value.absent(),
                Value<int> windDeg = const Value.absent(),
                Value<double?> windGust = const Value.absent(),
                Value<String> weatherMain = const Value.absent(),
                Value<String> weatherDescription = const Value.absent(),
                Value<String> weatherIcon = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<int> timezone = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<int> sunrise = const Value.absent(),
                Value<int> sunset = const Value.absent(),
                Value<bool> isCurrent = const Value.absent(),
              }) => WeatherDataTableCompanion(
                id: id,
                latitude: latitude,
                longitude: longitude,
                locationName: locationName,
                temperature: temperature,
                feelsLike: feelsLike,
                tempMin: tempMin,
                tempMax: tempMax,
                pressure: pressure,
                humidity: humidity,
                dewPoint: dewPoint,
                uvi: uvi,
                clouds: clouds,
                visibility: visibility,
                windSpeed: windSpeed,
                windDeg: windDeg,
                windGust: windGust,
                weatherMain: weatherMain,
                weatherDescription: weatherDescription,
                weatherIcon: weatherIcon,
                timestamp: timestamp,
                timezone: timezone,
                country: country,
                sunrise: sunrise,
                sunset: sunset,
                isCurrent: isCurrent,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double latitude,
                required double longitude,
                required String locationName,
                required double temperature,
                required double feelsLike,
                required double tempMin,
                required double tempMax,
                required int pressure,
                required int humidity,
                required double dewPoint,
                required double uvi,
                required int clouds,
                required int visibility,
                required double windSpeed,
                required int windDeg,
                Value<double?> windGust = const Value.absent(),
                required String weatherMain,
                required String weatherDescription,
                required String weatherIcon,
                required int timestamp,
                required int timezone,
                required String country,
                required int sunrise,
                required int sunset,
                required bool isCurrent,
              }) => WeatherDataTableCompanion.insert(
                id: id,
                latitude: latitude,
                longitude: longitude,
                locationName: locationName,
                temperature: temperature,
                feelsLike: feelsLike,
                tempMin: tempMin,
                tempMax: tempMax,
                pressure: pressure,
                humidity: humidity,
                dewPoint: dewPoint,
                uvi: uvi,
                clouds: clouds,
                visibility: visibility,
                windSpeed: windSpeed,
                windDeg: windDeg,
                windGust: windGust,
                weatherMain: weatherMain,
                weatherDescription: weatherDescription,
                weatherIcon: weatherIcon,
                timestamp: timestamp,
                timezone: timezone,
                country: country,
                sunrise: sunrise,
                sunset: sunset,
                isCurrent: isCurrent,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeatherDataTableTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $WeatherDataTableTable,
      WeatherDataTableData,
      $$WeatherDataTableTableFilterComposer,
      $$WeatherDataTableTableOrderingComposer,
      $$WeatherDataTableTableAnnotationComposer,
      $$WeatherDataTableTableCreateCompanionBuilder,
      $$WeatherDataTableTableUpdateCompanionBuilder,
      (
        WeatherDataTableData,
        BaseReferences<
          _$LocalDatabase,
          $WeatherDataTableTable,
          WeatherDataTableData
        >,
      ),
      WeatherDataTableData,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$RecommendationTableTableTableManager get recommendationTable =>
      $$RecommendationTableTableTableManager(_db, _db.recommendationTable);
  $$WardrobeTableTableTableManager get wardrobeTable =>
      $$WardrobeTableTableTableManager(_db, _db.wardrobeTable);
  $$WeatherDataTableTableTableManager get weatherDataTable =>
      $$WeatherDataTableTableTableManager(_db, _db.weatherDataTable);
}
