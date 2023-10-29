// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_network_connections.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocalNetworkConnectionsImpl _$$LocalNetworkConnectionsImplFromJson(
        Map<String, dynamic> json) =>
    _$LocalNetworkConnectionsImpl(
      uid: uidFromJson(json['uid'] as String),
      ip: json['ip'],
      lastUpdateTime: json['lastUpdateTime'],
    );

Map<String, dynamic> _$$LocalNetworkConnectionsImplToJson(
        _$LocalNetworkConnectionsImpl instance) =>
    <String, dynamic>{
      'uid': uidToJson(instance.uid),
      'ip': instance.ip,
      'lastUpdateTime': instance.lastUpdateTime,
    };
