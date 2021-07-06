// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Media extends DataClass implements Insertable<Media> {
  final int createdOn;
  final String createdBy;
  final int messageId;
  final MediaType type;
  final String roomId;
  final String json;
  Media(
      {@required this.createdOn,
      @required this.createdBy,
      @required this.messageId,
      @required this.type,
      @required this.roomId,
      @required this.json});
  factory Media.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    return Media(
      createdOn: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}created_on']),
      createdBy: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}created_by']),
      messageId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}message_id']),
      type: $MediasTable.$converter0.mapToDart(const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}type'])),
      roomId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      json: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}json']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || createdOn != null) {
      map['created_on'] = Variable<int>(createdOn);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || messageId != null) {
      map['message_id'] = Variable<int>(messageId);
    }
    if (!nullToAbsent || type != null) {
      final converter = $MediasTable.$converter0;
      map['type'] = Variable<int>(converter.mapToSql(type));
    }
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    if (!nullToAbsent || json != null) {
      map['json'] = Variable<String>(json);
    }
    return map;
  }

  MediasCompanion toCompanion(bool nullToAbsent) {
    return MediasCompanion(
      createdOn: createdOn == null && nullToAbsent
          ? const Value.absent()
          : Value(createdOn),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      messageId: messageId == null && nullToAbsent
          ? const Value.absent()
          : Value(messageId),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      roomId:
          roomId == null && nullToAbsent ? const Value.absent() : Value(roomId),
      json: json == null && nullToAbsent ? const Value.absent() : Value(json),
    );
  }

  factory Media.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Media(
      createdOn: serializer.fromJson<int>(json['createdOn']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      messageId: serializer.fromJson<int>(json['messageId']),
      type: serializer.fromJson<MediaType>(json['type']),
      roomId: serializer.fromJson<String>(json['roomId']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdOn': serializer.toJson<int>(createdOn),
      'createdBy': serializer.toJson<String>(createdBy),
      'messageId': serializer.toJson<int>(messageId),
      'type': serializer.toJson<MediaType>(type),
      'roomId': serializer.toJson<String>(roomId),
      'json': serializer.toJson<String>(json),
    };
  }

  Media copyWith(
          {int createdOn,
          String createdBy,
          int messageId,
          MediaType type,
          String roomId,
          String json}) =>
      Media(
        createdOn: createdOn ?? this.createdOn,
        createdBy: createdBy ?? this.createdBy,
        messageId: messageId ?? this.messageId,
        type: type ?? this.type,
        roomId: roomId ?? this.roomId,
        json: json ?? this.json,
      );
  @override
  String toString() {
    return (StringBuffer('Media(')
          ..write('createdOn: $createdOn, ')
          ..write('createdBy: $createdBy, ')
          ..write('messageId: $messageId, ')
          ..write('type: $type, ')
          ..write('roomId: $roomId, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      createdOn.hashCode,
      $mrjc(
          createdBy.hashCode,
          $mrjc(messageId.hashCode,
              $mrjc(type.hashCode, $mrjc(roomId.hashCode, json.hashCode))))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Media &&
          other.createdOn == this.createdOn &&
          other.createdBy == this.createdBy &&
          other.messageId == this.messageId &&
          other.type == this.type &&
          other.roomId == this.roomId &&
          other.json == this.json);
}

class MediasCompanion extends UpdateCompanion<Media> {
  final Value<int> createdOn;
  final Value<String> createdBy;
  final Value<int> messageId;
  final Value<MediaType> type;
  final Value<String> roomId;
  final Value<String> json;
  const MediasCompanion({
    this.createdOn = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.messageId = const Value.absent(),
    this.type = const Value.absent(),
    this.roomId = const Value.absent(),
    this.json = const Value.absent(),
  });
  MediasCompanion.insert({
    @required int createdOn,
    @required String createdBy,
    this.messageId = const Value.absent(),
    @required MediaType type,
    @required String roomId,
    @required String json,
  })  : createdOn = Value(createdOn),
        createdBy = Value(createdBy),
        type = Value(type),
        roomId = Value(roomId),
        json = Value(json);
  static Insertable<Media> custom({
    Expression<int> createdOn,
    Expression<String> createdBy,
    Expression<int> messageId,
    Expression<MediaType> type,
    Expression<String> roomId,
    Expression<String> json,
  }) {
    return RawValuesInsertable({
      if (createdOn != null) 'created_on': createdOn,
      if (createdBy != null) 'created_by': createdBy,
      if (messageId != null) 'message_id': messageId,
      if (type != null) 'type': type,
      if (roomId != null) 'room_id': roomId,
      if (json != null) 'json': json,
    });
  }

  MediasCompanion copyWith(
      {Value<int> createdOn,
      Value<String> createdBy,
      Value<int> messageId,
      Value<MediaType> type,
      Value<String> roomId,
      Value<String> json}) {
    return MediasCompanion(
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      messageId: messageId ?? this.messageId,
      type: type ?? this.type,
      roomId: roomId ?? this.roomId,
      json: json ?? this.json,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdOn.present) {
      map['created_on'] = Variable<int>(createdOn.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (type.present) {
      final converter = $MediasTable.$converter0;
      map['type'] = Variable<int>(converter.mapToSql(type.value));
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediasCompanion(')
          ..write('createdOn: $createdOn, ')
          ..write('createdBy: $createdBy, ')
          ..write('messageId: $messageId, ')
          ..write('type: $type, ')
          ..write('roomId: $roomId, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }
}

class $MediasTable extends Medias with TableInfo<$MediasTable, Media> {
  final GeneratedDatabase _db;
  final String _alias;
  $MediasTable(this._db, [this._alias]);
  final VerificationMeta _createdOnMeta = const VerificationMeta('createdOn');
  GeneratedIntColumn _createdOn;
  @override
  GeneratedIntColumn get createdOn => _createdOn ??= _constructCreatedOn();
  GeneratedIntColumn _constructCreatedOn() {
    return GeneratedIntColumn(
      'created_on',
      $tableName,
      false,
    );
  }

  final VerificationMeta _createdByMeta = const VerificationMeta('createdBy');
  GeneratedTextColumn _createdBy;
  @override
  GeneratedTextColumn get createdBy => _createdBy ??= _constructCreatedBy();
  GeneratedTextColumn _constructCreatedBy() {
    return GeneratedTextColumn(
      'created_by',
      $tableName,
      false,
    );
  }

  final VerificationMeta _messageIdMeta = const VerificationMeta('messageId');
  GeneratedIntColumn _messageId;
  @override
  GeneratedIntColumn get messageId => _messageId ??= _constructMessageId();
  GeneratedIntColumn _constructMessageId() {
    return GeneratedIntColumn(
      'message_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _typeMeta = const VerificationMeta('type');
  GeneratedIntColumn _type;
  @override
  GeneratedIntColumn get type => _type ??= _constructType();
  GeneratedIntColumn _constructType() {
    return GeneratedIntColumn(
      'type',
      $tableName,
      false,
    );
  }

  final VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  GeneratedTextColumn _roomId;
  @override
  GeneratedTextColumn get roomId => _roomId ??= _constructRoomId();
  GeneratedTextColumn _constructRoomId() {
    return GeneratedTextColumn(
      'room_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _jsonMeta = const VerificationMeta('json');
  GeneratedTextColumn _json;
  @override
  GeneratedTextColumn get json => _json ??= _constructJson();
  GeneratedTextColumn _constructJson() {
    return GeneratedTextColumn(
      'json',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns =>
      [createdOn, createdBy, messageId, type, roomId, json];
  @override
  $MediasTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'medias';
  @override
  final String actualTableName = 'medias';
  @override
  VerificationContext validateIntegrity(Insertable<Media> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_on')) {
      context.handle(_createdOnMeta,
          createdOn.isAcceptableOrUnknown(data['created_on'], _createdOnMeta));
    } else if (isInserting) {
      context.missing(_createdOnMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by'], _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id'], _messageIdMeta));
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id'], _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
          _jsonMeta, json.isAcceptableOrUnknown(data['json'], _jsonMeta));
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId};
  @override
  Media map(Map<String, dynamic> data, {String tablePrefix}) {
    return Media.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $MediasTable createAlias(String alias) {
    return $MediasTable(_db, alias);
  }

  static TypeConverter<MediaType, int> $converter0 =
      const EnumIndexConverter<MediaType>(MediaType.values);
}

class MediasMetaDataData extends DataClass
    implements Insertable<MediasMetaDataData> {
  final String roomId;
  final int imagesCount;
  final int videosCount;
  final int filesCount;
  final int documentsCount;
  final int audiosCount;
  final int musicsCount;
  final int linkCount;
  MediasMetaDataData(
      {@required this.roomId,
      @required this.imagesCount,
      @required this.videosCount,
      @required this.filesCount,
      @required this.documentsCount,
      @required this.audiosCount,
      @required this.musicsCount,
      @required this.linkCount});
  factory MediasMetaDataData.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    return MediasMetaDataData(
      roomId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      imagesCount: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}images_count']),
      videosCount: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}videos_count']),
      filesCount: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}files_count']),
      documentsCount: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}documents_count']),
      audiosCount: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}audios_count']),
      musicsCount: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}musics_count']),
      linkCount: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}link_count']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    if (!nullToAbsent || imagesCount != null) {
      map['images_count'] = Variable<int>(imagesCount);
    }
    if (!nullToAbsent || videosCount != null) {
      map['videos_count'] = Variable<int>(videosCount);
    }
    if (!nullToAbsent || filesCount != null) {
      map['files_count'] = Variable<int>(filesCount);
    }
    if (!nullToAbsent || documentsCount != null) {
      map['documents_count'] = Variable<int>(documentsCount);
    }
    if (!nullToAbsent || audiosCount != null) {
      map['audios_count'] = Variable<int>(audiosCount);
    }
    if (!nullToAbsent || musicsCount != null) {
      map['musics_count'] = Variable<int>(musicsCount);
    }
    if (!nullToAbsent || linkCount != null) {
      map['link_count'] = Variable<int>(linkCount);
    }
    return map;
  }

  MediasMetaDataCompanion toCompanion(bool nullToAbsent) {
    return MediasMetaDataCompanion(
      roomId:
          roomId == null && nullToAbsent ? const Value.absent() : Value(roomId),
      imagesCount: imagesCount == null && nullToAbsent
          ? const Value.absent()
          : Value(imagesCount),
      videosCount: videosCount == null && nullToAbsent
          ? const Value.absent()
          : Value(videosCount),
      filesCount: filesCount == null && nullToAbsent
          ? const Value.absent()
          : Value(filesCount),
      documentsCount: documentsCount == null && nullToAbsent
          ? const Value.absent()
          : Value(documentsCount),
      audiosCount: audiosCount == null && nullToAbsent
          ? const Value.absent()
          : Value(audiosCount),
      musicsCount: musicsCount == null && nullToAbsent
          ? const Value.absent()
          : Value(musicsCount),
      linkCount: linkCount == null && nullToAbsent
          ? const Value.absent()
          : Value(linkCount),
    );
  }

  factory MediasMetaDataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return MediasMetaDataData(
      roomId: serializer.fromJson<String>(json['roomId']),
      imagesCount: serializer.fromJson<int>(json['imagesCount']),
      videosCount: serializer.fromJson<int>(json['videosCount']),
      filesCount: serializer.fromJson<int>(json['filesCount']),
      documentsCount: serializer.fromJson<int>(json['documentsCount']),
      audiosCount: serializer.fromJson<int>(json['audiosCount']),
      musicsCount: serializer.fromJson<int>(json['musicsCount']),
      linkCount: serializer.fromJson<int>(json['linkCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roomId': serializer.toJson<String>(roomId),
      'imagesCount': serializer.toJson<int>(imagesCount),
      'videosCount': serializer.toJson<int>(videosCount),
      'filesCount': serializer.toJson<int>(filesCount),
      'documentsCount': serializer.toJson<int>(documentsCount),
      'audiosCount': serializer.toJson<int>(audiosCount),
      'musicsCount': serializer.toJson<int>(musicsCount),
      'linkCount': serializer.toJson<int>(linkCount),
    };
  }

  MediasMetaDataData copyWith(
          {String roomId,
          int imagesCount,
          int videosCount,
          int filesCount,
          int documentsCount,
          int audiosCount,
          int musicsCount,
          int linkCount}) =>
      MediasMetaDataData(
        roomId: roomId ?? this.roomId,
        imagesCount: imagesCount ?? this.imagesCount,
        videosCount: videosCount ?? this.videosCount,
        filesCount: filesCount ?? this.filesCount,
        documentsCount: documentsCount ?? this.documentsCount,
        audiosCount: audiosCount ?? this.audiosCount,
        musicsCount: musicsCount ?? this.musicsCount,
        linkCount: linkCount ?? this.linkCount,
      );
  @override
  String toString() {
    return (StringBuffer('MediasMetaDataData(')
          ..write('roomId: $roomId, ')
          ..write('imagesCount: $imagesCount, ')
          ..write('videosCount: $videosCount, ')
          ..write('filesCount: $filesCount, ')
          ..write('documentsCount: $documentsCount, ')
          ..write('audiosCount: $audiosCount, ')
          ..write('musicsCount: $musicsCount, ')
          ..write('linkCount: $linkCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      roomId.hashCode,
      $mrjc(
          imagesCount.hashCode,
          $mrjc(
              videosCount.hashCode,
              $mrjc(
                  filesCount.hashCode,
                  $mrjc(
                      documentsCount.hashCode,
                      $mrjc(
                          audiosCount.hashCode,
                          $mrjc(
                              musicsCount.hashCode, linkCount.hashCode))))))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediasMetaDataData &&
          other.roomId == this.roomId &&
          other.imagesCount == this.imagesCount &&
          other.videosCount == this.videosCount &&
          other.filesCount == this.filesCount &&
          other.documentsCount == this.documentsCount &&
          other.audiosCount == this.audiosCount &&
          other.musicsCount == this.musicsCount &&
          other.linkCount == this.linkCount);
}

class MediasMetaDataCompanion extends UpdateCompanion<MediasMetaDataData> {
  final Value<String> roomId;
  final Value<int> imagesCount;
  final Value<int> videosCount;
  final Value<int> filesCount;
  final Value<int> documentsCount;
  final Value<int> audiosCount;
  final Value<int> musicsCount;
  final Value<int> linkCount;
  const MediasMetaDataCompanion({
    this.roomId = const Value.absent(),
    this.imagesCount = const Value.absent(),
    this.videosCount = const Value.absent(),
    this.filesCount = const Value.absent(),
    this.documentsCount = const Value.absent(),
    this.audiosCount = const Value.absent(),
    this.musicsCount = const Value.absent(),
    this.linkCount = const Value.absent(),
  });
  MediasMetaDataCompanion.insert({
    @required String roomId,
    @required int imagesCount,
    @required int videosCount,
    @required int filesCount,
    @required int documentsCount,
    @required int audiosCount,
    @required int musicsCount,
    @required int linkCount,
  })  : roomId = Value(roomId),
        imagesCount = Value(imagesCount),
        videosCount = Value(videosCount),
        filesCount = Value(filesCount),
        documentsCount = Value(documentsCount),
        audiosCount = Value(audiosCount),
        musicsCount = Value(musicsCount),
        linkCount = Value(linkCount);
  static Insertable<MediasMetaDataData> custom({
    Expression<String> roomId,
    Expression<int> imagesCount,
    Expression<int> videosCount,
    Expression<int> filesCount,
    Expression<int> documentsCount,
    Expression<int> audiosCount,
    Expression<int> musicsCount,
    Expression<int> linkCount,
  }) {
    return RawValuesInsertable({
      if (roomId != null) 'room_id': roomId,
      if (imagesCount != null) 'images_count': imagesCount,
      if (videosCount != null) 'videos_count': videosCount,
      if (filesCount != null) 'files_count': filesCount,
      if (documentsCount != null) 'documents_count': documentsCount,
      if (audiosCount != null) 'audios_count': audiosCount,
      if (musicsCount != null) 'musics_count': musicsCount,
      if (linkCount != null) 'link_count': linkCount,
    });
  }

  MediasMetaDataCompanion copyWith(
      {Value<String> roomId,
      Value<int> imagesCount,
      Value<int> videosCount,
      Value<int> filesCount,
      Value<int> documentsCount,
      Value<int> audiosCount,
      Value<int> musicsCount,
      Value<int> linkCount}) {
    return MediasMetaDataCompanion(
      roomId: roomId ?? this.roomId,
      imagesCount: imagesCount ?? this.imagesCount,
      videosCount: videosCount ?? this.videosCount,
      filesCount: filesCount ?? this.filesCount,
      documentsCount: documentsCount ?? this.documentsCount,
      audiosCount: audiosCount ?? this.audiosCount,
      musicsCount: musicsCount ?? this.musicsCount,
      linkCount: linkCount ?? this.linkCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (imagesCount.present) {
      map['images_count'] = Variable<int>(imagesCount.value);
    }
    if (videosCount.present) {
      map['videos_count'] = Variable<int>(videosCount.value);
    }
    if (filesCount.present) {
      map['files_count'] = Variable<int>(filesCount.value);
    }
    if (documentsCount.present) {
      map['documents_count'] = Variable<int>(documentsCount.value);
    }
    if (audiosCount.present) {
      map['audios_count'] = Variable<int>(audiosCount.value);
    }
    if (musicsCount.present) {
      map['musics_count'] = Variable<int>(musicsCount.value);
    }
    if (linkCount.present) {
      map['link_count'] = Variable<int>(linkCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediasMetaDataCompanion(')
          ..write('roomId: $roomId, ')
          ..write('imagesCount: $imagesCount, ')
          ..write('videosCount: $videosCount, ')
          ..write('filesCount: $filesCount, ')
          ..write('documentsCount: $documentsCount, ')
          ..write('audiosCount: $audiosCount, ')
          ..write('musicsCount: $musicsCount, ')
          ..write('linkCount: $linkCount')
          ..write(')'))
        .toString();
  }
}

class $MediasMetaDataTable extends MediasMetaData
    with TableInfo<$MediasMetaDataTable, MediasMetaDataData> {
  final GeneratedDatabase _db;
  final String _alias;
  $MediasMetaDataTable(this._db, [this._alias]);
  final VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  GeneratedTextColumn _roomId;
  @override
  GeneratedTextColumn get roomId => _roomId ??= _constructRoomId();
  GeneratedTextColumn _constructRoomId() {
    return GeneratedTextColumn(
      'room_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _imagesCountMeta =
      const VerificationMeta('imagesCount');
  GeneratedIntColumn _imagesCount;
  @override
  GeneratedIntColumn get imagesCount =>
      _imagesCount ??= _constructImagesCount();
  GeneratedIntColumn _constructImagesCount() {
    return GeneratedIntColumn(
      'images_count',
      $tableName,
      false,
    );
  }

  final VerificationMeta _videosCountMeta =
      const VerificationMeta('videosCount');
  GeneratedIntColumn _videosCount;
  @override
  GeneratedIntColumn get videosCount =>
      _videosCount ??= _constructVideosCount();
  GeneratedIntColumn _constructVideosCount() {
    return GeneratedIntColumn(
      'videos_count',
      $tableName,
      false,
    );
  }

  final VerificationMeta _filesCountMeta = const VerificationMeta('filesCount');
  GeneratedIntColumn _filesCount;
  @override
  GeneratedIntColumn get filesCount => _filesCount ??= _constructFilesCount();
  GeneratedIntColumn _constructFilesCount() {
    return GeneratedIntColumn(
      'files_count',
      $tableName,
      false,
    );
  }

  final VerificationMeta _documentsCountMeta =
      const VerificationMeta('documentsCount');
  GeneratedIntColumn _documentsCount;
  @override
  GeneratedIntColumn get documentsCount =>
      _documentsCount ??= _constructDocumentsCount();
  GeneratedIntColumn _constructDocumentsCount() {
    return GeneratedIntColumn(
      'documents_count',
      $tableName,
      false,
    );
  }

  final VerificationMeta _audiosCountMeta =
      const VerificationMeta('audiosCount');
  GeneratedIntColumn _audiosCount;
  @override
  GeneratedIntColumn get audiosCount =>
      _audiosCount ??= _constructAudiosCount();
  GeneratedIntColumn _constructAudiosCount() {
    return GeneratedIntColumn(
      'audios_count',
      $tableName,
      false,
    );
  }

  final VerificationMeta _musicsCountMeta =
      const VerificationMeta('musicsCount');
  GeneratedIntColumn _musicsCount;
  @override
  GeneratedIntColumn get musicsCount =>
      _musicsCount ??= _constructMusicsCount();
  GeneratedIntColumn _constructMusicsCount() {
    return GeneratedIntColumn(
      'musics_count',
      $tableName,
      false,
    );
  }

  final VerificationMeta _linkCountMeta = const VerificationMeta('linkCount');
  GeneratedIntColumn _linkCount;
  @override
  GeneratedIntColumn get linkCount => _linkCount ??= _constructLinkCount();
  GeneratedIntColumn _constructLinkCount() {
    return GeneratedIntColumn(
      'link_count',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        roomId,
        imagesCount,
        videosCount,
        filesCount,
        documentsCount,
        audiosCount,
        musicsCount,
        linkCount
      ];
  @override
  $MediasMetaDataTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'medias_meta_data';
  @override
  final String actualTableName = 'medias_meta_data';
  @override
  VerificationContext validateIntegrity(Insertable<MediasMetaDataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id'], _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('images_count')) {
      context.handle(
          _imagesCountMeta,
          imagesCount.isAcceptableOrUnknown(
              data['images_count'], _imagesCountMeta));
    } else if (isInserting) {
      context.missing(_imagesCountMeta);
    }
    if (data.containsKey('videos_count')) {
      context.handle(
          _videosCountMeta,
          videosCount.isAcceptableOrUnknown(
              data['videos_count'], _videosCountMeta));
    } else if (isInserting) {
      context.missing(_videosCountMeta);
    }
    if (data.containsKey('files_count')) {
      context.handle(
          _filesCountMeta,
          filesCount.isAcceptableOrUnknown(
              data['files_count'], _filesCountMeta));
    } else if (isInserting) {
      context.missing(_filesCountMeta);
    }
    if (data.containsKey('documents_count')) {
      context.handle(
          _documentsCountMeta,
          documentsCount.isAcceptableOrUnknown(
              data['documents_count'], _documentsCountMeta));
    } else if (isInserting) {
      context.missing(_documentsCountMeta);
    }
    if (data.containsKey('audios_count')) {
      context.handle(
          _audiosCountMeta,
          audiosCount.isAcceptableOrUnknown(
              data['audios_count'], _audiosCountMeta));
    } else if (isInserting) {
      context.missing(_audiosCountMeta);
    }
    if (data.containsKey('musics_count')) {
      context.handle(
          _musicsCountMeta,
          musicsCount.isAcceptableOrUnknown(
              data['musics_count'], _musicsCountMeta));
    } else if (isInserting) {
      context.missing(_musicsCountMeta);
    }
    if (data.containsKey('link_count')) {
      context.handle(_linkCountMeta,
          linkCount.isAcceptableOrUnknown(data['link_count'], _linkCountMeta));
    } else if (isInserting) {
      context.missing(_linkCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roomId};
  @override
  MediasMetaDataData map(Map<String, dynamic> data, {String tablePrefix}) {
    return MediasMetaDataData.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $MediasMetaDataTable createAlias(String alias) {
    return $MediasMetaDataTable(_db, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $MediasTable _medias;
  $MediasTable get medias => _medias ??= $MediasTable(this);
  $MediasMetaDataTable _mediasMetaData;
  $MediasMetaDataTable get mediasMetaData =>
      _mediasMetaData ??= $MediasMetaDataTable(this);
  MediaDao _mediaDao;
  MediaDao get mediaDao => _mediaDao ??= MediaDao(this as Database);
  MediaMetaDataDao _mediaMetaDataDao;
  MediaMetaDataDao get mediaMetaDataDao =>
      _mediaMetaDataDao ??= MediaMetaDataDao(this as Database);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [medias, mediasMetaData];
}
