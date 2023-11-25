// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRoomIsarCollection on Isar {
  IsarCollection<RoomIsar> get roomIsars => this.collection();
}

const RoomIsarSchema = CollectionSchema(
  name: r'RoomIsar',
  id: 3465162000599211923,
  properties: {
    r'deleted': PropertySchema(
      id: 0,
      name: r'deleted',
      type: IsarType.bool,
    ),
    r'draft': PropertySchema(
      id: 1,
      name: r'draft',
      type: IsarType.string,
    ),
    r'firstMessageId': PropertySchema(
      id: 2,
      name: r'firstMessageId',
      type: IsarType.long,
    ),
    r'lastCurrentUserSentMessageId': PropertySchema(
      id: 3,
      name: r'lastCurrentUserSentMessageId',
      type: IsarType.long,
    ),
    r'lastLocalNetworkMessageId': PropertySchema(
      id: 4,
      name: r'lastLocalNetworkMessageId',
      type: IsarType.long,
    ),
    r'lastMessage': PropertySchema(
      id: 5,
      name: r'lastMessage',
      type: IsarType.string,
    ),
    r'lastMessageId': PropertySchema(
      id: 6,
      name: r'lastMessageId',
      type: IsarType.long,
    ),
    r'lastUpdateTime': PropertySchema(
      id: 7,
      name: r'lastUpdateTime',
      type: IsarType.long,
    ),
    r'localNetworkMessageCount': PropertySchema(
      id: 8,
      name: r'localNetworkMessageCount',
      type: IsarType.long,
    ),
    r'mentionsId': PropertySchema(
      id: 9,
      name: r'mentionsId',
      type: IsarType.longList,
    ),
    r'pinId': PropertySchema(
      id: 10,
      name: r'pinId',
      type: IsarType.long,
    ),
    r'pinned': PropertySchema(
      id: 11,
      name: r'pinned',
      type: IsarType.bool,
    ),
    r'replyKeyboardMarkup': PropertySchema(
      id: 12,
      name: r'replyKeyboardMarkup',
      type: IsarType.string,
    ),
    r'seenSynced': PropertySchema(
      id: 13,
      name: r'seenSynced',
      type: IsarType.bool,
    ),
    r'shouldUpdateMediaCount': PropertySchema(
      id: 14,
      name: r'shouldUpdateMediaCount',
      type: IsarType.bool,
    ),
    r'synced': PropertySchema(
      id: 15,
      name: r'synced',
      type: IsarType.bool,
    ),
    r'uid': PropertySchema(
      id: 16,
      name: r'uid',
      type: IsarType.string,
    )
  },
  estimateSize: _roomIsarEstimateSize,
  serialize: _roomIsarSerialize,
  deserialize: _roomIsarDeserialize,
  deserializeProp: _roomIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _roomIsarGetId,
  getLinks: _roomIsarGetLinks,
  attach: _roomIsarAttach,
  version: '3.1.0+1',
);

int _roomIsarEstimateSize(
  RoomIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.draft;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.mentionsId;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.replyKeyboardMarkup;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _roomIsarSerialize(
  RoomIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.deleted);
  writer.writeString(offsets[1], object.draft);
  writer.writeLong(offsets[2], object.firstMessageId);
  writer.writeLong(offsets[3], object.lastCurrentUserSentMessageId);
  writer.writeLong(offsets[4], object.lastLocalNetworkMessageId);
  writer.writeString(offsets[5], object.lastMessage);
  writer.writeLong(offsets[6], object.lastMessageId);
  writer.writeLong(offsets[7], object.lastUpdateTime);
  writer.writeLong(offsets[8], object.localNetworkMessageCount);
  writer.writeLongList(offsets[9], object.mentionsId);
  writer.writeLong(offsets[10], object.pinId);
  writer.writeBool(offsets[11], object.pinned);
  writer.writeString(offsets[12], object.replyKeyboardMarkup);
  writer.writeBool(offsets[13], object.seenSynced);
  writer.writeBool(offsets[14], object.shouldUpdateMediaCount);
  writer.writeBool(offsets[15], object.synced);
  writer.writeString(offsets[16], object.uid);
}

RoomIsar _roomIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RoomIsar(
    deleted: reader.readBoolOrNull(offsets[0]) ?? false,
    draft: reader.readStringOrNull(offsets[1]),
    firstMessageId: reader.readLongOrNull(offsets[2]) ?? 0,
    lastCurrentUserSentMessageId: reader.readLongOrNull(offsets[3]) ?? 0,
    lastLocalNetworkMessageId: reader.readLongOrNull(offsets[4]) ?? 0,
    lastMessage: reader.readStringOrNull(offsets[5]),
    lastMessageId: reader.readLongOrNull(offsets[6]) ?? 0,
    lastUpdateTime: reader.readLongOrNull(offsets[7]) ?? 0,
    localNetworkMessageCount: reader.readLongOrNull(offsets[8]) ?? 0,
    mentionsId: reader.readLongList(offsets[9]),
    pinId: reader.readLongOrNull(offsets[10]) ?? 0,
    pinned: reader.readBoolOrNull(offsets[11]) ?? false,
    replyKeyboardMarkup: reader.readStringOrNull(offsets[12]),
    seenSynced: reader.readBoolOrNull(offsets[13]) ?? false,
    shouldUpdateMediaCount: reader.readBoolOrNull(offsets[14]) ?? false,
    synced: reader.readBoolOrNull(offsets[15]) ?? false,
    uid: reader.readString(offsets[16]),
  );
  return object;
}

