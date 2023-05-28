// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_call_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CurrentCallInfo _$$_CurrentCallInfoFromJson(Map<String, dynamic> json) =>
    _$_CurrentCallInfo(
      callEvent: callEventV2FromJson(json['callEvent'] as String),
      from: json['from'] as String,
      to: json['to'] as String,
      expireTime: json['expireTime'] as int,
      notificationSelected: json['notificationSelected'] as bool,
      isAccepted: json['isAccepted'] as bool,
      offerBody: json['offerBody'] as String? ?? "",
      offerCandidate: json['offerCandidate'] as String? ?? "",
    );

Map<String, dynamic> _$$_CurrentCallInfoToJson(_$_CurrentCallInfo instance) =>
    <String, dynamic>{
      'callEvent': callEventV2ToJson(instance.callEvent),
      'from': instance.from,
      'to': instance.to,
      'expireTime': instance.expireTime,
      'notificationSelected': instance.notificationSelected,
      'isAccepted': instance.isAccepted,
      'offerBody': instance.offerBody,
      'offerCandidate': instance.offerCandidate,
    };
