///
//  Generated code. Do not modify.
//  source: pub/v1/query.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'models/uid.pb.dart' as $5;
import 'models/message.pb.dart' as $8;
import 'models/user_room_meta.pb.dart' as $15;

import 'query.pbenum.dart';

export 'query.pbenum.dart';

class IsUsernameValidReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('IsUsernameValidReq', package: const $pb.PackageName('proto.pub.v1.api'), createEmptyInstance: create)
    ..aOS(1, 'username')
    ..hasRequiredFields = false
  ;

  IsUsernameValidReq._() : super();
  factory IsUsernameValidReq() => create();
  factory IsUsernameValidReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory IsUsernameValidReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  IsUsernameValidReq clone() => IsUsernameValidReq()..mergeFromMessage(this);
  IsUsernameValidReq copyWith(void Function(IsUsernameValidReq) updates) => super.copyWith((message) => updates(message as IsUsernameValidReq));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static IsUsernameValidReq create() => IsUsernameValidReq._();
  IsUsernameValidReq createEmptyInstance() => create();
  static $pb.PbList<IsUsernameValidReq> createRepeated() => $pb.PbList<IsUsernameValidReq>();
  @$core.pragma('dart2js:noInline')
  static IsUsernameValidReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IsUsernameValidReq>(create);
  static IsUsernameValidReq _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => clearField(1);
}

class IsUsernameValidRes extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('IsUsernameValidRes', package: const $pb.PackageName('proto.pub.v1.api'), createEmptyInstance: create)
    ..e<IsUsernameValidRes_Status>(1, 'status', $pb.PbFieldType.OE, defaultOrMaker: IsUsernameValidRes_Status.OK, valueOf: IsUsernameValidRes_Status.valueOf, enumValues: IsUsernameValidRes_Status.values)
    ..hasRequiredFields = false
  ;

  IsUsernameValidRes._() : super();
  factory IsUsernameValidRes() => create();
  factory IsUsernameValidRes.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory IsUsernameValidRes.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  IsUsernameValidRes clone() => IsUsernameValidRes()..mergeFromMessage(this);
  IsUsernameValidRes copyWith(void Function(IsUsernameValidRes) updates) => super.copyWith((message) => updates(message as IsUsernameValidRes));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static IsUsernameValidRes create() => IsUsernameValidRes._();
  IsUsernameValidRes createEmptyInstance() => create();
  static $pb.PbList<IsUsernameValidRes> createRepeated() => $pb.PbList<IsUsernameValidRes>();
  @$core.pragma('dart2js:noInline')
  static IsUsernameValidRes getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IsUsernameValidRes>(create);
  static IsUsernameValidRes _defaultInstance;

  @$pb.TagNumber(1)
  IsUsernameValidRes_Status get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(IsUsernameValidRes_Status v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => clearField(1);
}

class FetchMessagesReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('FetchMessagesReq', package: const $pb.PackageName('proto.pub.v1.api'), createEmptyInstance: create)
    ..aOM<$5.Uid>(1, 'with', subBuilder: $5.Uid.create)
    ..aInt64(2, 'pointer')
    ..e<FetchMessagesReq_Type>(3, 'type', $pb.PbFieldType.OE, defaultOrMaker: FetchMessagesReq_Type.FORWARD_FETCH, valueOf: FetchMessagesReq_Type.valueOf, enumValues: FetchMessagesReq_Type.values)
    ..a<$core.int>(4, 'limit', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  FetchMessagesReq._() : super();
  factory FetchMessagesReq() => create();
  factory FetchMessagesReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FetchMessagesReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  FetchMessagesReq clone() => FetchMessagesReq()..mergeFromMessage(this);
  FetchMessagesReq copyWith(void Function(FetchMessagesReq) updates) => super.copyWith((message) => updates(message as FetchMessagesReq));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FetchMessagesReq create() => FetchMessagesReq._();
  FetchMessagesReq createEmptyInstance() => create();
  static $pb.PbList<FetchMessagesReq> createRepeated() => $pb.PbList<FetchMessagesReq>();
  @$core.pragma('dart2js:noInline')
  static FetchMessagesReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FetchMessagesReq>(create);
  static FetchMessagesReq _defaultInstance;

  @$pb.TagNumber(1)
  $5.Uid get with_1 => $_getN(0);
  @$pb.TagNumber(1)
  set with_1($5.Uid v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasWith_1() => $_has(0);
  @$pb.TagNumber(1)
  void clearWith_1() => clearField(1);
  @$pb.TagNumber(1)
  $5.Uid ensureWith_1() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get pointer => $_getI64(1);
  @$pb.TagNumber(2)
  set pointer($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPointer() => $_has(1);
  @$pb.TagNumber(2)
  void clearPointer() => clearField(2);

  @$pb.TagNumber(3)
  FetchMessagesReq_Type get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(FetchMessagesReq_Type v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get limit => $_getIZ(3);
  @$pb.TagNumber(4)
  set limit($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasLimit() => $_has(3);
  @$pb.TagNumber(4)
  void clearLimit() => clearField(4);
}

class FetchMessagesRes extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('FetchMessagesRes', package: const $pb.PackageName('proto.pub.v1.api'), createEmptyInstance: create)
    ..pc<$8.Message>(1, 'messages', $pb.PbFieldType.PM, subBuilder: $8.Message.create)
    ..hasRequiredFields = false
  ;

  FetchMessagesRes._() : super();
  factory FetchMessagesRes() => create();
  factory FetchMessagesRes.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FetchMessagesRes.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  FetchMessagesRes clone() => FetchMessagesRes()..mergeFromMessage(this);
  FetchMessagesRes copyWith(void Function(FetchMessagesRes) updates) => super.copyWith((message) => updates(message as FetchMessagesRes));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FetchMessagesRes create() => FetchMessagesRes._();
  FetchMessagesRes createEmptyInstance() => create();
  static $pb.PbList<FetchMessagesRes> createRepeated() => $pb.PbList<FetchMessagesRes>();
  @$core.pragma('dart2js:noInline')
  static FetchMessagesRes getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FetchMessagesRes>(create);
  static FetchMessagesRes _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$8.Message> get messages => $_getList(0);
}

class GetAllUserRoomMetaReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetAllUserRoomMetaReq', package: const $pb.PackageName('proto.pub.v1.api'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  GetAllUserRoomMetaReq._() : super();
  factory GetAllUserRoomMetaReq() => create();
  factory GetAllUserRoomMetaReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAllUserRoomMetaReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  GetAllUserRoomMetaReq clone() => GetAllUserRoomMetaReq()..mergeFromMessage(this);
  GetAllUserRoomMetaReq copyWith(void Function(GetAllUserRoomMetaReq) updates) => super.copyWith((message) => updates(message as GetAllUserRoomMetaReq));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GetAllUserRoomMetaReq create() => GetAllUserRoomMetaReq._();
  GetAllUserRoomMetaReq createEmptyInstance() => create();
  static $pb.PbList<GetAllUserRoomMetaReq> createRepeated() => $pb.PbList<GetAllUserRoomMetaReq>();
  @$core.pragma('dart2js:noInline')
  static GetAllUserRoomMetaReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAllUserRoomMetaReq>(create);
  static GetAllUserRoomMetaReq _defaultInstance;
}

class GetAllUserRoomMetaRes extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetAllUserRoomMetaRes', package: const $pb.PackageName('proto.pub.v1.api'), createEmptyInstance: create)
    ..pc<$15.UserRoomMeta>(1, 'roomsMeta', $pb.PbFieldType.PM, protoName: 'roomsMeta', subBuilder: $15.UserRoomMeta.create)
    ..hasRequiredFields = false
  ;

  GetAllUserRoomMetaRes._() : super();
  factory GetAllUserRoomMetaRes() => create();
  factory GetAllUserRoomMetaRes.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAllUserRoomMetaRes.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  GetAllUserRoomMetaRes clone() => GetAllUserRoomMetaRes()..mergeFromMessage(this);
  GetAllUserRoomMetaRes copyWith(void Function(GetAllUserRoomMetaRes) updates) => super.copyWith((message) => updates(message as GetAllUserRoomMetaRes));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GetAllUserRoomMetaRes create() => GetAllUserRoomMetaRes._();
  GetAllUserRoomMetaRes createEmptyInstance() => create();
  static $pb.PbList<GetAllUserRoomMetaRes> createRepeated() => $pb.PbList<GetAllUserRoomMetaRes>();
  @$core.pragma('dart2js:noInline')
  static GetAllUserRoomMetaRes getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAllUserRoomMetaRes>(create);
  static GetAllUserRoomMetaRes _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$15.UserRoomMeta> get roomsMeta => $_getList(0);
}

