// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BroadcastMemberImpl _$$BroadcastMemberImplFromJson(
        Map<String, dynamic> json) =>
    _$BroadcastMemberImpl(
      broadcastUid: uidFromJson(json['broadcastUid'] as String),
      memberUid: nullAbleUidFromJson(json['memberUid'] as String?),
      phoneNumber: nullAblePhoneNumberFromJson(json['phoneNumber'] as String?),
      type: $enumDecodeNullable(_$BroadCastMemberTypeEnumMap, json['type']) ??
          BroadCastMemberType.MESSAGE,
      name: json['name'] as String? ?? "",
    );

Map<String, dynamic> _$$BroadcastMemberImplToJson(
        _$BroadcastMemberImpl instance) =>
    <String, dynamic>{
      'broadcastUid': uidToJson(instance.broadcastUid),
      'memberUid': nullableUidToJson(instance.memberUid),
      'phoneNumber': nullablePhoneNumberToJson(instance.phoneNumber),
      'type': _$BroadCastMemberTypeEnumMap[instance.type]!,
      'name': instance.name,
    };

const _$BroadCastMemberTypeEnumMap = {
  BroadCastMemberType.SMS: 'SMS',
  BroadCastMemberType.MESSAGE: 'MESSAGE',
};
