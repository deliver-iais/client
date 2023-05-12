// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'is_verified_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsVerifiedIsarCollection on Isar {
  IsarCollection<IsVerifiedIsar> get isVerifiedIsars => this.collection();
}

const IsVerifiedIsarSchema = CollectionSchema(
  name: r'IsVerifiedIsar',
  id: -4673398028363503303,
  properties: {
    r'expireTime': PropertySchema(
      id: 0,
      name: r'expireTime',
      type: IsarType.long,
    ),
    r'lastUpdate': PropertySchema(
      id: 1,
      name: r'lastUpdate',
      type: IsarType.long,
    ),
    r'uid': PropertySchema(
      id: 2,
      name: r'uid',
      type: IsarType.string,
    )
  },
  estimateSize: _isVerifiedIsarEstimateSize,
  serialize: _isVerifiedIsarSerialize,
  deserialize: _isVerifiedIsarDeserialize,
  deserializeProp: _isVerifiedIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _isVerifiedIsarGetId,
  getLinks: _isVerifiedIsarGetLinks,
  attach: _isVerifiedIsarAttach,
  version: '3.1.0+1',
);

int _isVerifiedIsarEstimateSize(
  IsVerifiedIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _isVerifiedIsarSerialize(
  IsVerifiedIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer..writeLong(offsets[0], object.expireTime)
  ..writeLong(offsets[1], object.lastUpdate)
  ..writeString(offsets[2], object.uid);
}

IsVerifiedIsar _isVerifiedIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsVerifiedIsar(
    expireTime: reader.readLong(offsets[0]),
    lastUpdate: reader.readLong(offsets[1]),
    uid: reader.readString(offsets[2]),
  );
  object.id = id;
  return object;
}

P _isVerifiedIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isVerifiedIsarGetId(IsVerifiedIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isVerifiedIsarGetLinks(IsVerifiedIsar object) {
  return [];
}

void _isVerifiedIsarAttach(
    IsarCollection<dynamic> col, Id id, IsVerifiedIsar object) {
  object.id = id;
}

extension IsVerifiedIsarQueryWhereSort
    on QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QWhere> {
  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsVerifiedIsarQueryWhere
    on QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QWhereClause> {
  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterWhereClause> uidEqualTo(
      String uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uid',
        value: [uid],
      ));
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterWhereClause> uidNotEqualTo(
      String uid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension IsVerifiedIsarQueryFilter
    on QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QFilterCondition> {
  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      expireTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expireTime',
        value: value,
      ));
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
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

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
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

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
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

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
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

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
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

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      lastUpdateEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      lastUpdateGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      lastUpdateLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdate',
        value: value,
      ));
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      lastUpdateBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      uidEqualTo(
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

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      uidGreaterThan(
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

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      uidLessThan(
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

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      uidBetween(
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

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      uidStartsWith(
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

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      uidEndsWith(
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

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      uidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      uidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterFilterCondition>
      uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }
}

extension IsVerifiedIsarQueryObject
    on QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QFilterCondition> {}

extension IsVerifiedIsarQueryLinks
    on QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QFilterCondition> {}

extension IsVerifiedIsarQuerySortBy
    on QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QSortBy> {
  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterSortBy>
      sortByExpireTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireTime', Sort.asc);
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterSortBy>
      sortByExpireTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireTime', Sort.desc);
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterSortBy>
      sortByLastUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdate', Sort.asc);
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterSortBy>
      sortByLastUpdateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdate', Sort.desc);
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension IsVerifiedIsarQuerySortThenBy
    on QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QSortThenBy> {
  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterSortBy>
      thenByExpireTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireTime', Sort.asc);
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterSortBy>
      thenByExpireTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireTime', Sort.desc);
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterSortBy>
      thenByLastUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdate', Sort.asc);
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterSortBy>
      thenByLastUpdateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdate', Sort.desc);
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension IsVerifiedIsarQueryWhereDistinct
    on QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QDistinct> {
  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QDistinct>
      distinctByExpireTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expireTime');
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QDistinct>
      distinctByLastUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdate');
    });
  }

  QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }
}

extension IsVerifiedIsarQueryProperty
    on QueryBuilder<IsVerifiedIsar, IsVerifiedIsar, QQueryProperty> {
  QueryBuilder<IsVerifiedIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsVerifiedIsar, int, QQueryOperations> expireTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expireTime');
    });
  }

  QueryBuilder<IsVerifiedIsar, int, QQueryOperations> lastUpdateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdate');
    });
  }

  QueryBuilder<IsVerifiedIsar, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }
}
