///
//  Generated code. Do not modify.
//  source: pub/v1/models/error.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

// ignore_for_file: UNDEFINED_SHOWN_NAME,UNUSED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class ErrorCode extends $pb.ProtobufEnum {
  static const ErrorCode UNKNOWN = ErrorCode._(0, 'UNKNOWN');
  static const ErrorCode BAD_REQUEST = ErrorCode._(1, 'BAD_REQUEST');
  static const ErrorCode UNAUTHENTICATED = ErrorCode._(2, 'UNAUTHENTICATED');
  static const ErrorCode PERMISSION_DENIED = ErrorCode._(3, 'PERMISSION_DENIED');
  static const ErrorCode NOT_FOUND = ErrorCode._(4, 'NOT_FOUND');
  static const ErrorCode CONFLICT = ErrorCode._(5, 'CONFLICT');
  static const ErrorCode RESOURCE_EXHAUSTED = ErrorCode._(6, 'RESOURCE_EXHAUSTED');
  static const ErrorCode INTERNAL = ErrorCode._(7, 'INTERNAL');
  static const ErrorCode UNIMPLEMENTED = ErrorCode._(8, 'UNIMPLEMENTED');
  static const ErrorCode UNAVAILABLE = ErrorCode._(9, 'UNAVAILABLE');
  static const ErrorCode DEADLINE_EXCEEDED = ErrorCode._(10, 'DEADLINE_EXCEEDED');

  static const $core.List<ErrorCode> values = <ErrorCode> [
    UNKNOWN,
    BAD_REQUEST,
    UNAUTHENTICATED,
    PERMISSION_DENIED,
    NOT_FOUND,
    CONFLICT,
    RESOURCE_EXHAUSTED,
    INTERNAL,
    UNIMPLEMENTED,
    UNAVAILABLE,
    DEADLINE_EXCEEDED,
  ];

  static final $core.Map<$core.int, ErrorCode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ErrorCode valueOf($core.int value) => _byValue[value];

  const ErrorCode._($core.int v, $core.String n) : super(v, n);
}

