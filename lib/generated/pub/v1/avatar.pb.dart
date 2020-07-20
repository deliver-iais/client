///
//  Generated code. Do not modify.
//  source: pub/v1/avatar.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'models/avatar.pb.dart' as $4;
import 'models/uid.pb.dart' as $5;

class AddAvatarReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('AddAvatarReq', package: const $pb.PackageName('proto.pub.v1.avatar'), createEmptyInstance: create)
    ..aOM<$4.Avatar>(1, 'avatar', subBuilder: $4.Avatar.create)
    ..hasRequiredFields = false
  ;

  AddAvatarReq._() : super();
  factory AddAvatarReq() => create();
  factory AddAvatarReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddAvatarReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  AddAvatarReq clone() => AddAvatarReq()..mergeFromMessage(this);
  AddAvatarReq copyWith(void Function(AddAvatarReq) updates) => super.copyWith((message) => updates(message as AddAvatarReq));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AddAvatarReq create() => AddAvatarReq._();
  AddAvatarReq createEmptyInstance() => create();
  static $pb.PbList<AddAvatarReq> createRepeated() => $pb.PbList<AddAvatarReq>();
  @$core.pragma('dart2js:noInline')
  static AddAvatarReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddAvatarReq>(create);
  static AddAvatarReq _defaultInstance;

  @$pb.TagNumber(1)
  $4.Avatar get avatar => $_getN(0);
  @$pb.TagNumber(1)
  set avatar($4.Avatar v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasAvatar() => $_has(0);
  @$pb.TagNumber(1)
  void clearAvatar() => clearField(1);
  @$pb.TagNumber(1)
  $4.Avatar ensureAvatar() => $_ensure(0);
}

class AddAvatarRes extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('AddAvatarRes', package: const $pb.PackageName('proto.pub.v1.avatar'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  AddAvatarRes._() : super();
  factory AddAvatarRes() => create();
  factory AddAvatarRes.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddAvatarRes.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  AddAvatarRes clone() => AddAvatarRes()..mergeFromMessage(this);
  AddAvatarRes copyWith(void Function(AddAvatarRes) updates) => super.copyWith((message) => updates(message as AddAvatarRes));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AddAvatarRes create() => AddAvatarRes._();
  AddAvatarRes createEmptyInstance() => create();
  static $pb.PbList<AddAvatarRes> createRepeated() => $pb.PbList<AddAvatarRes>();
  @$core.pragma('dart2js:noInline')
  static AddAvatarRes getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddAvatarRes>(create);
  static AddAvatarRes _defaultInstance;
}

class RemoveAvatarReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('RemoveAvatarReq', package: const $pb.PackageName('proto.pub.v1.avatar'), createEmptyInstance: create)
    ..aOM<$4.Avatar>(1, 'removing', subBuilder: $4.Avatar.create)
    ..hasRequiredFields = false
  ;

  RemoveAvatarReq._() : super();
  factory RemoveAvatarReq() => create();
  factory RemoveAvatarReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RemoveAvatarReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  RemoveAvatarReq clone() => RemoveAvatarReq()..mergeFromMessage(this);
  RemoveAvatarReq copyWith(void Function(RemoveAvatarReq) updates) => super.copyWith((message) => updates(message as RemoveAvatarReq));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static RemoveAvatarReq create() => RemoveAvatarReq._();
  RemoveAvatarReq createEmptyInstance() => create();
  static $pb.PbList<RemoveAvatarReq> createRepeated() => $pb.PbList<RemoveAvatarReq>();
  @$core.pragma('dart2js:noInline')
  static RemoveAvatarReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RemoveAvatarReq>(create);
  static RemoveAvatarReq _defaultInstance;

  @$pb.TagNumber(1)
  $4.Avatar get removing => $_getN(0);
  @$pb.TagNumber(1)
  set removing($4.Avatar v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasRemoving() => $_has(0);
  @$pb.TagNumber(1)
  void clearRemoving() => clearField(1);
  @$pb.TagNumber(1)
  $4.Avatar ensureRemoving() => $_ensure(0);
}

class RemoveAvatarRes extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('RemoveAvatarRes', package: const $pb.PackageName('proto.pub.v1.avatar'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  RemoveAvatarRes._() : super();
  factory RemoveAvatarRes() => create();
  factory RemoveAvatarRes.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RemoveAvatarRes.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  RemoveAvatarRes clone() => RemoveAvatarRes()..mergeFromMessage(this);
  RemoveAvatarRes copyWith(void Function(RemoveAvatarRes) updates) => super.copyWith((message) => updates(message as RemoveAvatarRes));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static RemoveAvatarRes create() => RemoveAvatarRes._();
  RemoveAvatarRes createEmptyInstance() => create();
  static $pb.PbList<RemoveAvatarRes> createRepeated() => $pb.PbList<RemoveAvatarRes>();
  @$core.pragma('dart2js:noInline')
  static RemoveAvatarRes getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RemoveAvatarRes>(create);
  static RemoveAvatarRes _defaultInstance;
}

class GetAvatarReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetAvatarReq', package: const $pb.PackageName('proto.pub.v1.avatar'), createEmptyInstance: create)
    ..pc<$5.Uid>(1, 'uidList', $pb.PbFieldType.PM, subBuilder: $5.Uid.create)
    ..hasRequiredFields = false
  ;

  GetAvatarReq._() : super();
  factory GetAvatarReq() => create();
  factory GetAvatarReq.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAvatarReq.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  GetAvatarReq clone() => GetAvatarReq()..mergeFromMessage(this);
  GetAvatarReq copyWith(void Function(GetAvatarReq) updates) => super.copyWith((message) => updates(message as GetAvatarReq));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GetAvatarReq create() => GetAvatarReq._();
  GetAvatarReq createEmptyInstance() => create();
  static $pb.PbList<GetAvatarReq> createRepeated() => $pb.PbList<GetAvatarReq>();
  @$core.pragma('dart2js:noInline')
  static GetAvatarReq getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAvatarReq>(create);
  static GetAvatarReq _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$5.Uid> get uidList => $_getList(0);
}

class GetAvatarRes extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetAvatarRes', package: const $pb.PackageName('proto.pub.v1.avatar'), createEmptyInstance: create)
    ..pc<$4.Avatar>(1, 'avatar', $pb.PbFieldType.PM, subBuilder: $4.Avatar.create)
    ..hasRequiredFields = false
  ;

  GetAvatarRes._() : super();
  factory GetAvatarRes() => create();
  factory GetAvatarRes.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAvatarRes.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  GetAvatarRes clone() => GetAvatarRes()..mergeFromMessage(this);
  GetAvatarRes copyWith(void Function(GetAvatarRes) updates) => super.copyWith((message) => updates(message as GetAvatarRes));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GetAvatarRes create() => GetAvatarRes._();
  GetAvatarRes createEmptyInstance() => create();
  static $pb.PbList<GetAvatarRes> createRepeated() => $pb.PbList<GetAvatarRes>();
  @$core.pragma('dart2js:noInline')
  static GetAvatarRes getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAvatarRes>(create);
  static GetAvatarRes _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$4.Avatar> get avatar => $_getList(0);
}

