// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_call_status_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLastCallStatusIsarCollection on Isar {
  IsarCollection<LastCallStatusIsar> get lastCallStatusIsars =>
      this.collection();
}

const LastCallStatusIsarSchema = CollectionSchema(
  name: r'LastCallStatusIsar',
  id: 8532831443729671881,
  properties: {
    r'callId': PropertySchema(
      id: 0,
      name: r'callId',
      type: IsarType.string,
    ),
    r'expireTime': PropertySchema(
      id: 1,
      name: r'expireTime',
      type: IsarType.long,
    ),
    r'roomUid': PropertySchema(
      id: 2,
      name: r'roomUid',
      type: IsarType.string,
    )
  },
  estimateSize: _lastCallStatusIsarEstimateSize,
  serialize: _lastCallStatusIsarSerialize,
  deserialize: _lastCallStatusIsarDeserialize,
  deserializeProp: _lastCallStatusIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _lastCallStatusIsarGetId,
  getLinks: _lastCallStatusIsarGetLinks,
  attach: _lastCallStatusIsarAttach,
  version: '3.1.0+1',
);

int _lastCallStatusIsarEstimateSize(
  LastCallStatusIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.callId.length * 3;
  bytesCount += 3 + object.roomUid.length * 3;
  return bytesCount;
}

void _lastCallStatusIsarSerialize(
  LastCallStatusIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.callId);
  writer.writeLong(offsets[1], object.expireTime);
  writer.writeString(offsets[2], object.roomUid);
}

LastCallStatusIsar _lastCallStatusIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LastCallStatusIsar(
    callId: reader.readString(offsets[0]),
    expireTime: reader.readLong(offsets[1]),
    id: id,
    roomUid: reader.readString(offsets[2]),
  );
  return object;
}

P _lastCallStatusIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _lastCallStatusIsarGetId(LastCallStatusIsar object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _lastCallStatusIsarGetLinks(
    LastCallStatusIsar object) {
  return [];
}

void _lastCallStatusIsarAttach(
    IsarCollection<dynamic> col, Id id, LastCallStatusIsar object) {
  object.id = id;
}

extension LastCallStatusIsarQueryWhereSort
    on QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QWhere> {
  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LastCallStatusIsarQueryWhere
    on QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QWhereClause> {
  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterWhereClause>
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

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterWhereClause>
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

extension LastCallStatusIsarQueryFilter
    on QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QFilterCondition> {
  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      callIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'callId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      callIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'callId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      callIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'callId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      callIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'callId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      callIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'callId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      callIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'callId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      callIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'callId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      callIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'callId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      callIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'callId',
        value: '',
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      callIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'callId',
        value: '',
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      expireTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expireTime',
        value: value,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      expireTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expireTime',
        value: value,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      expireTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expireTime',
        value: value,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      expireTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expireTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      idGreaterThan(
    Id? value, {
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

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      idLessThan(
    Id? value, {
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

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      idBetween(
    Id? lower,
    Id? upper, {
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

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
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

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
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

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
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

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
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

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
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

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
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

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      roomUidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'roomUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      roomUidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'roomUid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      roomUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roomUid',
        value: '',
      ));
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterFilterCondition>
      roomUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roomUid',
        value: '',
      ));
    });
  }
}

extension LastCallStatusIsarQueryObject
    on QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QFilterCondition> {}

extension LastCallStatusIsarQueryLinks
    on QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QFilterCondition> {}

extension LastCallStatusIsarQuerySortBy
    on QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QSortBy> {
  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterSortBy>
      sortByCallId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'callId', Sort.asc);
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterSortBy>
      sortByCallIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'callId', Sort.desc);
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterSortBy>
      sortByExpireTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireTime', Sort.asc);
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterSortBy>
      sortByExpireTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireTime', Sort.desc);
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterSortBy>
      sortByRoomUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomUid', Sort.asc);
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterSortBy>
      sortByRoomUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomUid', Sort.desc);
    });
  }
}

extension LastCallStatusIsarQuerySortThenBy
    on QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QSortThenBy> {
  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterSortBy>
      thenByCallId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'callId', Sort.asc);
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterSortBy>
      thenByCallIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'callId', Sort.desc);
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterSortBy>
      thenByExpireTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireTime', Sort.asc);
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterSortBy>
      thenByExpireTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireTime', Sort.desc);
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterSortBy>
      thenByRoomUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomUid', Sort.asc);
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QAfterSortBy>
      thenByRoomUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomUid', Sort.desc);
    });
  }
}

extension LastCallStatusIsarQueryWhereDistinct
    on QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QDistinct> {
  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QDistinct>
      distinctByCallId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'callId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QDistinct>
      distinctByExpireTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expireTime');
    });
  }

  QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QDistinct>
      distinctByRoomUid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roomUid', caseSensitive: caseSensitive);
    });
  }
}

extension LastCallStatusIsarQueryProperty
    on QueryBuilder<LastCallStatusIsar, LastCallStatusIsar, QQueryProperty> {
  QueryBuilder<LastCallStatusIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LastCallStatusIsar, String, QQueryOperations> callIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'callId');
    });
  }

  QueryBuilder<LastCallStatusIsar, int, QQueryOperations> expireTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expireTime');
    });
  }

  QueryBuilder<LastCallStatusIsar, String, QQueryOperations> roomUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roomUid');
    });
  }
}
