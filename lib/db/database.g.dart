// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Message extends DataClass implements Insertable<Message> {
  final int roomId;
  final int id;
  final DateTime time;
  final String from;
  final String to;
  final String forwardedFrom;
  final int replyToId;
  final bool edited;
  final bool encrypted;
  final MessageType type;
  final String content;
  final bool seen;
  Message(
      {@required this.roomId,
      @required this.id,
      @required this.time,
      @required this.from,
      @required this.to,
      this.forwardedFrom,
      this.replyToId,
      @required this.edited,
      @required this.encrypted,
      @required this.type,
      @required this.content,
      @required this.seen});
  factory Message.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return Message(
      roomId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      time:
          dateTimeType.mapFromDatabaseResponse(data['${effectivePrefix}time']),
      from: stringType.mapFromDatabaseResponse(data['${effectivePrefix}from']),
      to: stringType.mapFromDatabaseResponse(data['${effectivePrefix}to']),
      forwardedFrom: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}forwarded_from']),
      replyToId: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}reply_to_id']),
      edited:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}edited']),
      encrypted:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}encrypted']),
      type: $MessagesTable.$converter0.mapToDart(
          intType.mapFromDatabaseResponse(data['${effectivePrefix}type'])),
      content:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}content']),
      seen: boolType.mapFromDatabaseResponse(data['${effectivePrefix}seen']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<int>(roomId);
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
    if (!nullToAbsent || forwardedFrom != null) {
      map['forwarded_from'] = Variable<String>(forwardedFrom);
    }
    if (!nullToAbsent || replyToId != null) {
      map['reply_to_id'] = Variable<int>(replyToId);
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
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || seen != null) {
      map['seen'] = Variable<bool>(seen);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      roomId:
          roomId == null && nullToAbsent ? const Value.absent() : Value(roomId),
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      time: time == null && nullToAbsent ? const Value.absent() : Value(time),
      from: from == null && nullToAbsent ? const Value.absent() : Value(from),
      to: to == null && nullToAbsent ? const Value.absent() : Value(to),
      forwardedFrom: forwardedFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(forwardedFrom),
      replyToId: replyToId == null && nullToAbsent
          ? const Value.absent()
          : Value(replyToId),
      edited:
          edited == null && nullToAbsent ? const Value.absent() : Value(edited),
      encrypted: encrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(encrypted),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      seen: seen == null && nullToAbsent ? const Value.absent() : Value(seen),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Message(
      roomId: serializer.fromJson<int>(json['roomId']),
      id: serializer.fromJson<int>(json['id']),
      time: serializer.fromJson<DateTime>(json['time']),
      from: serializer.fromJson<String>(json['from']),
      to: serializer.fromJson<String>(json['to']),
      forwardedFrom: serializer.fromJson<String>(json['forwardedFrom']),
      replyToId: serializer.fromJson<int>(json['replyToId']),
      edited: serializer.fromJson<bool>(json['edited']),
      encrypted: serializer.fromJson<bool>(json['encrypted']),
      type: serializer.fromJson<MessageType>(json['type']),
      content: serializer.fromJson<String>(json['content']),
      seen: serializer.fromJson<bool>(json['seen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roomId': serializer.toJson<int>(roomId),
      'id': serializer.toJson<int>(id),
      'time': serializer.toJson<DateTime>(time),
      'from': serializer.toJson<String>(from),
      'to': serializer.toJson<String>(to),
      'forwardedFrom': serializer.toJson<String>(forwardedFrom),
      'replyToId': serializer.toJson<int>(replyToId),
      'edited': serializer.toJson<bool>(edited),
      'encrypted': serializer.toJson<bool>(encrypted),
      'type': serializer.toJson<MessageType>(type),
      'content': serializer.toJson<String>(content),
      'seen': serializer.toJson<bool>(seen),
    };
  }

  Message copyWith(
          {int roomId,
          int id,
          DateTime time,
          String from,
          String to,
          String forwardedFrom,
          int replyToId,
          bool edited,
          bool encrypted,
          MessageType type,
          String content,
          bool seen}) =>
      Message(
        roomId: roomId ?? this.roomId,
        id: id ?? this.id,
        time: time ?? this.time,
        from: from ?? this.from,
        to: to ?? this.to,
        forwardedFrom: forwardedFrom ?? this.forwardedFrom,
        replyToId: replyToId ?? this.replyToId,
        edited: edited ?? this.edited,
        encrypted: encrypted ?? this.encrypted,
        type: type ?? this.type,
        content: content ?? this.content,
        seen: seen ?? this.seen,
      );
  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('roomId: $roomId, ')
          ..write('id: $id, ')
          ..write('time: $time, ')
          ..write('from: $from, ')
          ..write('to: $to, ')
          ..write('forwardedFrom: $forwardedFrom, ')
          ..write('replyToId: $replyToId, ')
          ..write('edited: $edited, ')
          ..write('encrypted: $encrypted, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('seen: $seen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
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
                          forwardedFrom.hashCode,
                          $mrjc(
                              replyToId.hashCode,
                              $mrjc(
                                  edited.hashCode,
                                  $mrjc(
                                      encrypted.hashCode,
                                      $mrjc(
                                          type.hashCode,
                                          $mrjc(content.hashCode,
                                              seen.hashCode))))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Message &&
          other.roomId == this.roomId &&
          other.id == this.id &&
          other.time == this.time &&
          other.from == this.from &&
          other.to == this.to &&
          other.forwardedFrom == this.forwardedFrom &&
          other.replyToId == this.replyToId &&
          other.edited == this.edited &&
          other.encrypted == this.encrypted &&
          other.type == this.type &&
          other.content == this.content &&
          other.seen == this.seen);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> roomId;
  final Value<int> id;
  final Value<DateTime> time;
  final Value<String> from;
  final Value<String> to;
  final Value<String> forwardedFrom;
  final Value<int> replyToId;
  final Value<bool> edited;
  final Value<bool> encrypted;
  final Value<MessageType> type;
  final Value<String> content;
  final Value<bool> seen;
  const MessagesCompanion({
    this.roomId = const Value.absent(),
    this.id = const Value.absent(),
    this.time = const Value.absent(),
    this.from = const Value.absent(),
    this.to = const Value.absent(),
    this.forwardedFrom = const Value.absent(),
    this.replyToId = const Value.absent(),
    this.edited = const Value.absent(),
    this.encrypted = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.seen = const Value.absent(),
  });
  MessagesCompanion.insert({
    @required int roomId,
    @required int id,
    @required DateTime time,
    @required String from,
    @required String to,
    this.forwardedFrom = const Value.absent(),
    this.replyToId = const Value.absent(),
    this.edited = const Value.absent(),
    this.encrypted = const Value.absent(),
    @required MessageType type,
    @required String content,
    this.seen = const Value.absent(),
  })  : roomId = Value(roomId),
        id = Value(id),
        time = Value(time),
        from = Value(from),
        to = Value(to),
        type = Value(type),
        content = Value(content);
  static Insertable<Message> custom({
    Expression<int> roomId,
    Expression<int> id,
    Expression<DateTime> time,
    Expression<String> from,
    Expression<String> to,
    Expression<String> forwardedFrom,
    Expression<int> replyToId,
    Expression<bool> edited,
    Expression<bool> encrypted,
    Expression<int> type,
    Expression<String> content,
    Expression<bool> seen,
  }) {
    return RawValuesInsertable({
      if (roomId != null) 'room_id': roomId,
      if (id != null) 'id': id,
      if (time != null) 'time': time,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (forwardedFrom != null) 'forwarded_from': forwardedFrom,
      if (replyToId != null) 'reply_to_id': replyToId,
      if (edited != null) 'edited': edited,
      if (encrypted != null) 'encrypted': encrypted,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (seen != null) 'seen': seen,
    });
  }

  MessagesCompanion copyWith(
      {Value<int> roomId,
      Value<int> id,
      Value<DateTime> time,
      Value<String> from,
      Value<String> to,
      Value<String> forwardedFrom,
      Value<int> replyToId,
      Value<bool> edited,
      Value<bool> encrypted,
      Value<MessageType> type,
      Value<String> content,
      Value<bool> seen}) {
    return MessagesCompanion(
      roomId: roomId ?? this.roomId,
      id: id ?? this.id,
      time: time ?? this.time,
      from: from ?? this.from,
      to: to ?? this.to,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      replyToId: replyToId ?? this.replyToId,
      edited: edited ?? this.edited,
      encrypted: encrypted ?? this.encrypted,
      type: type ?? this.type,
      content: content ?? this.content,
      seen: seen ?? this.seen,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
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
    if (forwardedFrom.present) {
      map['forwarded_from'] = Variable<String>(forwardedFrom.value);
    }
    if (replyToId.present) {
      map['reply_to_id'] = Variable<int>(replyToId.value);
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
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (seen.present) {
      map['seen'] = Variable<bool>(seen.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('roomId: $roomId, ')
          ..write('id: $id, ')
          ..write('time: $time, ')
          ..write('from: $from, ')
          ..write('to: $to, ')
          ..write('forwardedFrom: $forwardedFrom, ')
          ..write('replyToId: $replyToId, ')
          ..write('edited: $edited, ')
          ..write('encrypted: $encrypted, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('seen: $seen')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  final GeneratedDatabase _db;
  final String _alias;
  $MessagesTable(this._db, [this._alias]);
  final VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  GeneratedIntColumn _roomId;
  @override
  GeneratedIntColumn get roomId => _roomId ??= _constructRoomId();
  GeneratedIntColumn _constructRoomId() {
    return GeneratedIntColumn(
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

  final VerificationMeta _fromMeta = const VerificationMeta('from');
  GeneratedTextColumn _from;
  @override
  GeneratedTextColumn get from => _from ??= _constructFrom();
  GeneratedTextColumn _constructFrom() {
    return GeneratedTextColumn('from', $tableName, false,
        minTextLength: 22, maxTextLength: 22);
  }

  final VerificationMeta _toMeta = const VerificationMeta('to');
  GeneratedTextColumn _to;
  @override
  GeneratedTextColumn get to => _to ??= _constructTo();
  GeneratedTextColumn _constructTo() {
    return GeneratedTextColumn('to', $tableName, false,
        minTextLength: 22, maxTextLength: 22);
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

  final VerificationMeta _contentMeta = const VerificationMeta('content');
  GeneratedTextColumn _content;
  @override
  GeneratedTextColumn get content => _content ??= _constructContent();
  GeneratedTextColumn _constructContent() {
    return GeneratedTextColumn(
      'content',
      $tableName,
      false,
    );
  }

  final VerificationMeta _seenMeta = const VerificationMeta('seen');
  GeneratedBoolColumn _seen;
  @override
  GeneratedBoolColumn get seen => _seen ??= _constructSeen();
  GeneratedBoolColumn _constructSeen() {
    return GeneratedBoolColumn('seen', $tableName, false,
        defaultValue: Constant(false));
  }

  @override
  List<GeneratedColumn> get $columns => [
        roomId,
        id,
        time,
        from,
        to,
        forwardedFrom,
        replyToId,
        edited,
        encrypted,
        type,
        content,
        seen
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
    if (data.containsKey('room_id')) {
      context.handle(_roomIdMeta,
          roomId.isAcceptableOrUnknown(data['room_id'], _roomIdMeta));
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('forwarded_from')) {
      context.handle(
          _forwardedFromMeta,
          forwardedFrom.isAcceptableOrUnknown(
              data['forwarded_from'], _forwardedFromMeta));
    }
    if (data.containsKey('reply_to_id')) {
      context.handle(_replyToIdMeta,
          replyToId.isAcceptableOrUnknown(data['reply_to_id'], _replyToIdMeta));
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
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content'], _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('seen')) {
      context.handle(
          _seenMeta, seen.isAcceptableOrUnknown(data['seen'], _seenMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roomId, id};
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
  final int roomId;
  final String sender;
  final String reciever;
  final String mentioned;
  final int lastMessage;
  Room(
      {@required this.roomId,
      @required this.sender,
      @required this.reciever,
      this.mentioned,
      @required this.lastMessage});
  factory Room.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return Room(
      roomId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}room_id']),
      sender:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}sender']),
      reciever: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}reciever']),
      mentioned: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}mentioned']),
      lastMessage: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}last_message']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<int>(roomId);
    }
    if (!nullToAbsent || sender != null) {
      map['sender'] = Variable<String>(sender);
    }
    if (!nullToAbsent || reciever != null) {
      map['reciever'] = Variable<String>(reciever);
    }
    if (!nullToAbsent || mentioned != null) {
      map['mentioned'] = Variable<String>(mentioned);
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
      sender:
          sender == null && nullToAbsent ? const Value.absent() : Value(sender),
      reciever: reciever == null && nullToAbsent
          ? const Value.absent()
          : Value(reciever),
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
      roomId: serializer.fromJson<int>(json['roomId']),
      sender: serializer.fromJson<String>(json['sender']),
      reciever: serializer.fromJson<String>(json['reciever']),
      mentioned: serializer.fromJson<String>(json['mentioned']),
      lastMessage: serializer.fromJson<int>(json['lastMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roomId': serializer.toJson<int>(roomId),
      'sender': serializer.toJson<String>(sender),
      'reciever': serializer.toJson<String>(reciever),
      'mentioned': serializer.toJson<String>(mentioned),
      'lastMessage': serializer.toJson<int>(lastMessage),
    };
  }

  Room copyWith(
          {int roomId,
          String sender,
          String reciever,
          String mentioned,
          int lastMessage}) =>
      Room(
        roomId: roomId ?? this.roomId,
        sender: sender ?? this.sender,
        reciever: reciever ?? this.reciever,
        mentioned: mentioned ?? this.mentioned,
        lastMessage: lastMessage ?? this.lastMessage,
      );
  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('roomId: $roomId, ')
          ..write('sender: $sender, ')
          ..write('reciever: $reciever, ')
          ..write('mentioned: $mentioned, ')
          ..write('lastMessage: $lastMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      roomId.hashCode,
      $mrjc(
          sender.hashCode,
          $mrjc(reciever.hashCode,
              $mrjc(mentioned.hashCode, lastMessage.hashCode)))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Room &&
          other.roomId == this.roomId &&
          other.sender == this.sender &&
          other.reciever == this.reciever &&
          other.mentioned == this.mentioned &&
          other.lastMessage == this.lastMessage);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<int> roomId;
  final Value<String> sender;
  final Value<String> reciever;
  final Value<String> mentioned;
  final Value<int> lastMessage;
  const RoomsCompanion({
    this.roomId = const Value.absent(),
    this.sender = const Value.absent(),
    this.reciever = const Value.absent(),
    this.mentioned = const Value.absent(),
    this.lastMessage = const Value.absent(),
  });
  RoomsCompanion.insert({
    this.roomId = const Value.absent(),
    @required String sender,
    @required String reciever,
    this.mentioned = const Value.absent(),
    @required int lastMessage,
  })  : sender = Value(sender),
        reciever = Value(reciever),
        lastMessage = Value(lastMessage);
  static Insertable<Room> custom({
    Expression<int> roomId,
    Expression<String> sender,
    Expression<String> reciever,
    Expression<String> mentioned,
    Expression<int> lastMessage,
  }) {
    return RawValuesInsertable({
      if (roomId != null) 'room_id': roomId,
      if (sender != null) 'sender': sender,
      if (reciever != null) 'reciever': reciever,
      if (mentioned != null) 'mentioned': mentioned,
      if (lastMessage != null) 'last_message': lastMessage,
    });
  }

  RoomsCompanion copyWith(
      {Value<int> roomId,
      Value<String> sender,
      Value<String> reciever,
      Value<String> mentioned,
      Value<int> lastMessage}) {
    return RoomsCompanion(
      roomId: roomId ?? this.roomId,
      sender: sender ?? this.sender,
      reciever: reciever ?? this.reciever,
      mentioned: mentioned ?? this.mentioned,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (reciever.present) {
      map['reciever'] = Variable<String>(reciever.value);
    }
    if (mentioned.present) {
      map['mentioned'] = Variable<String>(mentioned.value);
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
          ..write('sender: $sender, ')
          ..write('reciever: $reciever, ')
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
  GeneratedIntColumn _roomId;
  @override
  GeneratedIntColumn get roomId => _roomId ??= _constructRoomId();
  GeneratedIntColumn _constructRoomId() {
    return GeneratedIntColumn('room_id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _senderMeta = const VerificationMeta('sender');
  GeneratedTextColumn _sender;
  @override
  GeneratedTextColumn get sender => _sender ??= _constructSender();
  GeneratedTextColumn _constructSender() {
    return GeneratedTextColumn('sender', $tableName, false,
        minTextLength: 22, maxTextLength: 22);
  }

  final VerificationMeta _recieverMeta = const VerificationMeta('reciever');
  GeneratedTextColumn _reciever;
  @override
  GeneratedTextColumn get reciever => _reciever ??= _constructReciever();
  GeneratedTextColumn _constructReciever() {
    return GeneratedTextColumn('reciever', $tableName, false,
        minTextLength: 22, maxTextLength: 22);
  }

  final VerificationMeta _mentionedMeta = const VerificationMeta('mentioned');
  GeneratedTextColumn _mentioned;
  @override
  GeneratedTextColumn get mentioned => _mentioned ??= _constructMentioned();
  GeneratedTextColumn _constructMentioned() {
    return GeneratedTextColumn('mentioned', $tableName, true,
        minTextLength: 22, maxTextLength: 22);
  }

  final VerificationMeta _lastMessageMeta =
      const VerificationMeta('lastMessage');
  GeneratedIntColumn _lastMessage;
  @override
  GeneratedIntColumn get lastMessage =>
      _lastMessage ??= _constructLastMessage();
  GeneratedIntColumn _constructLastMessage() {
    return GeneratedIntColumn('last_message', $tableName, false,
        $customConstraints: 'REFERENCES messages(id)');
  }

  @override
  List<GeneratedColumn> get $columns =>
      [roomId, sender, reciever, mentioned, lastMessage];
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
    }
    if (data.containsKey('sender')) {
      context.handle(_senderMeta,
          sender.isAcceptableOrUnknown(data['sender'], _senderMeta));
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('reciever')) {
      context.handle(_recieverMeta,
          reciever.isAcceptableOrUnknown(data['reciever'], _recieverMeta));
    } else if (isInserting) {
      context.missing(_recieverMeta);
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
      @required this.lastAvatarFileId,
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
    @required String lastAvatarFileId,
    @required String phoneNumber,
    @required String firstName,
    @required String lastName,
    @required DateTime lastSeen,
    @required bool notification,
    @required bool isBlock,
    @required bool isOnline,
  })  : uid = Value(uid),
        lastUpdateAvatarTime = Value(lastUpdateAvatarTime),
        lastAvatarFileId = Value(lastAvatarFileId),
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
      false,
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
    } else if (isInserting) {
      context.missing(_lastAvatarFileIdMeta);
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
  final String id;
  final String path;
  final String fileName;
  FileInfo({@required this.id, @required this.path, @required this.fileName});
  factory FileInfo.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    return FileInfo(
      id: stringType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      path: stringType.mapFromDatabaseResponse(data['${effectivePrefix}path']),
      fileName: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}file_name']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<String>(id);
    }
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    return map;
  }

  FileInfosCompanion toCompanion(bool nullToAbsent) {
    return FileInfosCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      fileName: fileName == null && nullToAbsent
          ? const Value.absent()
          : Value(fileName),
    );
  }

  factory FileInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return FileInfo(
      id: serializer.fromJson<String>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      fileName: serializer.fromJson<String>(json['fileName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'path': serializer.toJson<String>(path),
      'fileName': serializer.toJson<String>(fileName),
    };
  }

  FileInfo copyWith({String id, String path, String fileName}) => FileInfo(
        id: id ?? this.id,
        path: path ?? this.path,
        fileName: fileName ?? this.fileName,
      );
  @override
  String toString() {
    return (StringBuffer('FileInfo(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('fileName: $fileName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      $mrjf($mrjc(id.hashCode, $mrjc(path.hashCode, fileName.hashCode)));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is FileInfo &&
          other.id == this.id &&
          other.path == this.path &&
          other.fileName == this.fileName);
}

class FileInfosCompanion extends UpdateCompanion<FileInfo> {
  final Value<String> id;
  final Value<String> path;
  final Value<String> fileName;
  const FileInfosCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.fileName = const Value.absent(),
  });
  FileInfosCompanion.insert({
    @required String id,
    @required String path,
    @required String fileName,
  })  : id = Value(id),
        path = Value(path),
        fileName = Value(fileName);
  static Insertable<FileInfo> custom({
    Expression<String> id,
    Expression<String> path,
    Expression<String> fileName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (fileName != null) 'file_name': fileName,
    });
  }

  FileInfosCompanion copyWith(
      {Value<String> id, Value<String> path, Value<String> fileName}) {
    return FileInfosCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      fileName: fileName ?? this.fileName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileInfosCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('fileName: $fileName')
          ..write(')'))
        .toString();
  }
}

class $FileInfosTable extends FileInfos
    with TableInfo<$FileInfosTable, FileInfo> {
  final GeneratedDatabase _db;
  final String _alias;
  $FileInfosTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedTextColumn _id;
  @override
  GeneratedTextColumn get id => _id ??= _constructId();
  GeneratedTextColumn _constructId() {
    return GeneratedTextColumn(
      'id',
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

  @override
  List<GeneratedColumn> get $columns => [id, path, fileName];
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
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
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [messages, rooms, avatars, contacts, fileInfos];
}
