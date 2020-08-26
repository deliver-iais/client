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
  final int avatarIndex;
  final String fileName;
  Avatar(
      {@required this.uid,
      @required this.fileId,
      @required this.avatarIndex,
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
      avatarIndex: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}avatar_index']),
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
    if (!nullToAbsent || avatarIndex != null) {
      map['avatar_index'] = Variable<int>(avatarIndex);
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
      avatarIndex: avatarIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarIndex),
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
      avatarIndex: serializer.fromJson<int>(json['avatarIndex']),
      fileName: serializer.fromJson<String>(json['fileName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'fileId': serializer.toJson<String>(fileId),
      'avatarIndex': serializer.toJson<int>(avatarIndex),
      'fileName': serializer.toJson<String>(fileName),
    };
  }

  Avatar copyWith(
          {String uid, String fileId, int avatarIndex, String fileName}) =>
      Avatar(
        uid: uid ?? this.uid,
        fileId: fileId ?? this.fileId,
        avatarIndex: avatarIndex ?? this.avatarIndex,
        fileName: fileName ?? this.fileName,
      );
  @override
  String toString() {
    return (StringBuffer('Avatar(')
          ..write('uid: $uid, ')
          ..write('fileId: $fileId, ')
          ..write('avatarIndex: $avatarIndex, ')
          ..write('fileName: $fileName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(uid.hashCode,
      $mrjc(fileId.hashCode, $mrjc(avatarIndex.hashCode, fileName.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Avatar &&
          other.uid == this.uid &&
          other.fileId == this.fileId &&
          other.avatarIndex == this.avatarIndex &&
          other.fileName == this.fileName);
}

class AvatarsCompanion extends UpdateCompanion<Avatar> {
  final Value<String> uid;
  final Value<String> fileId;
  final Value<int> avatarIndex;
  final Value<String> fileName;
  const AvatarsCompanion({
    this.uid = const Value.absent(),
    this.fileId = const Value.absent(),
    this.avatarIndex = const Value.absent(),
    this.fileName = const Value.absent(),
  });
  AvatarsCompanion.insert({
    @required String uid,
    @required String fileId,
    @required int avatarIndex,
    @required String fileName,
  })  : uid = Value(uid),
        fileId = Value(fileId),
        avatarIndex = Value(avatarIndex),
        fileName = Value(fileName);
  static Insertable<Avatar> custom({
    Expression<String> uid,
    Expression<String> fileId,
    Expression<int> avatarIndex,
    Expression<String> fileName,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (fileId != null) 'file_id': fileId,
      if (avatarIndex != null) 'avatar_index': avatarIndex,
      if (fileName != null) 'file_name': fileName,
    });
  }

  AvatarsCompanion copyWith(
      {Value<String> uid,
      Value<String> fileId,
      Value<int> avatarIndex,
      Value<String> fileName}) {
    return AvatarsCompanion(
      uid: uid ?? this.uid,
      fileId: fileId ?? this.fileId,
      avatarIndex: avatarIndex ?? this.avatarIndex,
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
    if (avatarIndex.present) {
      map['avatar_index'] = Variable<int>(avatarIndex.value);
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
          ..write('avatarIndex: $avatarIndex, ')
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

  final VerificationMeta _avatarIndexMeta =
      const VerificationMeta('avatarIndex');
  GeneratedIntColumn _avatarIndex;
  @override
  GeneratedIntColumn get avatarIndex =>
      _avatarIndex ??= _constructAvatarIndex();
  GeneratedIntColumn _constructAvatarIndex() {
    return GeneratedIntColumn(
      'avatar_index',
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
  List<GeneratedColumn> get $columns => [uid, fileId, avatarIndex, fileName];
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
    if (data.containsKey('avatar_index')) {
      context.handle(
          _avatarIndexMeta,
          avatarIndex.isAcceptableOrUnknown(
              data['avatar_index'], _avatarIndexMeta));
    } else if (isInserting) {
      context.missing(_avatarIndexMeta);
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
  Set<GeneratedColumn> get $primaryKey => {uid, avatarIndex};
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
  final String path;
  final String fileName;
  final String size;
  FileInfo(
      {@required this.uuid,
      @required this.path,
      @required this.fileName,
      @required this.size});
  factory FileInfo.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    return FileInfo(
      uuid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uuid']),
      path: stringType.mapFromDatabaseResponse(data['${effectivePrefix}path']),
      fileName: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}file_name']),
      size: stringType.mapFromDatabaseResponse(data['${effectivePrefix}size']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || uuid != null) {
      map['uuid'] = Variable<String>(uuid);
    }
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<String>(size);
    }
    return map;
  }

  FileInfosCompanion toCompanion(bool nullToAbsent) {
    return FileInfosCompanion(
      uuid: uuid == null && nullToAbsent ? const Value.absent() : Value(uuid),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      fileName: fileName == null && nullToAbsent
          ? const Value.absent()
          : Value(fileName),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
    );
  }

  factory FileInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return FileInfo(
      uuid: serializer.fromJson<String>(json['uuid']),
      path: serializer.fromJson<String>(json['path']),
      fileName: serializer.fromJson<String>(json['fileName']),
      size: serializer.fromJson<String>(json['size']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'path': serializer.toJson<String>(path),
      'fileName': serializer.toJson<String>(fileName),
      'size': serializer.toJson<String>(size),
    };
  }

  FileInfo copyWith({String uuid, String path, String fileName, String size}) =>
      FileInfo(
        uuid: uuid ?? this.uuid,
        path: path ?? this.path,
        fileName: fileName ?? this.fileName,
        size: size ?? this.size,
      );
  @override
  String toString() {
    return (StringBuffer('FileInfo(')
          ..write('uuid: $uuid, ')
          ..write('path: $path, ')
          ..write('fileName: $fileName, ')
          ..write('size: $size')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(uuid.hashCode,
      $mrjc(path.hashCode, $mrjc(fileName.hashCode, size.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is FileInfo &&
          other.uuid == this.uuid &&
          other.path == this.path &&
          other.fileName == this.fileName &&
          other.size == this.size);
}

class FileInfosCompanion extends UpdateCompanion<FileInfo> {
  final Value<String> uuid;
  final Value<String> path;
  final Value<String> fileName;
  final Value<String> size;
  const FileInfosCompanion({
    this.uuid = const Value.absent(),
    this.path = const Value.absent(),
    this.fileName = const Value.absent(),
    this.size = const Value.absent(),
  });
  FileInfosCompanion.insert({
    @required String uuid,
    @required String path,
    @required String fileName,
    @required String size,
  })  : uuid = Value(uuid),
        path = Value(path),
        fileName = Value(fileName),
        size = Value(size);
  static Insertable<FileInfo> custom({
    Expression<String> uuid,
    Expression<String> path,
    Expression<String> fileName,
    Expression<String> size,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (path != null) 'path': path,
      if (fileName != null) 'file_name': fileName,
      if (size != null) 'size': size,
    });
  }

  FileInfosCompanion copyWith(
      {Value<String> uuid,
      Value<String> path,
      Value<String> fileName,
      Value<String> size}) {
    return FileInfosCompanion(
      uuid: uuid ?? this.uuid,
      path: path ?? this.path,
      fileName: fileName ?? this.fileName,
      size: size ?? this.size,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileInfosCompanion(')
          ..write('uuid: $uuid, ')
          ..write('path: $path, ')
          ..write('fileName: $fileName, ')
          ..write('size: $size')
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

  final VerificationMeta _sizeMeta = const VerificationMeta('size');
  GeneratedTextColumn _size;
  @override
  GeneratedTextColumn get size => _size ??= _constructSize();
  GeneratedTextColumn _constructSize() {
    return GeneratedTextColumn(
      'size',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [uuid, path, fileName, size];
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
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path'], _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name'], _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size'], _sizeMeta));
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid, size};
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
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [messages, rooms, avatars, contacts, fileInfos, seens];
}
