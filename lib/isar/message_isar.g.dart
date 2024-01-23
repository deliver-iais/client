// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMessageIsarCollection on Isar {
  IsarCollection<MessageIsar> get messageIsars => this.collection();
}

const MessageIsarSchema = CollectionSchema(
  name: r'MessageIsar',
  id: 3260995708908258659,
  properties: {
    r'edited': PropertySchema(
      id: 0,
      name: r'edited',
      type: IsarType.bool,
    ),
    r'encrypted': PropertySchema(
      id: 1,
      name: r'encrypted',
      type: IsarType.bool,
    ),
    r'forwardedFrom': PropertySchema(
      id: 2,
      name: r'forwardedFrom',
      type: IsarType.string,
    ),
    r'from': PropertySchema(
      id: 3,
      name: r'from',
      type: IsarType.string,
    ),
    r'generatedBy': PropertySchema(
      id: 4,
      name: r'generatedBy',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 5,
      name: r'id',
      type: IsarType.long,
    ),
    r'isHidden': PropertySchema(
      id: 6,
      name: r'isHidden',
      type: IsarType.bool,
    ),
    r'isLocalMessage': PropertySchema(
      id: 7,
      name: r'isLocalMessage',
      type: IsarType.bool,
    ),
    r'json': PropertySchema(
      id: 8,
      name: r'json',
      type: IsarType.string,
    ),
    r'localNetworkMessageId': PropertySchema(
      id: 9,
      name: r'localNetworkMessageId',
      type: IsarType.long,
    ),
    r'markup': PropertySchema(
      id: 10,
      name: r'markup',
      type: IsarType.string,
    ),
    r'needToBackup': PropertySchema(
      id: 11,
      name: r'needToBackup',
      type: IsarType.bool,
    ),
    r'packetId': PropertySchema(
      id: 12,
      name: r'packetId',
      type: IsarType.string,
    ),
    r'replyToId': PropertySchema(
      id: 13,
      name: r'replyToId',
      type: IsarType.long,
    ),
    r'roomUid': PropertySchema(
      id: 14,
      name: r'roomUid',
      type: IsarType.string,
    ),
    r'time': PropertySchema(
      id: 15,
      name: r'time',
      type: IsarType.long,
    ),
    r'to': PropertySchema(
      id: 16,
      name: r'to',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 17,
      name: r'type',
      type: IsarType.byte,
      enumMap: _MessageIsartypeEnumValueMap,
    )
  },
  estimateSize: _messageIsarEstimateSize,
  serialize: _messageIsarSerialize,
  deserialize: _messageIsarDeserialize,
  deserializeProp: _messageIsarDeserializeProp,
  idName: r'dbId',
  indexes: {
    r'roomUid': IndexSchema(
      id: -4759624696575789270,
      name: r'roomUid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'roomUid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _messageIsarGetId,
  getLinks: _messageIsarGetLinks,
  attach: _messageIsarAttach,
  version: '3.1.0+1',
);

int _messageIsarEstimateSize(
  MessageIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.forwardedFrom;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.from.length * 3;
  {
    final value = object.generatedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.json.length * 3;
  {
    final value = object.markup;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.packetId.length * 3;
  bytesCount += 3 + object.roomUid.length * 3;
  bytesCount += 3 + object.to.length * 3;
  return bytesCount;
}

void _messageIsarSerialize(
  MessageIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.edited);
  writer.writeBool(offsets[1], object.encrypted);
  writer.writeString(offsets[2], object.forwardedFrom);
  writer.writeString(offsets[3], object.from);
  writer.writeString(offsets[4], object.generatedBy);
  writer.writeLong(offsets[5], object.id);
  writer.writeBool(offsets[6], object.isHidden);
  writer.writeBool(offsets[7], object.isLocalMessage);
  writer.writeString(offsets[8], object.json);
  writer.writeLong(offsets[9], object.localNetworkMessageId);
  writer.writeString(offsets[10], object.markup);
  writer.writeBool(offsets[11], object.needToBackup);
  writer.writeString(offsets[12], object.packetId);
  writer.writeLong(offsets[13], object.replyToId);
  writer.writeString(offsets[14], object.roomUid);
  writer.writeLong(offsets[15], object.time);
  writer.writeString(offsets[16], object.to);
  writer.writeByte(offsets[17], object.type.index);
}

MessageIsar _messageIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MessageIsar(
    edited: reader.readBoolOrNull(offsets[0]) ?? false,
    encrypted: reader.readBoolOrNull(offsets[1]) ?? false,
    forwardedFrom: reader.readStringOrNull(offsets[2]),
    from: reader.readString(offsets[3]),
    generatedBy: reader.readStringOrNull(offsets[4]),
    id: reader.readLongOrNull(offsets[5]),
    isHidden: reader.readBoolOrNull(offsets[6]) ?? false,
    isLocalMessage: reader.readBoolOrNull(offsets[7]) ?? false,
    json: reader.readString(offsets[8]),
    localNetworkMessageId: reader.readLongOrNull(offsets[9]),
    markup: reader.readStringOrNull(offsets[10]),
    needToBackup: reader.readBoolOrNull(offsets[11]) ?? false,
    packetId: reader.readString(offsets[12]),
    replyToId: reader.readLongOrNull(offsets[13]) ?? 0,
    roomUid: reader.readString(offsets[14]),
    time: reader.readLong(offsets[15]),
    to: reader.readString(offsets[16]),
    type: _MessageIsartypeValueEnumMap[reader.readByteOrNull(offsets[17])] ??
        MessageType.NOT_SET,
  );
  object.dbId = id;
  return object;
}

P _messageIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (_MessageIsartypeValueEnumMap[reader.readByteOrNull(offset)] ??
          MessageType.NOT_SET) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MessageIsartypeEnumValueMap = {
  'TEXT': 0,
  'FILE': 1,
  'STICKER': 2,
  'LOCATION': 3,
  'LIVE_LOCATION': 4,
  'POLL': 5,
  'FORM': 6,
  'PERSISTENT_EVENT': 7,
  'NOT_SET': 8,
  'BUTTONS': 9,
  'SHARE_UID': 10,
  'FORM_RESULT': 11,
  'SHARE_PRIVATE_DATA_REQUEST': 12,
  'SHARE_PRIVATE_DATA_ACCEPTANCE': 13,
  'CALL': 14,
  'TABLE': 15,
  'TRANSACTION': 16,
  'PAYMENT_INFORMATION': 17,
  'CALL_LOG': 18,
};
const _MessageIsartypeValueEnumMap = {
  0: MessageType.TEXT,
  1: MessageType.FILE,
  2: MessageType.STICKER,
  3: MessageType.LOCATION,
  4: MessageType.LIVE_LOCATION,
  5: MessageType.POLL,
  6: MessageType.FORM,
  7: MessageType.PERSISTENT_EVENT,
  8: MessageType.NOT_SET,
  9: MessageType.BUTTONS,
  10: MessageType.SHARE_UID,
  11: MessageType.FORM_RESULT,
  12: MessageType.SHARE_PRIVATE_DATA_REQUEST,
  13: MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE,
  14: MessageType.CALL,
  15: MessageType.TABLE,
  16: MessageType.TRANSACTION,
  17: MessageType.PAYMENT_INFORMATION,
  18: MessageType.CALL_LOG,
};

Id _messageIsarGetId(MessageIsar object) {
  return object.dbId;
}

List<IsarLinkBase<dynamic>> _messageIsarGetLinks(MessageIsar object) {
  return [];
}

void _messageIsarAttach(
    IsarCollection<dynamic> col, Id id, MessageIsar object) {
  object.dbId = id;
}

extension MessageIsarQueryWhereSort
    on QueryBuilder<MessageIsar, MessageIsar, QWhere> {
  QueryBuilder<MessageIsar, MessageIsar, QAfterWhere> anyDbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MessageIsarQueryWhere
    on QueryBuilder<MessageIsar, MessageIsar, QWhereClause> {
  QueryBuilder<MessageIsar, MessageIsar, QAfterWhereClause> dbIdEqualTo(
      Id dbId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: dbId,
        upper: dbId,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterWhereClause> dbIdNotEqualTo(
      Id dbId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: dbId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: dbId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: dbId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: dbId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterWhereClause> dbIdGreaterThan(
      Id dbId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dbId, includeLower: include),
      );
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterWhereClause> dbIdLessThan(
      Id dbId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dbId, includeUpper: include),
      );
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterWhereClause> dbIdBetween(
    Id lowerDbId,
    Id upperDbId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerDbId,
        includeLower: includeLower,
        upper: upperDbId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterWhereClause> roomUidEqualTo(
      String roomUid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'roomUid',
        value: [roomUid],
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterWhereClause> roomUidNotEqualTo(
      String roomUid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roomUid',
              lower: [],
              upper: [roomUid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roomUid',
              lower: [roomUid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roomUid',
              lower: [roomUid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roomUid',
              lower: [],
              upper: [roomUid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MessageIsarQueryFilter
    on QueryBuilder<MessageIsar, MessageIsar, QFilterCondition> {
  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> dbIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dbId',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> dbIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dbId',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> dbIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dbId',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> dbIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dbId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> editedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'edited',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      encryptedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encrypted',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      forwardedFromIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'forwardedFrom',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      forwardedFromIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'forwardedFrom',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      forwardedFromEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'forwardedFrom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      forwardedFromGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'forwardedFrom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      forwardedFromLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'forwardedFrom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      forwardedFromBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'forwardedFrom',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      forwardedFromStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'forwardedFrom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      forwardedFromEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'forwardedFrom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      forwardedFromContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'forwardedFrom',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      forwardedFromMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'forwardedFrom',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      forwardedFromIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'forwardedFrom',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      forwardedFromIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'forwardedFrom',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> fromEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> fromGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> fromLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> fromBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'from',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> fromStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> fromEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> fromContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> fromMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'from',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> fromIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'from',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      fromIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'from',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      generatedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'generatedBy',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      generatedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'generatedBy',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      generatedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'generatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      generatedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'generatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      generatedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'generatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      generatedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'generatedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      generatedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'generatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      generatedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'generatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      generatedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'generatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      generatedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'generatedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      generatedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'generatedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      generatedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'generatedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> idEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> idGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> idLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> idBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> isHiddenEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isHidden',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      isLocalMessageEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLocalMessage',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> jsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> jsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> jsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> jsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'json',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> jsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> jsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> jsonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'json',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> jsonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'json',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> jsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'json',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      jsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'json',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      localNetworkMessageIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localNetworkMessageId',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      localNetworkMessageIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localNetworkMessageId',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      localNetworkMessageIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localNetworkMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      localNetworkMessageIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localNetworkMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      localNetworkMessageIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localNetworkMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      localNetworkMessageIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localNetworkMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> markupIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'markup',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      markupIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'markup',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> markupEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      markupGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'markup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> markupLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'markup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> markupBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'markup',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      markupStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'markup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> markupEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'markup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> markupContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'markup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> markupMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'markup',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      markupIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markup',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      markupIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'markup',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      needToBackupEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needToBackup',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> packetIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      packetIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'packetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      packetIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'packetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> packetIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'packetId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      packetIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'packetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      packetIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'packetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      packetIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'packetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> packetIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'packetId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      packetIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packetId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      packetIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'packetId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      replyToIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'replyToId',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      replyToIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'replyToId',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      replyToIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'replyToId',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      replyToIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'replyToId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> roomUidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roomUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      roomUidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'roomUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> roomUidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'roomUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> roomUidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'roomUid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      roomUidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'roomUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> roomUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'roomUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> roomUidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'roomUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> roomUidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'roomUid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      roomUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roomUid',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition>
      roomUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roomUid',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> timeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> timeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> timeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> timeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'time',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> toEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'to',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> toGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'to',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> toLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'to',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> toBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'to',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> toStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'to',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> toEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'to',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> toContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'to',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> toMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'to',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> toIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'to',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> toIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'to',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> typeEqualTo(
      MessageType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> typeGreaterThan(
    MessageType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> typeLessThan(
    MessageType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterFilterCondition> typeBetween(
    MessageType lower,
    MessageType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MessageIsarQueryObject
    on QueryBuilder<MessageIsar, MessageIsar, QFilterCondition> {}

extension MessageIsarQueryLinks
    on QueryBuilder<MessageIsar, MessageIsar, QFilterCondition> {}

extension MessageIsarQuerySortBy
    on QueryBuilder<MessageIsar, MessageIsar, QSortBy> {
  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByEdited() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'edited', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByEditedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'edited', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByEncrypted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encrypted', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByEncryptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encrypted', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByForwardedFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forwardedFrom', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy>
      sortByForwardedFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forwardedFrom', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByGeneratedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedBy', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByGeneratedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedBy', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByIsHidden() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHidden', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByIsHiddenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHidden', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByIsLocalMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalMessage', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy>
      sortByIsLocalMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalMessage', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy>
      sortByLocalNetworkMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localNetworkMessageId', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy>
      sortByLocalNetworkMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localNetworkMessageId', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByMarkup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markup', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByMarkupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markup', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByNeedToBackup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needToBackup', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy>
      sortByNeedToBackupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needToBackup', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByPacketId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetId', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByPacketIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetId', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByReplyToId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToId', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByReplyToIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToId', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByRoomUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomUid', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByRoomUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomUid', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension MessageIsarQuerySortThenBy
    on QueryBuilder<MessageIsar, MessageIsar, QSortThenBy> {
  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByDbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbId', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByDbIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbId', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByEdited() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'edited', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByEditedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'edited', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByEncrypted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encrypted', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByEncryptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encrypted', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByForwardedFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forwardedFrom', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy>
      thenByForwardedFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forwardedFrom', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByGeneratedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedBy', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByGeneratedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatedBy', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByIsHidden() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHidden', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByIsHiddenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHidden', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByIsLocalMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalMessage', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy>
      thenByIsLocalMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalMessage', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy>
      thenByLocalNetworkMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localNetworkMessageId', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy>
      thenByLocalNetworkMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localNetworkMessageId', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByMarkup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markup', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByMarkupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markup', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByNeedToBackup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needToBackup', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy>
      thenByNeedToBackupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needToBackup', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByPacketId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetId', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByPacketIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetId', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByReplyToId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToId', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByReplyToIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToId', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByRoomUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomUid', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByRoomUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomUid', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.desc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension MessageIsarQueryWhereDistinct
    on QueryBuilder<MessageIsar, MessageIsar, QDistinct> {
  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByEdited() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'edited');
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByEncrypted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'encrypted');
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByForwardedFrom(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'forwardedFrom',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByFrom(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'from', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByGeneratedBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generatedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctById() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id');
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByIsHidden() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isHidden');
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByIsLocalMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLocalMessage');
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'json', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct>
      distinctByLocalNetworkMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localNetworkMessageId');
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByMarkup(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'markup', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByNeedToBackup() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needToBackup');
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByPacketId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packetId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByReplyToId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'replyToId');
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByRoomUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roomUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'time');
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByTo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'to', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageIsar, MessageIsar, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension MessageIsarQueryProperty
    on QueryBuilder<MessageIsar, MessageIsar, QQueryProperty> {
  QueryBuilder<MessageIsar, int, QQueryOperations> dbIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dbId');
    });
  }

  QueryBuilder<MessageIsar, bool, QQueryOperations> editedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'edited');
    });
  }

  QueryBuilder<MessageIsar, bool, QQueryOperations> encryptedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encrypted');
    });
  }

  QueryBuilder<MessageIsar, String?, QQueryOperations> forwardedFromProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'forwardedFrom');
    });
  }

  QueryBuilder<MessageIsar, String, QQueryOperations> fromProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'from');
    });
  }

  QueryBuilder<MessageIsar, String?, QQueryOperations> generatedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generatedBy');
    });
  }

  QueryBuilder<MessageIsar, int?, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MessageIsar, bool, QQueryOperations> isHiddenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isHidden');
    });
  }

  QueryBuilder<MessageIsar, bool, QQueryOperations> isLocalMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLocalMessage');
    });
  }

  QueryBuilder<MessageIsar, String, QQueryOperations> jsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'json');
    });
  }

  QueryBuilder<MessageIsar, int?, QQueryOperations>
      localNetworkMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localNetworkMessageId');
    });
  }

  QueryBuilder<MessageIsar, String?, QQueryOperations> markupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'markup');
    });
  }

  QueryBuilder<MessageIsar, bool, QQueryOperations> needToBackupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needToBackup');
    });
  }

  QueryBuilder<MessageIsar, String, QQueryOperations> packetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packetId');
    });
  }

  QueryBuilder<MessageIsar, int, QQueryOperations> replyToIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'replyToId');
    });
  }

  QueryBuilder<MessageIsar, String, QQueryOperations> roomUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roomUid');
    });
  }

  QueryBuilder<MessageIsar, int, QQueryOperations> timeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'time');
    });
  }

  QueryBuilder<MessageIsar, String, QQueryOperations> toProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'to');
    });
  }

  QueryBuilder<MessageIsar, MessageType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
