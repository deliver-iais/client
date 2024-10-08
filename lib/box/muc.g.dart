// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MucImpl _$$MucImplFromJson(Map<String, dynamic> json) => _$MucImpl(
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
      lastUpdateTime: json['lastUpdateTime'] as int? ?? 0,
      mucType: $enumDecodeNullable(_$MucTypeEnumMap, json['mucType']) ??
          MucType.Public,
      currentUserRole:
          $enumDecodeNullable(_$MucRoleEnumMap, json['currentUserRole']) ??
              MucRole.NONE,
      synced: json['synced'] as bool? ?? true,
    );

Map<String, dynamic> _$$MucImplToJson(_$MucImpl instance) => <String, dynamic>{
      'uid': uidToJson(instance.uid),
      'name': instance.name,
      'token': instance.token,
      'id': instance.id,
      'info': instance.info,
      'pinMessagesIdList': instance.pinMessagesIdList,
      'population': instance.population,
      'lastCanceledPinMessageId': instance.lastCanceledPinMessageId,
      'lastUpdateTime': instance.lastUpdateTime,
      'mucType': _$MucTypeEnumMap[instance.mucType]!,
      'currentUserRole': _$MucRoleEnumMap[instance.currentUserRole]!,
      'synced': instance.synced,
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
