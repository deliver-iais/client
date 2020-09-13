// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Message extends DataClass implements Insertable<Message> {
  final int dbId;
  final String roomId;
  final int packetId;
  final int id;
  final DateTime time;
  final String from;
  final String to;
  final int replyToId;
  final String forwardedFrom;
  final bool edited;
  final bool encrypted;
  final MessageType type;
  final String json;
  Message(
      {@required this.dbId,
      @required this.roomId,
      @required this.packetId,
      this.id,
      @required this.time,
      @required this.from,
      @required this.to,
      this.replyToId,
      this.forwardedFrom,
      @required this.edited,
      @required this.encrypted,
      @required this.type,
      @required this.json});
  factory Message.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final boolType = db.typeSystem.forDartType<bool>();
    return Message(
      dbId: intType.mapFromDatabaseResponse(data['${effectivePrefix}db_id']),
      roomId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      packetId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}packet_id']),
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      time:
          dateTimeType.mapFromDatabaseResponse(data['${effectivePrefix}time']),
      from: stringType.mapFromDatabaseResponse(data['${effectivePrefix}from']),
      to: stringType.mapFromDatabaseResponse(data['${effectivePrefix}to']),
      replyToId: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}reply_to_id']),
      forwardedFrom: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}forwarded_from']),
      edited:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}edited']),
      encrypted:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}encrypted']),
      type: $MessagesTable.$converter0.mapToDart(
          intType.mapFromDatabaseResponse(data['${effectivePrefix}type'])),
      json: stringType.mapFromDatabaseResponse(data['${effectivePrefix}json']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || dbId != null) {
      map['db_id'] = Variable<int>(dbId);
    }
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    if (!nullToAbsent || packetId != null) {
      map['packet_id'] = Variable<int>(packetId);
    }
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || time != null) {
      map['time'] = Variable<DateTime>(time);
    }
    if (!nullToAbsent || from != null) {
      map['from'] = Variable<String>(from);
    }
    if (!nullToAbsent || to != null) {
      map['to'] = Variable<String>(to);
    }
    if (!nullToAbsent || replyToId != null) {
      map['reply_to_id'] = Variable<int>(replyToId);
    }
    if (!nullToAbsent || forwardedFrom != null) {
      map['forwarded_from'] = Variable<String>(forwardedFrom);
    }
    if (!nullToAbsent || edited != null) {
      map['edited'] = Variable<bool>(edited);
    }
    if (!nullToAbsent || encrypted != null) {
      map['encrypted'] = Variable<bool>(encrypted);
    }
    if (!nullToAbsent || type != null) {
      final converter = $MessagesTable.$converter0;
      map['type'] = Variable<int>(converter.mapToSql(type));
    }
    if (!nullToAbsent || json != null) {
      map['json'] = Variable<String>(json);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      dbId: dbId == null && nullToAbsent ? const Value.absent() : Value(dbId),
      roomId:
          roomId == null && nullToAbsent ? const Value.absent() : Value(roomId),
      packetId: packetId == null && nullToAbsent
          ? const Value.absent()
          : Value(packetId),
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      time: time == null && nullToAbsent ? const Value.absent() : Value(time),
      from: from == null && nullToAbsent ? const Value.absent() : Value(from),
      to: to == null && nullToAbsent ? const Value.absent() : Value(to),
      replyToId: replyToId == null && nullToAbsent
          ? const Value.absent()
          : Value(replyToId),
      forwardedFrom: forwardedFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(forwardedFrom),
      edited:
          edited == null && nullToAbsent ? const Value.absent() : Value(edited),
      encrypted: encrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(encrypted),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      json: json == null && nullToAbsent ? const Value.absent() : Value(json),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Message(
      dbId: serializer.fromJson<int>(json['dbId']),
      roomId: serializer.fromJson<String>(json['roomId']),
      packetId: serializer.fromJson<int>(json['packetId']),
      id: serializer.fromJson<int>(json['id']),
      time: serializer.fromJson<DateTime>(json['time']),
      from: serializer.fromJson<String>(json['from']),
      to: serializer.fromJson<String>(json['to']),
      replyToId: serializer.fromJson<int>(json['replyToId']),
      forwardedFrom: serializer.fromJson<String>(json['forwardedFrom']),
      edited: serializer.fromJson<bool>(json['edited']),
      encrypted: serializer.fromJson<bool>(json['encrypted']),
      type: serializer.fromJson<MessageType>(json['type']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dbId': serializer.toJson<int>(dbId),
      'roomId': serializer.toJson<String>(roomId),
      'packetId': serializer.toJson<int>(packetId),
      'id': serializer.toJson<int>(id),
      'time': serializer.toJson<DateTime>(time),
      'from': serializer.toJson<String>(from),
      'to': serializer.toJson<String>(to),
      'replyToId': serializer.toJson<int>(replyToId),
      'forwardedFrom': serializer.toJson<String>(forwardedFrom),
      'edited': serializer.toJson<bool>(edited),
      'encrypted': serializer.toJson<bool>(encrypted),
      'type': serializer.toJson<MessageType>(type),
      'json': serializer.toJson<String>(json),
    };
  }

  Message copyWith(
          {int dbId,
          String roomId,
          int packetId,
          int id,
          DateTime time,
          String from,
          String to,
          int replyToId,
          String forwardedFrom,
          bool edited,
          bool encrypted,
          MessageType type,
          String json}) =>
      Message(
        dbId: dbId ?? this.dbId,
        roomId: roomId ?? this.roomId,
        packetId: packetId ?? this.packetId,
        id: id ?? this.id,
        time: time ?? this.time,
        from: from ?? this.from,
        to: to ?? this.to,
        replyToId: replyToId ?? this.replyToId,
        forwardedFrom: forwardedFrom ?? this.forwardedFrom,
        edited: edited ?? this.edited,
        encrypted: encrypted ?? this.encrypted,
        type: type ?? this.type,
        json: json ?? this.json,
      );
  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('dbId: $dbId, ')
          ..write('roomId: $roomId, ')
          ..write('packetId: $packetId, ')
          ..write('id: $id, ')
          ..write('time: $time, ')
          ..write('from: $from, ')
          ..write('to: $to, ')
          ..write('replyToId: $replyToId, ')
          ..write('forwardedFrom: $forwardedFrom, ')
          ..write('edited: $edited, ')
          ..write('encrypted: $encrypted, ')
          ..write('type: $type, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      dbId.hashCode,
      $mrjc(
          roomId.hashCode,
          $mrjc(
              packetId.hashCode,
              $mrjc(
                  id.hashCode,
                  $mrjc(
                      time.hashCode,
                      $mrjc(
                          from.hashCode,
                          $mrjc(
                              to.hashCode,
                              $mrjc(
                                  replyToId.hashCode,
                                  $mrjc(
                                      forwardedFrom.hashCode,
                                      $mrjc(
                                          edited.hashCode,
                                          $mrjc(
                                              encrypted.hashCode,
                                              $mrjc(type.hashCode,
                                                  json.hashCode)))))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Message &&
          other.dbId == this.dbId &&
          other.roomId == this.roomId &&
          other.packetId == this.packetId &&
          other.id == this.id &&
          other.time == this.time &&
          other.from == this.from &&
          other.to == this.to &&
          other.replyToId == this.replyToId &&
          other.forwardedFrom == this.forwardedFrom &&
          other.edited == this.edited &&
          other.encrypted == this.encrypted &&
          other.type == this.type &&
          other.json == this.json);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> dbId;
  final Value<String> roomId;
  final Value<int> packetId;
  final Value<int> id;
  final Value<DateTime> time;
  final Value<String> from;
  final Value<String> to;
  final Value<int> replyToId;
  final Value<String> forwardedFrom;
  final Value<bool> edited;
  final Value<bool> encrypted;
  final Value<MessageType> type;
  final Value<String> json;
  const MessagesCompanion({
    this.dbId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.packetId = const Value.absent(),
    this.id = const Value.absent(),
    this.time = const Value.absent(),
    this.from = const Value.absent(),
    this.to = const Value.absent(),
    this.replyToId = const Value.absent(),
    this.forwardedFrom = const Value.absent(),
    this.edited = const Value.absent(),
    this.encrypted = const Value.absent(),
    this.type = const Value.absent(),
    this.json = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.dbId = const Value.absent(),
    @required String roomId,
    @required int packetId,
    this.id = const Value.absent(),
    @required DateTime time,
    @required String from,
    @required String to,
    this.replyToId = const Value.absent(),
    this.forwardedFrom = const Value.absent(),
    this.edited = const Value.absent(),
    this.encrypted = const Value.absent(),
    @required MessageType type,
    @required String json,
  })  : roomId = Value(roomId),
        packetId = Value(packetId),
        time = Value(time),
        from = Value(from),
        to = Value(to),
        type = Value(type),
        json = Value(json);
  static Insertable<Message> custom({
    Expression<int> dbId,
    Expression<String> roomId,
    Expression<int> packetId,
    Expression<int> id,
    Expression<DateTime> time,
    Expression<String> from,
    Expression<String> to,
    Expression<int> replyToId,
    Expression<String> forwardedFrom,
    Expression<bool> edited,
    Expression<bool> encrypted,
    Expression<int> type,
    Expression<String> json,
  }) {
    return RawValuesInsertable({
      if (dbId != null) 'db_id': dbId,
      if (roomId != null) 'room_id': roomId,
      if (packetId != null) 'packet_id': packetId,
      if (id != null) 'id': id,
      if (time != null) 'time': time,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (replyToId != null) 'reply_to_id': replyToId,
      if (forwardedFrom != null) 'forwarded_from': forwardedFrom,
      if (edited != null) 'edited': edited,
      if (encrypted != null) 'encrypted': encrypted,
      if (type != null) 'type': type,
      if (json != null) 'json': json,
    });
  }

  MessagesCompanion copyWith(
      {Value<int> dbId,
      Value<String> roomId,
      Value<int> packetId,
      Value<int> id,
      Value<DateTime> time,
      Value<String> from,
      Value<String> to,
      Value<int> replyToId,
      Value<String> forwardedFrom,
      Value<bool> edited,
      Value<bool> encrypted,
      Value<MessageType> type,
      Value<String> json}) {
    return MessagesCompanion(
      dbId: dbId ?? this.dbId,
      roomId: roomId ?? this.roomId,
      packetId: packetId ?? this.packetId,
      id: id ?? this.id,
      time: time ?? this.time,
      from: from ?? this.from,
      to: to ?? this.to,
      replyToId: replyToId ?? this.replyToId,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      edited: edited ?? this.edited,
      encrypted: encrypted ?? this.encrypted,
      type: type ?? this.type,
      json: json ?? this.json,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dbId.present) {
      map['db_id'] = Variable<int>(dbId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (packetId.present) {
      map['packet_id'] = Variable<int>(packetId.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (from.present) {
      map['from'] = Variable<String>(from.value);
    }
    if (to.present) {
      map['to'] = Variable<String>(to.value);
    }
    if (replyToId.present) {
      map['reply_to_id'] = Variable<int>(replyToId.value);
    }
    if (forwardedFrom.present) {
      map['forwarded_from'] = Variable<String>(forwardedFrom.value);
    }
    if (edited.present) {
      map['edited'] = Variable<bool>(edited.value);
    }
    if (encrypted.present) {
      map['encrypted'] = Variable<bool>(encrypted.value);
    }
    if (type.present) {
      final converter = $MessagesTable.$converter0;
      map['type'] = Variable<int>(converter.mapToSql(type.value));
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('dbId: $dbId, ')
          ..write('roomId: $roomId, ')
          ..write('packetId: $packetId, ')
          ..write('id: $id, ')
          ..write('time: $time, ')
          ..write('from: $from, ')
          ..write('to: $to, ')
          ..write('replyToId: $replyToId, ')
          ..write('forwardedFrom: $forwardedFrom, ')
          ..write('edited: $edited, ')
          ..write('encrypted: $encrypted, ')
          ..write('type: $type, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  final GeneratedDatabase _db;
  final String _alias;
  $MessagesTable(this._db, [this._alias]);
  final VerificationMeta _dbIdMeta = const VerificationMeta('dbId');
  GeneratedIntColumn _dbId;
  @override
  GeneratedIntColumn get dbId => _dbId ??= _constructDbId();
  GeneratedIntColumn _constructDbId() {
    return GeneratedIntColumn('db_id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
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

  final VerificationMeta _packetIdMeta = const VerificationMeta('packetId');
  GeneratedIntColumn _packetId;
  @override
  GeneratedIntColumn get packetId => _packetId ??= _constructPacketId();
  GeneratedIntColumn _constructPacketId() {
    return GeneratedIntColumn(
      'packet_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn(
      'id',
      $tableName,
      true,
    );
  }

  final VerificationMeta _timeMeta = const VerificationMeta('time');
  GeneratedDateTimeColumn _time;
  @override
  GeneratedDateTimeColumn get time => _time ??= _constructTime();
  GeneratedDateTimeColumn _constructTime() {
    return GeneratedDateTimeColumn(
      'time',
      $tableName,
      false,
    );
  }

  final VerificationMeta _fromMeta = const VerificationMeta('from');
  GeneratedTextColumn _from;
  @override
  GeneratedTextColumn get from => _from ??= _constructFrom();
  GeneratedTextColumn _constructFrom() {
    return GeneratedTextColumn(
      'from',
      $tableName,
      false,
    );
  }

  final VerificationMeta _toMeta = const VerificationMeta('to');
  GeneratedTextColumn _to;
  @override
  GeneratedTextColumn get to => _to ??= _constructTo();
  GeneratedTextColumn _constructTo() {
    return GeneratedTextColumn(
      'to',
      $tableName,
      false,
    );
  }

  final VerificationMeta _replyToIdMeta = const VerificationMeta('replyToId');
  GeneratedIntColumn _replyToId;
  @override
  GeneratedIntColumn get replyToId => _replyToId ??= _constructReplyToId();
  GeneratedIntColumn _constructReplyToId() {
    return GeneratedIntColumn(
      'reply_to_id',
      $tableName,
      true,
    );
  }

  final VerificationMeta _forwardedFromMeta =
      const VerificationMeta('forwardedFrom');
  GeneratedTextColumn _forwardedFrom;
  @override
  GeneratedTextColumn get forwardedFrom =>
      _forwardedFrom ??= _constructForwardedFrom();
  GeneratedTextColumn _constructForwardedFrom() {
    return GeneratedTextColumn(
      'forwarded_from',
      $tableName,
      true,
    );
  }

  final VerificationMeta _editedMeta = const VerificationMeta('edited');
  GeneratedBoolColumn _edited;
  @override
  GeneratedBoolColumn get edited => _edited ??= _constructEdited();
  GeneratedBoolColumn _constructEdited() {
    return GeneratedBoolColumn('edited', $tableName, false,
        defaultValue: Constant(false));
  }

  final VerificationMeta _encryptedMeta = const VerificationMeta('encrypted');
  GeneratedBoolColumn _encrypted;
  @override
  GeneratedBoolColumn get encrypted => _encrypted ??= _constructEncrypted();
  GeneratedBoolColumn _constructEncrypted() {
    return GeneratedBoolColumn('encrypted', $tableName, false,
        defaultValue: Constant(false));
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
  List<GeneratedColumn> get $columns => [
        dbId,
        roomId,
        packetId,
        id,
        time,
        from,
        to,
        replyToId,
        forwardedFrom,
        edited,
        encrypted,
        type,
        json
      ];
  @override
  $MessagesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'messages';
  @override
  final String actualTableName = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('db_id')) {
      context.handle(
          _dbIdMeta, dbId.isAcceptableOrUnknown(data['db_id'], _dbIdMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id'], _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('packet_id')) {
      context.handle(_packetIdMeta,
          packetId.isAcceptableOrUnknown(data['packet_id'], _packetIdMeta));
    } else if (isInserting) {
      context.missing(_packetIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time'], _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('from')) {
      context.handle(
          _fromMeta, from.isAcceptableOrUnknown(data['from'], _fromMeta));
    } else if (isInserting) {
      context.missing(_fromMeta);
    }
    if (data.containsKey('to')) {
      context.handle(_toMeta, to.isAcceptableOrUnknown(data['to'], _toMeta));
    } else if (isInserting) {
      context.missing(_toMeta);
    }
    if (data.containsKey('reply_to_id')) {
      context.handle(_replyToIdMeta,
          replyToId.isAcceptableOrUnknown(data['reply_to_id'], _replyToIdMeta));
    }
    if (data.containsKey('forwarded_from')) {
      context.handle(
          _forwardedFromMeta,
          forwardedFrom.isAcceptableOrUnknown(
              data['forwarded_from'], _forwardedFromMeta));
    }
    if (data.containsKey('edited')) {
      context.handle(_editedMeta,
          edited.isAcceptableOrUnknown(data['edited'], _editedMeta));
    }
    if (data.containsKey('encrypted')) {
      context.handle(_encryptedMeta,
          encrypted.isAcceptableOrUnknown(data['encrypted'], _encryptedMeta));
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('json')) {
      context.handle(
          _jsonMeta, json.isAcceptableOrUnknown(data['json'], _jsonMeta));
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dbId};
  @override
  Message map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Message.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(_db, alias);
  }

  static TypeConverter<MessageType, int> $converter0 =
      const EnumIndexConverter<MessageType>(MessageType.values);
}

class Room extends DataClass implements Insertable<Room> {
  final String roomId;
  final bool mentioned;
  final int lastMessage;
  Room({@required this.roomId, this.mentioned, @required this.lastMessage});
  factory Room.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    final intType = db.typeSystem.forDartType<int>();
    return Room(
      roomId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      mentioned:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}mentioned']),
      lastMessage: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}last_message']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    if (!nullToAbsent || mentioned != null) {
      map['mentioned'] = Variable<bool>(mentioned);
    }
    if (!nullToAbsent || lastMessage != null) {
      map['last_message'] = Variable<int>(lastMessage);
    }
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      roomId:
          roomId == null && nullToAbsent ? const Value.absent() : Value(roomId),
      mentioned: mentioned == null && nullToAbsent
          ? const Value.absent()
          : Value(mentioned),
      lastMessage: lastMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessage),
    );
  }

  factory Room.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Room(
      roomId: serializer.fromJson<String>(json['roomId']),
      mentioned: serializer.fromJson<bool>(json['mentioned']),
      lastMessage: serializer.fromJson<int>(json['lastMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roomId': serializer.toJson<String>(roomId),
      'mentioned': serializer.toJson<bool>(mentioned),
      'lastMessage': serializer.toJson<int>(lastMessage),
    };
  }

  Room copyWith({String roomId, bool mentioned, int lastMessage}) => Room(
        roomId: roomId ?? this.roomId,
        mentioned: mentioned ?? this.mentioned,
        lastMessage: lastMessage ?? this.lastMessage,
      );
  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('roomId: $roomId, ')
          ..write('mentioned: $mentioned, ')
          ..write('lastMessage: $lastMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf(
      $mrjc(roomId.hashCode, $mrjc(mentioned.hashCode, lastMessage.hashCode)));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Room &&
          other.roomId == this.roomId &&
          other.mentioned == this.mentioned &&
          other.lastMessage == this.lastMessage);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<String> roomId;
  final Value<bool> mentioned;
  final Value<int> lastMessage;
  const RoomsCompanion({
    this.roomId = const Value.absent(),
    this.mentioned = const Value.absent(),
    this.lastMessage = const Value.absent(),
  });
  RoomsCompanion.insert({
    @required String roomId,
    this.mentioned = const Value.absent(),
    @required int lastMessage,
  })  : roomId = Value(roomId),
        lastMessage = Value(lastMessage);
  static Insertable<Room> custom({
    Expression<String> roomId,
    Expression<bool> mentioned,
    Expression<int> lastMessage,
  }) {
    return RawValuesInsertable({
      if (roomId != null) 'room_id': roomId,
      if (mentioned != null) 'mentioned': mentioned,
      if (lastMessage != null) 'last_message': lastMessage,
    });
  }

  RoomsCompanion copyWith(
      {Value<String> roomId, Value<bool> mentioned, Value<int> lastMessage}) {
    return RoomsCompanion(
      roomId: roomId ?? this.roomId,
      mentioned: mentioned ?? this.mentioned,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (mentioned.present) {
      map['mentioned'] = Variable<bool>(mentioned.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<int>(lastMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('roomId: $roomId, ')
          ..write('mentioned: $mentioned, ')
          ..write('lastMessage: $lastMessage')
          ..write(')'))
        .toString();
  }
}

class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  final GeneratedDatabase _db;
  final String _alias;
  $RoomsTable(this._db, [this._alias]);
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

  final VerificationMeta _mentionedMeta = const VerificationMeta('mentioned');
  GeneratedBoolColumn _mentioned;
  @override
  GeneratedBoolColumn get mentioned => _mentioned ??= _constructMentioned();
  GeneratedBoolColumn _constructMentioned() {
    return GeneratedBoolColumn('mentioned', $tableName, true,
        defaultValue: Constant(false));
  }

  final VerificationMeta _lastMessageMeta =
      const VerificationMeta('lastMessage');
  GeneratedIntColumn _lastMessage;
  @override
  GeneratedIntColumn get lastMessage =>
      _lastMessage ??= _constructLastMessage();
  GeneratedIntColumn _constructLastMessage() {
    return GeneratedIntColumn('last_message', $tableName, false,
        $customConstraints: 'REFERENCES messages(db_id)');
  }

  @override
  List<GeneratedColumn> get $columns => [roomId, mentioned, lastMessage];
  @override
  $RoomsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'rooms';
  @override
  final String actualTableName = 'rooms';
  @override
  VerificationContext validateIntegrity(Insertable<Room> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id'], _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('mentioned')) {
      context.handle(_mentionedMeta,
          mentioned.isAcceptableOrUnknown(data['mentioned'], _mentionedMeta));
    }
    if (data.containsKey('last_message')) {
      context.handle(
          _lastMessageMeta,
          lastMessage.isAcceptableOrUnknown(
              data['last_message'], _lastMessageMeta));
    } else if (isInserting) {
      context.missing(_lastMessageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roomId};
  @override
  Room map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Room.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(_db, alias);
  }
}

class Avatar extends DataClass implements Insertable<Avatar> {
  final String uid;
  final String fileId;
  final int date;
  final String fileName;
  Avatar(
      {@required this.uid,
      @required this.fileId,
      @required this.date,
      @required this.fileName});
  factory Avatar.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    return Avatar(
      uid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uid']),
      fileId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}file_id']),
      date: intType.mapFromDatabaseResponse(data['${effectivePrefix}date']),
      fileName: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}file_name']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || uid != null) {
      map['uid'] = Variable<String>(uid);
    }
    if (!nullToAbsent || fileId != null) {
      map['file_id'] = Variable<String>(fileId);
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<int>(date);
    }
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    return map;
  }

  AvatarsCompanion toCompanion(bool nullToAbsent) {
    return AvatarsCompanion(
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
      fileId:
          fileId == null && nullToAbsent ? const Value.absent() : Value(fileId),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      fileName: fileName == null && nullToAbsent
          ? const Value.absent()
          : Value(fileName),
    );
  }

  factory Avatar.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Avatar(
      uid: serializer.fromJson<String>(json['uid']),
      fileId: serializer.fromJson<String>(json['fileId']),
      date: serializer.fromJson<int>(json['date']),
      fileName: serializer.fromJson<String>(json['fileName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'fileId': serializer.toJson<String>(fileId),
      'date': serializer.toJson<int>(date),
      'fileName': serializer.toJson<String>(fileName),
    };
  }

  Avatar copyWith({String uid, String fileId, int date, String fileName}) =>
      Avatar(
        uid: uid ?? this.uid,
        fileId: fileId ?? this.fileId,
        date: date ?? this.date,
        fileName: fileName ?? this.fileName,
      );
  @override
  String toString() {
    return (StringBuffer('Avatar(')
          ..write('uid: $uid, ')
          ..write('fileId: $fileId, ')
          ..write('date: $date, ')
          ..write('fileName: $fileName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(uid.hashCode,
      $mrjc(fileId.hashCode, $mrjc(date.hashCode, fileName.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Avatar &&
          other.uid == this.uid &&
          other.fileId == this.fileId &&
          other.date == this.date &&
          other.fileName == this.fileName);
}

class AvatarsCompanion extends UpdateCompanion<Avatar> {
  final Value<String> uid;
  final Value<String> fileId;
  final Value<int> date;
  final Value<String> fileName;
  const AvatarsCompanion({
    this.uid = const Value.absent(),
    this.fileId = const Value.absent(),
    this.date = const Value.absent(),
    this.fileName = const Value.absent(),
  });
  AvatarsCompanion.insert({
    @required String uid,
    @required String fileId,
    @required int date,
    @required String fileName,
  })  : uid = Value(uid),
        fileId = Value(fileId),
        date = Value(date),
        fileName = Value(fileName);
  static Insertable<Avatar> custom({
    Expression<String> uid,
    Expression<String> fileId,
    Expression<int> date,
    Expression<String> fileName,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (fileId != null) 'file_id': fileId,
      if (date != null) 'date': date,
      if (fileName != null) 'file_name': fileName,
    });
  }

  AvatarsCompanion copyWith(
      {Value<String> uid,
      Value<String> fileId,
      Value<int> date,
      Value<String> fileName}) {
    return AvatarsCompanion(
      uid: uid ?? this.uid,
      fileId: fileId ?? this.fileId,
      date: date ?? this.date,
      fileName: fileName ?? this.fileName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (fileId.present) {
      map['file_id'] = Variable<String>(fileId.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AvatarsCompanion(')
          ..write('uid: $uid, ')
          ..write('fileId: $fileId, ')
          ..write('date: $date, ')
          ..write('fileName: $fileName')
          ..write(')'))
        .toString();
  }
}

class $AvatarsTable extends Avatars with TableInfo<$AvatarsTable, Avatar> {
  final GeneratedDatabase _db;
  final String _alias;
  $AvatarsTable(this._db, [this._alias]);
  final VerificationMeta _uidMeta = const VerificationMeta('uid');
  GeneratedTextColumn _uid;
  @override
  GeneratedTextColumn get uid => _uid ??= _constructUid();
  GeneratedTextColumn _constructUid() {
    return GeneratedTextColumn(
      'uid',
      $tableName,
      false,
    );
  }

  final VerificationMeta _fileIdMeta = const VerificationMeta('fileId');
  GeneratedTextColumn _fileId;
  @override
  GeneratedTextColumn get fileId => _fileId ??= _constructFileId();
  GeneratedTextColumn _constructFileId() {
    return GeneratedTextColumn(
      'file_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _dateMeta = const VerificationMeta('date');
  GeneratedIntColumn _date;
  @override
  GeneratedIntColumn get date => _date ??= _constructDate();
  GeneratedIntColumn _constructDate() {
    return GeneratedIntColumn(
      'date',
      $tableName,
      false,
    );
  }

  final VerificationMeta _fileNameMeta = const VerificationMeta('fileName');
  GeneratedTextColumn _fileName;
  @override
  GeneratedTextColumn get fileName => _fileName ??= _constructFileName();
  GeneratedTextColumn _constructFileName() {
    return GeneratedTextColumn(
      'file_name',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [uid, fileId, date, fileName];
  @override
  $AvatarsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'avatars';
  @override
  final String actualTableName = 'avatars';
  @override
  VerificationContext validateIntegrity(Insertable<Avatar> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid'], _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('file_id')) {
      context.handle(_fileIdMeta,
          fileId.isAcceptableOrUnknown(data['file_id'], _fileIdMeta));
    } else if (isInserting) {
      context.missing(_fileIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date'], _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name'], _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fileId};
  @override
  Avatar map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Avatar.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $AvatarsTable createAlias(String alias) {
    return $AvatarsTable(_db, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final String uid;
  final DateTime lastUpdateAvatarTime;
  final String lastAvatarFileId;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final DateTime lastSeen;
  final bool notification;
  final bool isBlock;
  final bool isOnline;
  Contact(
      {@required this.uid,
      @required this.lastUpdateAvatarTime,
      this.lastAvatarFileId,
      @required this.phoneNumber,
      @required this.firstName,
      @required this.lastName,
      @required this.lastSeen,
      @required this.notification,
      @required this.isBlock,
      @required this.isOnline});
  factory Contact.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final boolType = db.typeSystem.forDartType<bool>();
    return Contact(
      uid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uid']),
      lastUpdateAvatarTime: dateTimeType.mapFromDatabaseResponse(
          data['${effectivePrefix}last_update_avatar_time']),
      lastAvatarFileId: stringType.mapFromDatabaseResponse(
          data['${effectivePrefix}last_avatar_file_id']),
      phoneNumber: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}phone_number']),
      firstName: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}first_name']),
      lastName: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}last_name']),
      lastSeen: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}last_seen']),
      notification: boolType
          .mapFromDatabaseResponse(data['${effectivePrefix}notification']),
      isBlock:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}is_block']),
      isOnline:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}is_online']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || uid != null) {
      map['uid'] = Variable<String>(uid);
    }
    if (!nullToAbsent || lastUpdateAvatarTime != null) {
      map['last_update_avatar_time'] = Variable<DateTime>(lastUpdateAvatarTime);
    }
    if (!nullToAbsent || lastAvatarFileId != null) {
      map['last_avatar_file_id'] = Variable<String>(lastAvatarFileId);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || lastSeen != null) {
      map['last_seen'] = Variable<DateTime>(lastSeen);
    }
    if (!nullToAbsent || notification != null) {
      map['notification'] = Variable<bool>(notification);
    }
    if (!nullToAbsent || isBlock != null) {
      map['is_block'] = Variable<bool>(isBlock);
    }
    if (!nullToAbsent || isOnline != null) {
      map['is_online'] = Variable<bool>(isOnline);
    }
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
      lastUpdateAvatarTime: lastUpdateAvatarTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdateAvatarTime),
      lastAvatarFileId: lastAvatarFileId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAvatarFileId),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      lastSeen: lastSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeen),
      notification: notification == null && nullToAbsent
          ? const Value.absent()
          : Value(notification),
      isBlock: isBlock == null && nullToAbsent
          ? const Value.absent()
          : Value(isBlock),
      isOnline: isOnline == null && nullToAbsent
          ? const Value.absent()
          : Value(isOnline),
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Contact(
      uid: serializer.fromJson<String>(json['uid']),
      lastUpdateAvatarTime:
          serializer.fromJson<DateTime>(json['lastUpdateAvatarTime']),
      lastAvatarFileId: serializer.fromJson<String>(json['lastAvatarFileId']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      lastSeen: serializer.fromJson<DateTime>(json['lastSeen']),
      notification: serializer.fromJson<bool>(json['notification']),
      isBlock: serializer.fromJson<bool>(json['isBlock']),
      isOnline: serializer.fromJson<bool>(json['isOnline']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'lastUpdateAvatarTime': serializer.toJson<DateTime>(lastUpdateAvatarTime),
      'lastAvatarFileId': serializer.toJson<String>(lastAvatarFileId),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'lastSeen': serializer.toJson<DateTime>(lastSeen),
      'notification': serializer.toJson<bool>(notification),
      'isBlock': serializer.toJson<bool>(isBlock),
      'isOnline': serializer.toJson<bool>(isOnline),
    };
  }

  Contact copyWith(
          {String uid,
          DateTime lastUpdateAvatarTime,
          String lastAvatarFileId,
          String phoneNumber,
          String firstName,
          String lastName,
          DateTime lastSeen,
          bool notification,
          bool isBlock,
          bool isOnline}) =>
      Contact(
        uid: uid ?? this.uid,
        lastUpdateAvatarTime: lastUpdateAvatarTime ?? this.lastUpdateAvatarTime,
        lastAvatarFileId: lastAvatarFileId ?? this.lastAvatarFileId,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        lastSeen: lastSeen ?? this.lastSeen,
        notification: notification ?? this.notification,
        isBlock: isBlock ?? this.isBlock,
        isOnline: isOnline ?? this.isOnline,
      );
  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('uid: $uid, ')
          ..write('lastUpdateAvatarTime: $lastUpdateAvatarTime, ')
          ..write('lastAvatarFileId: $lastAvatarFileId, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('notification: $notification, ')
          ..write('isBlock: $isBlock, ')
          ..write('isOnline: $isOnline')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      uid.hashCode,
      $mrjc(
          lastUpdateAvatarTime.hashCode,
          $mrjc(
              lastAvatarFileId.hashCode,
              $mrjc(
                  phoneNumber.hashCode,
                  $mrjc(
                      firstName.hashCode,
                      $mrjc(
                          lastName.hashCode,
                          $mrjc(
                              lastSeen.hashCode,
                              $mrjc(
                                  notification.hashCode,
                                  $mrjc(isBlock.hashCode,
                                      isOnline.hashCode))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Contact &&
          other.uid == this.uid &&
          other.lastUpdateAvatarTime == this.lastUpdateAvatarTime &&
          other.lastAvatarFileId == this.lastAvatarFileId &&
          other.phoneNumber == this.phoneNumber &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.lastSeen == this.lastSeen &&
          other.notification == this.notification &&
          other.isBlock == this.isBlock &&
          other.isOnline == this.isOnline);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<String> uid;
  final Value<DateTime> lastUpdateAvatarTime;
  final Value<String> lastAvatarFileId;
  final Value<String> phoneNumber;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<DateTime> lastSeen;
  final Value<bool> notification;
  final Value<bool> isBlock;
  final Value<bool> isOnline;
  const ContactsCompanion({
    this.uid = const Value.absent(),
    this.lastUpdateAvatarTime = const Value.absent(),
    this.lastAvatarFileId = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.notification = const Value.absent(),
    this.isBlock = const Value.absent(),
    this.isOnline = const Value.absent(),
  });
  ContactsCompanion.insert({
    @required String uid,
    @required DateTime lastUpdateAvatarTime,
    this.lastAvatarFileId = const Value.absent(),
    @required String phoneNumber,
    @required String firstName,
    @required String lastName,
    @required DateTime lastSeen,
    @required bool notification,
    @required bool isBlock,
    @required bool isOnline,
  })  : uid = Value(uid),
        lastUpdateAvatarTime = Value(lastUpdateAvatarTime),
        phoneNumber = Value(phoneNumber),
        firstName = Value(firstName),
        lastName = Value(lastName),
        lastSeen = Value(lastSeen),
        notification = Value(notification),
        isBlock = Value(isBlock),
        isOnline = Value(isOnline);
  static Insertable<Contact> custom({
    Expression<String> uid,
    Expression<DateTime> lastUpdateAvatarTime,
    Expression<String> lastAvatarFileId,
    Expression<String> phoneNumber,
    Expression<String> firstName,
    Expression<String> lastName,
    Expression<DateTime> lastSeen,
    Expression<bool> notification,
    Expression<bool> isBlock,
    Expression<bool> isOnline,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (lastUpdateAvatarTime != null)
        'last_update_avatar_time': lastUpdateAvatarTime,
      if (lastAvatarFileId != null) 'last_avatar_file_id': lastAvatarFileId,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (notification != null) 'notification': notification,
      if (isBlock != null) 'is_block': isBlock,
      if (isOnline != null) 'is_online': isOnline,
    });
  }

  ContactsCompanion copyWith(
      {Value<String> uid,
      Value<DateTime> lastUpdateAvatarTime,
      Value<String> lastAvatarFileId,
      Value<String> phoneNumber,
      Value<String> firstName,
      Value<String> lastName,
      Value<DateTime> lastSeen,
      Value<bool> notification,
      Value<bool> isBlock,
      Value<bool> isOnline}) {
    return ContactsCompanion(
      uid: uid ?? this.uid,
      lastUpdateAvatarTime: lastUpdateAvatarTime ?? this.lastUpdateAvatarTime,
      lastAvatarFileId: lastAvatarFileId ?? this.lastAvatarFileId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      lastSeen: lastSeen ?? this.lastSeen,
      notification: notification ?? this.notification,
      isBlock: isBlock ?? this.isBlock,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (lastUpdateAvatarTime.present) {
      map['last_update_avatar_time'] =
          Variable<DateTime>(lastUpdateAvatarTime.value);
    }
    if (lastAvatarFileId.present) {
      map['last_avatar_file_id'] = Variable<String>(lastAvatarFileId.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<DateTime>(lastSeen.value);
    }
    if (notification.present) {
      map['notification'] = Variable<bool>(notification.value);
    }
    if (isBlock.present) {
      map['is_block'] = Variable<bool>(isBlock.value);
    }
    if (isOnline.present) {
      map['is_online'] = Variable<bool>(isOnline.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('uid: $uid, ')
          ..write('lastUpdateAvatarTime: $lastUpdateAvatarTime, ')
          ..write('lastAvatarFileId: $lastAvatarFileId, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('notification: $notification, ')
          ..write('isBlock: $isBlock, ')
          ..write('isOnline: $isOnline')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  final GeneratedDatabase _db;
  final String _alias;
  $ContactsTable(this._db, [this._alias]);
  final VerificationMeta _uidMeta = const VerificationMeta('uid');
  GeneratedTextColumn _uid;
  @override
  GeneratedTextColumn get uid => _uid ??= _constructUid();
  GeneratedTextColumn _constructUid() {
    return GeneratedTextColumn(
      'uid',
      $tableName,
      false,
    );
  }

  final VerificationMeta _lastUpdateAvatarTimeMeta =
      const VerificationMeta('lastUpdateAvatarTime');
  GeneratedDateTimeColumn _lastUpdateAvatarTime;
  @override
  GeneratedDateTimeColumn get lastUpdateAvatarTime =>
      _lastUpdateAvatarTime ??= _constructLastUpdateAvatarTime();
  GeneratedDateTimeColumn _constructLastUpdateAvatarTime() {
    return GeneratedDateTimeColumn(
      'last_update_avatar_time',
      $tableName,
      false,
    );
  }

  final VerificationMeta _lastAvatarFileIdMeta =
      const VerificationMeta('lastAvatarFileId');
  GeneratedTextColumn _lastAvatarFileId;
  @override
  GeneratedTextColumn get lastAvatarFileId =>
      _lastAvatarFileId ??= _constructLastAvatarFileId();
  GeneratedTextColumn _constructLastAvatarFileId() {
    return GeneratedTextColumn(
      'last_avatar_file_id',
      $tableName,
      true,
    );
  }

  final VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  GeneratedTextColumn _phoneNumber;
  @override
  GeneratedTextColumn get phoneNumber =>
      _phoneNumber ??= _constructPhoneNumber();
  GeneratedTextColumn _constructPhoneNumber() {
    return GeneratedTextColumn(
      'phone_number',
      $tableName,
      false,
    );
  }

  final VerificationMeta _firstNameMeta = const VerificationMeta('firstName');
  GeneratedTextColumn _firstName;
  @override
  GeneratedTextColumn get firstName => _firstName ??= _constructFirstName();
  GeneratedTextColumn _constructFirstName() {
    return GeneratedTextColumn(
      'first_name',
      $tableName,
      false,
    );
  }

  final VerificationMeta _lastNameMeta = const VerificationMeta('lastName');
  GeneratedTextColumn _lastName;
  @override
  GeneratedTextColumn get lastName => _lastName ??= _constructLastName();
  GeneratedTextColumn _constructLastName() {
    return GeneratedTextColumn(
      'last_name',
      $tableName,
      false,
    );
  }

  final VerificationMeta _lastSeenMeta = const VerificationMeta('lastSeen');
  GeneratedDateTimeColumn _lastSeen;
  @override
  GeneratedDateTimeColumn get lastSeen => _lastSeen ??= _constructLastSeen();
  GeneratedDateTimeColumn _constructLastSeen() {
    return GeneratedDateTimeColumn(
      'last_seen',
      $tableName,
      false,
    );
  }

  final VerificationMeta _notificationMeta =
      const VerificationMeta('notification');
  GeneratedBoolColumn _notification;
  @override
  GeneratedBoolColumn get notification =>
      _notification ??= _constructNotification();
  GeneratedBoolColumn _constructNotification() {
    return GeneratedBoolColumn(
      'notification',
      $tableName,
      false,
    );
  }

  final VerificationMeta _isBlockMeta = const VerificationMeta('isBlock');
  GeneratedBoolColumn _isBlock;
  @override
  GeneratedBoolColumn get isBlock => _isBlock ??= _constructIsBlock();
  GeneratedBoolColumn _constructIsBlock() {
    return GeneratedBoolColumn(
      'is_block',
      $tableName,
      false,
    );
  }

  final VerificationMeta _isOnlineMeta = const VerificationMeta('isOnline');
  GeneratedBoolColumn _isOnline;
  @override
  GeneratedBoolColumn get isOnline => _isOnline ??= _constructIsOnline();
  GeneratedBoolColumn _constructIsOnline() {
    return GeneratedBoolColumn(
      'is_online',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        uid,
        lastUpdateAvatarTime,
        lastAvatarFileId,
        phoneNumber,
        firstName,
        lastName,
        lastSeen,
        notification,
        isBlock,
        isOnline
      ];
  @override
  $ContactsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'contacts';
  @override
  final String actualTableName = 'contacts';
  @override
  VerificationContext validateIntegrity(Insertable<Contact> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid'], _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('last_update_avatar_time')) {
      context.handle(
          _lastUpdateAvatarTimeMeta,
          lastUpdateAvatarTime.isAcceptableOrUnknown(
              data['last_update_avatar_time'], _lastUpdateAvatarTimeMeta));
    } else if (isInserting) {
      context.missing(_lastUpdateAvatarTimeMeta);
    }
    if (data.containsKey('last_avatar_file_id')) {
      context.handle(
          _lastAvatarFileIdMeta,
          lastAvatarFileId.isAcceptableOrUnknown(
              data['last_avatar_file_id'], _lastAvatarFileIdMeta));
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number'], _phoneNumberMeta));
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name'], _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name'], _lastNameMeta));
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('last_seen')) {
      context.handle(_lastSeenMeta,
          lastSeen.isAcceptableOrUnknown(data['last_seen'], _lastSeenMeta));
    } else if (isInserting) {
      context.missing(_lastSeenMeta);
    }
    if (data.containsKey('notification')) {
      context.handle(
          _notificationMeta,
          notification.isAcceptableOrUnknown(
              data['notification'], _notificationMeta));
    } else if (isInserting) {
      context.missing(_notificationMeta);
    }
    if (data.containsKey('is_block')) {
      context.handle(_isBlockMeta,
          isBlock.isAcceptableOrUnknown(data['is_block'], _isBlockMeta));
    } else if (isInserting) {
      context.missing(_isBlockMeta);
    }
    if (data.containsKey('is_online')) {
      context.handle(_isOnlineMeta,
          isOnline.isAcceptableOrUnknown(data['is_online'], _isOnlineMeta));
    } else if (isInserting) {
      context.missing(_isOnlineMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  Contact map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Contact.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(_db, alias);
  }
}

class FileInfo extends DataClass implements Insertable<FileInfo> {
  final String uuid;
  final String compressionSize;
  final String path;
  final String name;
  FileInfo(
      {@required this.uuid,
      @required this.compressionSize,
      @required this.path,
      @required this.name});
  factory FileInfo.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    return FileInfo(
      uuid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uuid']),
      compressionSize: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}compression_size']),
      path: stringType.mapFromDatabaseResponse(data['${effectivePrefix}path']),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || uuid != null) {
      map['uuid'] = Variable<String>(uuid);
    }
    if (!nullToAbsent || compressionSize != null) {
      map['compression_size'] = Variable<String>(compressionSize);
    }
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    return map;
  }

  FileInfosCompanion toCompanion(bool nullToAbsent) {
    return FileInfosCompanion(
      uuid: uuid == null && nullToAbsent ? const Value.absent() : Value(uuid),
      compressionSize: compressionSize == null && nullToAbsent
          ? const Value.absent()
          : Value(compressionSize),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
    );
  }

  factory FileInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return FileInfo(
      uuid: serializer.fromJson<String>(json['uuid']),
      compressionSize: serializer.fromJson<String>(json['compressionSize']),
      path: serializer.fromJson<String>(json['path']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'compressionSize': serializer.toJson<String>(compressionSize),
      'path': serializer.toJson<String>(path),
      'name': serializer.toJson<String>(name),
    };
  }

  FileInfo copyWith(
          {String uuid, String compressionSize, String path, String name}) =>
      FileInfo(
        uuid: uuid ?? this.uuid,
        compressionSize: compressionSize ?? this.compressionSize,
        path: path ?? this.path,
        name: name ?? this.name,
      );
  @override
  String toString() {
    return (StringBuffer('FileInfo(')
          ..write('uuid: $uuid, ')
          ..write('compressionSize: $compressionSize, ')
          ..write('path: $path, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(uuid.hashCode,
      $mrjc(compressionSize.hashCode, $mrjc(path.hashCode, name.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is FileInfo &&
          other.uuid == this.uuid &&
          other.compressionSize == this.compressionSize &&
          other.path == this.path &&
          other.name == this.name);
}

class FileInfosCompanion extends UpdateCompanion<FileInfo> {
  final Value<String> uuid;
  final Value<String> compressionSize;
  final Value<String> path;
  final Value<String> name;
  const FileInfosCompanion({
    this.uuid = const Value.absent(),
    this.compressionSize = const Value.absent(),
    this.path = const Value.absent(),
    this.name = const Value.absent(),
  });
  FileInfosCompanion.insert({
    @required String uuid,
    @required String compressionSize,
    @required String path,
    @required String name,
  })  : uuid = Value(uuid),
        compressionSize = Value(compressionSize),
        path = Value(path),
        name = Value(name);
  static Insertable<FileInfo> custom({
    Expression<String> uuid,
    Expression<String> compressionSize,
    Expression<String> path,
    Expression<String> name,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (compressionSize != null) 'compression_size': compressionSize,
      if (path != null) 'path': path,
      if (name != null) 'name': name,
    });
  }

  FileInfosCompanion copyWith(
      {Value<String> uuid,
      Value<String> compressionSize,
      Value<String> path,
      Value<String> name}) {
    return FileInfosCompanion(
      uuid: uuid ?? this.uuid,
      compressionSize: compressionSize ?? this.compressionSize,
      path: path ?? this.path,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (compressionSize.present) {
      map['compression_size'] = Variable<String>(compressionSize.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileInfosCompanion(')
          ..write('uuid: $uuid, ')
          ..write('compressionSize: $compressionSize, ')
          ..write('path: $path, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $FileInfosTable extends FileInfos
    with TableInfo<$FileInfosTable, FileInfo> {
  final GeneratedDatabase _db;
  final String _alias;
  $FileInfosTable(this._db, [this._alias]);
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

  final VerificationMeta _compressionSizeMeta =
      const VerificationMeta('compressionSize');
  GeneratedTextColumn _compressionSize;
  @override
  GeneratedTextColumn get compressionSize =>
      _compressionSize ??= _constructCompressionSize();
  GeneratedTextColumn _constructCompressionSize() {
    return GeneratedTextColumn(
      'compression_size',
      $tableName,
      false,
    );
  }

  final VerificationMeta _pathMeta = const VerificationMeta('path');
  GeneratedTextColumn _path;
  @override
  GeneratedTextColumn get path => _path ??= _constructPath();
  GeneratedTextColumn _constructPath() {
    return GeneratedTextColumn(
      'path',
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

  @override
  List<GeneratedColumn> get $columns => [uuid, compressionSize, path, name];
  @override
  $FileInfosTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'file_infos';
  @override
  final String actualTableName = 'file_infos';
  @override
  VerificationContext validateIntegrity(Insertable<FileInfo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid'], _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('compression_size')) {
      context.handle(
          _compressionSizeMeta,
          compressionSize.isAcceptableOrUnknown(
              data['compression_size'], _compressionSizeMeta));
    } else if (isInserting) {
      context.missing(_compressionSizeMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path'], _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name'], _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid, compressionSize};
  @override
  FileInfo map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return FileInfo.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $FileInfosTable createAlias(String alias) {
    return $FileInfosTable(_db, alias);
  }
}

class Seen extends DataClass implements Insertable<Seen> {
  final int dbId;
  final String roomId;
  final int messageId;
  final String user;
  Seen(
      {@required this.dbId,
      @required this.roomId,
      @required this.messageId,
      @required this.user});
  factory Seen.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return Seen(
      dbId: intType.mapFromDatabaseResponse(data['${effectivePrefix}db_id']),
      roomId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      messageId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}message_id']),
      user: stringType.mapFromDatabaseResponse(data['${effectivePrefix}user']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || dbId != null) {
      map['db_id'] = Variable<int>(dbId);
    }
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    if (!nullToAbsent || messageId != null) {
      map['message_id'] = Variable<int>(messageId);
    }
    if (!nullToAbsent || user != null) {
      map['user'] = Variable<String>(user);
    }
    return map;
  }

  SeensCompanion toCompanion(bool nullToAbsent) {
    return SeensCompanion(
      dbId: dbId == null && nullToAbsent ? const Value.absent() : Value(dbId),
      roomId:
          roomId == null && nullToAbsent ? const Value.absent() : Value(roomId),
      messageId: messageId == null && nullToAbsent
          ? const Value.absent()
          : Value(messageId),
      user: user == null && nullToAbsent ? const Value.absent() : Value(user),
    );
  }

  factory Seen.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Seen(
      dbId: serializer.fromJson<int>(json['dbId']),
      roomId: serializer.fromJson<String>(json['roomId']),
      messageId: serializer.fromJson<int>(json['messageId']),
      user: serializer.fromJson<String>(json['user']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dbId': serializer.toJson<int>(dbId),
      'roomId': serializer.toJson<String>(roomId),
      'messageId': serializer.toJson<int>(messageId),
      'user': serializer.toJson<String>(user),
    };
  }

  Seen copyWith({int dbId, String roomId, int messageId, String user}) => Seen(
        dbId: dbId ?? this.dbId,
        roomId: roomId ?? this.roomId,
        messageId: messageId ?? this.messageId,
        user: user ?? this.user,
      );
  @override
  String toString() {
    return (StringBuffer('Seen(')
          ..write('dbId: $dbId, ')
          ..write('roomId: $roomId, ')
          ..write('messageId: $messageId, ')
          ..write('user: $user')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(dbId.hashCode,
      $mrjc(roomId.hashCode, $mrjc(messageId.hashCode, user.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Seen &&
          other.dbId == this.dbId &&
          other.roomId == this.roomId &&
          other.messageId == this.messageId &&
          other.user == this.user);
}

class SeensCompanion extends UpdateCompanion<Seen> {
  final Value<int> dbId;
  final Value<String> roomId;
  final Value<int> messageId;
  final Value<String> user;
  const SeensCompanion({
    this.dbId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.messageId = const Value.absent(),
    this.user = const Value.absent(),
  });
  SeensCompanion.insert({
    this.dbId = const Value.absent(),
    @required String roomId,
    @required int messageId,
    @required String user,
  })  : roomId = Value(roomId),
        messageId = Value(messageId),
        user = Value(user);
  static Insertable<Seen> custom({
    Expression<int> dbId,
    Expression<String> roomId,
    Expression<int> messageId,
    Expression<String> user,
  }) {
    return RawValuesInsertable({
      if (dbId != null) 'db_id': dbId,
      if (roomId != null) 'room_id': roomId,
      if (messageId != null) 'message_id': messageId,
      if (user != null) 'user': user,
    });
  }

  SeensCompanion copyWith(
      {Value<int> dbId,
      Value<String> roomId,
      Value<int> messageId,
      Value<String> user}) {
    return SeensCompanion(
      dbId: dbId ?? this.dbId,
      roomId: roomId ?? this.roomId,
      messageId: messageId ?? this.messageId,
      user: user ?? this.user,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dbId.present) {
      map['db_id'] = Variable<int>(dbId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (user.present) {
      map['user'] = Variable<String>(user.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeensCompanion(')
          ..write('dbId: $dbId, ')
          ..write('roomId: $roomId, ')
          ..write('messageId: $messageId, ')
          ..write('user: $user')
          ..write(')'))
        .toString();
  }
}

class $SeensTable extends Seens with TableInfo<$SeensTable, Seen> {
  final GeneratedDatabase _db;
  final String _alias;
  $SeensTable(this._db, [this._alias]);
  final VerificationMeta _dbIdMeta = const VerificationMeta('dbId');
  GeneratedIntColumn _dbId;
  @override
  GeneratedIntColumn get dbId => _dbId ??= _constructDbId();
  GeneratedIntColumn _constructDbId() {
    return GeneratedIntColumn('db_id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
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

  final VerificationMeta _userMeta = const VerificationMeta('user');
  GeneratedTextColumn _user;
  @override
  GeneratedTextColumn get user => _user ??= _constructUser();
  GeneratedTextColumn _constructUser() {
    return GeneratedTextColumn(
      'user',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [dbId, roomId, messageId, user];
  @override
  $SeensTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'seens';
  @override
  final String actualTableName = 'seens';
  @override
  VerificationContext validateIntegrity(Insertable<Seen> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('db_id')) {
      context.handle(
          _dbIdMeta, dbId.isAcceptableOrUnknown(data['db_id'], _dbIdMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id'], _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id'], _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('user')) {
      context.handle(
          _userMeta, user.isAcceptableOrUnknown(data['user'], _userMeta));
    } else if (isInserting) {
      context.missing(_userMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dbId};
  @override
  Seen map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Seen.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $SeensTable createAlias(String alias) {
    return $SeensTable(_db, alias);
  }
}

class LastAvatar extends DataClass implements Insertable<LastAvatar> {
  final String uid;
  final int lastUpdate;
  LastAvatar({@required this.uid, @required this.lastUpdate});
  factory LastAvatar.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    return LastAvatar(
      uid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uid']),
      lastUpdate: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}last_update']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || uid != null) {
      map['uid'] = Variable<String>(uid);
    }
    if (!nullToAbsent || lastUpdate != null) {
      map['last_update'] = Variable<int>(lastUpdate);
    }
    return map;
  }

  LastAvatarsCompanion toCompanion(bool nullToAbsent) {
    return LastAvatarsCompanion(
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
      lastUpdate: lastUpdate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdate),
    );
  }

  factory LastAvatar.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return LastAvatar(
      uid: serializer.fromJson<String>(json['uid']),
      lastUpdate: serializer.fromJson<int>(json['lastUpdate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'lastUpdate': serializer.toJson<int>(lastUpdate),
    };
  }

  LastAvatar copyWith({String uid, int lastUpdate}) => LastAvatar(
        uid: uid ?? this.uid,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );
  @override
  String toString() {
    return (StringBuffer('LastAvatar(')
          ..write('uid: $uid, ')
          ..write('lastUpdate: $lastUpdate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(uid.hashCode, lastUpdate.hashCode));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is LastAvatar &&
          other.uid == this.uid &&
          other.lastUpdate == this.lastUpdate);
}

class LastAvatarsCompanion extends UpdateCompanion<LastAvatar> {
  final Value<String> uid;
  final Value<int> lastUpdate;
  const LastAvatarsCompanion({
    this.uid = const Value.absent(),
    this.lastUpdate = const Value.absent(),
  });
  LastAvatarsCompanion.insert({
    @required String uid,
    @required int lastUpdate,
  })  : uid = Value(uid),
        lastUpdate = Value(lastUpdate);
  static Insertable<LastAvatar> custom({
    Expression<String> uid,
    Expression<int> lastUpdate,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (lastUpdate != null) 'last_update': lastUpdate,
    });
  }

  LastAvatarsCompanion copyWith({Value<String> uid, Value<int> lastUpdate}) {
    return LastAvatarsCompanion(
      uid: uid ?? this.uid,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<int>(lastUpdate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LastAvatarsCompanion(')
          ..write('uid: $uid, ')
          ..write('lastUpdate: $lastUpdate')
          ..write(')'))
        .toString();
  }
}

class $LastAvatarsTable extends LastAvatars
    with TableInfo<$LastAvatarsTable, LastAvatar> {
  final GeneratedDatabase _db;
  final String _alias;
  $LastAvatarsTable(this._db, [this._alias]);
  final VerificationMeta _uidMeta = const VerificationMeta('uid');
  GeneratedTextColumn _uid;
  @override
  GeneratedTextColumn get uid => _uid ??= _constructUid();
  GeneratedTextColumn _constructUid() {
    return GeneratedTextColumn(
      'uid',
      $tableName,
      false,
    );
  }

  final VerificationMeta _lastUpdateMeta = const VerificationMeta('lastUpdate');
  GeneratedIntColumn _lastUpdate;
  @override
  GeneratedIntColumn get lastUpdate => _lastUpdate ??= _constructLastUpdate();
  GeneratedIntColumn _constructLastUpdate() {
    return GeneratedIntColumn(
      'last_update',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [uid, lastUpdate];
  @override
  $LastAvatarsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'last_avatars';
  @override
  final String actualTableName = 'last_avatars';
  @override
  VerificationContext validateIntegrity(Insertable<LastAvatar> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid'], _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('last_update')) {
      context.handle(
          _lastUpdateMeta,
          lastUpdate.isAcceptableOrUnknown(
              data['last_update'], _lastUpdateMeta));
    } else if (isInserting) {
      context.missing(_lastUpdateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  LastAvatar map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return LastAvatar.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $LastAvatarsTable createAlias(String alias) {
    return $LastAvatarsTable(_db, alias);
  }
}

class PendingMessage extends DataClass implements Insertable<PendingMessage> {
  final int dbId;
  final int messageId;
  final int retry;
  final DateTime time;
  final SendingStatus status;
  final String details;
  PendingMessage(
      {@required this.dbId,
      @required this.messageId,
      @required this.retry,
      @required this.time,
      @required this.status,
      this.details});
  factory PendingMessage.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final stringType = db.typeSystem.forDartType<String>();
    return PendingMessage(
      dbId: intType.mapFromDatabaseResponse(data['${effectivePrefix}db_id']),
      messageId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}message_id']),
      retry: intType.mapFromDatabaseResponse(data['${effectivePrefix}retry']),
      time:
          dateTimeType.mapFromDatabaseResponse(data['${effectivePrefix}time']),
      status: $PendingMessagesTable.$converter0.mapToDart(
          intType.mapFromDatabaseResponse(data['${effectivePrefix}status'])),
      details:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}details']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || dbId != null) {
      map['db_id'] = Variable<int>(dbId);
    }
    if (!nullToAbsent || messageId != null) {
      map['message_id'] = Variable<int>(messageId);
    }
    if (!nullToAbsent || retry != null) {
      map['retry'] = Variable<int>(retry);
    }
    if (!nullToAbsent || time != null) {
      map['time'] = Variable<DateTime>(time);
    }
    if (!nullToAbsent || status != null) {
      final converter = $PendingMessagesTable.$converter0;
      map['status'] = Variable<int>(converter.mapToSql(status));
    }
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    return map;
  }

  PendingMessagesCompanion toCompanion(bool nullToAbsent) {
    return PendingMessagesCompanion(
      dbId: dbId == null && nullToAbsent ? const Value.absent() : Value(dbId),
      messageId: messageId == null && nullToAbsent
          ? const Value.absent()
          : Value(messageId),
      retry:
          retry == null && nullToAbsent ? const Value.absent() : Value(retry),
      time: time == null && nullToAbsent ? const Value.absent() : Value(time),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
    );
  }

  factory PendingMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return PendingMessage(
      dbId: serializer.fromJson<int>(json['dbId']),
      messageId: serializer.fromJson<int>(json['messageId']),
      retry: serializer.fromJson<int>(json['retry']),
      time: serializer.fromJson<DateTime>(json['time']),
      status: serializer.fromJson<SendingStatus>(json['status']),
      details: serializer.fromJson<String>(json['details']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dbId': serializer.toJson<int>(dbId),
      'messageId': serializer.toJson<int>(messageId),
      'retry': serializer.toJson<int>(retry),
      'time': serializer.toJson<DateTime>(time),
      'status': serializer.toJson<SendingStatus>(status),
      'details': serializer.toJson<String>(details),
    };
  }

  PendingMessage copyWith(
          {int dbId,
          int messageId,
          int retry,
          DateTime time,
          SendingStatus status,
          String details}) =>
      PendingMessage(
        dbId: dbId ?? this.dbId,
        messageId: messageId ?? this.messageId,
        retry: retry ?? this.retry,
        time: time ?? this.time,
        status: status ?? this.status,
        details: details ?? this.details,
      );
  @override
  String toString() {
    return (StringBuffer('PendingMessage(')
          ..write('dbId: $dbId, ')
          ..write('messageId: $messageId, ')
          ..write('retry: $retry, ')
          ..write('time: $time, ')
          ..write('status: $status, ')
          ..write('details: $details')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      dbId.hashCode,
      $mrjc(
          messageId.hashCode,
          $mrjc(
              retry.hashCode,
              $mrjc(
                  time.hashCode, $mrjc(status.hashCode, details.hashCode))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is PendingMessage &&
          other.dbId == this.dbId &&
          other.messageId == this.messageId &&
          other.retry == this.retry &&
          other.time == this.time &&
          other.status == this.status &&
          other.details == this.details);
}

class PendingMessagesCompanion extends UpdateCompanion<PendingMessage> {
  final Value<int> dbId;
  final Value<int> messageId;
  final Value<int> retry;
  final Value<DateTime> time;
  final Value<SendingStatus> status;
  final Value<String> details;
  const PendingMessagesCompanion({
    this.dbId = const Value.absent(),
    this.messageId = const Value.absent(),
    this.retry = const Value.absent(),
    this.time = const Value.absent(),
    this.status = const Value.absent(),
    this.details = const Value.absent(),
  });
  PendingMessagesCompanion.insert({
    this.dbId = const Value.absent(),
    @required int messageId,
    @required int retry,
    @required DateTime time,
    @required SendingStatus status,
    this.details = const Value.absent(),
  })  : messageId = Value(messageId),
        retry = Value(retry),
        time = Value(time),
        status = Value(status);
  static Insertable<PendingMessage> custom({
    Expression<int> dbId,
    Expression<int> messageId,
    Expression<int> retry,
    Expression<DateTime> time,
    Expression<int> status,
    Expression<String> details,
  }) {
    return RawValuesInsertable({
      if (dbId != null) 'db_id': dbId,
      if (messageId != null) 'message_id': messageId,
      if (retry != null) 'retry': retry,
      if (time != null) 'time': time,
      if (status != null) 'status': status,
      if (details != null) 'details': details,
    });
  }

  PendingMessagesCompanion copyWith(
      {Value<int> dbId,
      Value<int> messageId,
      Value<int> retry,
      Value<DateTime> time,
      Value<SendingStatus> status,
      Value<String> details}) {
    return PendingMessagesCompanion(
      dbId: dbId ?? this.dbId,
      messageId: messageId ?? this.messageId,
      retry: retry ?? this.retry,
      time: time ?? this.time,
      status: status ?? this.status,
      details: details ?? this.details,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dbId.present) {
      map['db_id'] = Variable<int>(dbId.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (retry.present) {
      map['retry'] = Variable<int>(retry.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (status.present) {
      final converter = $PendingMessagesTable.$converter0;
      map['status'] = Variable<int>(converter.mapToSql(status.value));
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingMessagesCompanion(')
          ..write('dbId: $dbId, ')
          ..write('messageId: $messageId, ')
          ..write('retry: $retry, ')
          ..write('time: $time, ')
          ..write('status: $status, ')
          ..write('details: $details')
          ..write(')'))
        .toString();
  }
}

class $PendingMessagesTable extends PendingMessages
    with TableInfo<$PendingMessagesTable, PendingMessage> {
  final GeneratedDatabase _db;
  final String _alias;
  $PendingMessagesTable(this._db, [this._alias]);
  final VerificationMeta _dbIdMeta = const VerificationMeta('dbId');
  GeneratedIntColumn _dbId;
  @override
  GeneratedIntColumn get dbId => _dbId ??= _constructDbId();
  GeneratedIntColumn _constructDbId() {
    return GeneratedIntColumn('db_id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _messageIdMeta = const VerificationMeta('messageId');
  GeneratedIntColumn _messageId;
  @override
  GeneratedIntColumn get messageId => _messageId ??= _constructMessageId();
  GeneratedIntColumn _constructMessageId() {
    return GeneratedIntColumn('message_id', $tableName, false,
        $customConstraints: 'REFERENCES messages(db_id)');
  }

  final VerificationMeta _retryMeta = const VerificationMeta('retry');
  GeneratedIntColumn _retry;
  @override
  GeneratedIntColumn get retry => _retry ??= _constructRetry();
  GeneratedIntColumn _constructRetry() {
    return GeneratedIntColumn(
      'retry',
      $tableName,
      false,
    );
  }

  final VerificationMeta _timeMeta = const VerificationMeta('time');
  GeneratedDateTimeColumn _time;
  @override
  GeneratedDateTimeColumn get time => _time ??= _constructTime();
  GeneratedDateTimeColumn _constructTime() {
    return GeneratedDateTimeColumn(
      'time',
      $tableName,
      false,
    );
  }

  final VerificationMeta _statusMeta = const VerificationMeta('status');
  GeneratedIntColumn _status;
  @override
  GeneratedIntColumn get status => _status ??= _constructStatus();
  GeneratedIntColumn _constructStatus() {
    return GeneratedIntColumn(
      'status',
      $tableName,
      false,
    );
  }

  final VerificationMeta _detailsMeta = const VerificationMeta('details');
  GeneratedTextColumn _details;
  @override
  GeneratedTextColumn get details => _details ??= _constructDetails();
  GeneratedTextColumn _constructDetails() {
    return GeneratedTextColumn(
      'details',
      $tableName,
      true,
    );
  }

  @override
  List<GeneratedColumn> get $columns =>
      [dbId, messageId, retry, time, status, details];
  @override
  $PendingMessagesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'pending_messages';
  @override
  final String actualTableName = 'pending_messages';
  @override
  VerificationContext validateIntegrity(Insertable<PendingMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('db_id')) {
      context.handle(
          _dbIdMeta, dbId.isAcceptableOrUnknown(data['db_id'], _dbIdMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id'], _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('retry')) {
      context.handle(
          _retryMeta, retry.isAcceptableOrUnknown(data['retry'], _retryMeta));
    } else if (isInserting) {
      context.missing(_retryMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time'], _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    context.handle(_statusMeta, const VerificationResult.success());
    if (data.containsKey('details')) {
      context.handle(_detailsMeta,
          details.isAcceptableOrUnknown(data['details'], _detailsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dbId};
  @override
  PendingMessage map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return PendingMessage.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $PendingMessagesTable createAlias(String alias) {
    return $PendingMessagesTable(_db, alias);
  }

  static TypeConverter<SendingStatus, int> $converter0 =
      const EnumIndexConverter<SendingStatus>(SendingStatus.values);
}

class Media extends DataClass implements Insertable<Media> {
  final int messageId;
  final String mediaUrl;
  final String mediaSender;
  final String mediaName;
  final String mediaType;
  final String time;
  final String roomId;
  final String mediaUuid;
  Media(
      {@required this.messageId,
      @required this.mediaUrl,
      @required this.mediaSender,
      @required this.mediaName,
      @required this.mediaType,
      @required this.time,
      @required this.roomId,
      @required this.mediaUuid});
  factory Media.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return Media(
      messageId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}message_id']),
      mediaUrl: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}media_url']),
      mediaSender: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}media_sender']),
      mediaName: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}media_name']),
      mediaType: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}media_type']),
      time: stringType.mapFromDatabaseResponse(data['${effectivePrefix}time']),
      roomId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      mediaUuid: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}media_uuid']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || messageId != null) {
      map['message_id'] = Variable<int>(messageId);
    }
    if (!nullToAbsent || mediaUrl != null) {
      map['media_url'] = Variable<String>(mediaUrl);
    }
    if (!nullToAbsent || mediaSender != null) {
      map['media_sender'] = Variable<String>(mediaSender);
    }
    if (!nullToAbsent || mediaName != null) {
      map['media_name'] = Variable<String>(mediaName);
    }
    if (!nullToAbsent || mediaType != null) {
      map['media_type'] = Variable<String>(mediaType);
    }
    if (!nullToAbsent || time != null) {
      map['time'] = Variable<String>(time);
    }
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    if (!nullToAbsent || mediaUuid != null) {
      map['media_uuid'] = Variable<String>(mediaUuid);
    }
    return map;
  }

  MediasCompanion toCompanion(bool nullToAbsent) {
    return MediasCompanion(
      messageId: messageId == null && nullToAbsent
          ? const Value.absent()
          : Value(messageId),
      mediaUrl: mediaUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaUrl),
      mediaSender: mediaSender == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaSender),
      mediaName: mediaName == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaName),
      mediaType: mediaType == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaType),
      time: time == null && nullToAbsent ? const Value.absent() : Value(time),
      roomId:
          roomId == null && nullToAbsent ? const Value.absent() : Value(roomId),
      mediaUuid: mediaUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaUuid),
    );
  }

  factory Media.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Media(
      messageId: serializer.fromJson<int>(json['messageId']),
      mediaUrl: serializer.fromJson<String>(json['mediaUrl']),
      mediaSender: serializer.fromJson<String>(json['mediaSender']),
      mediaName: serializer.fromJson<String>(json['mediaName']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      time: serializer.fromJson<String>(json['time']),
      roomId: serializer.fromJson<String>(json['roomId']),
      mediaUuid: serializer.fromJson<String>(json['mediaUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<int>(messageId),
      'mediaUrl': serializer.toJson<String>(mediaUrl),
      'mediaSender': serializer.toJson<String>(mediaSender),
      'mediaName': serializer.toJson<String>(mediaName),
      'mediaType': serializer.toJson<String>(mediaType),
      'time': serializer.toJson<String>(time),
      'roomId': serializer.toJson<String>(roomId),
      'mediaUuid': serializer.toJson<String>(mediaUuid),
    };
  }

  Media copyWith(
          {int messageId,
          String mediaUrl,
          String mediaSender,
          String mediaName,
          String mediaType,
          String time,
          String roomId,
          String mediaUuid}) =>
      Media(
        messageId: messageId ?? this.messageId,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        mediaSender: mediaSender ?? this.mediaSender,
        mediaName: mediaName ?? this.mediaName,
        mediaType: mediaType ?? this.mediaType,
        time: time ?? this.time,
        roomId: roomId ?? this.roomId,
        mediaUuid: mediaUuid ?? this.mediaUuid,
      );
  @override
  String toString() {
    return (StringBuffer('Media(')
          ..write('messageId: $messageId, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('mediaSender: $mediaSender, ')
          ..write('mediaName: $mediaName, ')
          ..write('mediaType: $mediaType, ')
          ..write('time: $time, ')
          ..write('roomId: $roomId, ')
          ..write('mediaUuid: $mediaUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      messageId.hashCode,
      $mrjc(
          mediaUrl.hashCode,
          $mrjc(
              mediaSender.hashCode,
              $mrjc(
                  mediaName.hashCode,
                  $mrjc(
                      mediaType.hashCode,
                      $mrjc(time.hashCode,
                          $mrjc(roomId.hashCode, mediaUuid.hashCode))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Media &&
          other.messageId == this.messageId &&
          other.mediaUrl == this.mediaUrl &&
          other.mediaSender == this.mediaSender &&
          other.mediaName == this.mediaName &&
          other.mediaType == this.mediaType &&
          other.time == this.time &&
          other.roomId == this.roomId &&
          other.mediaUuid == this.mediaUuid);
}

class MediasCompanion extends UpdateCompanion<Media> {
  final Value<int> messageId;
  final Value<String> mediaUrl;
  final Value<String> mediaSender;
  final Value<String> mediaName;
  final Value<String> mediaType;
  final Value<String> time;
  final Value<String> roomId;
  final Value<String> mediaUuid;
  const MediasCompanion({
    this.messageId = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.mediaSender = const Value.absent(),
    this.mediaName = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.time = const Value.absent(),
    this.roomId = const Value.absent(),
    this.mediaUuid = const Value.absent(),
  });
  MediasCompanion.insert({
    this.messageId = const Value.absent(),
    @required String mediaUrl,
    @required String mediaSender,
    @required String mediaName,
    @required String mediaType,
    @required String time,
    @required String roomId,
    @required String mediaUuid,
  })  : mediaUrl = Value(mediaUrl),
        mediaSender = Value(mediaSender),
        mediaName = Value(mediaName),
        mediaType = Value(mediaType),
        time = Value(time),
        roomId = Value(roomId),
        mediaUuid = Value(mediaUuid);
  static Insertable<Media> custom({
    Expression<int> messageId,
    Expression<String> mediaUrl,
    Expression<String> mediaSender,
    Expression<String> mediaName,
    Expression<String> mediaType,
    Expression<String> time,
    Expression<String> roomId,
    Expression<String> mediaUuid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (mediaSender != null) 'media_sender': mediaSender,
      if (mediaName != null) 'media_name': mediaName,
      if (mediaType != null) 'media_type': mediaType,
      if (time != null) 'time': time,
      if (roomId != null) 'room_id': roomId,
      if (mediaUuid != null) 'media_uuid': mediaUuid,
    });
  }

  MediasCompanion copyWith(
      {Value<int> messageId,
      Value<String> mediaUrl,
      Value<String> mediaSender,
      Value<String> mediaName,
      Value<String> mediaType,
      Value<String> time,
      Value<String> roomId,
      Value<String> mediaUuid}) {
    return MediasCompanion(
      messageId: messageId ?? this.messageId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaSender: mediaSender ?? this.mediaSender,
      mediaName: mediaName ?? this.mediaName,
      mediaType: mediaType ?? this.mediaType,
      time: time ?? this.time,
      roomId: roomId ?? this.roomId,
      mediaUuid: mediaUuid ?? this.mediaUuid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (mediaUrl.present) {
      map['media_url'] = Variable<String>(mediaUrl.value);
    }
    if (mediaSender.present) {
      map['media_sender'] = Variable<String>(mediaSender.value);
    }
    if (mediaName.present) {
      map['media_name'] = Variable<String>(mediaName.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (mediaUuid.present) {
      map['media_uuid'] = Variable<String>(mediaUuid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediasCompanion(')
          ..write('messageId: $messageId, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('mediaSender: $mediaSender, ')
          ..write('mediaName: $mediaName, ')
          ..write('mediaType: $mediaType, ')
          ..write('time: $time, ')
          ..write('roomId: $roomId, ')
          ..write('mediaUuid: $mediaUuid')
          ..write(')'))
        .toString();
  }
}

class $MediasTable extends Medias with TableInfo<$MediasTable, Media> {
  final GeneratedDatabase _db;
  final String _alias;
  $MediasTable(this._db, [this._alias]);
  final VerificationMeta _messageIdMeta = const VerificationMeta('messageId');
  GeneratedIntColumn _messageId;
  @override
  GeneratedIntColumn get messageId => _messageId ??= _constructMessageId();
  GeneratedIntColumn _constructMessageId() {
    return GeneratedIntColumn('message_id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _mediaUrlMeta = const VerificationMeta('mediaUrl');
  GeneratedTextColumn _mediaUrl;
  @override
  GeneratedTextColumn get mediaUrl => _mediaUrl ??= _constructMediaUrl();
  GeneratedTextColumn _constructMediaUrl() {
    return GeneratedTextColumn(
      'media_url',
      $tableName,
      false,
    );
  }

  final VerificationMeta _mediaSenderMeta =
      const VerificationMeta('mediaSender');
  GeneratedTextColumn _mediaSender;
  @override
  GeneratedTextColumn get mediaSender =>
      _mediaSender ??= _constructMediaSender();
  GeneratedTextColumn _constructMediaSender() {
    return GeneratedTextColumn(
      'media_sender',
      $tableName,
      false,
    );
  }

  final VerificationMeta _mediaNameMeta = const VerificationMeta('mediaName');
  GeneratedTextColumn _mediaName;
  @override
  GeneratedTextColumn get mediaName => _mediaName ??= _constructMediaName();
  GeneratedTextColumn _constructMediaName() {
    return GeneratedTextColumn(
      'media_name',
      $tableName,
      false,
    );
  }

  final VerificationMeta _mediaTypeMeta = const VerificationMeta('mediaType');
  GeneratedTextColumn _mediaType;
  @override
  GeneratedTextColumn get mediaType => _mediaType ??= _constructMediaType();
  GeneratedTextColumn _constructMediaType() {
    return GeneratedTextColumn(
      'media_type',
      $tableName,
      false,
    );
  }

  final VerificationMeta _timeMeta = const VerificationMeta('time');
  GeneratedTextColumn _time;
  @override
  GeneratedTextColumn get time => _time ??= _constructTime();
  GeneratedTextColumn _constructTime() {
    return GeneratedTextColumn(
      'time',
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

  final VerificationMeta _mediaUuidMeta = const VerificationMeta('mediaUuid');
  GeneratedTextColumn _mediaUuid;
  @override
  GeneratedTextColumn get mediaUuid => _mediaUuid ??= _constructMediaUuid();
  GeneratedTextColumn _constructMediaUuid() {
    return GeneratedTextColumn(
      'media_uuid',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        messageId,
        mediaUrl,
        mediaSender,
        mediaName,
        mediaType,
        time,
        roomId,
        mediaUuid
      ];
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
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id'], _messageIdMeta));
    }
    if (data.containsKey('media_url')) {
      context.handle(_mediaUrlMeta,
          mediaUrl.isAcceptableOrUnknown(data['media_url'], _mediaUrlMeta));
    } else if (isInserting) {
      context.missing(_mediaUrlMeta);
    }
    if (data.containsKey('media_sender')) {
      context.handle(
          _mediaSenderMeta,
          mediaSender.isAcceptableOrUnknown(
              data['media_sender'], _mediaSenderMeta));
    } else if (isInserting) {
      context.missing(_mediaSenderMeta);
    }
    if (data.containsKey('media_name')) {
      context.handle(_mediaNameMeta,
          mediaName.isAcceptableOrUnknown(data['media_name'], _mediaNameMeta));
    } else if (isInserting) {
      context.missing(_mediaNameMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(_mediaTypeMeta,
          mediaType.isAcceptableOrUnknown(data['media_type'], _mediaTypeMeta));
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time'], _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id'], _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('media_uuid')) {
      context.handle(_mediaUuidMeta,
          mediaUuid.isAcceptableOrUnknown(data['media_uuid'], _mediaUuidMeta));
    } else if (isInserting) {
      context.missing(_mediaUuidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId};
  @override
  Media map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Media.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $MediasTable createAlias(String alias) {
    return $MediasTable(_db, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $MessagesTable _messages;
  $MessagesTable get messages => _messages ??= $MessagesTable(this);
  $RoomsTable _rooms;
  $RoomsTable get rooms => _rooms ??= $RoomsTable(this);
  $AvatarsTable _avatars;
  $AvatarsTable get avatars => _avatars ??= $AvatarsTable(this);
  $ContactsTable _contacts;
  $ContactsTable get contacts => _contacts ??= $ContactsTable(this);
  $FileInfosTable _fileInfos;
  $FileInfosTable get fileInfos => _fileInfos ??= $FileInfosTable(this);
  $SeensTable _seens;
  $SeensTable get seens => _seens ??= $SeensTable(this);
  $LastAvatarsTable _lastAvatars;
  $LastAvatarsTable get lastAvatars => _lastAvatars ??= $LastAvatarsTable(this);
  $PendingMessagesTable _pendingMessages;
  $PendingMessagesTable get pendingMessages =>
      _pendingMessages ??= $PendingMessagesTable(this);
  $MediasTable _medias;
  $MediasTable get medias => _medias ??= $MediasTable(this);
  MessageDao _messageDao;
  MessageDao get messageDao => _messageDao ??= MessageDao(this as Database);
  RoomDao _roomDao;
  RoomDao get roomDao => _roomDao ??= RoomDao(this as Database);
  AvatarDao _avatarDao;
  AvatarDao get avatarDao => _avatarDao ??= AvatarDao(this as Database);
  ContactDao _contactDao;
  ContactDao get contactDao => _contactDao ??= ContactDao(this as Database);
  FileDao _fileDao;
  FileDao get fileDao => _fileDao ??= FileDao(this as Database);
  SeenDao _seenDao;
  SeenDao get seenDao => _seenDao ??= SeenDao(this as Database);
  LastAvatarDao _lastAvatarDao;
  LastAvatarDao get lastAvatarDao =>
      _lastAvatarDao ??= LastAvatarDao(this as Database);
  PendingMessageDao _pendingMessageDao;
  PendingMessageDao get pendingMessageDao =>
      _pendingMessageDao ??= PendingMessageDao(this as Database);
  MediaDao _mediaDao;
  MediaDao get mediaDao => _mediaDao ??= MediaDao(this as Database);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        messages,
        rooms,
        avatars,
        contacts,
        fileInfos,
        seens,
        lastAvatars,
        pendingMessages,
        medias
      ];
}
