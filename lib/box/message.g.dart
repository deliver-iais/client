// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      roomUid: uidFromJson(json['roomUid'] as String),
      from: uidFromJson(json['from'] as String),
      to: uidFromJson(json['to'] as String),
      packetId: json['packetId'] as String,
      time: json['time'] as int,
      json: json['json'] as String,
      replyToId: json['replyToId'] as int? ?? 0,
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.NOT_SET,
      edited: json['edited'] as bool? ?? false,
      encrypted: json['encrypted'] as bool? ?? false,
      isHidden: json['isHidden'] as bool? ?? false,
      isLocalMessage: json['isLocalMessage'] as bool? ?? false,
      needToBackup: json['needToBackup'] as bool? ?? false,
      markup: json['markup'] as String?,
      id: json['id'] as int?,
      localNetworkMessageId: json['localNetworkMessageId'] as int?,
      forwardedFrom: nullAbleUidFromJson(json['forwardedFrom'] as String?),
      generatedBy: nullAbleUidFromJson(json['generatedBy'] as String?),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'roomUid': uidToJson(instance.roomUid),
      'from': uidToJson(instance.from),
      'to': uidToJson(instance.to),
      'packetId': instance.packetId,
      'time': instance.time,
      'json': instance.json,
      'replyToId': instance.replyToId,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'edited': instance.edited,
      'encrypted': instance.encrypted,
      'isHidden': instance.isHidden,
      'isLocalMessage': instance.isLocalMessage,
      'needToBackup': instance.needToBackup,
      'markup': instance.markup,
      'id': instance.id,
      'localNetworkMessageId': instance.localNetworkMessageId,
      'forwardedFrom': nullableUidToJson(instance.forwardedFrom),
      'generatedBy': nullableUidToJson(instance.generatedBy),
    };

const _$MessageTypeEnumMap = {
  MessageType.TEXT: 'TEXT',
  MessageType.FILE: 'FILE',
  MessageType.STICKER: 'STICKER',
  MessageType.LOCATION: 'LOCATION',
  MessageType.LIVE_LOCATION: 'LIVE_LOCATION',
  MessageType.POLL: 'POLL',
  MessageType.FORM: 'FORM',
  MessageType.PERSISTENT_EVENT: 'PERSISTENT_EVENT',
  MessageType.NOT_SET: 'NOT_SET',
  MessageType.BUTTONS: 'BUTTONS',
  MessageType.SHARE_UID: 'SHARE_UID',
  MessageType.FORM_RESULT: 'FORM_RESULT',
  MessageType.SHARE_PRIVATE_DATA_REQUEST: 'SHARE_PRIVATE_DATA_REQUEST',
  MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE: 'SHARE_PRIVATE_DATA_ACCEPTANCE',
  MessageType.CALL: 'CALL',
  MessageType.TABLE: 'TABLE',
  MessageType.TRANSACTION: 'TRANSACTION',
  MessageType.PAYMENT_INFORMATION: 'PAYMENT_INFORMATION',
  MessageType.CALL_LOG: 'CALL_LOG',
};
