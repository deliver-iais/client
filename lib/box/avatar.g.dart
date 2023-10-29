// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AvatarImpl _$$AvatarImplFromJson(Map<String, dynamic> json) => _$AvatarImpl(
      uid: uidFromJson(json['uid'] as String),
      fileName: json['fileName'] as String,
      fileUuid: json['fileUuid'] as String,
      lastUpdateTime: json['lastUpdateTime'] as int,
      avatarIsEmpty: json['avatarIsEmpty'] as bool? ?? false,
      createdOn: json['createdOn'] as int,
    );

Map<String, dynamic> _$$AvatarImplToJson(_$AvatarImpl instance) =>
    <String, dynamic>{
      'uid': uidToJson(instance.uid),
      'fileName': instance.fileName,
      'fileUuid': instance.fileUuid,
      'lastUpdateTime': instance.lastUpdateTime,
      'avatarIsEmpty': instance.avatarIsEmpty,
      'createdOn': instance.createdOn,
    };
