// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContactImpl _$$ContactImplFromJson(Map<String, dynamic> json) =>
    _$ContactImpl(
      phoneNumber: fromJson(json['phoneNumber'] as String),
      uid: nullAbleUidFromJson(json['uid'] as String?),
      firstName: json['firstName'] as String? ?? "",
      lastName: json['lastName'] as String? ?? "",
      description: json['description'] as String? ?? "",
      syncHash: json['syncHash'] as int? ?? 0,
      updateTime: json['updateTime'] as int? ?? 0,
    );

Map<String, dynamic> _$$ContactImplToJson(_$ContactImpl instance) =>
    <String, dynamic>{
      'phoneNumber': toJson(instance.phoneNumber),
      'uid': nullableUidToJson(instance.uid),
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'description': instance.description,
      'syncHash': instance.syncHash,
      'updateTime': instance.updateTime,
    };
