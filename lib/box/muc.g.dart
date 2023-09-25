// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Muc _$$_MucFromJson(Map<String, dynamic> json) => _$_Muc(
      uid: uidFromJson(json['uid'] as String),
      name: json['name'] as String? ?? "",
      token: json['token'] as String? ?? "",
      id: json['id'] as String? ?? "",
      info: json['info'] as String? ?? "",
      pinMessagesIdList: (json['pinMessagesIdList'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      population: json['population'] as int? ?? 0,
      lastCanceledPinMessageId: json['lastCanceledPinMessageId'] as int? ?? 0,
      mucType: $enumDecodeNullable(_$MucTypeEnumMap, json['mucType']) ??
          MucType.Public,
      currentUserRole:
          $enumDecodeNullable(_$MucRoleEnumMap, json['currentUserRole']) ??
              MucRole.NONE,
    );

Map<String, dynamic> _$$_MucToJson(_$_Muc instance) => <String, dynamic>{
      'uid': uidToJson(instance.uid),
      'name': instance.name,
      'token': instance.token,
      'id': instance.id,
      'info': instance.info,
      'pinMessagesIdList': instance.pinMessagesIdList,
      'population': instance.population,
      'lastCanceledPinMessageId': instance.lastCanceledPinMessageId,
      'mucType': _$MucTypeEnumMap[instance.mucType]!,
      'currentUserRole': _$MucRoleEnumMap[instance.currentUserRole]!,
    };

const _$MucTypeEnumMap = {
  MucType.Private: 'Private',
  MucType.Public: 'Public',
};

const _$MucRoleEnumMap = {
  MucRole.NONE: 'NONE',
  MucRole.MEMBER: 'MEMBER',
  MucRole.ADMIN: 'ADMIN',
  MucRole.OWNER: 'OWNER',
};
