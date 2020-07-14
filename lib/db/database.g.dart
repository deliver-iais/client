// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Message extends DataClass implements Insertable<Message> {
  final int chatId;
  final int id;
  final DateTime time;
  final String from;
  final String to;
  final String forwardedFrom;
  final int replyToId;
  final bool edited;
  final bool encrypted;
  final MessageType type;
  Message(
      {@required this.chatId,
      @required this.id,
      @required this.time,
      @required this.from,
      @required this.to,
      @required this.forwardedFrom,
      @required this.replyToId,
      @required this.edited,
      @required this.encrypted,
      @required this.type});
  factory Message.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return Message(
      chatId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}chat_id']),
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
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || chatId != null) {
      map['chat_id'] = Variable<int>(chatId);
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
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      chatId:
          chatId == null && nullToAbsent ? const Value.absent() : Value(chatId),
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
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Message(
      chatId: serializer.fromJson<int>(json['chatId']),
      id: serializer.fromJson<int>(json['id']),
      time: serializer.fromJson<DateTime>(json['time']),
      from: serializer.fromJson<String>(json['from']),
      to: serializer.fromJson<String>(json['to']),
      forwardedFrom: serializer.fromJson<String>(json['forwardedFrom']),
      replyToId: serializer.fromJson<int>(json['replyToId']),
      edited: serializer.fromJson<bool>(json['edited']),
      encrypted: serializer.fromJson<bool>(json['encrypted']),
      type: serializer.fromJson<MessageType>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<int>(chatId),
      'id': serializer.toJson<int>(id),
      'time': serializer.toJson<DateTime>(time),
      'from': serializer.toJson<String>(from),
      'to': serializer.toJson<String>(to),
      'forwardedFrom': serializer.toJson<String>(forwardedFrom),
      'replyToId': serializer.toJson<int>(replyToId),
      'edited': serializer.toJson<bool>(edited),
      'encrypted': serializer.toJson<bool>(encrypted),
      'type': serializer.toJson<MessageType>(type),
    };
  }

  Message copyWith(
          {int chatId,
          int id,
          DateTime time,
          String from,
          String to,
          String forwardedFrom,
          int replyToId,
          bool edited,
          bool encrypted,
          MessageType type}) =>
      Message(
        chatId: chatId ?? this.chatId,
        id: id ?? this.id,
        time: time ?? this.time,
        from: from ?? this.from,
        to: to ?? this.to,
        forwardedFrom: forwardedFrom ?? this.forwardedFrom,
        replyToId: replyToId ?? this.replyToId,
        edited: edited ?? this.edited,
        encrypted: encrypted ?? this.encrypted,
        type: type ?? this.type,
      );
  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('chatId: $chatId, ')
          ..write('id: $id, ')
          ..write('time: $time, ')
          ..write('from: $from, ')
          ..write('to: $to, ')
          ..write('forwardedFrom: $forwardedFrom, ')
          ..write('replyToId: $replyToId, ')
          ..write('edited: $edited, ')
          ..write('encrypted: $encrypted, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      chatId.hashCode,
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
                                  $mrjc(encrypted.hashCode,
                                      type.hashCode))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Message &&
          other.chatId == this.chatId &&
          other.id == this.id &&
          other.time == this.time &&
          other.from == this.from &&
          other.to == this.to &&
          other.forwardedFrom == this.forwardedFrom &&
          other.replyToId == this.replyToId &&
          other.edited == this.edited &&
          other.encrypted == this.encrypted &&
          other.type == this.type);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> chatId;
  final Value<int> id;
  final Value<DateTime> time;
  final Value<String> from;
  final Value<String> to;
  final Value<String> forwardedFrom;
  final Value<int> replyToId;
  final Value<bool> edited;
  final Value<bool> encrypted;
  final Value<MessageType> type;
  const MessagesCompanion({
    this.chatId = const Value.absent(),
    this.id = const Value.absent(),
    this.time = const Value.absent(),
    this.from = const Value.absent(),
    this.to = const Value.absent(),
    this.forwardedFrom = const Value.absent(),
    this.replyToId = const Value.absent(),
    this.edited = const Value.absent(),
    this.encrypted = const Value.absent(),
    this.type = const Value.absent(),
  });
  MessagesCompanion.insert({
    @required int chatId,
    @required int id,
    @required DateTime time,
    @required String from,
    @required String to,
    @required String forwardedFrom,
    @required int replyToId,
    this.edited = const Value.absent(),
    this.encrypted = const Value.absent(),
    @required MessageType type,
  })  : chatId = Value(chatId),
        id = Value(id),
        time = Value(time),
        from = Value(from),
        to = Value(to),
        forwardedFrom = Value(forwardedFrom),
        replyToId = Value(replyToId),
        type = Value(type);
  static Insertable<Message> custom({
    Expression<int> chatId,
    Expression<int> id,
    Expression<DateTime> time,
    Expression<String> from,
    Expression<String> to,
    Expression<String> forwardedFrom,
    Expression<int> replyToId,
    Expression<bool> edited,
    Expression<bool> encrypted,
    Expression<int> type,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (id != null) 'id': id,
      if (time != null) 'time': time,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (forwardedFrom != null) 'forwarded_from': forwardedFrom,
      if (replyToId != null) 'reply_to_id': replyToId,
      if (edited != null) 'edited': edited,
      if (encrypted != null) 'encrypted': encrypted,
      if (type != null) 'type': type,
    });
  }

  MessagesCompanion copyWith(
      {Value<int> chatId,
      Value<int> id,
      Value<DateTime> time,
      Value<String> from,
      Value<String> to,
      Value<String> forwardedFrom,
      Value<int> replyToId,
      Value<bool> edited,
      Value<bool> encrypted,
      Value<MessageType> type}) {
    return MessagesCompanion(
      chatId: chatId ?? this.chatId,
      id: id ?? this.id,
      time: time ?? this.time,
      from: from ?? this.from,
      to: to ?? this.to,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      replyToId: replyToId ?? this.replyToId,
      edited: edited ?? this.edited,
      encrypted: encrypted ?? this.encrypted,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('chatId: $chatId, ')
          ..write('id: $id, ')
          ..write('time: $time, ')
          ..write('from: $from, ')
          ..write('to: $to, ')
          ..write('forwardedFrom: $forwardedFrom, ')
          ..write('replyToId: $replyToId, ')
          ..write('edited: $edited, ')
          ..write('encrypted: $encrypted, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  final GeneratedDatabase _db;
  final String _alias;
  $MessagesTable(this._db, [this._alias]);
  final VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  GeneratedIntColumn _chatId;
  @override
  GeneratedIntColumn get chatId => _chatId ??= _constructChatId();
  GeneratedIntColumn _constructChatId() {
    return GeneratedIntColumn(
      'chat_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
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
    return GeneratedTextColumn('forwarded_from', $tableName, false,
        minTextLength: 22, maxTextLength: 22);
  }

  final VerificationMeta _replyToIdMeta = const VerificationMeta('replyToId');
  GeneratedIntColumn _replyToId;
  @override
  GeneratedIntColumn get replyToId => _replyToId ??= _constructReplyToId();
  GeneratedIntColumn _constructReplyToId() {
    return GeneratedIntColumn(
      'reply_to_id',
      $tableName,
      false,
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

  @override
  List<GeneratedColumn> get $columns => [
        chatId,
        id,
        time,
        from,
        to,
        forwardedFrom,
        replyToId,
        edited,
        encrypted,
        type
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
    if (data.containsKey('chat_id')) {
      context.handle(_chatIdMeta,
          chatId.isAcceptableOrUnknown(data['chat_id'], _chatIdMeta));
    } else if (isInserting) {
      context.missing(_chatIdMeta);
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
    } else if (isInserting) {
      context.missing(_forwardedFromMeta);
    }
    if (data.containsKey('reply_to_id')) {
      context.handle(_replyToIdMeta,
          replyToId.isAcceptableOrUnknown(data['reply_to_id'], _replyToIdMeta));
    } else if (isInserting) {
      context.missing(_replyToIdMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId, id};
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

class Chat extends DataClass implements Insertable<Chat> {
  final int chatId;
  final String sender;
  final String reciever;
  final String mentioned;
  final int lastMessage;
  Chat(
      {@required this.chatId,
      @required this.sender,
      @required this.reciever,
      @required this.mentioned,
      @required this.lastMessage});
  factory Chat.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return Chat(
      chatId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}chat_id']),
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
    if (!nullToAbsent || chatId != null) {
      map['chat_id'] = Variable<int>(chatId);
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

  ChatsCompanion toCompanion(bool nullToAbsent) {
    return ChatsCompanion(
      chatId:
          chatId == null && nullToAbsent ? const Value.absent() : Value(chatId),
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

  factory Chat.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Chat(
      chatId: serializer.fromJson<int>(json['chatId']),
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
      'chatId': serializer.toJson<int>(chatId),
      'sender': serializer.toJson<String>(sender),
      'reciever': serializer.toJson<String>(reciever),
      'mentioned': serializer.toJson<String>(mentioned),
      'lastMessage': serializer.toJson<int>(lastMessage),
    };
  }

  Chat copyWith(
          {int chatId,
          String sender,
          String reciever,
          String mentioned,
          int lastMessage}) =>
      Chat(
        chatId: chatId ?? this.chatId,
        sender: sender ?? this.sender,
        reciever: reciever ?? this.reciever,
        mentioned: mentioned ?? this.mentioned,
        lastMessage: lastMessage ?? this.lastMessage,
      );
  @override
  String toString() {
    return (StringBuffer('Chat(')
          ..write('chatId: $chatId, ')
          ..write('sender: $sender, ')
          ..write('reciever: $reciever, ')
          ..write('mentioned: $mentioned, ')
          ..write('lastMessage: $lastMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      chatId.hashCode,
      $mrjc(
          sender.hashCode,
          $mrjc(reciever.hashCode,
              $mrjc(mentioned.hashCode, lastMessage.hashCode)))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Chat &&
          other.chatId == this.chatId &&
          other.sender == this.sender &&
          other.reciever == this.reciever &&
          other.mentioned == this.mentioned &&
          other.lastMessage == this.lastMessage);
}

class ChatsCompanion extends UpdateCompanion<Chat> {
  final Value<int> chatId;
  final Value<String> sender;
  final Value<String> reciever;
  final Value<String> mentioned;
  final Value<int> lastMessage;
  const ChatsCompanion({
    this.chatId = const Value.absent(),
    this.sender = const Value.absent(),
    this.reciever = const Value.absent(),
    this.mentioned = const Value.absent(),
    this.lastMessage = const Value.absent(),
  });
  ChatsCompanion.insert({
    this.chatId = const Value.absent(),
    @required String sender,
    @required String reciever,
    @required String mentioned,
    @required int lastMessage,
  })  : sender = Value(sender),
        reciever = Value(reciever),
        mentioned = Value(mentioned),
        lastMessage = Value(lastMessage);
  static Insertable<Chat> custom({
    Expression<int> chatId,
    Expression<String> sender,
    Expression<String> reciever,
    Expression<String> mentioned,
    Expression<int> lastMessage,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (sender != null) 'sender': sender,
      if (reciever != null) 'reciever': reciever,
      if (mentioned != null) 'mentioned': mentioned,
      if (lastMessage != null) 'last_message': lastMessage,
    });
  }

  ChatsCompanion copyWith(
      {Value<int> chatId,
      Value<String> sender,
      Value<String> reciever,
      Value<String> mentioned,
      Value<int> lastMessage}) {
    return ChatsCompanion(
      chatId: chatId ?? this.chatId,
      sender: sender ?? this.sender,
      reciever: reciever ?? this.reciever,
      mentioned: mentioned ?? this.mentioned,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
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
    return (StringBuffer('ChatsCompanion(')
          ..write('chatId: $chatId, ')
          ..write('sender: $sender, ')
          ..write('reciever: $reciever, ')
          ..write('mentioned: $mentioned, ')
          ..write('lastMessage: $lastMessage')
          ..write(')'))
        .toString();
  }
}

class $ChatsTable extends Chats with TableInfo<$ChatsTable, Chat> {
  final GeneratedDatabase _db;
  final String _alias;
  $ChatsTable(this._db, [this._alias]);
  final VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  GeneratedIntColumn _chatId;
  @override
  GeneratedIntColumn get chatId => _chatId ??= _constructChatId();
  GeneratedIntColumn _constructChatId() {
    return GeneratedIntColumn('chat_id', $tableName, false,
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
    return GeneratedTextColumn('mentioned', $tableName, false,
        minTextLength: 22, maxTextLength: 22);
  }

  final VerificationMeta _lastMessageMeta =
      const VerificationMeta('lastMessage');
  GeneratedIntColumn _lastMessage;
  @override
  GeneratedIntColumn get lastMessage =>
      _lastMessage ??= _constructLastMessage();
  GeneratedIntColumn _constructLastMessage() {
    return GeneratedIntColumn(
      'last_message',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns =>
      [chatId, sender, reciever, mentioned, lastMessage];
  @override
  $ChatsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'chats';
  @override
  final String actualTableName = 'chats';
  @override
  VerificationContext validateIntegrity(Insertable<Chat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chat_id')) {
      context.handle(_chatIdMeta,
          chatId.isAcceptableOrUnknown(data['chat_id'], _chatIdMeta));
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
    } else if (isInserting) {
      context.missing(_mentionedMeta);
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
  Set<GeneratedColumn> get $primaryKey => {chatId};
  @override
  Chat map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Chat.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $ChatsTable createAlias(String alias) {
    return $ChatsTable(_db, alias);
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $MessagesTable _messages;
  $MessagesTable get messages => _messages ??= $MessagesTable(this);
  $ChatsTable _chats;
  $ChatsTable get chats => _chats ??= $ChatsTable(this);
  MessageDao _messageDao;
  MessageDao get messageDao => _messageDao ??= MessageDao(this as Database);
  ChatDao _chatDao;
  ChatDao get chatDao => _chatDao ??= ChatDao(this as Database);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [messages, chats];
}
