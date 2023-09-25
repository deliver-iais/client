// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMemberIsarCollection on Isar {
  IsarCollection<MemberIsar> get memberIsars => this.collection();
}

const MemberIsarSchema = CollectionSchema(
  name: r'MemberIsar',
  id: 3895952919462223268,
  properties: {
    r'memberUid': PropertySchema(
      id: 0,
      name: r'memberUid',
      type: IsarType.string,
    ),
    r'mucUid': PropertySchema(
      id: 1,
      name: r'mucUid',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'realName': PropertySchema(
      id: 3,
      name: r'realName',
      type: IsarType.string,
    ),
    r'role': PropertySchema(
      id: 4,
      name: r'role',
      type: IsarType.byte,
      enumMap: _MemberIsarroleEnumValueMap,
    ),
    r'username': PropertySchema(
      id: 5,
      name: r'username',
      type: IsarType.string,
    )
  },
  estimateSize: _memberIsarEstimateSize,
  serialize: _memberIsarSerialize,
  deserialize: _memberIsarDeserialize,
  deserializeProp: _memberIsarDeserializeProp,
  idName: r'dbId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _memberIsarGetId,
  getLinks: _memberIsarGetLinks,
  attach: _memberIsarAttach,
  version: '3.1.0+1',
);

int _memberIsarEstimateSize(
  MemberIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.memberUid.length * 3;
  bytesCount += 3 + object.mucUid.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.realName.length * 3;
  bytesCount += 3 + object.username.length * 3;
  return bytesCount;
}

void _memberIsarSerialize(
  MemberIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.memberUid);
  writer.writeString(offsets[1], object.mucUid);
  writer.writeString(offsets[2], object.name);
  writer.writeString(offsets[3], object.realName);
  writer.writeByte(offsets[4], object.role.index);
  writer.writeString(offsets[5], object.username);
}

MemberIsar _memberIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MemberIsar(
    memberUid: reader.readString(offsets[0]),
    mucUid: reader.readString(offsets[1]),
    name: reader.readStringOrNull(offsets[2]) ?? "",
    realName: reader.readStringOrNull(offsets[3]) ?? "",
    role: _MemberIsarroleValueEnumMap[reader.readByteOrNull(offsets[4])] ??
        MucRole.NONE,
    username: reader.readStringOrNull(offsets[5]) ?? "",
  );
  return object;
}

P _memberIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 3:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 4:
      return (_MemberIsarroleValueEnumMap[reader.readByteOrNull(offset)] ??
          MucRole.NONE) as P;
    case 5:
      return (reader.readStringOrNull(offset) ?? "") as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MemberIsarroleEnumValueMap = {
  'NONE': 0,
  'MEMBER': 1,
  'ADMIN': 2,
  'OWNER': 3,
};
const _MemberIsarroleValueEnumMap = {
  0: MucRole.NONE,
  1: MucRole.MEMBER,
  2: MucRole.ADMIN,
  3: MucRole.OWNER,
};

Id _memberIsarGetId(MemberIsar object) {
  return object.dbId;
}

List<IsarLinkBase<dynamic>> _memberIsarGetLinks(MemberIsar object) {
  return [];
}

void _memberIsarAttach(IsarCollection<dynamic> col, Id id, MemberIsar object) {}

