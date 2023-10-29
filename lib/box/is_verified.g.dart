// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'is_verified.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IsVerifiedImpl _$$IsVerifiedImplFromJson(Map<String, dynamic> json) =>
    _$IsVerifiedImpl(
      uid: uidFromJson(json['uid'] as String),
      lastUpdate: json['lastUpdate'] as int,
      expireTime: json['expireTime'] as int,
    );

Map<String, dynamic> _$$IsVerifiedImplToJson(_$IsVerifiedImpl instance) =>
    <String, dynamic>{
      'uid': uidToJson(instance.uid),
      'lastUpdate': instance.lastUpdate,
      'expireTime': instance.expireTime,
    };
