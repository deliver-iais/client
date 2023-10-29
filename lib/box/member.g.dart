// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemberImpl _$$MemberImplFromJson(Map<String, dynamic> json) => _$MemberImpl(
      mucUid: uidFromJson(json['mucUid'] as String),
      memberUid: uidFromJson(json['memberUid'] as String),
      role: $enumDecodeNullable(_$MucRoleEnumMap, json['role']) ?? MucRole.NONE,
      username: json['username'] as String? ?? "",
      name: json['name'] as String? ?? "",
      realName: json['realName'] as String? ?? "",
    );

Map<String, dynamic> _$$MemberImplToJson(_$MemberImpl instance) =>
    <String, dynamic>{
      'mucUid': uidToJson(instance.mucUid),
      'memberUid': uidToJson(instance.memberUid),
      'role': _$MucRoleEnumMap[instance.role]!,
      'username': instance.username,
      'name': instance.name,
      'realName': instance.realName,
    };

const _$MucRoleEnumMap = {
  MucRole.NONE: 'NONE',
  MucRole.MEMBER: 'MEMBER',
  MucRole.ADMIN: 'ADMIN',
  MucRole.OWNER: 'OWNER',
};