extension MemberIsarQueryWhereSort
    on QueryBuilder<MemberIsar, MemberIsar, QWhere> {
  QueryBuilder<MemberIsar, MemberIsar, QAfterWhere> anyDbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MemberIsarQueryWhere
    on QueryBuilder<MemberIsar, MemberIsar, QWhereClause> {
  QueryBuilder<MemberIsar, MemberIsar, QAfterWhereClause> dbIdEqualTo(Id dbId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: dbId,
        upper: dbId,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterWhereClause> dbIdNotEqualTo(
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterWhereClause> dbIdGreaterThan(
      Id dbId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dbId, includeLower: include),
      );
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterWhereClause> dbIdLessThan(Id dbId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dbId, includeUpper: include),
      );
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterWhereClause> dbIdBetween(
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
}

extension MemberIsarQueryFilter
    on QueryBuilder<MemberIsar, MemberIsar, QFilterCondition> {
  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> dbIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dbId',
        value: value,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> dbIdGreaterThan(
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> dbIdLessThan(
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> dbIdBetween(
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> memberUidEqualTo(
    String value, {
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition>
      memberUidGreaterThan(
    String value, {
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> memberUidLessThan(
    String value, {
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> memberUidBetween(
    String lower,
    String upper, {
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition>
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> memberUidEndsWith(
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> memberUidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'memberUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> memberUidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'memberUid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition>
      memberUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memberUid',
        value: '',
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition>
      memberUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'memberUid',
        value: '',
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> mucUidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mucUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> mucUidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mucUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> mucUidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mucUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> mucUidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mucUid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> mucUidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mucUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> mucUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mucUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> mucUidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mucUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> mucUidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mucUid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> mucUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mucUid',
        value: '',
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition>
      mucUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mucUid',
        value: '',
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> realNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'realName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition>
      realNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'realName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> realNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'realName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> realNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'realName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition>
      realNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'realName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> realNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'realName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> realNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'realName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> realNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'realName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition>
      realNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'realName',
        value: '',
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition>
      realNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'realName',
        value: '',
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> roleEqualTo(
      MucRole value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'role',
        value: value,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> roleGreaterThan(
    MucRole value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'role',
        value: value,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> roleLessThan(
    MucRole value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'role',
        value: value,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> roleBetween(
    MucRole lower,
    MucRole upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'role',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> usernameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition>
      usernameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> usernameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> usernameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'username',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition>
      usernameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> usernameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> usernameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition> usernameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'username',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition>
      usernameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'username',
        value: '',
      ));
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterFilterCondition>
      usernameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'username',
        value: '',
      ));
    });
  }
}

extension MemberIsarQueryObject
    on QueryBuilder<MemberIsar, MemberIsar, QFilterCondition> {}

extension MemberIsarQueryLinks
    on QueryBuilder<MemberIsar, MemberIsar, QFilterCondition> {}

extension MemberIsarQuerySortBy
    on QueryBuilder<MemberIsar, MemberIsar, QSortBy> {
  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> sortByMemberUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberUid', Sort.asc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> sortByMemberUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberUid', Sort.desc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> sortByMucUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mucUid', Sort.asc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> sortByMucUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mucUid', Sort.desc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> sortByRealName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realName', Sort.asc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> sortByRealNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realName', Sort.desc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> sortByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> sortByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> sortByUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.asc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> sortByUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.desc);
    });
  }
}

extension MemberIsarQuerySortThenBy
    on QueryBuilder<MemberIsar, MemberIsar, QSortThenBy> {
  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> thenByDbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbId', Sort.asc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> thenByDbIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbId', Sort.desc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> thenByMemberUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberUid', Sort.asc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> thenByMemberUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberUid', Sort.desc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> thenByMucUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mucUid', Sort.asc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> thenByMucUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mucUid', Sort.desc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> thenByRealName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realName', Sort.asc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> thenByRealNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realName', Sort.desc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> thenByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> thenByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> thenByUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.asc);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QAfterSortBy> thenByUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.desc);
    });
  }
}

extension MemberIsarQueryWhereDistinct
    on QueryBuilder<MemberIsar, MemberIsar, QDistinct> {
  QueryBuilder<MemberIsar, MemberIsar, QDistinct> distinctByMemberUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memberUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QDistinct> distinctByMucUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mucUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QDistinct> distinctByRealName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'realName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QDistinct> distinctByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'role');
    });
  }

  QueryBuilder<MemberIsar, MemberIsar, QDistinct> distinctByUsername(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'username', caseSensitive: caseSensitive);
    });
  }
}

extension MemberIsarQueryProperty
    on QueryBuilder<MemberIsar, MemberIsar, QQueryProperty> {
  QueryBuilder<MemberIsar, int, QQueryOperations> dbIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dbId');
    });
  }

  QueryBuilder<MemberIsar, String, QQueryOperations> memberUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memberUid');
    });
  }

  QueryBuilder<MemberIsar, String, QQueryOperations> mucUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mucUid');
    });
  }

  QueryBuilder<MemberIsar, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<MemberIsar, String, QQueryOperations> realNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'realName');
    });
  }

  QueryBuilder<MemberIsar, MucRole, QQueryOperations> roleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'role');
    });
  }

  QueryBuilder<MemberIsar, String, QQueryOperations> usernameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'username');
    });
  }
}
