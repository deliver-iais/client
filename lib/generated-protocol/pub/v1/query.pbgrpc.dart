///
//  Generated code. Do not modify.
//  source: pub/v1/query.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'query.pb.dart' as $3;
export 'query.pb.dart';

class QueryServiceClient extends $grpc.Client {
  static final _$fetchMessages =
      $grpc.ClientMethod<$3.FetchMessagesReq, $3.FetchMessagesRes>(
          '/proto.pub.v1.api.QueryService/FetchMessages',
          ($3.FetchMessagesReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $3.FetchMessagesRes.fromBuffer(value));
  static final _$getAllUserRoomMeta =
      $grpc.ClientMethod<$3.GetAllUserRoomMetaReq, $3.GetAllUserRoomMetaRes>(
          '/proto.pub.v1.api.QueryService/GetAllUserRoomMeta',
          ($3.GetAllUserRoomMetaReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $3.GetAllUserRoomMetaRes.fromBuffer(value));

  QueryServiceClient($grpc.ClientChannel channel, {$grpc.CallOptions options})
      : super(channel, options: options);

  $grpc.ResponseFuture<$3.FetchMessagesRes> fetchMessages(
      $3.FetchMessagesReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$fetchMessages, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }

  $grpc.ResponseFuture<$3.GetAllUserRoomMetaRes> getAllUserRoomMeta(
      $3.GetAllUserRoomMetaReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$getAllUserRoomMeta, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }
}

abstract class QueryServiceBase extends $grpc.Service {
  $core.String get $name => 'proto.pub.v1.api.QueryService';

  QueryServiceBase() {
    $addMethod($grpc.ServiceMethod<$3.FetchMessagesReq, $3.FetchMessagesRes>(
        'FetchMessages',
        fetchMessages_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $3.FetchMessagesReq.fromBuffer(value),
        ($3.FetchMessagesRes value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$3.GetAllUserRoomMetaReq, $3.GetAllUserRoomMetaRes>(
            'GetAllUserRoomMeta',
            getAllUserRoomMeta_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $3.GetAllUserRoomMetaReq.fromBuffer(value),
            ($3.GetAllUserRoomMetaRes value) => value.writeToBuffer()));
  }

  $async.Future<$3.FetchMessagesRes> fetchMessages_Pre($grpc.ServiceCall call,
      $async.Future<$3.FetchMessagesReq> request) async {
    return fetchMessages(call, await request);
  }

  $async.Future<$3.GetAllUserRoomMetaRes> getAllUserRoomMeta_Pre(
      $grpc.ServiceCall call,
      $async.Future<$3.GetAllUserRoomMetaReq> request) async {
    return getAllUserRoomMeta(call, await request);
  }

  $async.Future<$3.FetchMessagesRes> fetchMessages(
      $grpc.ServiceCall call, $3.FetchMessagesReq request);
  $async.Future<$3.GetAllUserRoomMetaRes> getAllUserRoomMeta(
      $grpc.ServiceCall call, $3.GetAllUserRoomMetaReq request);
}
