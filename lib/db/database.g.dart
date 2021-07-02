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
  final bool sendingFailed;
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
      @required this.sendingFailed,
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
    return Message(
      dbId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}db_id']),
      packetId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}packet_id']),
      roomId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      id: const IntType().mapFromDatabaseResponse(data['${effectivePrefix}id']),
      time: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}time']),
      sendingFailed: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}sending_failed']),
      from: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}from']),
      to: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}to']),
      replyToId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}reply_to_id']),
      forwardedFrom: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}forwarded_from']),
      edited: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}edited']),
      encrypted: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}encrypted']),
      type: $MessagesTable.$converter0.mapToDart(const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}type'])),
      json: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}json']),
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
    if (!nullToAbsent || sendingFailed != null) {
      map['sending_failed'] = Variable<bool>(sendingFailed);
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
      sendingFailed: sendingFailed == null && nullToAbsent
          ? const Value.absent()
          : Value(sendingFailed),
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
      sendingFailed: serializer.fromJson<bool>(json['sendingFailed']),
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
      'sendingFailed': serializer.toJson<bool>(sendingFailed),
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
          bool sendingFailed,
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
        sendingFailed: sendingFailed ?? this.sendingFailed,
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
          ..write('sendingFailed: $sendingFailed, ')
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
                          sendingFailed.hashCode,
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
                                                      json.hashCode))))))))))))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.dbId == this.dbId &&
          other.packetId == this.packetId &&
          other.roomId == this.roomId &&
          other.id == this.id &&
          other.time == this.time &&
          other.sendingFailed == this.sendingFailed &&
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
  final Value<bool> sendingFailed;
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
    this.sendingFailed = const Value.absent(),
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
    this.sendingFailed = const Value.absent(),
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
    Expression<bool> sendingFailed,
    Expression<String> from,
    Expression<String> to,
    Expression<int> replyToId,
    Expression<String> forwardedFrom,
    Expression<bool> edited,
    Expression<bool> encrypted,
    Expression<MessageType> type,
    Expression<String> json,
  }) {
    return RawValuesInsertable({
      if (dbId != null) 'db_id': dbId,
      if (packetId != null) 'packet_id': packetId,
      if (roomId != null) 'room_id': roomId,
      if (id != null) 'id': id,
      if (time != null) 'time': time,
      if (sendingFailed != null) 'sending_failed': sendingFailed,
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
      Value<bool> sendingFailed,
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
      sendingFailed: sendingFailed ?? this.sendingFailed,
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
    if (sendingFailed.present) {
      map['sending_failed'] = Variable<bool>(sendingFailed.value);
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
          ..write('sendingFailed: $sendingFailed, ')
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

  final VerificationMeta _sendingFailedMeta =
      const VerificationMeta('sendingFailed');
  GeneratedBoolColumn _sendingFailed;
  @override
  GeneratedBoolColumn get sendingFailed =>
      _sendingFailed ??= _constructSendingFailed();
  GeneratedBoolColumn _constructSendingFailed() {
    return GeneratedBoolColumn('sending_failed', $tableName, false,
        defaultValue: Constant(false));
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
        sendingFailed,
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
    if (data.containsKey('sending_failed')) {
      context.handle(
          _sendingFailedMeta,
          sendingFailed.isAcceptableOrUnknown(
              data['sending_failed'], _sendingFailedMeta));
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
    return Message.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
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
  final bool deleted;
  final int lastMessageDbId;
  Room(
      {@required this.roomId,
      this.mentioned,
      this.lastMessageId,
      @required this.deleted,
      this.lastMessageDbId});
  factory Room.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    return Room(
      roomId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      mentioned: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}mentioned']),
      lastMessageId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}last_message_id']),
      deleted: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}deleted']),
      lastMessageDbId: const IntType().mapFromDatabaseResponse(
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
    if (!nullToAbsent || deleted != null) {
      map['deleted'] = Variable<bool>(deleted);
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
      deleted: deleted == null && nullToAbsent
          ? const Value.absent()
          : Value(deleted),
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
      deleted: serializer.fromJson<bool>(json['deleted']),
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
      'deleted': serializer.toJson<bool>(deleted),
      'lastMessageDbId': serializer.toJson<int>(lastMessageDbId),
    };
  }

  Room copyWith(
          {String roomId,
          bool mentioned,
          int lastMessageId,
          bool deleted,
          int lastMessageDbId}) =>
      Room(
        roomId: roomId ?? this.roomId,
        mentioned: mentioned ?? this.mentioned,
        lastMessageId: lastMessageId ?? this.lastMessageId,
        deleted: deleted ?? this.deleted,
        lastMessageDbId: lastMessageDbId ?? this.lastMessageDbId,
      );
  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('roomId: $roomId, ')
          ..write('mentioned: $mentioned, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('deleted: $deleted, ')
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
              $mrjc(deleted.hashCode, lastMessageDbId.hashCode)))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Room &&
          other.roomId == this.roomId &&
          other.mentioned == this.mentioned &&
          other.lastMessageId == this.lastMessageId &&
          other.deleted == this.deleted &&
          other.lastMessageDbId == this.lastMessageDbId);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<String> roomId;
  final Value<bool> mentioned;
  final Value<int> lastMessageId;
  final Value<bool> deleted;
  final Value<int> lastMessageDbId;
  const RoomsCompanion({
    this.roomId = const Value.absent(),
    this.mentioned = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.lastMessageDbId = const Value.absent(),
  });
  RoomsCompanion.insert({
    @required String roomId,
    this.mentioned = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.lastMessageDbId = const Value.absent(),
  }) : roomId = Value(roomId);
  static Insertable<Room> custom({
    Expression<String> roomId,
    Expression<bool> mentioned,
    Expression<int> lastMessageId,
    Expression<bool> deleted,
    Expression<int> lastMessageDbId,
  }) {
    return RawValuesInsertable({
      if (roomId != null) 'room_id': roomId,
      if (mentioned != null) 'mentioned': mentioned,
      if (lastMessageId != null) 'last_message_id': lastMessageId,
      if (deleted != null) 'deleted': deleted,
      if (lastMessageDbId != null) 'last_message_db_id': lastMessageDbId,
    });
  }

  RoomsCompanion copyWith(
      {Value<String> roomId,
      Value<bool> mentioned,
      Value<int> lastMessageId,
      Value<bool> deleted,
      Value<int> lastMessageDbId}) {
    return RoomsCompanion(
      roomId: roomId ?? this.roomId,
      mentioned: mentioned ?? this.mentioned,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      deleted: deleted ?? this.deleted,
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
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
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
          ..write('deleted: $deleted, ')
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

  final VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  GeneratedBoolColumn _deleted;
  @override
  GeneratedBoolColumn get deleted => _deleted ??= _constructDeleted();
  GeneratedBoolColumn _constructDeleted() {
    return GeneratedBoolColumn('deleted', $tableName, false,
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
      [roomId, mentioned, lastMessageId, deleted, lastMessageDbId];
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
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted'], _deletedMeta));
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
    return Room.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(_db, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final String username;
  final String uid;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  Contact(
      {this.username,
      this.uid,
      @required this.phoneNumber,
      this.firstName,
      this.lastName});
  factory Contact.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    return Contact(
      username: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}username']),
      uid: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}uid']),
      phoneNumber: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}phone_number']),
      firstName: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}first_name']),
      lastName: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}last_name']),
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
    };
  }

  Contact copyWith(
          {String username,
          String uid,
          String phoneNumber,
          String firstName,
          String lastName}) =>
      Contact(
        username: username ?? this.username,
        uid: uid ?? this.uid,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
      );
  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('username: $username, ')
          ..write('uid: $uid, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      username.hashCode,
      $mrjc(
          uid.hashCode,
          $mrjc(phoneNumber.hashCode,
              $mrjc(firstName.hashCode, lastName.hashCode)))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.username == this.username &&
          other.uid == this.uid &&
          other.phoneNumber == this.phoneNumber &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<String> username;
  final Value<String> uid;
  final Value<String> phoneNumber;
  final Value<String> firstName;
  final Value<String> lastName;
  const ContactsCompanion({
    this.username = const Value.absent(),
    this.uid = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
  });
  ContactsCompanion.insert({
    this.username = const Value.absent(),
    this.uid = const Value.absent(),
    @required String phoneNumber,
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
  }) : phoneNumber = Value(phoneNumber);
  static Insertable<Contact> custom({
    Expression<String> username,
    Expression<String> uid,
    Expression<String> phoneNumber,
    Expression<String> firstName,
    Expression<String> lastName,
  }) {
    return RawValuesInsertable({
      if (username != null) 'username': username,
      if (uid != null) 'uid': uid,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
    });
  }

  ContactsCompanion copyWith(
      {Value<String> username,
      Value<String> uid,
      Value<String> phoneNumber,
      Value<String> firstName,
      Value<String> lastName}) {
    return ContactsCompanion(
      username: username ?? this.username,
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('username: $username, ')
          ..write('uid: $uid, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName')
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

  @override
  List<GeneratedColumn> get $columns =>
      [username, uid, phoneNumber, firstName, lastName];
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {phoneNumber};
  @override
  Contact map(Map<String, dynamic> data, {String tablePrefix}) {
    return Contact.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(_db, alias);
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
    return PendingMessage(
      messageDbId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}message_db_id']),
      messagePacketId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}message_packet_id']),
      roomId: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      remainingRetries: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}remaining_retries']),
      status: $PendingMessagesTable.$converter0.mapToDart(const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}status'])),
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
  bool operator ==(Object other) =>
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
    Expression<SendingStatus> status,
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
    return PendingMessage.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
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

class BotInfo extends DataClass implements Insertable<BotInfo> {
  final String description;
  final String name;
  final String username;
  final String commands;
  BotInfo(
      {@required this.description,
      this.name,
      @required this.username,
      @required this.commands});
  factory BotInfo.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    return BotInfo(
      description: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}description']),
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name']),
      username: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}username']),
      commands: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}commands']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || commands != null) {
      map['commands'] = Variable<String>(commands);
    }
    return map;
  }

  BotInfosCompanion toCompanion(bool nullToAbsent) {
    return BotInfosCompanion(
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      commands: commands == null && nullToAbsent
          ? const Value.absent()
          : Value(commands),
    );
  }

  factory BotInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return BotInfo(
      description: serializer.fromJson<String>(json['description']),
      name: serializer.fromJson<String>(json['name']),
      username: serializer.fromJson<String>(json['username']),
      commands: serializer.fromJson<String>(json['commands']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'description': serializer.toJson<String>(description),
      'name': serializer.toJson<String>(name),
      'username': serializer.toJson<String>(username),
      'commands': serializer.toJson<String>(commands),
    };
  }

  BotInfo copyWith(
          {String description,
          String name,
          String username,
          String commands}) =>
      BotInfo(
        description: description ?? this.description,
        name: name ?? this.name,
        username: username ?? this.username,
        commands: commands ?? this.commands,
      );
  @override
  String toString() {
    return (StringBuffer('BotInfo(')
          ..write('description: $description, ')
          ..write('name: $name, ')
          ..write('username: $username, ')
          ..write('commands: $commands')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(description.hashCode,
      $mrjc(name.hashCode, $mrjc(username.hashCode, commands.hashCode))));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BotInfo &&
          other.description == this.description &&
          other.name == this.name &&
          other.username == this.username &&
          other.commands == this.commands);
}

