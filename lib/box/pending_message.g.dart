// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PendingMessageImpl _$$PendingMessageImplFromJson(Map<String, dynamic> json) =>
    _$PendingMessageImpl(
      roomUid: uidFromJson(json['roomUid'] as String),
      packetId: json['packetId'] as String,
      msg: getMessageFromJson(json['msg'] as String),
      failed: json['failed'] as bool? ?? false,
      isLocalMessage: json['isLocalMessage'] as bool? ?? false,
      status: $enumDecode(_$SendingStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$$PendingMessageImplToJson(
        _$PendingMessageImpl instance) =>
    <String, dynamic>{
      'roomUid': uidToJson(instance.roomUid),
      'packetId': instance.packetId,
      'msg': messageToJson(instance.msg),
      'failed': instance.failed,
      'isLocalMessage': instance.isLocalMessage,
      'status': _$SendingStatusEnumMap[instance.status]!,
    };

const _$SendingStatusEnumMap = {
  SendingStatus.UPLOAD_FILE_COMPLETED: 'UPLOAD_FILE_COMPLETED',
  SendingStatus.UPLOAD_FILE_FAIL: 'UPLOAD_FILE_FAIL',
  SendingStatus.UPLOAD_FILE_IN_PROGRESS: 'UPLOAD_FILE_IN_PROGRESS',
  SendingStatus.PENDING: 'PENDING',
};
