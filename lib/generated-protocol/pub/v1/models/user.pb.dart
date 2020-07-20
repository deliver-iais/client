///
//  Generated code. Do not modify.
//  source: pub/v1/models/user.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'uid.pb.dart' as $5;
import 'phone.pb.dart' as $11;

class UserAsContact extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('UserAsContact', package: const $pb.PackageName('proto.pub.v1.models'), createEmptyInstance: create)
    ..aOM<$5.Uid>(1, 'node', subBuilder: $5.Uid.create)
    ..aOM<$11.PhoneNumber>(2, 'phoneNumber', protoName: 'phoneNumber', subBuilder: $11.PhoneNumber.create)
    ..aOS(3, 'username')
    ..aOS(4, 'firstName')
    ..aOS(5, 'lastName')
    ..aOS(6, 'description')
    ..aOS(8, 'email')
    ..hasRequiredFields = false
  ;

  UserAsContact._() : super();
  factory UserAsContact() => create();
  factory UserAsContact.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserAsContact.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  UserAsContact clone() => UserAsContact()..mergeFromMessage(this);
  UserAsContact copyWith(void Function(UserAsContact) updates) => super.copyWith((message) => updates(message as UserAsContact));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static UserAsContact create() => UserAsContact._();
  UserAsContact createEmptyInstance() => create();
  static $pb.PbList<UserAsContact> createRepeated() => $pb.PbList<UserAsContact>();
  @$core.pragma('dart2js:noInline')
  static UserAsContact getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserAsContact>(create);
  static UserAsContact _defaultInstance;

  @$pb.TagNumber(1)
  $5.Uid get node => $_getN(0);
  @$pb.TagNumber(1)
  set node($5.Uid v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasNode() => $_has(0);
  @$pb.TagNumber(1)
  void clearNode() => clearField(1);
  @$pb.TagNumber(1)
  $5.Uid ensureNode() => $_ensure(0);

  @$pb.TagNumber(2)
  $11.PhoneNumber get phoneNumber => $_getN(1);
  @$pb.TagNumber(2)
  set phoneNumber($11.PhoneNumber v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPhoneNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearPhoneNumber() => clearField(2);
  @$pb.TagNumber(2)
  $11.PhoneNumber ensurePhoneNumber() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get username => $_getSZ(2);
  @$pb.TagNumber(3)
  set username($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUsername() => $_has(2);
  @$pb.TagNumber(3)
  void clearUsername() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get firstName => $_getSZ(3);
  @$pb.TagNumber(4)
  set firstName($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFirstName() => $_has(3);
  @$pb.TagNumber(4)
  void clearFirstName() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get lastName => $_getSZ(4);
  @$pb.TagNumber(5)
  set lastName($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLastName() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastName() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => clearField(6);

  @$pb.TagNumber(8)
  $core.String get email => $_getSZ(6);
  @$pb.TagNumber(8)
  set email($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(8)
  $core.bool hasEmail() => $_has(6);
  @$pb.TagNumber(8)
  void clearEmail() => clearField(8);
}

class UserPrivateData extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('UserPrivateData', package: const $pb.PackageName('proto.pub.v1.models'), createEmptyInstance: create)
    ..aOM<$5.Uid>(1, 'node', subBuilder: $5.Uid.create)
    ..aOM<$11.PhoneNumber>(2, 'phoneNumber', subBuilder: $11.PhoneNumber.create)
    ..aOS(3, 'username')
    ..aOS(4, 'passwordHash')
    ..aOS(5, 'firstName')
    ..aOS(6, 'lastName')
    ..aOS(7, 'description')
    ..aOS(8, 'email')
    ..hasRequiredFields = false
  ;

  UserPrivateData._() : super();
  factory UserPrivateData() => create();
  factory UserPrivateData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserPrivateData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  UserPrivateData clone() => UserPrivateData()..mergeFromMessage(this);
  UserPrivateData copyWith(void Function(UserPrivateData) updates) => super.copyWith((message) => updates(message as UserPrivateData));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static UserPrivateData create() => UserPrivateData._();
  UserPrivateData createEmptyInstance() => create();
  static $pb.PbList<UserPrivateData> createRepeated() => $pb.PbList<UserPrivateData>();
  @$core.pragma('dart2js:noInline')
  static UserPrivateData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserPrivateData>(create);
  static UserPrivateData _defaultInstance;

  @$pb.TagNumber(1)
  $5.Uid get node => $_getN(0);
  @$pb.TagNumber(1)
  set node($5.Uid v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasNode() => $_has(0);
  @$pb.TagNumber(1)
  void clearNode() => clearField(1);
  @$pb.TagNumber(1)
  $5.Uid ensureNode() => $_ensure(0);

  @$pb.TagNumber(2)
  $11.PhoneNumber get phoneNumber => $_getN(1);
  @$pb.TagNumber(2)
  set phoneNumber($11.PhoneNumber v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPhoneNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearPhoneNumber() => clearField(2);
  @$pb.TagNumber(2)
  $11.PhoneNumber ensurePhoneNumber() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get username => $_getSZ(2);
  @$pb.TagNumber(3)
  set username($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUsername() => $_has(2);
  @$pb.TagNumber(3)
  void clearUsername() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get passwordHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set passwordHash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPasswordHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearPasswordHash() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get firstName => $_getSZ(4);
  @$pb.TagNumber(5)
  set firstName($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFirstName() => $_has(4);
  @$pb.TagNumber(5)
  void clearFirstName() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get lastName => $_getSZ(5);
  @$pb.TagNumber(6)
  set lastName($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasLastName() => $_has(5);
  @$pb.TagNumber(6)
  void clearLastName() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get description => $_getSZ(6);
  @$pb.TagNumber(7)
  set description($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasDescription() => $_has(6);
  @$pb.TagNumber(7)
  void clearDescription() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get email => $_getSZ(7);
  @$pb.TagNumber(8)
  set email($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasEmail() => $_has(7);
  @$pb.TagNumber(8)
  void clearEmail() => clearField(8);
}

