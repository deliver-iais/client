///
//  Generated code. Do not modify.
//  source: pub/v1/profile.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

// ignore_for_file: UNDEFINED_SHOWN_NAME,UNUSED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class VerificationType extends $pb.ProtobufEnum {
  static const VerificationType MESSAGE = VerificationType._(0, 'MESSAGE');
  static const VerificationType SMS = VerificationType._(1, 'SMS');

  static const $core.List<VerificationType> values = <VerificationType> [
    MESSAGE,
    SMS,
  ];

  static final $core.Map<$core.int, VerificationType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static VerificationType valueOf($core.int value) => _byValue[value];

  const VerificationType._($core.int v, $core.String n) : super(v, n);
}

class AccessTokenRes_Status extends $pb.ProtobufEnum {
  static const AccessTokenRes_Status OK = AccessTokenRes_Status._(0, 'OK');
  static const AccessTokenRes_Status PASSWORD_PROTECTED = AccessTokenRes_Status._(1, 'PASSWORD_PROTECTED');
  static const AccessTokenRes_Status NOT_VALID = AccessTokenRes_Status._(2, 'NOT_VALID');

  static const $core.List<AccessTokenRes_Status> values = <AccessTokenRes_Status> [
    OK,
    PASSWORD_PROTECTED,
    NOT_VALID,
  ];

  static final $core.Map<$core.int, AccessTokenRes_Status> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AccessTokenRes_Status valueOf($core.int value) => _byValue[value];

  const AccessTokenRes_Status._($core.int v, $core.String n) : super(v, n);
}

class RenewAccessTokenRes_Status extends $pb.ProtobufEnum {
  static const RenewAccessTokenRes_Status OK = RenewAccessTokenRes_Status._(0, 'OK');
  static const RenewAccessTokenRes_Status NOT_VALID = RenewAccessTokenRes_Status._(1, 'NOT_VALID');

  static const $core.List<RenewAccessTokenRes_Status> values = <RenewAccessTokenRes_Status> [
    OK,
    NOT_VALID,
  ];

  static final $core.Map<$core.int, RenewAccessTokenRes_Status> _byValue = $pb.ProtobufEnum.initByValue(values);
  static RenewAccessTokenRes_Status valueOf($core.int value) => _byValue[value];

  const RenewAccessTokenRes_Status._($core.int v, $core.String n) : super(v, n);
}

