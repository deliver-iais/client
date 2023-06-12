// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      countryCode: json['countryCode'] as int?,
      nationalNumber: json['nationalNumber'] as int?,
      username: json['username'] as String?,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      passwordProtected: json['passwordProtected'] as bool?,
      email: json['email'] as String?,
      description: json['description'] as String?,
      emailVerified: json['emailVerified'] as bool?,
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'countryCode': instance.countryCode,
      'nationalNumber': instance.nationalNumber,
      'username': instance.username,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'passwordProtected': instance.passwordProtected,
      'email': instance.email,
      'description': instance.description,
      'emailVerified': instance.emailVerified,
    };
