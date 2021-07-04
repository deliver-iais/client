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

class Sticker extends DataClass implements Insertable<Sticker> {
  final String uuid;
  final String packId;
  final String name;
  final String packName;
  Sticker(
      {@required this.uuid,
      @required this.packId,
      @required this.name,
      @required this.packName});
  factory Sticker.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    return Sticker(
      uuid: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}uuid']),
      packId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}pack_id']),
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name']),
      packName: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}pack_name']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || uuid != null) {
      map['uuid'] = Variable<String>(uuid);
    }
    if (!nullToAbsent || packId != null) {
      map['pack_id'] = Variable<String>(packId);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || packName != null) {
      map['pack_name'] = Variable<String>(packName);
    }
    return map;
  }

  StickersCompanion toCompanion(bool nullToAbsent) {
    return StickersCompanion(
      uuid: uuid == null && nullToAbsent ? const Value.absent() : Value(uuid),
      packId:
          packId == null && nullToAbsent ? const Value.absent() : Value(packId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      packName: packName == null && nullToAbsent
          ? const Value.absent()
          : Value(packName),
    );
  }

  factory Sticker.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Sticker(
      uuid: serializer.fromJson<String>(json['uuid']),
      packId: serializer.fromJson<String>(json['packId']),
      name: serializer.fromJson<String>(json['name']),
      packName: serializer.fromJson<String>(json['packName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'packId': serializer.toJson<String>(packId),
      'name': serializer.toJson<String>(name),
      'packName': serializer.toJson<String>(packName),
    };
  }

  Sticker copyWith(
          {String uuid, String packId, String name, String packName}) =>
      Sticker(
        uuid: uuid ?? this.uuid,
        packId: packId ?? this.packId,
        name: name ?? this.name,
        packName: packName ?? this.packName,
      );
  @override
  String toString() {
    return (StringBuffer('Sticker(')
          ..write('uuid: $uuid, ')
          ..write('packId: $packId, ')
          ..write('name: $name, ')
          ..write('packName: $packName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(uuid.hashCode,
      $mrjc(packId.hashCode, $mrjc(name.hashCode, packName.hashCode))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sticker &&
          other.uuid == this.uuid &&
          other.packId == this.packId &&
          other.name == this.name &&
          other.packName == this.packName);
}

class StickersCompanion extends UpdateCompanion<Sticker> {
  final Value<String> uuid;
  final Value<String> packId;
  final Value<String> name;
  final Value<String> packName;
  const StickersCompanion({
    this.uuid = const Value.absent(),
    this.packId = const Value.absent(),
    this.name = const Value.absent(),
    this.packName = const Value.absent(),
  });
  StickersCompanion.insert({
    @required String uuid,
    @required String packId,
    @required String name,
    @required String packName,
  })  : uuid = Value(uuid),
        packId = Value(packId),
        name = Value(name),
        packName = Value(packName);
  static Insertable<Sticker> custom({
    Expression<String> uuid,
    Expression<String> packId,
    Expression<String> name,
    Expression<String> packName,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (packId != null) 'pack_id': packId,
      if (name != null) 'name': name,
      if (packName != null) 'pack_name': packName,
    });
  }

  StickersCompanion copyWith(
      {Value<String> uuid,
      Value<String> packId,
      Value<String> name,
      Value<String> packName}) {
    return StickersCompanion(
      uuid: uuid ?? this.uuid,
      packId: packId ?? this.packId,
      name: name ?? this.name,
      packName: packName ?? this.packName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (packName.present) {
      map['pack_name'] = Variable<String>(packName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StickersCompanion(')
          ..write('uuid: $uuid, ')
          ..write('packId: $packId, ')
          ..write('name: $name, ')
          ..write('packName: $packName')
          ..write(')'))
        .toString();
  }
}

class $StickersTable extends Stickers with TableInfo<$StickersTable, Sticker> {
  final GeneratedDatabase _db;
  final String _alias;
  $StickersTable(this._db, [this._alias]);
  final VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  GeneratedTextColumn _uuid;
  @override
  GeneratedTextColumn get uuid => _uuid ??= _constructUuid();
  GeneratedTextColumn _constructUuid() {
    return GeneratedTextColumn(
      'uuid',
      $tableName,
      false,
    );
  }

  final VerificationMeta _packIdMeta = const VerificationMeta('packId');
  GeneratedTextColumn _packId;
  @override
  GeneratedTextColumn get packId => _packId ??= _constructPackId();
  GeneratedTextColumn _constructPackId() {
    return GeneratedTextColumn(
      'pack_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  GeneratedTextColumn _name;
  @override
  GeneratedTextColumn get name => _name ??= _constructName();
  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn(
      'name',
      $tableName,
      false,
    );
  }

  final VerificationMeta _packNameMeta = const VerificationMeta('packName');
  GeneratedTextColumn _packName;
  @override
  GeneratedTextColumn get packName => _packName ??= _constructPackName();
  GeneratedTextColumn _constructPackName() {
    return GeneratedTextColumn(
      'pack_name',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [uuid, packId, name, packName];
  @override
  $StickersTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'stickers';
  @override
  final String actualTableName = 'stickers';
  @override
  VerificationContext validateIntegrity(Insertable<Sticker> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid'], _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(_packIdMeta,
          packId.isAcceptableOrUnknown(data['pack_id'], _packIdMeta));
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name'], _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('pack_name')) {
      context.handle(_packNameMeta,
          packName.isAcceptableOrUnknown(data['pack_name'], _packNameMeta));
    } else if (isInserting) {
      context.missing(_packNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  Sticker map(Map<String, dynamic> data, {String tablePrefix}) {
    return Sticker.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $StickersTable createAlias(String alias) {
    return $StickersTable(_db, alias);
  }
}

class StickerId extends DataClass implements Insertable<StickerId> {
  final DateTime getPackTime;
  final String packId;
  final bool packISDownloaded;
  StickerId(
      {@required this.getPackTime,
      @required this.packId,
      @required this.packISDownloaded});
  factory StickerId.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    return StickerId(
      getPackTime: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}get_pack_time']),
      packId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}pack_id']),
      packISDownloaded: const BoolType().mapFromDatabaseResponse(
          data['${effectivePrefix}pack_i_s_downloaded']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || getPackTime != null) {
      map['get_pack_time'] = Variable<DateTime>(getPackTime);
    }
    if (!nullToAbsent || packId != null) {
      map['pack_id'] = Variable<String>(packId);
    }
    if (!nullToAbsent || packISDownloaded != null) {
      map['pack_i_s_downloaded'] = Variable<bool>(packISDownloaded);
    }
    return map;
  }

  StickerIdsCompanion toCompanion(bool nullToAbsent) {
    return StickerIdsCompanion(
      getPackTime: getPackTime == null && nullToAbsent
          ? const Value.absent()
          : Value(getPackTime),
      packId:
          packId == null && nullToAbsent ? const Value.absent() : Value(packId),
      packISDownloaded: packISDownloaded == null && nullToAbsent
          ? const Value.absent()
          : Value(packISDownloaded),
    );
  }

  factory StickerId.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return StickerId(
      getPackTime: serializer.fromJson<DateTime>(json['getPackTime']),
      packId: serializer.fromJson<String>(json['packId']),
      packISDownloaded: serializer.fromJson<bool>(json['packISDownloaded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'getPackTime': serializer.toJson<DateTime>(getPackTime),
      'packId': serializer.toJson<String>(packId),
      'packISDownloaded': serializer.toJson<bool>(packISDownloaded),
    };
  }

  StickerId copyWith(
          {DateTime getPackTime, String packId, bool packISDownloaded}) =>
      StickerId(
        getPackTime: getPackTime ?? this.getPackTime,
        packId: packId ?? this.packId,
        packISDownloaded: packISDownloaded ?? this.packISDownloaded,
      );
  @override
  String toString() {
    return (StringBuffer('StickerId(')
          ..write('getPackTime: $getPackTime, ')
          ..write('packId: $packId, ')
          ..write('packISDownloaded: $packISDownloaded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      getPackTime.hashCode, $mrjc(packId.hashCode, packISDownloaded.hashCode)));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StickerId &&
          other.getPackTime == this.getPackTime &&
          other.packId == this.packId &&
          other.packISDownloaded == this.packISDownloaded);
}

class StickerIdsCompanion extends UpdateCompanion<StickerId> {
  final Value<DateTime> getPackTime;
  final Value<String> packId;
  final Value<bool> packISDownloaded;
  const StickerIdsCompanion({
    this.getPackTime = const Value.absent(),
    this.packId = const Value.absent(),
    this.packISDownloaded = const Value.absent(),
  });
  StickerIdsCompanion.insert({
    @required DateTime getPackTime,
    @required String packId,
    this.packISDownloaded = const Value.absent(),
  })  : getPackTime = Value(getPackTime),
        packId = Value(packId);
  static Insertable<StickerId> custom({
    Expression<DateTime> getPackTime,
    Expression<String> packId,
    Expression<bool> packISDownloaded,
  }) {
    return RawValuesInsertable({
      if (getPackTime != null) 'get_pack_time': getPackTime,
      if (packId != null) 'pack_id': packId,
      if (packISDownloaded != null) 'pack_i_s_downloaded': packISDownloaded,
    });
  }

  StickerIdsCompanion copyWith(
      {Value<DateTime> getPackTime,
      Value<String> packId,
      Value<bool> packISDownloaded}) {
    return StickerIdsCompanion(
      getPackTime: getPackTime ?? this.getPackTime,
      packId: packId ?? this.packId,
      packISDownloaded: packISDownloaded ?? this.packISDownloaded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (getPackTime.present) {
      map['get_pack_time'] = Variable<DateTime>(getPackTime.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (packISDownloaded.present) {
      map['pack_i_s_downloaded'] = Variable<bool>(packISDownloaded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StickerIdsCompanion(')
          ..write('getPackTime: $getPackTime, ')
          ..write('packId: $packId, ')
          ..write('packISDownloaded: $packISDownloaded')
          ..write(')'))
        .toString();
  }
}

class $StickerIdsTable extends StickerIds
    with TableInfo<$StickerIdsTable, StickerId> {
  final GeneratedDatabase _db;
  final String _alias;
  $StickerIdsTable(this._db, [this._alias]);
  final VerificationMeta _getPackTimeMeta =
      const VerificationMeta('getPackTime');
  GeneratedDateTimeColumn _getPackTime;
  @override
  GeneratedDateTimeColumn get getPackTime =>
      _getPackTime ??= _constructGetPackTime();
  GeneratedDateTimeColumn _constructGetPackTime() {
    return GeneratedDateTimeColumn(
      'get_pack_time',
      $tableName,
      false,
    );
  }

  final VerificationMeta _packIdMeta = const VerificationMeta('packId');
  GeneratedTextColumn _packId;
  @override
  GeneratedTextColumn get packId => _packId ??= _constructPackId();
  GeneratedTextColumn _constructPackId() {
    return GeneratedTextColumn(
      'pack_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _packISDownloadedMeta =
      const VerificationMeta('packISDownloaded');
  GeneratedBoolColumn _packISDownloaded;
  @override
  GeneratedBoolColumn get packISDownloaded =>
      _packISDownloaded ??= _constructPackISDownloaded();
  GeneratedBoolColumn _constructPackISDownloaded() {
    return GeneratedBoolColumn('pack_i_s_downloaded', $tableName, false,
        defaultValue: Constant(false));
  }

  @override
  List<GeneratedColumn> get $columns => [getPackTime, packId, packISDownloaded];
  @override
  $StickerIdsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'sticker_ids';
  @override
  final String actualTableName = 'sticker_ids';
  @override
  VerificationContext validateIntegrity(Insertable<StickerId> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('get_pack_time')) {
      context.handle(
          _getPackTimeMeta,
          getPackTime.isAcceptableOrUnknown(
              data['get_pack_time'], _getPackTimeMeta));
    } else if (isInserting) {
      context.missing(_getPackTimeMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(_packIdMeta,
          packId.isAcceptableOrUnknown(data['pack_id'], _packIdMeta));
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('pack_i_s_downloaded')) {
      context.handle(
          _packISDownloadedMeta,
          packISDownloaded.isAcceptableOrUnknown(
              data['pack_i_s_downloaded'], _packISDownloadedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packId};
  @override
  StickerId map(Map<String, dynamic> data, {String tablePrefix}) {
    return StickerId.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $StickerIdsTable createAlias(String alias) {
    return $StickerIdsTable(_db, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $MediasTable _medias;
  $MediasTable get medias => _medias ??= $MediasTable(this);
  $MediasMetaDataTable _mediasMetaData;
  $MediasMetaDataTable get mediasMetaData =>
      _mediasMetaData ??= $MediasMetaDataTable(this);
  $StickersTable _stickers;
  $StickersTable get stickers => _stickers ??= $StickersTable(this);
  $StickerIdsTable _stickerIds;
  $StickerIdsTable get stickerIds => _stickerIds ??= $StickerIdsTable(this);
  MediaDao _mediaDao;
  MediaDao get mediaDao => _mediaDao ??= MediaDao(this as Database);
  MediaMetaDataDao _mediaMetaDataDao;
  MediaMetaDataDao get mediaMetaDataDao =>
      _mediaMetaDataDao ??= MediaMetaDataDao(this as Database);
  StickerDao _stickerDao;
  StickerDao get stickerDao => _stickerDao ??= StickerDao(this as Database);
  StickerIdDao _stickerIdDao;
  StickerIdDao get stickerIdDao =>
      _stickerIdDao ??= StickerIdDao(this as Database);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [medias, mediasMetaData, stickers, stickerIds];
}
