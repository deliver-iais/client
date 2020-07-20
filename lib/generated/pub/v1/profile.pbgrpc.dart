///
//  Generated code. Do not modify.
//  source: pub/v1/profile.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'profile.pb.dart' as $2;
export 'profile.pb.dart';

class ContactServiceClient extends $grpc.Client {
  static final _$saveContacts =
      $grpc.ClientMethod<$2.SaveContactsReq, $2.SaveContactsRes>(
          '/proto.pub.v1.profile.ContactService/SaveContacts',
          ($2.SaveContactsReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $2.SaveContactsRes.fromBuffer(value));
  static final _$getContactList =
      $grpc.ClientMethod<$2.GetContactListReq, $2.GetContactListRes>(
          '/proto.pub.v1.profile.ContactService/GetContactList',
          ($2.GetContactListReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $2.GetContactListRes.fromBuffer(value));
  static final _$getContactListUsers =
      $grpc.ClientMethod<$2.GetContactListUsersReq, $2.GetContactListUsersRes>(
          '/proto.pub.v1.profile.ContactService/GetContactListUsers',
          ($2.GetContactListUsersReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $2.GetContactListUsersRes.fromBuffer(value));

  ContactServiceClient($grpc.ClientChannel channel, {$grpc.CallOptions options})
      : super(channel, options: options);

  $grpc.ResponseFuture<$2.SaveContactsRes> saveContacts(
      $2.SaveContactsReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$saveContacts, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }

  $grpc.ResponseFuture<$2.GetContactListRes> getContactList(
      $2.GetContactListReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$getContactList, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }

  $grpc.ResponseFuture<$2.GetContactListUsersRes> getContactListUsers(
      $2.GetContactListUsersReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$getContactListUsers, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }
}

abstract class ContactServiceBase extends $grpc.Service {
  $core.String get $name => 'proto.pub.v1.profile.ContactService';

  ContactServiceBase() {
    $addMethod($grpc.ServiceMethod<$2.SaveContactsReq, $2.SaveContactsRes>(
        'SaveContacts',
        saveContacts_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.SaveContactsReq.fromBuffer(value),
        ($2.SaveContactsRes value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.GetContactListReq, $2.GetContactListRes>(
        'GetContactList',
        getContactList_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.GetContactListReq.fromBuffer(value),
        ($2.GetContactListRes value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.GetContactListUsersReq,
            $2.GetContactListUsersRes>(
        'GetContactListUsers',
        getContactListUsers_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $2.GetContactListUsersReq.fromBuffer(value),
        ($2.GetContactListUsersRes value) => value.writeToBuffer()));
  }

  $async.Future<$2.SaveContactsRes> saveContacts_Pre(
      $grpc.ServiceCall call, $async.Future<$2.SaveContactsReq> request) async {
    return saveContacts(call, await request);
  }

  $async.Future<$2.GetContactListRes> getContactList_Pre($grpc.ServiceCall call,
      $async.Future<$2.GetContactListReq> request) async {
    return getContactList(call, await request);
  }

  $async.Future<$2.GetContactListUsersRes> getContactListUsers_Pre(
      $grpc.ServiceCall call,
      $async.Future<$2.GetContactListUsersReq> request) async {
    return getContactListUsers(call, await request);
  }

  $async.Future<$2.SaveContactsRes> saveContacts(
      $grpc.ServiceCall call, $2.SaveContactsReq request);
  $async.Future<$2.GetContactListRes> getContactList(
      $grpc.ServiceCall call, $2.GetContactListReq request);
  $async.Future<$2.GetContactListUsersRes> getContactListUsers(
      $grpc.ServiceCall call, $2.GetContactListUsersReq request);
}

class UserServiceClient extends $grpc.Client {
  static final _$saveUserProfile =
      $grpc.ClientMethod<$2.SaveUserProfileReq, $2.SaveUserProfileRes>(
          '/proto.pub.v1.profile.UserService/SaveUserProfile',
          ($2.SaveUserProfileReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $2.SaveUserProfileRes.fromBuffer(value));
  static final _$getUserProfile =
      $grpc.ClientMethod<$2.GetUserProfileReq, $2.GetUserProfileRes>(
          '/proto.pub.v1.profile.UserService/GetUserProfile',
          ($2.GetUserProfileReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $2.GetUserProfileRes.fromBuffer(value));

  UserServiceClient($grpc.ClientChannel channel, {$grpc.CallOptions options})
      : super(channel, options: options);

  $grpc.ResponseFuture<$2.SaveUserProfileRes> saveUserProfile(
      $2.SaveUserProfileReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$saveUserProfile, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }

  $grpc.ResponseFuture<$2.GetUserProfileRes> getUserProfile(
      $2.GetUserProfileReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$getUserProfile, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }
}

abstract class UserServiceBase extends $grpc.Service {
  $core.String get $name => 'proto.pub.v1.profile.UserService';

  UserServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$2.SaveUserProfileReq, $2.SaveUserProfileRes>(
            'SaveUserProfile',
            saveUserProfile_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $2.SaveUserProfileReq.fromBuffer(value),
            ($2.SaveUserProfileRes value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.GetUserProfileReq, $2.GetUserProfileRes>(
        'GetUserProfile',
        getUserProfile_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.GetUserProfileReq.fromBuffer(value),
        ($2.GetUserProfileRes value) => value.writeToBuffer()));
  }

  $async.Future<$2.SaveUserProfileRes> saveUserProfile_Pre(
      $grpc.ServiceCall call,
      $async.Future<$2.SaveUserProfileReq> request) async {
    return saveUserProfile(call, await request);
  }

  $async.Future<$2.GetUserProfileRes> getUserProfile_Pre($grpc.ServiceCall call,
      $async.Future<$2.GetUserProfileReq> request) async {
    return getUserProfile(call, await request);
  }

  $async.Future<$2.SaveUserProfileRes> saveUserProfile(
      $grpc.ServiceCall call, $2.SaveUserProfileReq request);
  $async.Future<$2.GetUserProfileRes> getUserProfile(
      $grpc.ServiceCall call, $2.GetUserProfileReq request);
}

class AuthServiceClient extends $grpc.Client {
  static final _$getVerificationCode =
      $grpc.ClientMethod<$2.GetVerificationCodeReq, $2.GetVerificationCodeRes>(
          '/proto.pub.v1.profile.AuthService/GetVerificationCode',
          ($2.GetVerificationCodeReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $2.GetVerificationCodeRes.fromBuffer(value));
  static final _$verifyAndGetToken =
      $grpc.ClientMethod<$2.VerifyCodeReq, $2.AccessTokenRes>(
          '/proto.pub.v1.profile.AuthService/VerifyAndGetToken',
          ($2.VerifyCodeReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $2.AccessTokenRes.fromBuffer(value));
  static final _$renewAccessToken =
      $grpc.ClientMethod<$2.RenewAccessTokenReq, $2.RenewAccessTokenRes>(
          '/proto.pub.v1.profile.AuthService/RenewAccessToken',
          ($2.RenewAccessTokenReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $2.RenewAccessTokenRes.fromBuffer(value));

  AuthServiceClient($grpc.ClientChannel channel, {$grpc.CallOptions options})
      : super(channel, options: options);

  $grpc.ResponseFuture<$2.GetVerificationCodeRes> getVerificationCode(
      $2.GetVerificationCodeReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$getVerificationCode, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }

  $grpc.ResponseFuture<$2.AccessTokenRes> verifyAndGetToken(
      $2.VerifyCodeReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$verifyAndGetToken, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }

  $grpc.ResponseFuture<$2.RenewAccessTokenRes> renewAccessToken(
      $2.RenewAccessTokenReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$renewAccessToken, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }
}

abstract class AuthServiceBase extends $grpc.Service {
  $core.String get $name => 'proto.pub.v1.profile.AuthService';

  AuthServiceBase() {
    $addMethod($grpc.ServiceMethod<$2.GetVerificationCodeReq,
            $2.GetVerificationCodeRes>(
        'GetVerificationCode',
        getVerificationCode_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $2.GetVerificationCodeReq.fromBuffer(value),
        ($2.GetVerificationCodeRes value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.VerifyCodeReq, $2.AccessTokenRes>(
        'VerifyAndGetToken',
        verifyAndGetToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.VerifyCodeReq.fromBuffer(value),
        ($2.AccessTokenRes value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$2.RenewAccessTokenReq, $2.RenewAccessTokenRes>(
            'RenewAccessToken',
            renewAccessToken_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $2.RenewAccessTokenReq.fromBuffer(value),
            ($2.RenewAccessTokenRes value) => value.writeToBuffer()));
  }

  $async.Future<$2.GetVerificationCodeRes> getVerificationCode_Pre(
      $grpc.ServiceCall call,
      $async.Future<$2.GetVerificationCodeReq> request) async {
    return getVerificationCode(call, await request);
  }

  $async.Future<$2.AccessTokenRes> verifyAndGetToken_Pre(
      $grpc.ServiceCall call, $async.Future<$2.VerifyCodeReq> request) async {
    return verifyAndGetToken(call, await request);
  }

  $async.Future<$2.RenewAccessTokenRes> renewAccessToken_Pre(
      $grpc.ServiceCall call,
      $async.Future<$2.RenewAccessTokenReq> request) async {
    return renewAccessToken(call, await request);
  }

  $async.Future<$2.GetVerificationCodeRes> getVerificationCode(
      $grpc.ServiceCall call, $2.GetVerificationCodeReq request);
  $async.Future<$2.AccessTokenRes> verifyAndGetToken(
      $grpc.ServiceCall call, $2.VerifyCodeReq request);
  $async.Future<$2.RenewAccessTokenRes> renewAccessToken(
      $grpc.ServiceCall call, $2.RenewAccessTokenReq request);
}

class SessionServiceClient extends $grpc.Client {
  static final _$getMySessions =
      $grpc.ClientMethod<$2.GetMySessionsReq, $2.GetMySessionsRes>(
          '/proto.pub.v1.profile.SessionService/GetMySessions',
          ($2.GetMySessionsReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $2.GetMySessionsRes.fromBuffer(value));
  static final _$revokeSession =
      $grpc.ClientMethod<$2.RevokeSessionReq, $2.RevokeSessionRes>(
          '/proto.pub.v1.profile.SessionService/RevokeSession',
          ($2.RevokeSessionReq value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $2.RevokeSessionRes.fromBuffer(value));

  SessionServiceClient($grpc.ClientChannel channel, {$grpc.CallOptions options})
      : super(channel, options: options);

  $grpc.ResponseFuture<$2.GetMySessionsRes> getMySessions(
      $2.GetMySessionsReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$getMySessions, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }

  $grpc.ResponseFuture<$2.RevokeSessionRes> revokeSession(
      $2.RevokeSessionReq request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$revokeSession, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }
}

abstract class SessionServiceBase extends $grpc.Service {
  $core.String get $name => 'proto.pub.v1.profile.SessionService';

  SessionServiceBase() {
    $addMethod($grpc.ServiceMethod<$2.GetMySessionsReq, $2.GetMySessionsRes>(
        'GetMySessions',
        getMySessions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.GetMySessionsReq.fromBuffer(value),
        ($2.GetMySessionsRes value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.RevokeSessionReq, $2.RevokeSessionRes>(
        'RevokeSession',
        revokeSession_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.RevokeSessionReq.fromBuffer(value),
        ($2.RevokeSessionRes value) => value.writeToBuffer()));
  }

  $async.Future<$2.GetMySessionsRes> getMySessions_Pre($grpc.ServiceCall call,
      $async.Future<$2.GetMySessionsReq> request) async {
    return getMySessions(call, await request);
  }

  $async.Future<$2.RevokeSessionRes> revokeSession_Pre($grpc.ServiceCall call,
      $async.Future<$2.RevokeSessionReq> request) async {
    return revokeSession(call, await request);
  }

  $async.Future<$2.GetMySessionsRes> getMySessions(
      $grpc.ServiceCall call, $2.GetMySessionsReq request);
  $async.Future<$2.RevokeSessionRes> revokeSession(
      $grpc.ServiceCall call, $2.RevokeSessionReq request);
}
