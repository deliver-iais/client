// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallData _$CallDataFromJson(Map<String, dynamic> json) => CallData(
      callId: json['callId'] as String,
      roomUid: json['roomUid'] as String,
      expireTime: json['expireTime'] as int,
    );

Map<String, dynamic> _$CallDataToJson(CallData instance) => <String, dynamic>{
      'callId': instance.callId,
      'roomUid': instance.roomUid,
      'expireTime': instance.expireTime,
    };
