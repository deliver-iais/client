// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uid_id_name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UidIdNameImpl _$$UidIdNameImplFromJson(Map<String, dynamic> json) =>
    _$UidIdNameImpl(
      uid: uidFromJson(json['uid'] as String),
      id: json['id'] as String?,
      name: json['name'] as String?,
      realName: json['realName'] as String?,
      lastUpdateTime: json['lastUpdateTime'] as int? ?? 0,
      isContact: json['isContact'] as bool?,
    );

Map<String, dynamic> _$$UidIdNameImplToJson(_$UidIdNameImpl instance) =>
    <String, dynamic>{
      'uid': uidToJson(instance.uid),
      'id': instance.id,
      'name': instance.name,
      'realName': instance.realName,
      'lastUpdateTime': instance.lastUpdateTime,
      'isContact': instance.isContact,
    };