class BotInfosCompanion extends UpdateCompanion<BotInfo> {
  final Value<String> description;
  final Value<String> name;
  final Value<String> username;
  final Value<String> commands;
  const BotInfosCompanion({
    this.description = const Value.absent(),
    this.name = const Value.absent(),
    this.username = const Value.absent(),
    this.commands = const Value.absent(),
  });
  BotInfosCompanion.insert({
    @required String description,
    this.name = const Value.absent(),
    @required String username,
    @required String commands,
  })  : description = Value(description),
        username = Value(username),
        commands = Value(commands);
  static Insertable<BotInfo> custom({
    Expression<String> description,
    Expression<String> name,
    Expression<String> username,
    Expression<String> commands,
  }) {
    return RawValuesInsertable({
      if (description != null) 'description': description,
      if (name != null) 'name': name,
      if (username != null) 'username': username,
      if (commands != null) 'commands': commands,
    });
  }

  BotInfosCompanion copyWith(
      {Value<String> description,
      Value<String> name,
      Value<String> username,
      Value<String> commands}) {
    return BotInfosCompanion(
      description: description ?? this.description,
      name: name ?? this.name,
      username: username ?? this.username,
      commands: commands ?? this.commands,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (commands.present) {
      map['commands'] = Variable<String>(commands.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BotInfosCompanion(')
          ..write('description: $description, ')
          ..write('name: $name, ')
          ..write('username: $username, ')
          ..write('commands: $commands')
          ..write(')'))
        .toString();
  }
}

class $BotInfosTable extends BotInfos with TableInfo<$BotInfosTable, BotInfo> {
  final GeneratedDatabase _db;
  final String _alias;
  $BotInfosTable(this._db, [this._alias]);
  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  GeneratedTextColumn _description;
  @override
  GeneratedTextColumn get description =>
      _description ??= _constructDescription();
  GeneratedTextColumn _constructDescription() {
    return GeneratedTextColumn(
      'description',
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
      false,
    );
  }

  final VerificationMeta _commandsMeta = const VerificationMeta('commands');
  GeneratedTextColumn _commands;
  @override
  GeneratedTextColumn get commands => _commands ??= _constructCommands();
  GeneratedTextColumn _constructCommands() {
    return GeneratedTextColumn(
      'commands',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [description, name, username, commands];
  @override
  $BotInfosTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'bot_infos';
  @override
  final String actualTableName = 'bot_infos';
  @override
  VerificationContext validateIntegrity(Insertable<BotInfo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description'], _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name'], _nameMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username'], _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('commands')) {
      context.handle(_commandsMeta,
          commands.isAcceptableOrUnknown(data['commands'], _commandsMeta));
    } else if (isInserting) {
      context.missing(_commandsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {username};
  @override
  BotInfo map(Map<String, dynamic> data, {String tablePrefix}) {
    return BotInfo.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $BotInfosTable createAlias(String alias) {
    return $BotInfosTable(_db, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $MessagesTable _messages;
  $MessagesTable get messages => _messages ??= $MessagesTable(this);
  $RoomsTable _rooms;
  $RoomsTable get rooms => _rooms ??= $RoomsTable(this);
  $ContactsTable _contacts;
  $ContactsTable get contacts => _contacts ??= $ContactsTable(this);
  $PendingMessagesTable _pendingMessages;
  $PendingMessagesTable get pendingMessages =>
      _pendingMessages ??= $PendingMessagesTable(this);
  $MediasTable _medias;
  $MediasTable get medias => _medias ??= $MediasTable(this);
  $MediasMetaDataTable _mediasMetaData;
  $MediasMetaDataTable get mediasMetaData =>
      _mediasMetaData ??= $MediasMetaDataTable(this);
  $StickersTable _stickers;
  $StickersTable get stickers => _stickers ??= $StickersTable(this);
  $StickerIdsTable _stickerIds;
  $StickerIdsTable get stickerIds => _stickerIds ??= $StickerIdsTable(this);
  $BotInfosTable _botInfos;
  $BotInfosTable get botInfos => _botInfos ??= $BotInfosTable(this);
  MessageDao _messageDao;
  MessageDao get messageDao => _messageDao ??= MessageDao(this as Database);
  RoomDao _roomDao;
  RoomDao get roomDao => _roomDao ??= RoomDao(this as Database);
  ContactDao _contactDao;
  ContactDao get contactDao => _contactDao ??= ContactDao(this as Database);
  PendingMessageDao _pendingMessageDao;
  PendingMessageDao get pendingMessageDao =>
      _pendingMessageDao ??= PendingMessageDao(this as Database);
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
  BotInfoDao _botInfoDao;
  BotInfoDao get botInfoDao => _botInfoDao ??= BotInfoDao(this as Database);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        messages,
        rooms,
        contacts,
        pendingMessages,
        medias,
        mediasMetaData,
        stickers,
        stickerIds,
        botInfos
      ];
}
