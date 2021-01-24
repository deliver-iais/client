// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Message extends DataClass implements Insertable<Message> {
  final int dbId;
  final String packetId;
  final String roomId;
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
      @required this.packetId,
      @required this.roomId,
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
      packetId: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}packet_id']),
      roomId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
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
    if (!nullToAbsent || packetId != null) {
      map['packet_id'] = Variable<String>(packetId);
    }
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
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
      packetId: packetId == null && nullToAbsent
          ? const Value.absent()
          : Value(packetId),
      roomId:
          roomId == null && nullToAbsent ? const Value.absent() : Value(roomId),
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
      packetId: serializer.fromJson<String>(json['packetId']),
      roomId: serializer.fromJson<String>(json['roomId']),
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
      'packetId': serializer.toJson<String>(packetId),
      'roomId': serializer.toJson<String>(roomId),
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
          String packetId,
          String roomId,
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
        packetId: packetId ?? this.packetId,
        roomId: roomId ?? this.roomId,
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
          ..write('packetId: $packetId, ')
          ..write('roomId: $roomId, ')
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
          packetId.hashCode,
          $mrjc(
              roomId.hashCode,
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
          other.packetId == this.packetId &&
          other.roomId == this.roomId &&
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
  final Value<String> packetId;
  final Value<String> roomId;
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
    this.packetId = const Value.absent(),
    this.roomId = const Value.absent(),
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
    @required String packetId,
    @required String roomId,
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
  })  : packetId = Value(packetId),
        roomId = Value(roomId),
        time = Value(time),
        from = Value(from),
        to = Value(to),
        type = Value(type),
        json = Value(json);
  static Insertable<Message> custom({
    Expression<int> dbId,
    Expression<String> packetId,
    Expression<String> roomId,
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
      if (packetId != null) 'packet_id': packetId,
      if (roomId != null) 'room_id': roomId,
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
      Value<String> packetId,
      Value<String> roomId,
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
      packetId: packetId ?? this.packetId,
      roomId: roomId ?? this.roomId,
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
    if (packetId.present) {
      map['packet_id'] = Variable<String>(packetId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
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
          ..write('packetId: $packetId, ')
          ..write('roomId: $roomId, ')
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

  final VerificationMeta _packetIdMeta = const VerificationMeta('packetId');
  GeneratedTextColumn _packetId;
  @override
  GeneratedTextColumn get packetId => _packetId ??= _constructPacketId();
  GeneratedTextColumn _constructPacketId() {
    return GeneratedTextColumn(
      'packet_id',
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
        packetId,
        roomId,
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
    if (data.containsKey('packet_id')) {
      context.handle(_packetIdMeta,
          packetId.isAcceptableOrUnknown(data['packet_id'], _packetIdMeta));
    } else if (isInserting) {
      context.missing(_packetIdMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id'], _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
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
  final int lastMessageId;
  final bool mute;
  final int lastMessageDbId;
  Room(
      {@required this.roomId,
      this.mentioned,
      this.lastMessageId,
      @required this.mute,
      this.lastMessageDbId});
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
      lastMessageId: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}last_message_id']),
      mute: boolType.mapFromDatabaseResponse(data['${effectivePrefix}mute']),
      lastMessageDbId: intType.mapFromDatabaseResponse(
          data['${effectivePrefix}last_message_db_id']),
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
    if (!nullToAbsent || lastMessageId != null) {
      map['last_message_id'] = Variable<int>(lastMessageId);
    }
    if (!nullToAbsent || mute != null) {
      map['mute'] = Variable<bool>(mute);
    }
    if (!nullToAbsent || lastMessageDbId != null) {
      map['last_message_db_id'] = Variable<int>(lastMessageDbId);
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
      lastMessageId: lastMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageId),
      mute: mute == null && nullToAbsent ? const Value.absent() : Value(mute),
      lastMessageDbId: lastMessageDbId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageDbId),
    );
  }

  factory Room.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Room(
      roomId: serializer.fromJson<String>(json['roomId']),
      mentioned: serializer.fromJson<bool>(json['mentioned']),
      lastMessageId: serializer.fromJson<int>(json['lastMessageId']),
      mute: serializer.fromJson<bool>(json['mute']),
      lastMessageDbId: serializer.fromJson<int>(json['lastMessageDbId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roomId': serializer.toJson<String>(roomId),
      'mentioned': serializer.toJson<bool>(mentioned),
      'lastMessageId': serializer.toJson<int>(lastMessageId),
      'mute': serializer.toJson<bool>(mute),
      'lastMessageDbId': serializer.toJson<int>(lastMessageDbId),
    };
  }

  Room copyWith(
          {String roomId,
          bool mentioned,
          int lastMessageId,
          bool mute,
          int lastMessageDbId}) =>
      Room(
        roomId: roomId ?? this.roomId,
        mentioned: mentioned ?? this.mentioned,
        lastMessageId: lastMessageId ?? this.lastMessageId,
        mute: mute ?? this.mute,
        lastMessageDbId: lastMessageDbId ?? this.lastMessageDbId,
      );
  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('roomId: $roomId, ')
          ..write('mentioned: $mentioned, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('mute: $mute, ')
          ..write('lastMessageDbId: $lastMessageDbId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      roomId.hashCode,
      $mrjc(
          mentioned.hashCode,
          $mrjc(lastMessageId.hashCode,
              $mrjc(mute.hashCode, lastMessageDbId.hashCode)))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Room &&
          other.roomId == this.roomId &&
          other.mentioned == this.mentioned &&
          other.lastMessageId == this.lastMessageId &&
          other.mute == this.mute &&
          other.lastMessageDbId == this.lastMessageDbId);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<String> roomId;
  final Value<bool> mentioned;
  final Value<int> lastMessageId;
  final Value<bool> mute;
  final Value<int> lastMessageDbId;
  const RoomsCompanion({
    this.roomId = const Value.absent(),
    this.mentioned = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.mute = const Value.absent(),
    this.lastMessageDbId = const Value.absent(),
  });
  RoomsCompanion.insert({
    @required String roomId,
    this.mentioned = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.mute = const Value.absent(),
    this.lastMessageDbId = const Value.absent(),
  }) : roomId = Value(roomId);
  static Insertable<Room> custom({
    Expression<String> roomId,
    Expression<bool> mentioned,
    Expression<int> lastMessageId,
    Expression<bool> mute,
    Expression<int> lastMessageDbId,
  }) {
    return RawValuesInsertable({
      if (roomId != null) 'room_id': roomId,
      if (mentioned != null) 'mentioned': mentioned,
      if (lastMessageId != null) 'last_message_id': lastMessageId,
      if (mute != null) 'mute': mute,
      if (lastMessageDbId != null) 'last_message_db_id': lastMessageDbId,
    });
  }

  RoomsCompanion copyWith(
      {Value<String> roomId,
      Value<bool> mentioned,
      Value<int> lastMessageId,
      Value<bool> mute,
      Value<int> lastMessageDbId}) {
    return RoomsCompanion(
      roomId: roomId ?? this.roomId,
      mentioned: mentioned ?? this.mentioned,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      mute: mute ?? this.mute,
      lastMessageDbId: lastMessageDbId ?? this.lastMessageDbId,
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
    if (lastMessageId.present) {
      map['last_message_id'] = Variable<int>(lastMessageId.value);
    }
    if (mute.present) {
      map['mute'] = Variable<bool>(mute.value);
    }
    if (lastMessageDbId.present) {
      map['last_message_db_id'] = Variable<int>(lastMessageDbId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('roomId: $roomId, ')
          ..write('mentioned: $mentioned, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('mute: $mute, ')
          ..write('lastMessageDbId: $lastMessageDbId')
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

  final VerificationMeta _lastMessageIdMeta =
      const VerificationMeta('lastMessageId');
  GeneratedIntColumn _lastMessageId;
  @override
  GeneratedIntColumn get lastMessageId =>
      _lastMessageId ??= _constructLastMessageId();
  GeneratedIntColumn _constructLastMessageId() {
    return GeneratedIntColumn(
      'last_message_id',
      $tableName,
      true,
    );
  }

  final VerificationMeta _muteMeta = const VerificationMeta('mute');
  GeneratedBoolColumn _mute;
  @override
  GeneratedBoolColumn get mute => _mute ??= _constructMute();
  GeneratedBoolColumn _constructMute() {
    return GeneratedBoolColumn('mute', $tableName, false,
        defaultValue: Constant(false));
  }

  final VerificationMeta _lastMessageDbIdMeta =
      const VerificationMeta('lastMessageDbId');
  GeneratedIntColumn _lastMessageDbId;
  @override
  GeneratedIntColumn get lastMessageDbId =>
      _lastMessageDbId ??= _constructLastMessageDbId();
  GeneratedIntColumn _constructLastMessageDbId() {
    return GeneratedIntColumn('last_message_db_id', $tableName, true,
        $customConstraints: 'REFERENCES messages(db_id)');
  }

  @override
  List<GeneratedColumn> get $columns =>
      [roomId, mentioned, lastMessageId, mute, lastMessageDbId];
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
    if (data.containsKey('last_message_id')) {
      context.handle(
          _lastMessageIdMeta,
          lastMessageId.isAcceptableOrUnknown(
              data['last_message_id'], _lastMessageIdMeta));
    }
    if (data.containsKey('mute')) {
      context.handle(
          _muteMeta, mute.isAcceptableOrUnknown(data['mute'], _muteMeta));
    }
    if (data.containsKey('last_message_db_id')) {
      context.handle(
          _lastMessageDbIdMeta,
          lastMessageDbId.isAcceptableOrUnknown(
              data['last_message_db_id'], _lastMessageDbIdMeta));
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
  final int createdOn;
  final String fileId;
  final String fileName;
  Avatar(
      {@required this.uid,
      @required this.createdOn,
      @required this.fileId,
      @required this.fileName});
  factory Avatar.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    return Avatar(
      uid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uid']),
      createdOn:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}created_on']),
      fileId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}file_id']),
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
    if (!nullToAbsent || createdOn != null) {
      map['created_on'] = Variable<int>(createdOn);
    }
    if (!nullToAbsent || fileId != null) {
      map['file_id'] = Variable<String>(fileId);
    }
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    return map;
  }

  AvatarsCompanion toCompanion(bool nullToAbsent) {
    return AvatarsCompanion(
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
      createdOn: createdOn == null && nullToAbsent
          ? const Value.absent()
          : Value(createdOn),
      fileId:
          fileId == null && nullToAbsent ? const Value.absent() : Value(fileId),
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
      createdOn: serializer.fromJson<int>(json['createdOn']),
      fileId: serializer.fromJson<String>(json['fileId']),
      fileName: serializer.fromJson<String>(json['fileName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'createdOn': serializer.toJson<int>(createdOn),
      'fileId': serializer.toJson<String>(fileId),
      'fileName': serializer.toJson<String>(fileName),
    };
  }

  Avatar copyWith(
          {String uid, int createdOn, String fileId, String fileName}) =>
      Avatar(
        uid: uid ?? this.uid,
        createdOn: createdOn ?? this.createdOn,
        fileId: fileId ?? this.fileId,
        fileName: fileName ?? this.fileName,
      );
  @override
  String toString() {
    return (StringBuffer('Avatar(')
          ..write('uid: $uid, ')
          ..write('createdOn: $createdOn, ')
          ..write('fileId: $fileId, ')
          ..write('fileName: $fileName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(uid.hashCode,
      $mrjc(createdOn.hashCode, $mrjc(fileId.hashCode, fileName.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Avatar &&
          other.uid == this.uid &&
          other.createdOn == this.createdOn &&
          other.fileId == this.fileId &&
          other.fileName == this.fileName);
}

class AvatarsCompanion extends UpdateCompanion<Avatar> {
  final Value<String> uid;
  final Value<int> createdOn;
  final Value<String> fileId;
  final Value<String> fileName;
  const AvatarsCompanion({
    this.uid = const Value.absent(),
    this.createdOn = const Value.absent(),
    this.fileId = const Value.absent(),
    this.fileName = const Value.absent(),
  });
  AvatarsCompanion.insert({
    @required String uid,
    @required int createdOn,
    @required String fileId,
    @required String fileName,
  })  : uid = Value(uid),
        createdOn = Value(createdOn),
        fileId = Value(fileId),
        fileName = Value(fileName);
  static Insertable<Avatar> custom({
    Expression<String> uid,
    Expression<int> createdOn,
    Expression<String> fileId,
    Expression<String> fileName,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (createdOn != null) 'created_on': createdOn,
      if (fileId != null) 'file_id': fileId,
      if (fileName != null) 'file_name': fileName,
    });
  }

  AvatarsCompanion copyWith(
      {Value<String> uid,
      Value<int> createdOn,
      Value<String> fileId,
      Value<String> fileName}) {
    return AvatarsCompanion(
      uid: uid ?? this.uid,
      createdOn: createdOn ?? this.createdOn,
      fileId: fileId ?? this.fileId,
      fileName: fileName ?? this.fileName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (createdOn.present) {
      map['created_on'] = Variable<int>(createdOn.value);
    }
    if (fileId.present) {
      map['file_id'] = Variable<String>(fileId.value);
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
          ..write('createdOn: $createdOn, ')
          ..write('fileId: $fileId, ')
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
  List<GeneratedColumn> get $columns => [uid, createdOn, fileId, fileName];
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
    if (data.containsKey('created_on')) {
      context.handle(_createdOnMeta,
          createdOn.isAcceptableOrUnknown(data['created_on'], _createdOnMeta));
    } else if (isInserting) {
      context.missing(_createdOnMeta);
    }
    if (data.containsKey('file_id')) {
      context.handle(_fileIdMeta,
          fileId.isAcceptableOrUnknown(data['file_id'], _fileIdMeta));
    } else if (isInserting) {
      context.missing(_fileIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {uid, createdOn};
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
  final String username;
  final String uid;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final bool isMute;
  final bool isBlock;
  Contact(
      {this.username,
      this.uid,
      @required this.phoneNumber,
      this.firstName,
      this.lastName,
      @required this.isMute,
      @required this.isBlock});
  factory Contact.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return Contact(
      username: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}username']),
      uid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uid']),
      phoneNumber: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}phone_number']),
      firstName: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}first_name']),
      lastName: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}last_name']),
      isMute:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}is_mute']),
      isBlock:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}is_block']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || uid != null) {
      map['uid'] = Variable<String>(uid);
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
    if (!nullToAbsent || isMute != null) {
      map['is_mute'] = Variable<bool>(isMute);
    }
    if (!nullToAbsent || isBlock != null) {
      map['is_block'] = Variable<bool>(isBlock);
    }
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      isMute:
          isMute == null && nullToAbsent ? const Value.absent() : Value(isMute),
      isBlock: isBlock == null && nullToAbsent
          ? const Value.absent()
          : Value(isBlock),
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Contact(
      username: serializer.fromJson<String>(json['username']),
      uid: serializer.fromJson<String>(json['uid']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      isMute: serializer.fromJson<bool>(json['isMute']),
      isBlock: serializer.fromJson<bool>(json['isBlock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'username': serializer.toJson<String>(username),
      'uid': serializer.toJson<String>(uid),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'isMute': serializer.toJson<bool>(isMute),
      'isBlock': serializer.toJson<bool>(isBlock),
    };
  }

  Contact copyWith(
          {String username,
          String uid,
          String phoneNumber,
          String firstName,
          String lastName,
          bool isMute,
          bool isBlock}) =>
      Contact(
        username: username ?? this.username,
        uid: uid ?? this.uid,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        isMute: isMute ?? this.isMute,
        isBlock: isBlock ?? this.isBlock,
      );
  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('username: $username, ')
          ..write('uid: $uid, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('isMute: $isMute, ')
          ..write('isBlock: $isBlock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      username.hashCode,
      $mrjc(
          uid.hashCode,
          $mrjc(
              phoneNumber.hashCode,
              $mrjc(
                  firstName.hashCode,
                  $mrjc(lastName.hashCode,
                      $mrjc(isMute.hashCode, isBlock.hashCode)))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Contact &&
          other.username == this.username &&
          other.uid == this.uid &&
          other.phoneNumber == this.phoneNumber &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.isMute == this.isMute &&
          other.isBlock == this.isBlock);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<String> username;
  final Value<String> uid;
  final Value<String> phoneNumber;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<bool> isMute;
  final Value<bool> isBlock;
  const ContactsCompanion({
    this.username = const Value.absent(),
    this.uid = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.isMute = const Value.absent(),
    this.isBlock = const Value.absent(),
  });
  ContactsCompanion.insert({
    this.username = const Value.absent(),
    this.uid = const Value.absent(),
    @required String phoneNumber,
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    @required bool isMute,
    @required bool isBlock,
  })  : phoneNumber = Value(phoneNumber),
        isMute = Value(isMute),
        isBlock = Value(isBlock);
  static Insertable<Contact> custom({
    Expression<String> username,
    Expression<String> uid,
    Expression<String> phoneNumber,
    Expression<String> firstName,
    Expression<String> lastName,
    Expression<bool> isMute,
    Expression<bool> isBlock,
  }) {
    return RawValuesInsertable({
      if (username != null) 'username': username,
      if (uid != null) 'uid': uid,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (isMute != null) 'is_mute': isMute,
      if (isBlock != null) 'is_block': isBlock,
    });
  }

  ContactsCompanion copyWith(
      {Value<String> username,
      Value<String> uid,
      Value<String> phoneNumber,
      Value<String> firstName,
      Value<String> lastName,
      Value<bool> isMute,
      Value<bool> isBlock}) {
    return ContactsCompanion(
      username: username ?? this.username,
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isMute: isMute ?? this.isMute,
      isBlock: isBlock ?? this.isBlock,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
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
    if (isMute.present) {
      map['is_mute'] = Variable<bool>(isMute.value);
    }
    if (isBlock.present) {
      map['is_block'] = Variable<bool>(isBlock.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('username: $username, ')
          ..write('uid: $uid, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('isMute: $isMute, ')
          ..write('isBlock: $isBlock')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  final GeneratedDatabase _db;
  final String _alias;
  $ContactsTable(this._db, [this._alias]);
  final VerificationMeta _usernameMeta = const VerificationMeta('username');
  GeneratedTextColumn _username;
  @override
  GeneratedTextColumn get username => _username ??= _constructUsername();
  GeneratedTextColumn _constructUsername() {
    return GeneratedTextColumn(
      'username',
      $tableName,
      true,
    );
  }

  final VerificationMeta _uidMeta = const VerificationMeta('uid');
  GeneratedTextColumn _uid;
  @override
  GeneratedTextColumn get uid => _uid ??= _constructUid();
  GeneratedTextColumn _constructUid() {
    return GeneratedTextColumn(
      'uid',
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
      true,
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
      true,
    );
  }

  final VerificationMeta _isMuteMeta = const VerificationMeta('isMute');
  GeneratedBoolColumn _isMute;
  @override
  GeneratedBoolColumn get isMute => _isMute ??= _constructIsMute();
  GeneratedBoolColumn _constructIsMute() {
    return GeneratedBoolColumn(
      'is_mute',
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

  @override
  List<GeneratedColumn> get $columns =>
      [username, uid, phoneNumber, firstName, lastName, isMute, isBlock];
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
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username'], _usernameMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid'], _uidMeta));
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
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name'], _lastNameMeta));
    }
    if (data.containsKey('is_mute')) {
      context.handle(_isMuteMeta,
          isMute.isAcceptableOrUnknown(data['is_mute'], _isMuteMeta));
    } else if (isInserting) {
      context.missing(_isMuteMeta);
    }
    if (data.containsKey('is_block')) {
      context.handle(_isBlockMeta,
          isBlock.isAcceptableOrUnknown(data['is_block'], _isBlockMeta));
    } else if (isInserting) {
      context.missing(_isBlockMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {phoneNumber};
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
  final String name;
  final String path;
  final String compressionSize;
  FileInfo(
      {@required this.uuid,
      @required this.name,
      @required this.path,
      @required this.compressionSize});
  factory FileInfo.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    return FileInfo(
      uuid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uuid']),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
      path: stringType.mapFromDatabaseResponse(data['${effectivePrefix}path']),
      compressionSize: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}compression_size']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || uuid != null) {
      map['uuid'] = Variable<String>(uuid);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    if (!nullToAbsent || compressionSize != null) {
      map['compression_size'] = Variable<String>(compressionSize);
    }
    return map;
  }

  FileInfosCompanion toCompanion(bool nullToAbsent) {
    return FileInfosCompanion(
      uuid: uuid == null && nullToAbsent ? const Value.absent() : Value(uuid),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      compressionSize: compressionSize == null && nullToAbsent
          ? const Value.absent()
          : Value(compressionSize),
    );
  }

  factory FileInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return FileInfo(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<String>(json['path']),
      compressionSize: serializer.fromJson<String>(json['compressionSize']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<String>(path),
      'compressionSize': serializer.toJson<String>(compressionSize),
    };
  }

  FileInfo copyWith(
          {String uuid, String name, String path, String compressionSize}) =>
      FileInfo(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        path: path ?? this.path,
        compressionSize: compressionSize ?? this.compressionSize,
      );
  @override
  String toString() {
    return (StringBuffer('FileInfo(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('compressionSize: $compressionSize')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(uuid.hashCode,
      $mrjc(name.hashCode, $mrjc(path.hashCode, compressionSize.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is FileInfo &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.path == this.path &&
          other.compressionSize == this.compressionSize);
}

class FileInfosCompanion extends UpdateCompanion<FileInfo> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String> path;
  final Value<String> compressionSize;
  const FileInfosCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.compressionSize = const Value.absent(),
  });
  FileInfosCompanion.insert({
    @required String uuid,
    @required String name,
    @required String path,
    @required String compressionSize,
  })  : uuid = Value(uuid),
        name = Value(name),
        path = Value(path),
        compressionSize = Value(compressionSize);
  static Insertable<FileInfo> custom({
    Expression<String> uuid,
    Expression<String> name,
    Expression<String> path,
    Expression<String> compressionSize,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (compressionSize != null) 'compression_size': compressionSize,
    });
  }

  FileInfosCompanion copyWith(
      {Value<String> uuid,
      Value<String> name,
      Value<String> path,
      Value<String> compressionSize}) {
    return FileInfosCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      path: path ?? this.path,
      compressionSize: compressionSize ?? this.compressionSize,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (compressionSize.present) {
      map['compression_size'] = Variable<String>(compressionSize.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileInfosCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('compressionSize: $compressionSize')
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

  @override
  List<GeneratedColumn> get $columns => [uuid, name, path, compressionSize];
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name'], _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path'], _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('compression_size')) {
      context.handle(
          _compressionSizeMeta,
          compressionSize.isAcceptableOrUnknown(
              data['compression_size'], _compressionSizeMeta));
    } else if (isInserting) {
      context.missing(_compressionSizeMeta);
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
  final int createdOn;
  final String fileId;
  final String fileName;
  final int lastUpdate;
  LastAvatar(
      {@required this.uid,
      this.createdOn,
      this.fileId,
      this.fileName,
      @required this.lastUpdate});
  factory LastAvatar.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    return LastAvatar(
      uid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uid']),
      createdOn:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}created_on']),
      fileId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}file_id']),
      fileName: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}file_name']),
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
    if (!nullToAbsent || createdOn != null) {
      map['created_on'] = Variable<int>(createdOn);
    }
    if (!nullToAbsent || fileId != null) {
      map['file_id'] = Variable<String>(fileId);
    }
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    if (!nullToAbsent || lastUpdate != null) {
      map['last_update'] = Variable<int>(lastUpdate);
    }
    return map;
  }

  LastAvatarsCompanion toCompanion(bool nullToAbsent) {
    return LastAvatarsCompanion(
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
      createdOn: createdOn == null && nullToAbsent
          ? const Value.absent()
          : Value(createdOn),
      fileId:
          fileId == null && nullToAbsent ? const Value.absent() : Value(fileId),
      fileName: fileName == null && nullToAbsent
          ? const Value.absent()
          : Value(fileName),
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
      createdOn: serializer.fromJson<int>(json['createdOn']),
      fileId: serializer.fromJson<String>(json['fileId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      lastUpdate: serializer.fromJson<int>(json['lastUpdate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'createdOn': serializer.toJson<int>(createdOn),
      'fileId': serializer.toJson<String>(fileId),
      'fileName': serializer.toJson<String>(fileName),
      'lastUpdate': serializer.toJson<int>(lastUpdate),
    };
  }

  LastAvatar copyWith(
          {String uid,
          int createdOn,
          String fileId,
          String fileName,
          int lastUpdate}) =>
      LastAvatar(
        uid: uid ?? this.uid,
        createdOn: createdOn ?? this.createdOn,
        fileId: fileId ?? this.fileId,
        fileName: fileName ?? this.fileName,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );
  @override
  String toString() {
    return (StringBuffer('LastAvatar(')
          ..write('uid: $uid, ')
          ..write('createdOn: $createdOn, ')
          ..write('fileId: $fileId, ')
          ..write('fileName: $fileName, ')
          ..write('lastUpdate: $lastUpdate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      uid.hashCode,
      $mrjc(
          createdOn.hashCode,
          $mrjc(fileId.hashCode,
              $mrjc(fileName.hashCode, lastUpdate.hashCode)))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is LastAvatar &&
          other.uid == this.uid &&
          other.createdOn == this.createdOn &&
          other.fileId == this.fileId &&
          other.fileName == this.fileName &&
          other.lastUpdate == this.lastUpdate);
}

class LastAvatarsCompanion extends UpdateCompanion<LastAvatar> {
  final Value<String> uid;
  final Value<int> createdOn;
  final Value<String> fileId;
  final Value<String> fileName;
  final Value<int> lastUpdate;
  const LastAvatarsCompanion({
    this.uid = const Value.absent(),
    this.createdOn = const Value.absent(),
    this.fileId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.lastUpdate = const Value.absent(),
  });
  LastAvatarsCompanion.insert({
    @required String uid,
    this.createdOn = const Value.absent(),
    this.fileId = const Value.absent(),
    this.fileName = const Value.absent(),
    @required int lastUpdate,
  })  : uid = Value(uid),
        lastUpdate = Value(lastUpdate);
  static Insertable<LastAvatar> custom({
    Expression<String> uid,
    Expression<int> createdOn,
    Expression<String> fileId,
    Expression<String> fileName,
    Expression<int> lastUpdate,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (createdOn != null) 'created_on': createdOn,
      if (fileId != null) 'file_id': fileId,
      if (fileName != null) 'file_name': fileName,
      if (lastUpdate != null) 'last_update': lastUpdate,
    });
  }

  LastAvatarsCompanion copyWith(
      {Value<String> uid,
      Value<int> createdOn,
      Value<String> fileId,
      Value<String> fileName,
      Value<int> lastUpdate}) {
    return LastAvatarsCompanion(
      uid: uid ?? this.uid,
      createdOn: createdOn ?? this.createdOn,
      fileId: fileId ?? this.fileId,
      fileName: fileName ?? this.fileName,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (createdOn.present) {
      map['created_on'] = Variable<int>(createdOn.value);
    }
    if (fileId.present) {
      map['file_id'] = Variable<String>(fileId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
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
          ..write('createdOn: $createdOn, ')
          ..write('fileId: $fileId, ')
          ..write('fileName: $fileName, ')
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

  final VerificationMeta _createdOnMeta = const VerificationMeta('createdOn');
  GeneratedIntColumn _createdOn;
  @override
  GeneratedIntColumn get createdOn => _createdOn ??= _constructCreatedOn();
  GeneratedIntColumn _constructCreatedOn() {
    return GeneratedIntColumn(
      'created_on',
      $tableName,
      true,
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
      true,
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
      true,
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
  List<GeneratedColumn> get $columns =>
      [uid, createdOn, fileId, fileName, lastUpdate];
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
    if (data.containsKey('created_on')) {
      context.handle(_createdOnMeta,
          createdOn.isAcceptableOrUnknown(data['created_on'], _createdOnMeta));
    }
    if (data.containsKey('file_id')) {
      context.handle(_fileIdMeta,
          fileId.isAcceptableOrUnknown(data['file_id'], _fileIdMeta));
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name'], _fileNameMeta));
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
  final int messageDbId;
  final String messagePacketId;
  final String roomId;
  final int remainingRetries;
  final SendingStatus status;
  PendingMessage(
      {@required this.messageDbId,
      @required this.messagePacketId,
      @required this.roomId,
      @required this.remainingRetries,
      @required this.status});
  factory PendingMessage.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return PendingMessage(
      messageDbId: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}message_db_id']),
      messagePacketId: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}message_packet_id']),
      roomId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      remainingRetries: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}remaining_retries']),
      status: $PendingMessagesTable.$converter0.mapToDart(
          intType.mapFromDatabaseResponse(data['${effectivePrefix}status'])),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || messageDbId != null) {
      map['message_db_id'] = Variable<int>(messageDbId);
    }
    if (!nullToAbsent || messagePacketId != null) {
      map['message_packet_id'] = Variable<String>(messagePacketId);
    }
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    if (!nullToAbsent || remainingRetries != null) {
      map['remaining_retries'] = Variable<int>(remainingRetries);
    }
    if (!nullToAbsent || status != null) {
      final converter = $PendingMessagesTable.$converter0;
      map['status'] = Variable<int>(converter.mapToSql(status));
    }
    return map;
  }

  PendingMessagesCompanion toCompanion(bool nullToAbsent) {
    return PendingMessagesCompanion(
      messageDbId: messageDbId == null && nullToAbsent
          ? const Value.absent()
          : Value(messageDbId),
      messagePacketId: messagePacketId == null && nullToAbsent
          ? const Value.absent()
          : Value(messagePacketId),
      roomId:
          roomId == null && nullToAbsent ? const Value.absent() : Value(roomId),
      remainingRetries: remainingRetries == null && nullToAbsent
          ? const Value.absent()
          : Value(remainingRetries),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
    );
  }

  factory PendingMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return PendingMessage(
      messageDbId: serializer.fromJson<int>(json['messageDbId']),
      messagePacketId: serializer.fromJson<String>(json['messagePacketId']),
      roomId: serializer.fromJson<String>(json['roomId']),
      remainingRetries: serializer.fromJson<int>(json['remainingRetries']),
      status: serializer.fromJson<SendingStatus>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageDbId': serializer.toJson<int>(messageDbId),
      'messagePacketId': serializer.toJson<String>(messagePacketId),
      'roomId': serializer.toJson<String>(roomId),
      'remainingRetries': serializer.toJson<int>(remainingRetries),
      'status': serializer.toJson<SendingStatus>(status),
    };
  }

  PendingMessage copyWith(
          {int messageDbId,
          String messagePacketId,
          String roomId,
          int remainingRetries,
          SendingStatus status}) =>
      PendingMessage(
        messageDbId: messageDbId ?? this.messageDbId,
        messagePacketId: messagePacketId ?? this.messagePacketId,
        roomId: roomId ?? this.roomId,
        remainingRetries: remainingRetries ?? this.remainingRetries,
        status: status ?? this.status,
      );
  @override
  String toString() {
    return (StringBuffer('PendingMessage(')
          ..write('messageDbId: $messageDbId, ')
          ..write('messagePacketId: $messagePacketId, ')
          ..write('roomId: $roomId, ')
          ..write('remainingRetries: $remainingRetries, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      messageDbId.hashCode,
      $mrjc(
          messagePacketId.hashCode,
          $mrjc(roomId.hashCode,
              $mrjc(remainingRetries.hashCode, status.hashCode)))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is PendingMessage &&
          other.messageDbId == this.messageDbId &&
          other.messagePacketId == this.messagePacketId &&
          other.roomId == this.roomId &&
          other.remainingRetries == this.remainingRetries &&
          other.status == this.status);
}

class PendingMessagesCompanion extends UpdateCompanion<PendingMessage> {
  final Value<int> messageDbId;
  final Value<String> messagePacketId;
  final Value<String> roomId;
  final Value<int> remainingRetries;
  final Value<SendingStatus> status;
  const PendingMessagesCompanion({
    this.messageDbId = const Value.absent(),
    this.messagePacketId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.remainingRetries = const Value.absent(),
    this.status = const Value.absent(),
  });
  PendingMessagesCompanion.insert({
    this.messageDbId = const Value.absent(),
    @required String messagePacketId,
    @required String roomId,
    @required int remainingRetries,
    @required SendingStatus status,
  })  : messagePacketId = Value(messagePacketId),
        roomId = Value(roomId),
        remainingRetries = Value(remainingRetries),
        status = Value(status);
  static Insertable<PendingMessage> custom({
    Expression<int> messageDbId,
    Expression<String> messagePacketId,
    Expression<String> roomId,
    Expression<int> remainingRetries,
    Expression<int> status,
  }) {
    return RawValuesInsertable({
      if (messageDbId != null) 'message_db_id': messageDbId,
      if (messagePacketId != null) 'message_packet_id': messagePacketId,
      if (roomId != null) 'room_id': roomId,
      if (remainingRetries != null) 'remaining_retries': remainingRetries,
      if (status != null) 'status': status,
    });
  }

  PendingMessagesCompanion copyWith(
      {Value<int> messageDbId,
      Value<String> messagePacketId,
      Value<String> roomId,
      Value<int> remainingRetries,
      Value<SendingStatus> status}) {
    return PendingMessagesCompanion(
      messageDbId: messageDbId ?? this.messageDbId,
      messagePacketId: messagePacketId ?? this.messagePacketId,
      roomId: roomId ?? this.roomId,
      remainingRetries: remainingRetries ?? this.remainingRetries,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageDbId.present) {
      map['message_db_id'] = Variable<int>(messageDbId.value);
    }
    if (messagePacketId.present) {
      map['message_packet_id'] = Variable<String>(messagePacketId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (remainingRetries.present) {
      map['remaining_retries'] = Variable<int>(remainingRetries.value);
    }
    if (status.present) {
      final converter = $PendingMessagesTable.$converter0;
      map['status'] = Variable<int>(converter.mapToSql(status.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingMessagesCompanion(')
          ..write('messageDbId: $messageDbId, ')
          ..write('messagePacketId: $messagePacketId, ')
          ..write('roomId: $roomId, ')
          ..write('remainingRetries: $remainingRetries, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $PendingMessagesTable extends PendingMessages
    with TableInfo<$PendingMessagesTable, PendingMessage> {
  final GeneratedDatabase _db;
  final String _alias;
  $PendingMessagesTable(this._db, [this._alias]);
  final VerificationMeta _messageDbIdMeta =
      const VerificationMeta('messageDbId');
  GeneratedIntColumn _messageDbId;
  @override
  GeneratedIntColumn get messageDbId =>
      _messageDbId ??= _constructMessageDbId();
  GeneratedIntColumn _constructMessageDbId() {
    return GeneratedIntColumn('message_db_id', $tableName, false,
        $customConstraints: 'REFERENCES messages(db_id)');
  }

  final VerificationMeta _messagePacketIdMeta =
      const VerificationMeta('messagePacketId');
  GeneratedTextColumn _messagePacketId;
  @override
  GeneratedTextColumn get messagePacketId =>
      _messagePacketId ??= _constructMessagePacketId();
  GeneratedTextColumn _constructMessagePacketId() {
    return GeneratedTextColumn(
      'message_packet_id',
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

  final VerificationMeta _remainingRetriesMeta =
      const VerificationMeta('remainingRetries');
  GeneratedIntColumn _remainingRetries;
  @override
  GeneratedIntColumn get remainingRetries =>
      _remainingRetries ??= _constructRemainingRetries();
  GeneratedIntColumn _constructRemainingRetries() {
    return GeneratedIntColumn(
      'remaining_retries',
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

  @override
  List<GeneratedColumn> get $columns =>
      [messageDbId, messagePacketId, roomId, remainingRetries, status];
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
    if (data.containsKey('message_db_id')) {
      context.handle(
          _messageDbIdMeta,
          messageDbId.isAcceptableOrUnknown(
              data['message_db_id'], _messageDbIdMeta));
    }
    if (data.containsKey('message_packet_id')) {
      context.handle(
          _messagePacketIdMeta,
          messagePacketId.isAcceptableOrUnknown(
              data['message_packet_id'], _messagePacketIdMeta));
    } else if (isInserting) {
      context.missing(_messagePacketIdMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id'], _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('remaining_retries')) {
      context.handle(
          _remainingRetriesMeta,
          remainingRetries.isAcceptableOrUnknown(
              data['remaining_retries'], _remainingRetriesMeta));
    } else if (isInserting) {
      context.missing(_remainingRetriesMeta);
    }
    context.handle(_statusMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageDbId};
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
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return Media(
      createdOn:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}created_on']),
      createdBy: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}created_by']),
      messageId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}message_id']),
      type: $MediasTable.$converter0.mapToDart(
          intType.mapFromDatabaseResponse(data['${effectivePrefix}type'])),
      roomId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      json: stringType.mapFromDatabaseResponse(data['${effectivePrefix}json']),
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
  bool operator ==(dynamic other) =>
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
    Expression<int> type,
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
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Media.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $MediasTable createAlias(String alias) {
    return $MediasTable(_db, alias);
  }

  static TypeConverter<MediaType, int> $converter0 =
      const EnumIndexConverter<MediaType>(MediaType.values);
}

class SharedPreference extends DataClass
    implements Insertable<SharedPreference> {
  final String key;
  final String value;
  SharedPreference({@required this.key, @required this.value});
  factory SharedPreference.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    return SharedPreference(
      key: stringType.mapFromDatabaseResponse(data['${effectivePrefix}key']),
      value:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}value']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || key != null) {
      map['key'] = Variable<String>(key);
    }
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SharedPreferencesCompanion toCompanion(bool nullToAbsent) {
    return SharedPreferencesCompanion(
      key: key == null && nullToAbsent ? const Value.absent() : Value(key),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
    );
  }

  factory SharedPreference.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return SharedPreference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SharedPreference copyWith({String key, String value}) => SharedPreference(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('SharedPreference(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(key.hashCode, value.hashCode));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is SharedPreference &&
          other.key == this.key &&
          other.value == this.value);
}

class SharedPreferencesCompanion extends UpdateCompanion<SharedPreference> {
  final Value<String> key;
  final Value<String> value;
  const SharedPreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
  });
  SharedPreferencesCompanion.insert({
    @required String key,
    @required String value,
  })  : key = Value(key),
        value = Value(value);
  static Insertable<SharedPreference> custom({
    Expression<String> key,
    Expression<String> value,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
    });
  }

  SharedPreferencesCompanion copyWith(
      {Value<String> key, Value<String> value}) {
    return SharedPreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SharedPreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $SharedPreferencesTable extends SharedPreferences
    with TableInfo<$SharedPreferencesTable, SharedPreference> {
  final GeneratedDatabase _db;
  final String _alias;
  $SharedPreferencesTable(this._db, [this._alias]);
  final VerificationMeta _keyMeta = const VerificationMeta('key');
  GeneratedTextColumn _key;
  @override
  GeneratedTextColumn get key => _key ??= _constructKey();
  GeneratedTextColumn _constructKey() {
    return GeneratedTextColumn(
      'key',
      $tableName,
      false,
    );
  }

  final VerificationMeta _valueMeta = const VerificationMeta('value');
  GeneratedTextColumn _value;
  @override
  GeneratedTextColumn get value => _value ??= _constructValue();
  GeneratedTextColumn _constructValue() {
    return GeneratedTextColumn(
      'value',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  $SharedPreferencesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'shared_preferences';
  @override
  final String actualTableName = 'shared_preferences';
  @override
  VerificationContext validateIntegrity(Insertable<SharedPreference> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key'], _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value'], _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SharedPreference map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return SharedPreference.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $SharedPreferencesTable createAlias(String alias) {
    return $SharedPreferencesTable(_db, alias);
  }
}

class Member extends DataClass implements Insertable<Member> {
  final String memberUid;
  final String mucUid;
  final MucRole role;
  final String name;
  final String username;
  Member(
      {@required this.memberUid,
      @required this.mucUid,
      @required this.role,
      this.name,
      this.username});
  factory Member.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    return Member(
      memberUid: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}member_uid']),
      mucUid:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}muc_uid']),
      role: $MembersTable.$converter0.mapToDart(
          intType.mapFromDatabaseResponse(data['${effectivePrefix}role'])),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
      username: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}username']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || memberUid != null) {
      map['member_uid'] = Variable<String>(memberUid);
    }
    if (!nullToAbsent || mucUid != null) {
      map['muc_uid'] = Variable<String>(mucUid);
    }
    if (!nullToAbsent || role != null) {
      final converter = $MembersTable.$converter0;
      map['role'] = Variable<int>(converter.mapToSql(role));
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      memberUid: memberUid == null && nullToAbsent
          ? const Value.absent()
          : Value(memberUid),
      mucUid:
          mucUid == null && nullToAbsent ? const Value.absent() : Value(mucUid),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
    );
  }

  factory Member.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Member(
      memberUid: serializer.fromJson<String>(json['memberUid']),
      mucUid: serializer.fromJson<String>(json['mucUid']),
      role: serializer.fromJson<MucRole>(json['role']),
      name: serializer.fromJson<String>(json['name']),
      username: serializer.fromJson<String>(json['username']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'memberUid': serializer.toJson<String>(memberUid),
      'mucUid': serializer.toJson<String>(mucUid),
      'role': serializer.toJson<MucRole>(role),
      'name': serializer.toJson<String>(name),
      'username': serializer.toJson<String>(username),
    };
  }

  Member copyWith(
          {String memberUid,
          String mucUid,
          MucRole role,
          String name,
          String username}) =>
      Member(
        memberUid: memberUid ?? this.memberUid,
        mucUid: mucUid ?? this.mucUid,
        role: role ?? this.role,
        name: name ?? this.name,
        username: username ?? this.username,
      );
  @override
  String toString() {
    return (StringBuffer('Member(')
          ..write('memberUid: $memberUid, ')
          ..write('mucUid: $mucUid, ')
          ..write('role: $role, ')
          ..write('name: $name, ')
          ..write('username: $username')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      memberUid.hashCode,
      $mrjc(mucUid.hashCode,
          $mrjc(role.hashCode, $mrjc(name.hashCode, username.hashCode)))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Member &&
          other.memberUid == this.memberUid &&
          other.mucUid == this.mucUid &&
          other.role == this.role &&
          other.name == this.name &&
          other.username == this.username);
}

class MembersCompanion extends UpdateCompanion<Member> {
  final Value<String> memberUid;
  final Value<String> mucUid;
  final Value<MucRole> role;
  final Value<String> name;
  final Value<String> username;
  const MembersCompanion({
    this.memberUid = const Value.absent(),
    this.mucUid = const Value.absent(),
    this.role = const Value.absent(),
    this.name = const Value.absent(),
    this.username = const Value.absent(),
  });
  MembersCompanion.insert({
    @required String memberUid,
    @required String mucUid,
    @required MucRole role,
    this.name = const Value.absent(),
    this.username = const Value.absent(),
  })  : memberUid = Value(memberUid),
        mucUid = Value(mucUid),
        role = Value(role);
  static Insertable<Member> custom({
    Expression<String> memberUid,
    Expression<String> mucUid,
    Expression<int> role,
    Expression<String> name,
    Expression<String> username,
  }) {
    return RawValuesInsertable({
      if (memberUid != null) 'member_uid': memberUid,
      if (mucUid != null) 'muc_uid': mucUid,
      if (role != null) 'role': role,
      if (name != null) 'name': name,
      if (username != null) 'username': username,
    });
  }

  MembersCompanion copyWith(
      {Value<String> memberUid,
      Value<String> mucUid,
      Value<MucRole> role,
      Value<String> name,
      Value<String> username}) {
    return MembersCompanion(
      memberUid: memberUid ?? this.memberUid,
      mucUid: mucUid ?? this.mucUid,
      role: role ?? this.role,
      name: name ?? this.name,
      username: username ?? this.username,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (memberUid.present) {
      map['member_uid'] = Variable<String>(memberUid.value);
    }
    if (mucUid.present) {
      map['muc_uid'] = Variable<String>(mucUid.value);
    }
    if (role.present) {
      final converter = $MembersTable.$converter0;
      map['role'] = Variable<int>(converter.mapToSql(role.value));
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('memberUid: $memberUid, ')
          ..write('mucUid: $mucUid, ')
          ..write('role: $role, ')
          ..write('name: $name, ')
          ..write('username: $username')
          ..write(')'))
        .toString();
  }
}

class $MembersTable extends Members with TableInfo<$MembersTable, Member> {
  final GeneratedDatabase _db;
  final String _alias;
  $MembersTable(this._db, [this._alias]);
  final VerificationMeta _memberUidMeta = const VerificationMeta('memberUid');
  GeneratedTextColumn _memberUid;
  @override
  GeneratedTextColumn get memberUid => _memberUid ??= _constructMemberUid();
  GeneratedTextColumn _constructMemberUid() {
    return GeneratedTextColumn(
      'member_uid',
      $tableName,
      false,
    );
  }

  final VerificationMeta _mucUidMeta = const VerificationMeta('mucUid');
  GeneratedTextColumn _mucUid;
  @override
  GeneratedTextColumn get mucUid => _mucUid ??= _constructMucUid();
  GeneratedTextColumn _constructMucUid() {
    return GeneratedTextColumn(
      'muc_uid',
      $tableName,
      false,
    );
  }

  final VerificationMeta _roleMeta = const VerificationMeta('role');
  GeneratedIntColumn _role;
  @override
  GeneratedIntColumn get role => _role ??= _constructRole();
  GeneratedIntColumn _constructRole() {
    return GeneratedIntColumn(
      'role',
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
      true,
    );
  }

  final VerificationMeta _usernameMeta = const VerificationMeta('username');
  GeneratedTextColumn _username;
  @override
  GeneratedTextColumn get username => _username ??= _constructUsername();
  GeneratedTextColumn _constructUsername() {
    return GeneratedTextColumn(
      'username',
      $tableName,
      true,
    );
  }

  @override
  List<GeneratedColumn> get $columns =>
      [memberUid, mucUid, role, name, username];
  @override
  $MembersTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'members';
  @override
  final String actualTableName = 'members';
  @override
  VerificationContext validateIntegrity(Insertable<Member> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('member_uid')) {
      context.handle(_memberUidMeta,
          memberUid.isAcceptableOrUnknown(data['member_uid'], _memberUidMeta));
    } else if (isInserting) {
      context.missing(_memberUidMeta);
    }
    if (data.containsKey('muc_uid')) {
      context.handle(_mucUidMeta,
          mucUid.isAcceptableOrUnknown(data['muc_uid'], _mucUidMeta));
    } else if (isInserting) {
      context.missing(_mucUidMeta);
    }
    context.handle(_roleMeta, const VerificationResult.success());
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name'], _nameMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username'], _usernameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {memberUid, mucUid};
  @override
  Member map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Member.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(_db, alias);
  }

  static TypeConverter<MucRole, int> $converter0 =
      const EnumIndexConverter<MucRole>(MucRole.values);
}

class Muc extends DataClass implements Insertable<Muc> {
  final String uid;
  final String name;
  final String info;
  final int members;
  Muc(
      {@required this.uid,
      @required this.name,
      this.info,
      @required this.members});
  factory Muc.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    return Muc(
      uid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uid']),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
      info: stringType.mapFromDatabaseResponse(data['${effectivePrefix}info']),
      members:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}members']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || uid != null) {
      map['uid'] = Variable<String>(uid);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || info != null) {
      map['info'] = Variable<String>(info);
    }
    if (!nullToAbsent || members != null) {
      map['members'] = Variable<int>(members);
    }
    return map;
  }

  MucsCompanion toCompanion(bool nullToAbsent) {
    return MucsCompanion(
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      info: info == null && nullToAbsent ? const Value.absent() : Value(info),
      members: members == null && nullToAbsent
          ? const Value.absent()
          : Value(members),
    );
  }

  factory Muc.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Muc(
      uid: serializer.fromJson<String>(json['uid']),
      name: serializer.fromJson<String>(json['name']),
      info: serializer.fromJson<String>(json['info']),
      members: serializer.fromJson<int>(json['members']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'name': serializer.toJson<String>(name),
      'info': serializer.toJson<String>(info),
      'members': serializer.toJson<int>(members),
    };
  }

  Muc copyWith({String uid, String name, String info, int members}) => Muc(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        info: info ?? this.info,
        members: members ?? this.members,
      );
  @override
  String toString() {
    return (StringBuffer('Muc(')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('info: $info, ')
          ..write('members: $members')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(uid.hashCode,
      $mrjc(name.hashCode, $mrjc(info.hashCode, members.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Muc &&
          other.uid == this.uid &&
          other.name == this.name &&
          other.info == this.info &&
          other.members == this.members);
}

class MucsCompanion extends UpdateCompanion<Muc> {
  final Value<String> uid;
  final Value<String> name;
  final Value<String> info;
  final Value<int> members;
  const MucsCompanion({
    this.uid = const Value.absent(),
    this.name = const Value.absent(),
    this.info = const Value.absent(),
    this.members = const Value.absent(),
  });
  MucsCompanion.insert({
    @required String uid,
    @required String name,
    this.info = const Value.absent(),
    @required int members,
  })  : uid = Value(uid),
        name = Value(name),
        members = Value(members);
  static Insertable<Muc> custom({
    Expression<String> uid,
    Expression<String> name,
    Expression<String> info,
    Expression<int> members,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (name != null) 'name': name,
      if (info != null) 'info': info,
      if (members != null) 'members': members,
    });
  }

  MucsCompanion copyWith(
      {Value<String> uid,
      Value<String> name,
      Value<String> info,
      Value<int> members}) {
    return MucsCompanion(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      info: info ?? this.info,
      members: members ?? this.members,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (info.present) {
      map['info'] = Variable<String>(info.value);
    }
    if (members.present) {
      map['members'] = Variable<int>(members.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MucsCompanion(')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('info: $info, ')
          ..write('members: $members')
          ..write(')'))
        .toString();
  }
}

class $MucsTable extends Mucs with TableInfo<$MucsTable, Muc> {
  final GeneratedDatabase _db;
  final String _alias;
  $MucsTable(this._db, [this._alias]);
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

  final VerificationMeta _infoMeta = const VerificationMeta('info');
  GeneratedTextColumn _info;
  @override
  GeneratedTextColumn get info => _info ??= _constructInfo();
  GeneratedTextColumn _constructInfo() {
    return GeneratedTextColumn(
      'info',
      $tableName,
      true,
    );
  }

  final VerificationMeta _membersMeta = const VerificationMeta('members');
  GeneratedIntColumn _members;
  @override
  GeneratedIntColumn get members => _members ??= _constructMembers();
  GeneratedIntColumn _constructMembers() {
    return GeneratedIntColumn(
      'members',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [uid, name, info, members];
  @override
  $MucsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'mucs';
  @override
  final String actualTableName = 'mucs';
  @override
  VerificationContext validateIntegrity(Insertable<Muc> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid'], _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name'], _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('info')) {
      context.handle(
          _infoMeta, info.isAcceptableOrUnknown(data['info'], _infoMeta));
    }
    if (data.containsKey('members')) {
      context.handle(_membersMeta,
          members.isAcceptableOrUnknown(data['members'], _membersMeta));
    } else if (isInserting) {
      context.missing(_membersMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  Muc map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Muc.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $MucsTable createAlias(String alias) {
    return $MucsTable(_db, alias);
  }
}

class LastSeen extends DataClass implements Insertable<LastSeen> {
  final int messageId;
  final String roomId;
  LastSeen({this.messageId, @required this.roomId});
  factory LastSeen.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return LastSeen(
      messageId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}message_id']),
      roomId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || messageId != null) {
      map['message_id'] = Variable<int>(messageId);
    }
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    return map;
  }

  LastSeensCompanion toCompanion(bool nullToAbsent) {
    return LastSeensCompanion(
      messageId: messageId == null && nullToAbsent
          ? const Value.absent()
          : Value(messageId),
      roomId:
          roomId == null && nullToAbsent ? const Value.absent() : Value(roomId),
    );
  }

  factory LastSeen.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return LastSeen(
      messageId: serializer.fromJson<int>(json['messageId']),
      roomId: serializer.fromJson<String>(json['roomId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<int>(messageId),
      'roomId': serializer.toJson<String>(roomId),
    };
  }

  LastSeen copyWith({int messageId, String roomId}) => LastSeen(
        messageId: messageId ?? this.messageId,
        roomId: roomId ?? this.roomId,
      );
  @override
  String toString() {
    return (StringBuffer('LastSeen(')
          ..write('messageId: $messageId, ')
          ..write('roomId: $roomId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(messageId.hashCode, roomId.hashCode));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is LastSeen &&
          other.messageId == this.messageId &&
          other.roomId == this.roomId);
}

class LastSeensCompanion extends UpdateCompanion<LastSeen> {
  final Value<int> messageId;
  final Value<String> roomId;
  const LastSeensCompanion({
    this.messageId = const Value.absent(),
    this.roomId = const Value.absent(),
  });
  LastSeensCompanion.insert({
    this.messageId = const Value.absent(),
    @required String roomId,
  }) : roomId = Value(roomId);
  static Insertable<LastSeen> custom({
    Expression<int> messageId,
    Expression<String> roomId,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (roomId != null) 'room_id': roomId,
    });
  }

  LastSeensCompanion copyWith({Value<int> messageId, Value<String> roomId}) {
    return LastSeensCompanion(
      messageId: messageId ?? this.messageId,
      roomId: roomId ?? this.roomId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LastSeensCompanion(')
          ..write('messageId: $messageId, ')
          ..write('roomId: $roomId')
          ..write(')'))
        .toString();
  }
}

class $LastSeensTable extends LastSeens
    with TableInfo<$LastSeensTable, LastSeen> {
  final GeneratedDatabase _db;
  final String _alias;
  $LastSeensTable(this._db, [this._alias]);
  final VerificationMeta _messageIdMeta = const VerificationMeta('messageId');
  GeneratedIntColumn _messageId;
  @override
  GeneratedIntColumn get messageId => _messageId ??= _constructMessageId();
  GeneratedIntColumn _constructMessageId() {
    return GeneratedIntColumn(
      'message_id',
      $tableName,
      true,
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

  @override
  List<GeneratedColumn> get $columns => [messageId, roomId];
  @override
  $LastSeensTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'last_seens';
  @override
  final String actualTableName = 'last_seens';
  @override
  VerificationContext validateIntegrity(Insertable<LastSeen> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id'], _messageIdMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id'], _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roomId};
  @override
  LastSeen map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return LastSeen.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $LastSeensTable createAlias(String alias) {
    return $LastSeensTable(_db, alias);
  }
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
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    return MediasMetaDataData(
      roomId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      imagesCount: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}images_count']),
      videosCount: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}videos_count']),
      filesCount: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}files_count']),
      documentsCount: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}documents_count']),
      audiosCount: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}audios_count']),
      musicsCount: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}musics_count']),
      linkCount:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}link_count']),
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
  bool operator ==(dynamic other) =>
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
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return MediasMetaDataData.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $MediasMetaDataTable createAlias(String alias) {
    return $MediasMetaDataTable(_db, alias);
  }
}

class UserInfo extends DataClass implements Insertable<UserInfo> {
  final String uid;
  final String username;
  final DateTime lastActivity;
  final DateTime lastTimeActivityUpdated;
  UserInfo(
      {@required this.uid,
      this.username,
      this.lastActivity,
      this.lastTimeActivityUpdated});
  factory UserInfo.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    return UserInfo(
      uid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uid']),
      username: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}username']),
      lastActivity: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}last_activity']),
      lastTimeActivityUpdated: dateTimeType.mapFromDatabaseResponse(
          data['${effectivePrefix}last_time_activity_updated']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || uid != null) {
      map['uid'] = Variable<String>(uid);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || lastActivity != null) {
      map['last_activity'] = Variable<DateTime>(lastActivity);
    }
    if (!nullToAbsent || lastTimeActivityUpdated != null) {
      map['last_time_activity_updated'] =
          Variable<DateTime>(lastTimeActivityUpdated);
    }
    return map;
  }

  UserInfosCompanion toCompanion(bool nullToAbsent) {
    return UserInfosCompanion(
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      lastActivity: lastActivity == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActivity),
      lastTimeActivityUpdated: lastTimeActivityUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTimeActivityUpdated),
    );
  }

  factory UserInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return UserInfo(
      uid: serializer.fromJson<String>(json['uid']),
      username: serializer.fromJson<String>(json['username']),
      lastActivity: serializer.fromJson<DateTime>(json['lastActivity']),
      lastTimeActivityUpdated:
          serializer.fromJson<DateTime>(json['lastTimeActivityUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'username': serializer.toJson<String>(username),
      'lastActivity': serializer.toJson<DateTime>(lastActivity),
      'lastTimeActivityUpdated':
          serializer.toJson<DateTime>(lastTimeActivityUpdated),
    };
  }

  UserInfo copyWith(
          {String uid,
          String username,
          DateTime lastActivity,
          DateTime lastTimeActivityUpdated}) =>
      UserInfo(
        uid: uid ?? this.uid,
        username: username ?? this.username,
        lastActivity: lastActivity ?? this.lastActivity,
        lastTimeActivityUpdated:
            lastTimeActivityUpdated ?? this.lastTimeActivityUpdated,
      );
  @override
  String toString() {
    return (StringBuffer('UserInfo(')
          ..write('uid: $uid, ')
          ..write('username: $username, ')
          ..write('lastActivity: $lastActivity, ')
          ..write('lastTimeActivityUpdated: $lastTimeActivityUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      uid.hashCode,
      $mrjc(username.hashCode,
          $mrjc(lastActivity.hashCode, lastTimeActivityUpdated.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is UserInfo &&
          other.uid == this.uid &&
          other.username == this.username &&
          other.lastActivity == this.lastActivity &&
          other.lastTimeActivityUpdated == this.lastTimeActivityUpdated);
}

class UserInfosCompanion extends UpdateCompanion<UserInfo> {
  final Value<String> uid;
  final Value<String> username;
  final Value<DateTime> lastActivity;
  final Value<DateTime> lastTimeActivityUpdated;
  const UserInfosCompanion({
    this.uid = const Value.absent(),
    this.username = const Value.absent(),
    this.lastActivity = const Value.absent(),
    this.lastTimeActivityUpdated = const Value.absent(),
  });
  UserInfosCompanion.insert({
    @required String uid,
    this.username = const Value.absent(),
    this.lastActivity = const Value.absent(),
    this.lastTimeActivityUpdated = const Value.absent(),
  }) : uid = Value(uid);
  static Insertable<UserInfo> custom({
    Expression<String> uid,
    Expression<String> username,
    Expression<DateTime> lastActivity,
    Expression<DateTime> lastTimeActivityUpdated,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (username != null) 'username': username,
      if (lastActivity != null) 'last_activity': lastActivity,
      if (lastTimeActivityUpdated != null)
        'last_time_activity_updated': lastTimeActivityUpdated,
    });
  }

  UserInfosCompanion copyWith(
      {Value<String> uid,
      Value<String> username,
      Value<DateTime> lastActivity,
      Value<DateTime> lastTimeActivityUpdated}) {
    return UserInfosCompanion(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      lastActivity: lastActivity ?? this.lastActivity,
      lastTimeActivityUpdated:
          lastTimeActivityUpdated ?? this.lastTimeActivityUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (lastActivity.present) {
      map['last_activity'] = Variable<DateTime>(lastActivity.value);
    }
    if (lastTimeActivityUpdated.present) {
      map['last_time_activity_updated'] =
          Variable<DateTime>(lastTimeActivityUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserInfosCompanion(')
          ..write('uid: $uid, ')
          ..write('username: $username, ')
          ..write('lastActivity: $lastActivity, ')
          ..write('lastTimeActivityUpdated: $lastTimeActivityUpdated')
          ..write(')'))
        .toString();
  }
}

class $UserInfosTable extends UserInfos
    with TableInfo<$UserInfosTable, UserInfo> {
  final GeneratedDatabase _db;
  final String _alias;
  $UserInfosTable(this._db, [this._alias]);
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

  final VerificationMeta _usernameMeta = const VerificationMeta('username');
  GeneratedTextColumn _username;
  @override
  GeneratedTextColumn get username => _username ??= _constructUsername();
  GeneratedTextColumn _constructUsername() {
    return GeneratedTextColumn(
      'username',
      $tableName,
      true,
    );
  }

  final VerificationMeta _lastActivityMeta =
      const VerificationMeta('lastActivity');
  GeneratedDateTimeColumn _lastActivity;
  @override
  GeneratedDateTimeColumn get lastActivity =>
      _lastActivity ??= _constructLastActivity();
  GeneratedDateTimeColumn _constructLastActivity() {
    return GeneratedDateTimeColumn(
      'last_activity',
      $tableName,
      true,
    );
  }

  final VerificationMeta _lastTimeActivityUpdatedMeta =
      const VerificationMeta('lastTimeActivityUpdated');
  GeneratedDateTimeColumn _lastTimeActivityUpdated;
  @override
  GeneratedDateTimeColumn get lastTimeActivityUpdated =>
      _lastTimeActivityUpdated ??= _constructLastTimeActivityUpdated();
  GeneratedDateTimeColumn _constructLastTimeActivityUpdated() {
    return GeneratedDateTimeColumn(
      'last_time_activity_updated',
      $tableName,
      true,
    );
  }

  @override
  List<GeneratedColumn> get $columns =>
      [uid, username, lastActivity, lastTimeActivityUpdated];
  @override
  $UserInfosTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'user_infos';
  @override
  final String actualTableName = 'user_infos';
  @override
  VerificationContext validateIntegrity(Insertable<UserInfo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid'], _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username'], _usernameMeta));
    }
    if (data.containsKey('last_activity')) {
      context.handle(
          _lastActivityMeta,
          lastActivity.isAcceptableOrUnknown(
              data['last_activity'], _lastActivityMeta));
    }
    if (data.containsKey('last_time_activity_updated')) {
      context.handle(
          _lastTimeActivityUpdatedMeta,
          lastTimeActivityUpdated.isAcceptableOrUnknown(
              data['last_time_activity_updated'],
              _lastTimeActivityUpdatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  UserInfo map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return UserInfo.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $UserInfosTable createAlias(String alias) {
    return $UserInfosTable(_db, alias);
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
    final stringType = db.typeSystem.forDartType<String>();
    return Sticker(
      uuid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uuid']),
      packId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}pack_id']),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
      packName: stringType
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
  bool operator ==(dynamic other) =>
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
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Sticker.fromData(data, _db, prefix: effectivePrefix);
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
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return StickerId(
      getPackTime: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}get_pack_time']),
      packId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}pack_id']),
      packISDownloaded: boolType.mapFromDatabaseResponse(
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
  bool operator ==(dynamic other) =>
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
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return StickerId.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $StickerIdsTable createAlias(String alias) {
    return $StickerIdsTable(_db, alias);
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
  $SharedPreferencesTable _sharedPreferences;
  $SharedPreferencesTable get sharedPreferences =>
      _sharedPreferences ??= $SharedPreferencesTable(this);
  $MembersTable _members;
  $MembersTable get members => _members ??= $MembersTable(this);
  $MucsTable _mucs;
  $MucsTable get mucs => _mucs ??= $MucsTable(this);
  $LastSeensTable _lastSeens;
  $LastSeensTable get lastSeens => _lastSeens ??= $LastSeensTable(this);
  $MediasMetaDataTable _mediasMetaData;
  $MediasMetaDataTable get mediasMetaData =>
      _mediasMetaData ??= $MediasMetaDataTable(this);
  $UserInfosTable _userInfos;
  $UserInfosTable get userInfos => _userInfos ??= $UserInfosTable(this);
  $StickersTable _stickers;
  $StickersTable get stickers => _stickers ??= $StickersTable(this);
  $StickerIdsTable _stickerIds;
  $StickerIdsTable get stickerIds => _stickerIds ??= $StickerIdsTable(this);
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
  SharedPreferencesDao _sharedPreferencesDao;
  SharedPreferencesDao get sharedPreferencesDao =>
      _sharedPreferencesDao ??= SharedPreferencesDao(this as Database);
  MemberDao _memberDao;
  MemberDao get memberDao => _memberDao ??= MemberDao(this as Database);
  MucDao _mucDao;
  MucDao get mucDao => _mucDao ??= MucDao(this as Database);
  LastSeenDao _lastSeenDao;
  LastSeenDao get lastSeenDao => _lastSeenDao ??= LastSeenDao(this as Database);
  MediaMetaDataDao _mediaMetaDataDao;
  MediaMetaDataDao get mediaMetaDataDao =>
      _mediaMetaDataDao ??= MediaMetaDataDao(this as Database);
  UserInfoDao _userInfoDao;
  UserInfoDao get userInfoDao => _userInfoDao ??= UserInfoDao(this as Database);
  StickerDao _stickerDao;
  StickerDao get stickerDao => _stickerDao ??= StickerDao(this as Database);
  StickerIdDao _stickerIdDao;
  StickerIdDao get stickerIdDao =>
      _stickerIdDao ??= StickerIdDao(this as Database);
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
        medias,
        sharedPreferences,
        members,
        mucs,
        lastSeens,
        mediasMetaData,
        userInfos,
        stickers,
        stickerIds
      ];
}
