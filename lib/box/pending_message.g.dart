// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PendingMessage _$$_PendingMessageFromJson(Map<String, dynamic> json) =>
    _$_PendingMessage(
      roomUid: uidFromJson(json['roomUid'] as String),
      packetId: json['packetId'] as String,
      msg: getMessageFromJson(json['msg'] as String),
      failed: json['failed'] as bool? ?? false,
      status: $enumDecode(_$SendingStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$$_PendingMessageToJson(_$_PendingMessage instance) =>
    <String, dynamic>{
      'roomUid': uidToJson(instance.roomUid),
      'packetId': instance.packetId,
      'msg': messageToJson(instance.msg),
      'failed': instance.failed,
      'status': _$SendingStatusEnumMap[instance.status]!,
    };

const _$SendingStatusEnumMap = {
  SendingStatus.UPLOAD_FILE_COMPLETED: 'UPLOAD_FILE_COMPLETED',
  SendingStatus.UPLOAD_FILE_FAIL: 'UPLOAD_FILE_FAIL',
  SendingStatus.UPLOAD_FILE_IN_PROGRESS: 'UPLOAD_FILE_IN_PROGRESS',
  SendingStatus.PENDING: 'PENDING',
};