P _roomIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 7:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 8:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 9:
      return (reader.readLongList(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 11:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 14:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 15:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 16:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _roomIsarGetId(RoomIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _roomIsarGetLinks(RoomIsar object) {
  return [];
}

void _roomIsarAttach(IsarCollection<dynamic> col, Id id, RoomIsar object) {}

extension RoomIsarQueryWhereSort on QueryBuilder<RoomIsar, RoomIsar, QWhere> {
  QueryBuilder<RoomIsar, RoomIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RoomIsarQueryWhere on QueryBuilder<RoomIsar, RoomIsar, QWhereClause> {
  QueryBuilder<RoomIsar, RoomIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RoomIsarQueryFilter
    on QueryBuilder<RoomIsar, RoomIsar, QFilterCondition> {
  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> deletedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deleted',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> draftIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'draft',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> draftIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'draft',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> draftEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'draft',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> draftGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'draft',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> draftLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'draft',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> draftBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'draft',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> draftStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'draft',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> draftEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'draft',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> draftContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'draft',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> draftMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'draft',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> draftIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'draft',
        value: '',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> draftIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'draft',
        value: '',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> firstMessageIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firstMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      firstMessageIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'firstMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      firstMessageIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'firstMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> firstMessageIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'firstMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> idGreaterThan(
    Id value, {
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

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> idLessThan(
    Id value, {
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

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
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

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      lastCurrentUserSentMessageIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCurrentUserSentMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      lastCurrentUserSentMessageIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCurrentUserSentMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      lastCurrentUserSentMessageIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCurrentUserSentMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      lastCurrentUserSentMessageIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCurrentUserSentMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      lastLocalNetworkMessageIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastLocalNetworkMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      lastLocalNetworkMessageIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastLocalNetworkMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      lastLocalNetworkMessageIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastLocalNetworkMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      lastLocalNetworkMessageIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastLocalNetworkMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> lastMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMessage',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      lastMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMessage',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> lastMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      lastMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> lastMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> lastMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> lastMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> lastMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> lastMessageContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> lastMessageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> lastMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      lastMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> lastMessageIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      lastMessageIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> lastMessageIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> lastMessageIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> lastUpdateTimeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      lastUpdateTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      lastUpdateTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> lastUpdateTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      localNetworkMessageCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localNetworkMessageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      localNetworkMessageCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localNetworkMessageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      localNetworkMessageCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localNetworkMessageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      localNetworkMessageCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localNetworkMessageCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> mentionsIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mentionsId',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      mentionsIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mentionsId',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      mentionsIdElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mentionsId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      mentionsIdElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mentionsId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      mentionsIdElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mentionsId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      mentionsIdElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mentionsId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      mentionsIdLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mentionsId',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> mentionsIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mentionsId',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      mentionsIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mentionsId',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      mentionsIdLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mentionsId',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      mentionsIdLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mentionsId',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      mentionsIdLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mentionsId',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> pinIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pinId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> pinIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pinId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> pinIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pinId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> pinIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pinId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> pinnedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pinned',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      replyKeyboardMarkupIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'replyKeyboardMarkup',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      replyKeyboardMarkupIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'replyKeyboardMarkup',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      replyKeyboardMarkupEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'replyKeyboardMarkup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      replyKeyboardMarkupGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'replyKeyboardMarkup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      replyKeyboardMarkupLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'replyKeyboardMarkup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      replyKeyboardMarkupBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'replyKeyboardMarkup',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      replyKeyboardMarkupStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'replyKeyboardMarkup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      replyKeyboardMarkupEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'replyKeyboardMarkup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      replyKeyboardMarkupContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'replyKeyboardMarkup',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      replyKeyboardMarkupMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'replyKeyboardMarkup',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      replyKeyboardMarkupIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'replyKeyboardMarkup',
        value: '',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      replyKeyboardMarkupIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'replyKeyboardMarkup',
        value: '',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> seenSyncedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'seenSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition>
      shouldUpdateMediaCountEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shouldUpdateMediaCount',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> syncedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'synced',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> uidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> uidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }
}

extension RoomIsarQueryObject
    on QueryBuilder<RoomIsar, RoomIsar, QFilterCondition> {}

extension RoomIsarQueryLinks
    on QueryBuilder<RoomIsar, RoomIsar, QFilterCondition> {}

extension RoomIsarQuerySortBy on QueryBuilder<RoomIsar, RoomIsar, QSortBy> {
  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByDraft() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'draft', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByDraftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'draft', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByFirstMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstMessageId', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByFirstMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstMessageId', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      sortByLastCurrentUserSentMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCurrentUserSentMessageId', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      sortByLastCurrentUserSentMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCurrentUserSentMessageId', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      sortByLastLocalNetworkMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLocalNetworkMessageId', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      sortByLastLocalNetworkMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLocalNetworkMessageId', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByLastMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessage', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByLastMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessage', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByLastMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByLastMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByLastUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      sortByLocalNetworkMessageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localNetworkMessageCount', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      sortByLocalNetworkMessageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localNetworkMessageCount', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByPinId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinId', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByPinIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinId', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByReplyKeyboardMarkup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyKeyboardMarkup', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      sortByReplyKeyboardMarkupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyKeyboardMarkup', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortBySeenSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenSynced', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortBySeenSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenSynced', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      sortByShouldUpdateMediaCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldUpdateMediaCount', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      sortByShouldUpdateMediaCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldUpdateMediaCount', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension RoomIsarQuerySortThenBy
    on QueryBuilder<RoomIsar, RoomIsar, QSortThenBy> {
  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleted', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByDraft() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'draft', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByDraftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'draft', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByFirstMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstMessageId', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByFirstMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstMessageId', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      thenByLastCurrentUserSentMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCurrentUserSentMessageId', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      thenByLastCurrentUserSentMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCurrentUserSentMessageId', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      thenByLastLocalNetworkMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLocalNetworkMessageId', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      thenByLastLocalNetworkMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLocalNetworkMessageId', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByLastMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessage', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByLastMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessage', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByLastMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByLastMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByLastUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      thenByLocalNetworkMessageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localNetworkMessageCount', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      thenByLocalNetworkMessageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localNetworkMessageCount', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByPinId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinId', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByPinIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinId', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByReplyKeyboardMarkup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyKeyboardMarkup', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      thenByReplyKeyboardMarkupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyKeyboardMarkup', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenBySeenSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenSynced', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenBySeenSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenSynced', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      thenByShouldUpdateMediaCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldUpdateMediaCount', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy>
      thenByShouldUpdateMediaCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldUpdateMediaCount', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension RoomIsarQueryWhereDistinct
    on QueryBuilder<RoomIsar, RoomIsar, QDistinct> {
  QueryBuilder<RoomIsar, RoomIsar, QDistinct> distinctByDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deleted');
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct> distinctByDraft(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'draft', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct> distinctByFirstMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstMessageId');
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct>
      distinctByLastCurrentUserSentMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCurrentUserSentMessageId');
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct>
      distinctByLastLocalNetworkMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastLocalNetworkMessageId');
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct> distinctByLastMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct> distinctByLastMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessageId');
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct> distinctByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdateTime');
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct>
      distinctByLocalNetworkMessageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localNetworkMessageCount');
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct> distinctByMentionsId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mentionsId');
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct> distinctByPinId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pinId');
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct> distinctByPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pinned');
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct> distinctByReplyKeyboardMarkup(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'replyKeyboardMarkup',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct> distinctBySeenSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seenSynced');
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct>
      distinctByShouldUpdateMediaCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shouldUpdateMediaCount');
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<RoomIsar, RoomIsar, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }
}

extension RoomIsarQueryProperty
    on QueryBuilder<RoomIsar, RoomIsar, QQueryProperty> {
  QueryBuilder<RoomIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RoomIsar, bool, QQueryOperations> deletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deleted');
    });
  }

  QueryBuilder<RoomIsar, String?, QQueryOperations> draftProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'draft');
    });
  }

  QueryBuilder<RoomIsar, int, QQueryOperations> firstMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstMessageId');
    });
  }

  QueryBuilder<RoomIsar, int, QQueryOperations>
      lastCurrentUserSentMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCurrentUserSentMessageId');
    });
  }

  QueryBuilder<RoomIsar, int, QQueryOperations>
      lastLocalNetworkMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastLocalNetworkMessageId');
    });
  }

  QueryBuilder<RoomIsar, String?, QQueryOperations> lastMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessage');
    });
  }

  QueryBuilder<RoomIsar, int, QQueryOperations> lastMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessageId');
    });
  }

  QueryBuilder<RoomIsar, int, QQueryOperations> lastUpdateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdateTime');
    });
  }

  QueryBuilder<RoomIsar, int, QQueryOperations>
      localNetworkMessageCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localNetworkMessageCount');
    });
  }

  QueryBuilder<RoomIsar, List<int>?, QQueryOperations> mentionsIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mentionsId');
    });
  }

  QueryBuilder<RoomIsar, int, QQueryOperations> pinIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pinId');
    });
  }

  QueryBuilder<RoomIsar, bool, QQueryOperations> pinnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pinned');
    });
  }

  QueryBuilder<RoomIsar, String?, QQueryOperations>
      replyKeyboardMarkupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'replyKeyboardMarkup');
    });
  }

  QueryBuilder<RoomIsar, bool, QQueryOperations> seenSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seenSynced');
    });
  }

  QueryBuilder<RoomIsar, bool, QQueryOperations>
      shouldUpdateMediaCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shouldUpdateMediaCount');
    });
  }

  QueryBuilder<RoomIsar, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<RoomIsar, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }
}
