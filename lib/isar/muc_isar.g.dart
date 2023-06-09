// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muc_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMucIsarCollection on Isar {
  IsarCollection<MucIsar> get mucIsars => this.collection();
}

const MucIsarSchema = CollectionSchema(
  name: r'MucIsar',
  id: 8289644650241443454,
  properties: {
    r'currentUserRole': PropertySchema(
      id: 0,
      name: r'currentUserRole',
      type: IsarType.byte,
      enumMap: _MucIsarcurrentUserRoleEnumValueMap,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'info': PropertySchema(
      id: 2,
      name: r'info',
      type: IsarType.string,
    ),
    r'lastCanceledPinMessageId': PropertySchema(
      id: 3,
      name: r'lastCanceledPinMessageId',
      type: IsarType.long,
    ),
    r'mucType': PropertySchema(
      id: 4,
      name: r'mucType',
      type: IsarType.byte,
      enumMap: _MucIsarmucTypeEnumValueMap,
    ),
    r'name': PropertySchema(
      id: 5,
      name: r'name',
      type: IsarType.string,
    ),
    r'pinMessagesIdList': PropertySchema(
      id: 6,
      name: r'pinMessagesIdList',
      type: IsarType.longList,
    ),
    r'population': PropertySchema(
      id: 7,
      name: r'population',
      type: IsarType.long,
    ),
    r'token': PropertySchema(
      id: 8,
      name: r'token',
      type: IsarType.string,
    ),
    r'uid': PropertySchema(
      id: 9,
      name: r'uid',
      type: IsarType.string,
    )
  },
  estimateSize: _mucIsarEstimateSize,
  serialize: _mucIsarSerialize,
  deserialize: _mucIsarDeserialize,
  deserializeProp: _mucIsarDeserializeProp,
  idName: r'dbId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _mucIsarGetId,
  getLinks: _mucIsarGetLinks,
  attach: _mucIsarAttach,
  version: '3.1.0+1',
);

int _mucIsarEstimateSize(
  MucIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.info.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.pinMessagesIdList;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  bytesCount += 3 + object.token.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _mucIsarSerialize(
  MucIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.currentUserRole.index);
  writer.writeString(offsets[1], object.id);
  writer.writeString(offsets[2], object.info);
  writer.writeLong(offsets[3], object.lastCanceledPinMessageId);
  writer.writeByte(offsets[4], object.mucType.index);
  writer.writeString(offsets[5], object.name);
  writer.writeLongList(offsets[6], object.pinMessagesIdList);
  writer.writeLong(offsets[7], object.population);
  writer.writeString(offsets[8], object.token);
  writer.writeString(offsets[9], object.uid);
}

MucIsar _mucIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MucIsar(
    currentUserRole: _MucIsarcurrentUserRoleValueEnumMap[
            reader.readByteOrNull(offsets[0])] ??
        MucRole.NONE,
    id: reader.readStringOrNull(offsets[1]) ?? "",
    info: reader.readStringOrNull(offsets[2]) ?? "",
    lastCanceledPinMessageId: reader.readLongOrNull(offsets[3]) ?? 0,
    mucType: _MucIsarmucTypeValueEnumMap[reader.readByteOrNull(offsets[4])] ??
        MucType.Public,
    name: reader.readStringOrNull(offsets[5]) ?? "",
    pinMessagesIdList: reader.readLongList(offsets[6]),
    population: reader.readLongOrNull(offsets[7]) ?? 0,
    token: reader.readStringOrNull(offsets[8]) ?? "",
    uid: reader.readString(offsets[9]),
  );
  return object;
}

