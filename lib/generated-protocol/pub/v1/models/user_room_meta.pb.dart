///
//  Generated code. Do not modify.
//  source: pub/v1/models/user_room_meta.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'uid.pb.dart' as $5;

class UserRoomMeta extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('UserRoomMeta', package: const $pb.PackageName('proto.pub.v1.models'), createEmptyInstance: create)
    ..aOM<$5.Uid>(1, 'uid', subBuilder: $5.Uid.create)
    ..aInt64(2, 'lastMessageId', protoName: 'lastMessageId')
    ..aInt64(3, 'lastMessageTime', protoName: 'lastMessageTime')
    ..hasRequiredFields = false
  ;

  UserRoomMeta._() : super();
  factory UserRoomMeta() => create();
  factory UserRoomMeta.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserRoomMeta.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  UserRoomMeta clone() => UserRoomMeta()..mergeFromMessage(this);
  UserRoomMeta copyWith(void Function(UserRoomMeta) updates) => super.copyWith((message) => updates(message as UserRoomMeta));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static UserRoomMeta create() => UserRoomMeta._();
  UserRoomMeta createEmptyInstance() => create();
  static $pb.PbList<UserRoomMeta> createRepeated() => $pb.PbList<UserRoomMeta>();
  @$core.pragma('dart2js:noInline')
  static UserRoomMeta getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserRoomMeta>(create);
  static UserRoomMeta _defaultInstance;

  @$pb.TagNumber(1)
  $5.Uid get uid => $_getN(0);
  @$pb.TagNumber(1)
  set uid($5.Uid v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasUid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUid() => clearField(1);
  @$pb.TagNumber(1)
  $5.Uid ensureUid() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get lastMessageId => $_getI64(1);
  @$pb.TagNumber(2)
  set lastMessageId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLastMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastMessageId() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get lastMessageTime => $_getI64(2);
  @$pb.TagNumber(3)
  set lastMessageTime($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLastMessageTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastMessageTime() => clearField(3);
}

