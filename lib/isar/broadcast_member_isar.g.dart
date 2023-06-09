// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_member_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBroadcastMemberIsarCollection on Isar {
  IsarCollection<BroadcastMemberIsar> get broadcastMemberIsars =>
      this.collection();
}

const BroadcastMemberIsarSchema = CollectionSchema(
  name: r'BroadcastMemberIsar',
  id: 7476876970995083613,
  properties: {
    r'broadcastUid': PropertySchema(
      id: 0,
      name: r'broadcastUid',
      type: IsarType.string,
    ),
    r'memberUid': PropertySchema(
      id: 1,
      name: r'memberUid',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'phoneNumber': PropertySchema(
      id: 3,
      name: r'phoneNumber',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 4,
      name: r'type',
      type: IsarType.byte,
      enumMap: _BroadcastMemberIsartypeEnumValueMap,
    )
  },
  estimateSize: _broadcastMemberIsarEstimateSize,
  serialize: _broadcastMemberIsarSerialize,
  deserialize: _broadcastMemberIsarDeserialize,
  deserializeProp: _broadcastMemberIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _broadcastMemberIsarGetId,
  getLinks: _broadcastMemberIsarGetLinks,
  attach: _broadcastMemberIsarAttach,
  version: '3.1.0+1',
);

int _broadcastMemberIsarEstimateSize(
  BroadcastMemberIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.broadcastUid.length * 3;
  {
    final value = object.memberUid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.phoneNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _broadcastMemberIsarSerialize(
  BroadcastMemberIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.broadcastUid);
  writer.writeString(offsets[1], object.memberUid);
  writer.writeString(offsets[2], object.name);
  writer.writeString(offsets[3], object.phoneNumber);
  writer.writeByte(offsets[4], object.type.index);
}

BroadcastMemberIsar _broadcastMemberIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BroadcastMemberIsar(
    broadcastUid: reader.readString(offsets[0]),
    memberUid: reader.readStringOrNull(offsets[1]),
    name: reader.readStringOrNull(offsets[2]) ?? "",
    phoneNumber: reader.readStringOrNull(offsets[3]),
    type: _BroadcastMemberIsartypeValueEnumMap[
            reader.readByteOrNull(offsets[4])] ??
        BroadCastMemberType.MESSAGE,
  );
  object.id = id;
  return object;
}

P _broadcastMemberIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (_BroadcastMemberIsartypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          BroadCastMemberType.MESSAGE) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _BroadcastMemberIsartypeEnumValueMap = {
  'SMS': 0,
  'MESSAGE': 1,
};
const _BroadcastMemberIsartypeValueEnumMap = {
  0: BroadCastMemberType.SMS,
  1: BroadCastMemberType.MESSAGE,
};

Id _broadcastMemberIsarGetId(BroadcastMemberIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _broadcastMemberIsarGetLinks(
    BroadcastMemberIsar object) {
  return [];
}

void _broadcastMemberIsarAttach(
    IsarCollection<dynamic> col, Id id, BroadcastMemberIsar object) {
  object.id = id;
}

extension BroadcastMemberIsarQueryWhereSort
    on QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QWhere> {
  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BroadcastMemberIsarQueryWhere
    on QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QWhereClause> {
  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterWhereClause>
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

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterWhereClause>
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

extension BroadcastMemberIsarQueryFilter on QueryBuilder<BroadcastMemberIsar,
    BroadcastMemberIsar, QFilterCondition> {
  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      broadcastUidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'broadcastUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      broadcastUidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'broadcastUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      broadcastUidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'broadcastUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      broadcastUidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'broadcastUid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      broadcastUidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'broadcastUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      broadcastUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'broadcastUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      broadcastUidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'broadcastUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      broadcastUidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'broadcastUid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      broadcastUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'broadcastUid',
        value: '',
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      broadcastUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'broadcastUid',
        value: '',
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
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

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
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

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
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

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      memberUidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'memberUid',
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      memberUidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'memberUid',
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      memberUidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memberUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      memberUidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'memberUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      memberUidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'memberUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      memberUidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'memberUid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      memberUidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'memberUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      memberUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'memberUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      memberUidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'memberUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      memberUidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'memberUid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      memberUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memberUid',
        value: '',
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      memberUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'memberUid',
        value: '',
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      phoneNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'phoneNumber',
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      phoneNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'phoneNumber',
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      phoneNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      phoneNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      phoneNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      phoneNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phoneNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      phoneNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      phoneNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      phoneNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      phoneNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phoneNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      phoneNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phoneNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      phoneNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phoneNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      typeEqualTo(BroadCastMemberType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      typeGreaterThan(
    BroadCastMemberType value, {
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

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      typeLessThan(
    BroadCastMemberType value, {
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

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterFilterCondition>
      typeBetween(
    BroadCastMemberType lower,
    BroadCastMemberType upper, {
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

extension BroadcastMemberIsarQueryObject on QueryBuilder<BroadcastMemberIsar,
    BroadcastMemberIsar, QFilterCondition> {}

extension BroadcastMemberIsarQueryLinks on QueryBuilder<BroadcastMemberIsar,
    BroadcastMemberIsar, QFilterCondition> {}

extension BroadcastMemberIsarQuerySortBy
    on QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QSortBy> {
  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      sortByBroadcastUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'broadcastUid', Sort.asc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      sortByBroadcastUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'broadcastUid', Sort.desc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      sortByMemberUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberUid', Sort.asc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      sortByMemberUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberUid', Sort.desc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      sortByPhoneNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.asc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      sortByPhoneNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.desc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension BroadcastMemberIsarQuerySortThenBy
    on QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QSortThenBy> {
  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      thenByBroadcastUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'broadcastUid', Sort.asc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      thenByBroadcastUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'broadcastUid', Sort.desc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      thenByMemberUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberUid', Sort.asc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      thenByMemberUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberUid', Sort.desc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      thenByPhoneNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.asc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      thenByPhoneNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.desc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension BroadcastMemberIsarQueryWhereDistinct
    on QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QDistinct> {
  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QDistinct>
      distinctByBroadcastUid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'broadcastUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QDistinct>
      distinctByMemberUid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memberUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QDistinct>
      distinctByPhoneNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phoneNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QDistinct>
      distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension BroadcastMemberIsarQueryProperty
    on QueryBuilder<BroadcastMemberIsar, BroadcastMemberIsar, QQueryProperty> {
  QueryBuilder<BroadcastMemberIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BroadcastMemberIsar, String, QQueryOperations>
      broadcastUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'broadcastUid');
    });
  }

  QueryBuilder<BroadcastMemberIsar, String?, QQueryOperations>
      memberUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memberUid');
    });
  }

  QueryBuilder<BroadcastMemberIsar, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<BroadcastMemberIsar, String?, QQueryOperations>
      phoneNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phoneNumber');
    });
  }

  QueryBuilder<BroadcastMemberIsar, BroadCastMemberType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
