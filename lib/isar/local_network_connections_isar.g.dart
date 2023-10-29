// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_network_connections_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalNetworkConnectionsIsarCollection on Isar {
  IsarCollection<LocalNetworkConnectionsIsar>
      get localNetworkConnectionsIsars => this.collection();
}

const LocalNetworkConnectionsIsarSchema = CollectionSchema(
  name: r'LocalNetworkConnectionsIsar',
  id: -2151876209398742346,
  properties: {
    r'ip': PropertySchema(
      id: 0,
      name: r'ip',
      type: IsarType.string,
    ),
    r'lastUpdateTime': PropertySchema(
      id: 1,
      name: r'lastUpdateTime',
      type: IsarType.long,
    ),
    r'uid': PropertySchema(
      id: 2,
      name: r'uid',
      type: IsarType.string,
    )
  },
  estimateSize: _localNetworkConnectionsIsarEstimateSize,
  serialize: _localNetworkConnectionsIsarSerialize,
  deserialize: _localNetworkConnectionsIsarDeserialize,
  deserializeProp: _localNetworkConnectionsIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _localNetworkConnectionsIsarGetId,
  getLinks: _localNetworkConnectionsIsarGetLinks,
  attach: _localNetworkConnectionsIsarAttach,
  version: '3.1.0+1',
);

int _localNetworkConnectionsIsarEstimateSize(
  LocalNetworkConnectionsIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.ip.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _localNetworkConnectionsIsarSerialize(
  LocalNetworkConnectionsIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.ip);
  writer.writeLong(offsets[1], object.lastUpdateTime);
  writer.writeString(offsets[2], object.uid);
}

LocalNetworkConnectionsIsar _localNetworkConnectionsIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalNetworkConnectionsIsar(
    ip: reader.readString(offsets[0]),
    lastUpdateTime: reader.readLong(offsets[1]),
    uid: reader.readString(offsets[2]),
  );
  return object;
}

P _localNetworkConnectionsIsarDeserializeProp<P>(
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

Id _localNetworkConnectionsIsarGetId(LocalNetworkConnectionsIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localNetworkConnectionsIsarGetLinks(
    LocalNetworkConnectionsIsar object) {
  return [];
}

void _localNetworkConnectionsIsarAttach(
    IsarCollection<dynamic> col, Id id, LocalNetworkConnectionsIsar object) {}

extension LocalNetworkConnectionsIsarQueryWhereSort on QueryBuilder<
    LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar, QWhere> {
  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalNetworkConnectionsIsarQueryWhere on QueryBuilder<
    LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar, QWhereClause> {
  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterWhereClause> idBetween(
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

extension LocalNetworkConnectionsIsarQueryFilter on QueryBuilder<
    LocalNetworkConnectionsIsar,
    LocalNetworkConnectionsIsar,
    QFilterCondition> {
  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> ipEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ip',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> ipGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ip',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> ipLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ip',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> ipBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ip',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> ipStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ip',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> ipEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ip',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
          QAfterFilterCondition>
      ipContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ip',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
          QAfterFilterCondition>
      ipMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ip',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> ipIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ip',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> ipIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ip',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> lastUpdateTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> lastUpdateTimeGreaterThan(
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

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> lastUpdateTimeLessThan(
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

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> lastUpdateTimeBetween(
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

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> uidEqualTo(
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

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> uidGreaterThan(
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

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> uidLessThan(
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

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> uidBetween(
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

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> uidStartsWith(
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

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> uidEndsWith(
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

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
          QAfterFilterCondition>
      uidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
          QAfterFilterCondition>
      uidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }
}

extension LocalNetworkConnectionsIsarQueryObject on QueryBuilder<
    LocalNetworkConnectionsIsar,
    LocalNetworkConnectionsIsar,
    QFilterCondition> {}

extension LocalNetworkConnectionsIsarQueryLinks on QueryBuilder<
    LocalNetworkConnectionsIsar,
    LocalNetworkConnectionsIsar,
    QFilterCondition> {}

extension LocalNetworkConnectionsIsarQuerySortBy on QueryBuilder<
    LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar, QSortBy> {
  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterSortBy> sortByIp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ip', Sort.asc);
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterSortBy> sortByIpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ip', Sort.desc);
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterSortBy> sortByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.asc);
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterSortBy> sortByLastUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.desc);
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension LocalNetworkConnectionsIsarQuerySortThenBy on QueryBuilder<
    LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar, QSortThenBy> {
  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterSortBy> thenByIp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ip', Sort.asc);
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterSortBy> thenByIpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ip', Sort.desc);
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterSortBy> thenByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.asc);
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterSortBy> thenByLastUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.desc);
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension LocalNetworkConnectionsIsarQueryWhereDistinct on QueryBuilder<
    LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar, QDistinct> {
  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QDistinct> distinctByIp({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ip', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QDistinct> distinctByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdateTime');
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar,
      QDistinct> distinctByUid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }
}

extension LocalNetworkConnectionsIsarQueryProperty on QueryBuilder<
    LocalNetworkConnectionsIsar, LocalNetworkConnectionsIsar, QQueryProperty> {
  QueryBuilder<LocalNetworkConnectionsIsar, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, String, QQueryOperations>
      ipProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ip');
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, int, QQueryOperations>
      lastUpdateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdateTime');
    });
  }

  QueryBuilder<LocalNetworkConnectionsIsar, String, QQueryOperations>
      uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }
}
