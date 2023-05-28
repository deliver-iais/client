// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_call_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_LastCallStatus _$$_LastCallStatusFromJson(Map<String, dynamic> json) =>
    _$_LastCallStatus(
      id: json['id'] as int,
      callId: json['callId'] as String,
      roomUid: json['roomUid'] as String,
      expireTime: json['expireTime'] as int,
    );

Map<String, dynamic> _$$_LastCallStatusToJson(_$_LastCallStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'callId': instance.callId,
      'roomUid': instance.roomUid,
      'expireTime': instance.expireTime,
    };
