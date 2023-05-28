// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_call_info_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCurrentCallInfoIsarCollection on Isar {
  IsarCollection<CurrentCallInfoIsar> get currentCallInfoIsars =>
      this.collection();
}

const CurrentCallInfoIsarSchema = CollectionSchema(
  name: r'CurrentCallInfoIsar',
  id: 1923905614673607992,
  properties: {
    r'callEvent': PropertySchema(
      id: 0,
      name: r'callEvent',
      type: IsarType.string,
    ),
    r'expireTime': PropertySchema(
      id: 1,
      name: r'expireTime',
      type: IsarType.long,
    ),
    r'from': PropertySchema(
      id: 2,
      name: r'from',
      type: IsarType.string,
    ),
    r'isAccepted': PropertySchema(
      id: 3,
      name: r'isAccepted',
      type: IsarType.bool,
    ),
    r'notificationSelected': PropertySchema(
      id: 4,
      name: r'notificationSelected',
      type: IsarType.bool,
    ),
    r'offerBody': PropertySchema(
      id: 5,
      name: r'offerBody',
      type: IsarType.string,
    ),
    r'offerCandidate': PropertySchema(
      id: 6,
      name: r'offerCandidate',
      type: IsarType.string,
    ),
    r'to': PropertySchema(
      id: 7,
      name: r'to',
      type: IsarType.string,
    )
  },
  estimateSize: _currentCallInfoIsarEstimateSize,
  serialize: _currentCallInfoIsarSerialize,
  deserialize: _currentCallInfoIsarDeserialize,
  deserializeProp: _currentCallInfoIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _currentCallInfoIsarGetId,
  getLinks: _currentCallInfoIsarGetLinks,
  attach: _currentCallInfoIsarAttach,
  version: '3.1.0+1',
);

int _currentCallInfoIsarEstimateSize(
  CurrentCallInfoIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.callEvent.length * 3;
  bytesCount += 3 + object.from.length * 3;
  bytesCount += 3 + object.offerBody.length * 3;
  bytesCount += 3 + object.offerCandidate.length * 3;
  bytesCount += 3 + object.to.length * 3;
  return bytesCount;
}

void _currentCallInfoIsarSerialize(
  CurrentCallInfoIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.callEvent);
  writer.writeLong(offsets[1], object.expireTime);
  writer.writeString(offsets[2], object.from);
  writer.writeBool(offsets[3], object.isAccepted);
  writer.writeBool(offsets[4], object.notificationSelected);
  writer.writeString(offsets[5], object.offerBody);
  writer.writeString(offsets[6], object.offerCandidate);
  writer.writeString(offsets[7], object.to);
}

CurrentCallInfoIsar _currentCallInfoIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CurrentCallInfoIsar(
    callEvent: reader.readString(offsets[0]),
    expireTime: reader.readLong(offsets[1]),
    from: reader.readString(offsets[2]),
    isAccepted: reader.readBool(offsets[3]),
    notificationSelected: reader.readBool(offsets[4]),
    offerBody: reader.readStringOrNull(offsets[5]) ?? "",
    offerCandidate: reader.readStringOrNull(offsets[6]) ?? "",
    to: reader.readString(offsets[7]),
  );
  object.id = id;
  return object;
}

