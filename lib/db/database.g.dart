// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Message extends DataClass implements Insertable<Message> {
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
      {@required this.packetId,
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
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final boolType = db.typeSystem.forDartType<bool>();
    return Message(
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
          {String packetId,
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
                                              json.hashCode))))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Message &&
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
      {Value<String> packetId,
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
  Set<GeneratedColumn> get $primaryKey => {packetId};
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
  final bool mute;
  final String lastMessage;
  Room(
      {@required this.roomId,
      this.mentioned,
      @required this.mute,
      this.lastMessage});
  factory Room.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return Room(
      roomId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      mentioned:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}mentioned']),
      mute: boolType.mapFromDatabaseResponse(data['${effectivePrefix}mute']),
      lastMessage: stringType
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
    if (!nullToAbsent || mute != null) {
      map['mute'] = Variable<bool>(mute);
    }
    if (!nullToAbsent || lastMessage != null) {
      map['last_message'] = Variable<String>(lastMessage);
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
      mute: mute == null && nullToAbsent ? const Value.absent() : Value(mute),
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
      mute: serializer.fromJson<bool>(json['mute']),
      lastMessage: serializer.fromJson<String>(json['lastMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roomId': serializer.toJson<String>(roomId),
      'mentioned': serializer.toJson<bool>(mentioned),
      'mute': serializer.toJson<bool>(mute),
      'lastMessage': serializer.toJson<String>(lastMessage),
    };
  }

  Room copyWith(
          {String roomId, bool mentioned, bool mute, String lastMessage}) =>
      Room(
        roomId: roomId ?? this.roomId,
        mentioned: mentioned ?? this.mentioned,
        mute: mute ?? this.mute,
        lastMessage: lastMessage ?? this.lastMessage,
      );
  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('roomId: $roomId, ')
          ..write('mentioned: $mentioned, ')
          ..write('mute: $mute, ')
          ..write('lastMessage: $lastMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(roomId.hashCode,
      $mrjc(mentioned.hashCode, $mrjc(mute.hashCode, lastMessage.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Room &&
          other.roomId == this.roomId &&
          other.mentioned == this.mentioned &&
          other.mute == this.mute &&
          other.lastMessage == this.lastMessage);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<String> roomId;
  final Value<bool> mentioned;
  final Value<bool> mute;
  final Value<String> lastMessage;
  const RoomsCompanion({
    this.roomId = const Value.absent(),
    this.mentioned = const Value.absent(),
    this.mute = const Value.absent(),
    this.lastMessage = const Value.absent(),
  });
  RoomsCompanion.insert({
    @required String roomId,
    this.mentioned = const Value.absent(),
    this.mute = const Value.absent(),
    this.lastMessage = const Value.absent(),
  }) : roomId = Value(roomId);
  static Insertable<Room> custom({
    Expression<String> roomId,
    Expression<bool> mentioned,
    Expression<bool> mute,
    Expression<String> lastMessage,
  }) {
    return RawValuesInsertable({
      if (roomId != null) 'room_id': roomId,
      if (mentioned != null) 'mentioned': mentioned,
      if (mute != null) 'mute': mute,
      if (lastMessage != null) 'last_message': lastMessage,
    });
  }

  RoomsCompanion copyWith(
      {Value<String> roomId,
      Value<bool> mentioned,
      Value<bool> mute,
      Value<String> lastMessage}) {
    return RoomsCompanion(
      roomId: roomId ?? this.roomId,
      mentioned: mentioned ?? this.mentioned,
      mute: mute ?? this.mute,
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
    if (mute.present) {
      map['mute'] = Variable<bool>(mute.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('roomId: $roomId, ')
          ..write('mentioned: $mentioned, ')
          ..write('mute: $mute, ')
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

  final VerificationMeta _muteMeta = const VerificationMeta('mute');
  GeneratedBoolColumn _mute;
  @override
  GeneratedBoolColumn get mute => _mute ??= _constructMute();
  GeneratedBoolColumn _constructMute() {
    return GeneratedBoolColumn('mute', $tableName, false,
        defaultValue: Constant(false));
  }

  final VerificationMeta _lastMessageMeta =
      const VerificationMeta('lastMessage');
  GeneratedTextColumn _lastMessage;
  @override
  GeneratedTextColumn get lastMessage =>
      _lastMessage ??= _constructLastMessage();
  GeneratedTextColumn _constructLastMessage() {
    return GeneratedTextColumn('last_message', $tableName, true,
        $customConstraints: 'REFERENCES messages(packet_id)');
  }

  @override
  List<GeneratedColumn> get $columns => [roomId, mentioned, mute, lastMessage];
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
    if (data.containsKey('mute')) {
      context.handle(
          _muteMeta, mute.isAcceptableOrUnknown(data['mute'], _muteMeta));
    }
    if (data.containsKey('last_message')) {
      context.handle(
          _lastMessageMeta,
          lastMessage.isAcceptableOrUnknown(
              data['last_message'], _lastMessageMeta));
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
  final String messageId;
  final int remainingRetries;
  final DateTime time;
  final SendingStatus status;
  final String details;
  PendingMessage(
      {@required this.messageId,
      @required this.remainingRetries,
      @required this.time,
      @required this.status,
      this.details});
  factory PendingMessage.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    return PendingMessage(
      messageId: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}message_id']),
      remainingRetries: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}remaining_retries']),
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
    if (!nullToAbsent || messageId != null) {
      map['message_id'] = Variable<String>(messageId);
    }
    if (!nullToAbsent || remainingRetries != null) {
      map['remaining_retries'] = Variable<int>(remainingRetries);
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
      messageId: messageId == null && nullToAbsent
          ? const Value.absent()
          : Value(messageId),
      remainingRetries: remainingRetries == null && nullToAbsent
          ? const Value.absent()
          : Value(remainingRetries),
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
      messageId: serializer.fromJson<String>(json['messageId']),
      remainingRetries: serializer.fromJson<int>(json['remainingRetries']),
      time: serializer.fromJson<DateTime>(json['time']),
      status: serializer.fromJson<SendingStatus>(json['status']),
      details: serializer.fromJson<String>(json['details']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<String>(messageId),
      'remainingRetries': serializer.toJson<int>(remainingRetries),
      'time': serializer.toJson<DateTime>(time),
      'status': serializer.toJson<SendingStatus>(status),
      'details': serializer.toJson<String>(details),
    };
  }

  PendingMessage copyWith(
          {String messageId,
          int remainingRetries,
          DateTime time,
          SendingStatus status,
          String details}) =>
      PendingMessage(
        messageId: messageId ?? this.messageId,
        remainingRetries: remainingRetries ?? this.remainingRetries,
        time: time ?? this.time,
        status: status ?? this.status,
        details: details ?? this.details,
      );
  @override
  String toString() {
    return (StringBuffer('PendingMessage(')
          ..write('messageId: $messageId, ')
          ..write('remainingRetries: $remainingRetries, ')
          ..write('time: $time, ')
          ..write('status: $status, ')
          ..write('details: $details')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      messageId.hashCode,
      $mrjc(remainingRetries.hashCode,
          $mrjc(time.hashCode, $mrjc(status.hashCode, details.hashCode)))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is PendingMessage &&
          other.messageId == this.messageId &&
          other.remainingRetries == this.remainingRetries &&
          other.time == this.time &&
          other.status == this.status &&
          other.details == this.details);
}

class PendingMessagesCompanion extends UpdateCompanion<PendingMessage> {
  final Value<String> messageId;
  final Value<int> remainingRetries;
  final Value<DateTime> time;
  final Value<SendingStatus> status;
  final Value<String> details;
  const PendingMessagesCompanion({
    this.messageId = const Value.absent(),
    this.remainingRetries = const Value.absent(),
    this.time = const Value.absent(),
    this.status = const Value.absent(),
    this.details = const Value.absent(),
  });
  PendingMessagesCompanion.insert({
    @required String messageId,
    @required int remainingRetries,
    @required DateTime time,
    @required SendingStatus status,
    this.details = const Value.absent(),
  })  : messageId = Value(messageId),
        remainingRetries = Value(remainingRetries),
        time = Value(time),
        status = Value(status);
  static Insertable<PendingMessage> custom({
    Expression<String> messageId,
    Expression<int> remainingRetries,
    Expression<DateTime> time,
    Expression<int> status,
    Expression<String> details,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (remainingRetries != null) 'remaining_retries': remainingRetries,
      if (time != null) 'time': time,
      if (status != null) 'status': status,
      if (details != null) 'details': details,
    });
  }

  PendingMessagesCompanion copyWith(
      {Value<String> messageId,
      Value<int> remainingRetries,
      Value<DateTime> time,
      Value<SendingStatus> status,
      Value<String> details}) {
    return PendingMessagesCompanion(
      messageId: messageId ?? this.messageId,
      remainingRetries: remainingRetries ?? this.remainingRetries,
      time: time ?? this.time,
      status: status ?? this.status,
      details: details ?? this.details,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (remainingRetries.present) {
      map['remaining_retries'] = Variable<int>(remainingRetries.value);
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
          ..write('messageId: $messageId, ')
          ..write('remainingRetries: $remainingRetries, ')
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
  final VerificationMeta _messageIdMeta = const VerificationMeta('messageId');
  GeneratedTextColumn _messageId;
  @override
  GeneratedTextColumn get messageId => _messageId ??= _constructMessageId();
  GeneratedTextColumn _constructMessageId() {
    return GeneratedTextColumn('message_id', $tableName, false,
        $customConstraints: 'REFERENCES messages(packet_id)');
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
      [messageId, remainingRetries, time, status, details];
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
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id'], _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('remaining_retries')) {
      context.handle(
          _remainingRetriesMeta,
          remainingRetries.isAcceptableOrUnknown(
              data['remaining_retries'], _remainingRetriesMeta));
    } else if (isInserting) {
      context.missing(_remainingRetriesMeta);
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
  Set<GeneratedColumn> get $primaryKey => {messageId};
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
  Member(
      {@required this.memberUid, @required this.mucUid, @required this.role});
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
    );
  }

  factory Member.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Member(
      memberUid: serializer.fromJson<String>(json['memberUid']),
      mucUid: serializer.fromJson<String>(json['mucUid']),
      role: serializer.fromJson<MucRole>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'memberUid': serializer.toJson<String>(memberUid),
      'mucUid': serializer.toJson<String>(mucUid),
      'role': serializer.toJson<MucRole>(role),
    };
  }

  Member copyWith({String memberUid, String mucUid, MucRole role}) => Member(
        memberUid: memberUid ?? this.memberUid,
        mucUid: mucUid ?? this.mucUid,
        role: role ?? this.role,
      );
  @override
  String toString() {
    return (StringBuffer('Member(')
          ..write('memberUid: $memberUid, ')
          ..write('mucUid: $mucUid, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      $mrjf($mrjc(memberUid.hashCode, $mrjc(mucUid.hashCode, role.hashCode)));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Member &&
          other.memberUid == this.memberUid &&
          other.mucUid == this.mucUid &&
          other.role == this.role);
}

class MembersCompanion extends UpdateCompanion<Member> {
  final Value<String> memberUid;
  final Value<String> mucUid;
  final Value<MucRole> role;
  const MembersCompanion({
    this.memberUid = const Value.absent(),
    this.mucUid = const Value.absent(),
    this.role = const Value.absent(),
  });
  MembersCompanion.insert({
    @required String memberUid,
    @required String mucUid,
    @required MucRole role,
  })  : memberUid = Value(memberUid),
        mucUid = Value(mucUid),
        role = Value(role);
  static Insertable<Member> custom({
    Expression<String> memberUid,
    Expression<String> mucUid,
    Expression<int> role,
  }) {
    return RawValuesInsertable({
      if (memberUid != null) 'member_uid': memberUid,
      if (mucUid != null) 'muc_uid': mucUid,
      if (role != null) 'role': role,
    });
  }

  MembersCompanion copyWith(
      {Value<String> memberUid, Value<String> mucUid, Value<MucRole> role}) {
    return MembersCompanion(
      memberUid: memberUid ?? this.memberUid,
      mucUid: mucUid ?? this.mucUid,
      role: role ?? this.role,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('memberUid: $memberUid, ')
          ..write('mucUid: $mucUid, ')
          ..write('role: $role')
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

  @override
  List<GeneratedColumn> get $columns => [memberUid, mucUid, role];
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
  GroupDao _groupDao;
  GroupDao get groupDao => _groupDao ??= GroupDao(this as Database);
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
        mucs
      ];
}
