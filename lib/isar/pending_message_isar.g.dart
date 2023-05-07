// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_message_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPendingMessageIsarCollection on Isar {
  IsarCollection<PendingMessageIsar> get pendingMessageIsars =>
      this.collection();
}

const PendingMessageIsarSchema = CollectionSchema(
  name: r'PendingMessageIsar',
  id: 63032984793338065,
  properties: {
    r'failed': PropertySchema(
      id: 0,
      name: r'failed',
      type: IsarType.bool,
    ),
    r'messageId': PropertySchema(
      id: 1,
      name: r'messageId',
      type: IsarType.long,
    ),
    r'msg': PropertySchema(
      id: 2,
      name: r'msg',
      type: IsarType.string,
    ),
    r'packetId': PropertySchema(
      id: 3,
      name: r'packetId',
      type: IsarType.string,
    ),
    r'roomUid': PropertySchema(
      id: 4,
      name: r'roomUid',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 5,
      name: r'status',
      type: IsarType.byte,
      enumMap: _PendingMessageIsarstatusEnumValueMap,
    )
  },
  estimateSize: _pendingMessageIsarEstimateSize,
  serialize: _pendingMessageIsarSerialize,
  deserialize: _pendingMessageIsarDeserialize,
  deserializeProp: _pendingMessageIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _pendingMessageIsarGetId,
  getLinks: _pendingMessageIsarGetLinks,
  attach: _pendingMessageIsarAttach,
  version: '3.1.0+1',
);

int _pendingMessageIsarEstimateSize(
  PendingMessageIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.msg.length * 3;
  bytesCount += 3 + object.packetId.length * 3;
  bytesCount += 3 + object.roomUid.length * 3;
  return bytesCount;
}

void _pendingMessageIsarSerialize(
  PendingMessageIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.failed);
  writer.writeLong(offsets[1], object.messageId);
  writer.writeString(offsets[2], object.msg);
  writer.writeString(offsets[3], object.packetId);
  writer.writeString(offsets[4], object.roomUid);
  writer.writeByte(offsets[5], object.status.index);
}

PendingMessageIsar _pendingMessageIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PendingMessageIsar(
    failed: reader.readBoolOrNull(offsets[0]) ?? false,
    messageId: reader.readLong(offsets[1]),
    msg: reader.readString(offsets[2]),
    packetId: reader.readString(offsets[3]),
    roomUid: reader.readString(offsets[4]),
    status: _PendingMessageIsarstatusValueEnumMap[
            reader.readByteOrNull(offsets[5])] ??
        SendingStatus.UPLOAD_FILE_COMPLETED,
  );
  return object;
}

P _pendingMessageIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (_PendingMessageIsarstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SendingStatus.UPLOAD_FILE_COMPLETED) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PendingMessageIsarstatusEnumValueMap = {
  'UPLOAD_FILE_COMPLETED': 0,
  'UPLOAD_FILE_FAIL': 1,
  'UPLOAD_FILE_IN_PROGRESS': 2,
  'PENDING': 3,
};
const _PendingMessageIsarstatusValueEnumMap = {
  0: SendingStatus.UPLOAD_FILE_COMPLETED,
  1: SendingStatus.UPLOAD_FILE_FAIL,
  2: SendingStatus.UPLOAD_FILE_IN_PROGRESS,
  3: SendingStatus.PENDING,
};

Id _pendingMessageIsarGetId(PendingMessageIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pendingMessageIsarGetLinks(
    PendingMessageIsar object) {
  return [];
}

void _pendingMessageIsarAttach(
    IsarCollection<dynamic> col, Id id, PendingMessageIsar object) {}

extension PendingMessageIsarQueryWhereSort
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QWhere> {
  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PendingMessageIsarQueryWhere
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QWhereClause> {
  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      idBetween(
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

extension PendingMessageIsarQueryFilter
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QFilterCondition> {
  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      failedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'failed',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      messageIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageId',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      messageIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'messageId',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      messageIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'messageId',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      messageIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'messageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      msgEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'msg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      msgGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'msg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      msgLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'msg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      msgBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'msg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      msgStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'msg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      msgEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'msg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      msgContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'msg',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      msgMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'msg',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      msgIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'msg',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      msgIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'msg',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      packetIdEqualTo(
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      packetIdBetween(
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      packetIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'packetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      packetIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'packetId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      packetIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packetId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      packetIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'packetId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      roomUidEqualTo(
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      roomUidLessThan(
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      roomUidBetween(
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      roomUidEndsWith(
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      roomUidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'roomUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      roomUidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'roomUid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      roomUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roomUid',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      roomUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roomUid',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      statusEqualTo(SendingStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      statusGreaterThan(
    SendingStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      statusLessThan(
    SendingStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      statusBetween(
    SendingStatus lower,
    SendingStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PendingMessageIsarQueryObject
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QFilterCondition> {}

extension PendingMessageIsarQueryLinks
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QFilterCondition> {}

extension PendingMessageIsarQuerySortBy
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QSortBy> {
  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failed', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByFailedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failed', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByMsg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msg', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByMsgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msg', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByPacketId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByPacketIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByRoomUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomUid', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByRoomUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomUid', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension PendingMessageIsarQuerySortThenBy
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QSortThenBy> {
  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failed', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByFailedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failed', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByMsg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msg', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByMsgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msg', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByPacketId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByPacketIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packetId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByRoomUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomUid', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByRoomUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomUid', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension PendingMessageIsarQueryWhereDistinct
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct> {
  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failed');
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageId');
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct> distinctByMsg(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'msg', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByPacketId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packetId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByRoomUid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roomUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }
}

extension PendingMessageIsarQueryProperty
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QQueryProperty> {
  QueryBuilder<PendingMessageIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PendingMessageIsar, bool, QQueryOperations> failedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failed');
    });
  }

  QueryBuilder<PendingMessageIsar, int, QQueryOperations> messageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageId');
    });
  }

  QueryBuilder<PendingMessageIsar, String, QQueryOperations> msgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'msg');
    });
  }

  QueryBuilder<PendingMessageIsar, String, QQueryOperations>
      packetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packetId');
    });
  }

  QueryBuilder<PendingMessageIsar, String, QQueryOperations> roomUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roomUid');
    });
  }

  QueryBuilder<PendingMessageIsar, SendingStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