P _currentCallInfoIsarDeserializeProp<P>(
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
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 6:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _currentCallInfoIsarGetId(CurrentCallInfoIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _currentCallInfoIsarGetLinks(
    CurrentCallInfoIsar object) {
  return [];
}

void _currentCallInfoIsarAttach(
    IsarCollection<dynamic> col, Id id, CurrentCallInfoIsar object) {
  object.id = id;
}

extension CurrentCallInfoIsarQueryWhereSort
    on QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QWhere> {
  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CurrentCallInfoIsarQueryWhere
    on QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QWhereClause> {
  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterWhereClause>
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterWhereClause>
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

extension CurrentCallInfoIsarQueryFilter on QueryBuilder<CurrentCallInfoIsar,
    CurrentCallInfoIsar, QFilterCondition> {
  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      callEventEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'callEvent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      callEventGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'callEvent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      callEventLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'callEvent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      callEventBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'callEvent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      callEventStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'callEvent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      callEventEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'callEvent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      callEventContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'callEvent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      callEventMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'callEvent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      callEventIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'callEvent',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      callEventIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'callEvent',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      expireTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expireTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      fromEqualTo(
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      fromGreaterThan(
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      fromLessThan(
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      fromBetween(
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      fromStartsWith(
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      fromEndsWith(
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      fromContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'from',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      fromMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'from',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      fromIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'from',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      fromIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'from',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      isAcceptedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAccepted',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      notificationSelectedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationSelected',
        value: value,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerBodyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offerBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerBodyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'offerBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerBodyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'offerBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerBodyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'offerBody',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerBodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'offerBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerBodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'offerBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerBodyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'offerBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerBodyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'offerBody',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerBodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offerBody',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerBodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'offerBody',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerCandidateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offerCandidate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerCandidateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'offerCandidate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerCandidateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'offerCandidate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerCandidateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'offerCandidate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerCandidateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'offerCandidate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerCandidateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'offerCandidate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerCandidateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'offerCandidate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerCandidateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'offerCandidate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerCandidateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offerCandidate',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      offerCandidateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'offerCandidate',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      toEqualTo(
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      toGreaterThan(
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      toLessThan(
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      toBetween(
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      toStartsWith(
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      toEndsWith(
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

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      toContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'to',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      toMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'to',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      toIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'to',
        value: '',
      ));
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterFilterCondition>
      toIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'to',
        value: '',
      ));
    });
  }
}

extension CurrentCallInfoIsarQueryObject on QueryBuilder<CurrentCallInfoIsar,
    CurrentCallInfoIsar, QFilterCondition> {}

extension CurrentCallInfoIsarQueryLinks on QueryBuilder<CurrentCallInfoIsar,
    CurrentCallInfoIsar, QFilterCondition> {}

extension CurrentCallInfoIsarQuerySortBy
    on QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QSortBy> {
  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByCallEvent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'callEvent', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByCallEventDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'callEvent', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByExpireTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireTime', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByExpireTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireTime', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByIsAccepted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAccepted', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByIsAcceptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAccepted', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByNotificationSelected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationSelected', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByNotificationSelectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationSelected', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByOfferBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offerBody', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByOfferBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offerBody', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByOfferCandidate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offerCandidate', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByOfferCandidateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offerCandidate', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      sortByToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.desc);
    });
  }
}

extension CurrentCallInfoIsarQuerySortThenBy
    on QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QSortThenBy> {
  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByCallEvent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'callEvent', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByCallEventDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'callEvent', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByExpireTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireTime', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByExpireTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expireTime', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'from', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByIsAccepted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAccepted', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByIsAcceptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAccepted', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByNotificationSelected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationSelected', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByNotificationSelectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationSelected', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByOfferBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offerBody', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByOfferBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offerBody', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByOfferCandidate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offerCandidate', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByOfferCandidateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offerCandidate', Sort.desc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.asc);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QAfterSortBy>
      thenByToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'to', Sort.desc);
    });
  }
}

extension CurrentCallInfoIsarQueryWhereDistinct
    on QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QDistinct> {
  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QDistinct>
      distinctByCallEvent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'callEvent', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QDistinct>
      distinctByExpireTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expireTime');
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QDistinct>
      distinctByFrom({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'from', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QDistinct>
      distinctByIsAccepted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAccepted');
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QDistinct>
      distinctByNotificationSelected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationSelected');
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QDistinct>
      distinctByOfferBody({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'offerBody', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QDistinct>
      distinctByOfferCandidate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'offerCandidate',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QDistinct>
      distinctByTo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'to', caseSensitive: caseSensitive);
    });
  }
}

extension CurrentCallInfoIsarQueryProperty
    on QueryBuilder<CurrentCallInfoIsar, CurrentCallInfoIsar, QQueryProperty> {
  QueryBuilder<CurrentCallInfoIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CurrentCallInfoIsar, String, QQueryOperations>
      callEventProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'callEvent');
    });
  }

  QueryBuilder<CurrentCallInfoIsar, int, QQueryOperations>
      expireTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expireTime');
    });
  }

  QueryBuilder<CurrentCallInfoIsar, String, QQueryOperations> fromProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'from');
    });
  }

  QueryBuilder<CurrentCallInfoIsar, bool, QQueryOperations>
      isAcceptedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAccepted');
    });
  }

  QueryBuilder<CurrentCallInfoIsar, bool, QQueryOperations>
      notificationSelectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationSelected');
    });
  }

  QueryBuilder<CurrentCallInfoIsar, String, QQueryOperations>
      offerBodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'offerBody');
    });
  }

  QueryBuilder<CurrentCallInfoIsar, String, QQueryOperations>
      offerCandidateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'offerCandidate');
    });
  }

  QueryBuilder<CurrentCallInfoIsar, String, QQueryOperations> toProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'to');
    });
  }
}