P _mucIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_MucIsarcurrentUserRoleValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MucRole.NONE) as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 2:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (_MucIsarmucTypeValueEnumMap[reader.readByteOrNull(offset)] ??
          MucType.Public) as P;
    case 5:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 6:
      return (reader.readLongList(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 8:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MucIsarcurrentUserRoleEnumValueMap = {
  'NONE': 0,
  'MEMBER': 1,
  'ADMIN': 2,
  'OWNER': 3,
};
const _MucIsarcurrentUserRoleValueEnumMap = {
  0: MucRole.NONE,
  1: MucRole.MEMBER,
  2: MucRole.ADMIN,
  3: MucRole.OWNER,
};
const _MucIsarmucTypeEnumValueMap = {
  'Private': 0,
  'Public': 1,
};
const _MucIsarmucTypeValueEnumMap = {
  0: MucType.Private,
  1: MucType.Public,
};

Id _mucIsarGetId(MucIsar object) {
  return object.dbId;
}

List<IsarLinkBase<dynamic>> _mucIsarGetLinks(MucIsar object) {
  return [];
}

void _mucIsarAttach(IsarCollection<dynamic> col, Id id, MucIsar object) {}

extension MucIsarQueryWhereSort on QueryBuilder<MucIsar, MucIsar, QWhere> {
  QueryBuilder<MucIsar, MucIsar, QAfterWhere> anyDbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MucIsarQueryWhere on QueryBuilder<MucIsar, MucIsar, QWhereClause> {
  QueryBuilder<MucIsar, MucIsar, QAfterWhereClause> dbIdEqualTo(Id dbId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: dbId,
        upper: dbId,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterWhereClause> dbIdNotEqualTo(Id dbId) {
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

  QueryBuilder<MucIsar, MucIsar, QAfterWhereClause> dbIdGreaterThan(Id dbId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: dbId, includeLower: include),
      );
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterWhereClause> dbIdLessThan(Id dbId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: dbId, includeUpper: include),
      );
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterWhereClause> dbIdBetween(
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

extension MucIsarQueryFilter
    on QueryBuilder<MucIsar, MucIsar, QFilterCondition> {
  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> currentUserRoleEqualTo(
      MucRole value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentUserRole',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      currentUserRoleGreaterThan(
    MucRole value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentUserRole',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> currentUserRoleLessThan(
    MucRole value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentUserRole',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> currentUserRoleBetween(
    MucRole lower,
    MucRole upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentUserRole',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> dbIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dbId',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> dbIdGreaterThan(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> dbIdLessThan(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> dbIdBetween(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> idContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> infoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'info',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> infoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'info',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> infoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'info',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> infoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'info',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> infoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'info',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> infoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'info',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> infoContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'info',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> infoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'info',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> infoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'info',
        value: '',
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> infoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'info',
        value: '',
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      lastCanceledPinMessageIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCanceledPinMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      lastCanceledPinMessageIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCanceledPinMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      lastCanceledPinMessageIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCanceledPinMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      lastCanceledPinMessageIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCanceledPinMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> mucTypeEqualTo(
      MucType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mucType',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> mucTypeGreaterThan(
    MucType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mucType',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> mucTypeLessThan(
    MucType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mucType',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> mucTypeBetween(
    MucType lower,
    MucType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mucType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> nameContains(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      pinMessagesIdListIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pinMessagesIdList',
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      pinMessagesIdListIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pinMessagesIdList',
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      pinMessagesIdListElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pinMessagesIdList',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      pinMessagesIdListElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pinMessagesIdList',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      pinMessagesIdListElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pinMessagesIdList',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      pinMessagesIdListElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pinMessagesIdList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      pinMessagesIdListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pinMessagesIdList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      pinMessagesIdListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pinMessagesIdList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      pinMessagesIdListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pinMessagesIdList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      pinMessagesIdListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pinMessagesIdList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      pinMessagesIdListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pinMessagesIdList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition>
      pinMessagesIdListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pinMessagesIdList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> populationEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'population',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> populationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'population',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> populationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'population',
        value: value,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> populationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'population',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> tokenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> tokenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> tokenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> tokenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'token',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> tokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> tokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> tokenContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> tokenMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'token',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> tokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'token',
        value: '',
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> tokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'token',
        value: '',
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> uidEqualTo(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> uidGreaterThan(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> uidLessThan(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> uidBetween(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> uidStartsWith(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> uidEndsWith(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> uidContains(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> uidMatches(
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

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }
}

extension MucIsarQueryObject
    on QueryBuilder<MucIsar, MucIsar, QFilterCondition> {}

extension MucIsarQueryLinks
    on QueryBuilder<MucIsar, MucIsar, QFilterCondition> {}

extension MucIsarQuerySortBy on QueryBuilder<MucIsar, MucIsar, QSortBy> {
  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByCurrentUserRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentUserRole', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByCurrentUserRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentUserRole', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'info', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByInfoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'info', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy>
      sortByLastCanceledPinMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCanceledPinMessageId', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy>
      sortByLastCanceledPinMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCanceledPinMessageId', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByMucType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mucType', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByMucTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mucType', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByPopulation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'population', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByPopulationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'population', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension MucIsarQuerySortThenBy
    on QueryBuilder<MucIsar, MucIsar, QSortThenBy> {
  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByCurrentUserRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentUserRole', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByCurrentUserRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentUserRole', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByDbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbId', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByDbIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbId', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'info', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByInfoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'info', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy>
      thenByLastCanceledPinMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCanceledPinMessageId', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy>
      thenByLastCanceledPinMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCanceledPinMessageId', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByMucType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mucType', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByMucTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mucType', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByPopulation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'population', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByPopulationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'population', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension MucIsarQueryWhereDistinct
    on QueryBuilder<MucIsar, MucIsar, QDistinct> {
  QueryBuilder<MucIsar, MucIsar, QDistinct> distinctByCurrentUserRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentUserRole');
    });
  }

  QueryBuilder<MucIsar, MucIsar, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QDistinct> distinctByInfo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'info', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QDistinct>
      distinctByLastCanceledPinMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCanceledPinMessageId');
    });
  }

  QueryBuilder<MucIsar, MucIsar, QDistinct> distinctByMucType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mucType');
    });
  }

  QueryBuilder<MucIsar, MucIsar, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QDistinct> distinctByPinMessagesIdList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pinMessagesIdList');
    });
  }

  QueryBuilder<MucIsar, MucIsar, QDistinct> distinctByPopulation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'population');
    });
  }

  QueryBuilder<MucIsar, MucIsar, QDistinct> distinctByToken(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'token', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MucIsar, MucIsar, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }
}

extension MucIsarQueryProperty
    on QueryBuilder<MucIsar, MucIsar, QQueryProperty> {
  QueryBuilder<MucIsar, int, QQueryOperations> dbIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dbId');
    });
  }

  QueryBuilder<MucIsar, MucRole, QQueryOperations> currentUserRoleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentUserRole');
    });
  }

  QueryBuilder<MucIsar, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MucIsar, String, QQueryOperations> infoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'info');
    });
  }

  QueryBuilder<MucIsar, int, QQueryOperations>
      lastCanceledPinMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCanceledPinMessageId');
    });
  }

  QueryBuilder<MucIsar, MucType, QQueryOperations> mucTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mucType');
    });
  }

  QueryBuilder<MucIsar, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<MucIsar, List<int>?, QQueryOperations>
      pinMessagesIdListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pinMessagesIdList');
    });
  }

  QueryBuilder<MucIsar, int, QQueryOperations> populationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'population');
    });
  }

  QueryBuilder<MucIsar, String, QQueryOperations> tokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'token');
    });
  }

  QueryBuilder<MucIsar, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }
}
