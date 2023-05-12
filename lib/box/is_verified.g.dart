// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'is_verified.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_IsVerified _$$_IsVerifiedFromJson(Map<String, dynamic> json) =>
    _$_IsVerified(
      uid: uidFromJson(json['uid'] as String),
      lastUpdate: json['lastUpdate'] as int,
      expireTime: json['expireTime'] as int,
    );

Map<String, dynamic> _$$_IsVerifiedToJson(_$_IsVerified instance) =>
    <String, dynamic>{
      'uid': uidToJson(instance.uid),
      'lastUpdate': instance.lastUpdate,
      'expireTime': instance.expireTime,
    };
