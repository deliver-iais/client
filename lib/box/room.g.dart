// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Room _$$_RoomFromJson(Map<String, dynamic> json) => _$_Room(
      uid: uidFromJson(json['uid'] as String),
      lastMessage: getNullableMessageFromJson(json['lastMessage'] as String?),
      replyKeyboardMarkup: json['replyKeyboardMarkup'] as String?,
      draft: json['draft'] as String? ?? "",
      mentionsId: (json['mentionsId'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      lastUpdateTime: json['lastUpdateTime'] as int? ?? 0,
      lastMessageId: json['lastMessageId'] as int? ?? 0,
      firstMessageId: json['firstMessageId'] as int? ?? 0,
      pinId: json['pinId'] as int? ?? 0,
      lastCurrentUserSentMessageId:
          json['lastCurrentUserSentMessageId'] as int? ?? 0,
      deleted: json['deleted'] as bool? ?? false,
      pinned: json['pinned'] as bool? ?? false,
      synced: json['synced'] as bool? ?? false,
      seenSynced: json['seenSynced'] as bool? ?? false,
      shouldUpdateMediaCount: json['shouldUpdateMediaCount'] as bool? ?? true,
    );

Map<String, dynamic> _$$_RoomToJson(_$_Room instance) => <String, dynamic>{
      'uid': uidToJson(instance.uid),
      'lastMessage': nullableMessageToJson(instance.lastMessage),
      'replyKeyboardMarkup': instance.replyKeyboardMarkup,
      'draft': instance.draft,
      'mentionsId': instance.mentionsId,
      'lastUpdateTime': instance.lastUpdateTime,
      'lastMessageId': instance.lastMessageId,
      'firstMessageId': instance.firstMessageId,
      'pinId': instance.pinId,
      'lastCurrentUserSentMessageId': instance.lastCurrentUserSentMessageId,
      'deleted': instance.deleted,
      'pinned': instance.pinned,
      'synced': instance.synced,
      'seenSynced': instance.seenSynced,
      'shouldUpdateMediaCount': instance.shouldUpdateMediaCount,
    };
