///
//  Generated code. Do not modify.
//  source: pub/v1/avatar.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'avatar.pb.dart' as $0;
export 'avatar.pb.dart';

class AvatarServiceClient extends $grpc.Client {
  static final _$getAvatar =
      $grpc.ClientMethod<$0.GetAvatarReq, $0.GetAvatarRes>(
          '/proto.pub.v1.avatar.AvatarService/GetAvatar',
          ($0.GetAvatarReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.GetAvatarRes.fromBuffer(value));
  static final _$addAvatar =
      $grpc.ClientMethod<$0.AddAvatarReq, $0.AddAvatarRes>(
          '/proto.pub.v1.avatar.AvatarService/AddAvatar',
          ($0.AddAvatarReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.AddAvatarRes.fromBuffer(value));
  static final _$removeAvatar =
      $grpc.ClientMethod<$0.RemoveAvatarReq, $0.RemoveAvatarRes>(
          '/proto.pub.v1.avatar.AvatarService/RemoveAvatar',
          ($0.RemoveAvatarReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.RemoveAvatarRes.fromBuffer(value));

  AvatarServiceClient($grpc.ClientChannel channel, {$grpc.CallOptions options})
      : super(channel, options: options);

  $grpc.ResponseFuture<$0.GetAvatarRes> getAvatar($0.GetAvatarReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(_$getAvatar, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }

  $grpc.ResponseFuture<$0.AddAvatarRes> addAvatar($0.AddAvatarReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(_$addAvatar, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }

  $grpc.ResponseFuture<$0.RemoveAvatarRes> removeAvatar(
      $0.RemoveAvatarReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$removeAvatar, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }
}

abstract class AvatarServiceBase extends $grpc.Service {
  $core.String get $name => 'proto.pub.v1.avatar.AvatarService';

  AvatarServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetAvatarReq, $0.GetAvatarRes>(
        'GetAvatar',
        getAvatar_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetAvatarReq.fromBuffer(value),
        ($0.GetAvatarRes value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddAvatarReq, $0.AddAvatarRes>(
        'AddAvatar',
        addAvatar_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddAvatarReq.fromBuffer(value),
        ($0.AddAvatarRes value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RemoveAvatarReq, $0.RemoveAvatarRes>(
        'RemoveAvatar',
        removeAvatar_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RemoveAvatarReq.fromBuffer(value),
        ($0.RemoveAvatarRes value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetAvatarRes> getAvatar_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GetAvatarReq> request) async {
    return getAvatar(call, await request);
  }

  $async.Future<$0.AddAvatarRes> addAvatar_Pre(
      $grpc.ServiceCall call, $async.Future<$0.AddAvatarReq> request) async {
    return addAvatar(call, await request);
  }

  $async.Future<$0.RemoveAvatarRes> removeAvatar_Pre(
      $grpc.ServiceCall call, $async.Future<$0.RemoveAvatarReq> request) async {
    return removeAvatar(call, await request);
  }

  $async.Future<$0.GetAvatarRes> getAvatar(
      $grpc.ServiceCall call, $0.GetAvatarReq request);
  $async.Future<$0.AddAvatarRes> addAvatar(
      $grpc.ServiceCall call, $0.AddAvatarReq request);
  $async.Future<$0.RemoveAvatarRes> removeAvatar(
      $grpc.ServiceCall call, $0.RemoveAvatarReq request);
}
