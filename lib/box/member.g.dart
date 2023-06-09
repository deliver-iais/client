// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Member _$$_MemberFromJson(Map<String, dynamic> json) => _$_Member(
      mucUid: uidFromJson(json['mucUid'] as String),
      memberUid: uidFromJson(json['memberUid'] as String),
      role: $enumDecodeNullable(_$MucRoleEnumMap, json['role']) ?? MucRole.NONE,
    );

Map<String, dynamic> _$$_MemberToJson(_$_Member instance) => <String, dynamic>{
      'mucUid': uidToJson(instance.mucUid),
      'memberUid': uidToJson(instance.memberUid),
      'role': _$MucRoleEnumMap[instance.role]!,
    };

const _$MucRoleEnumMap = {
  MucRole.NONE: 'NONE',
  MucRole.MEMBER: 'MEMBER',
  MucRole.ADMIN: 'ADMIN',
  MucRole.OWNER: 'OWNER',
};
