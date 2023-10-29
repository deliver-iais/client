// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_call_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LastCallStatusImpl _$$LastCallStatusImplFromJson(Map<String, dynamic> json) =>
    _$LastCallStatusImpl(
      id: json['id'] as int,
      callId: json['callId'] as String,
      roomUid: json['roomUid'] as String,
      expireTime: json['expireTime'] as int,
    );

Map<String, dynamic> _$$LastCallStatusImplToJson(
        _$LastCallStatusImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'callId': instance.callId,
      'roomUid': instance.roomUid,
      'expireTime': instance.expireTime,
    };
