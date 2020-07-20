///
//  Generated code. Do not modify.
//  source: pub/v1/query.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

// ignore_for_file: UNDEFINED_SHOWN_NAME,UNUSED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class IsUsernameValidRes_Status extends $pb.ProtobufEnum {
  static const IsUsernameValidRes_Status OK = IsUsernameValidRes_Status._(0, 'OK');
  static const IsUsernameValidRes_Status ALREADY_EXIST = IsUsernameValidRes_Status._(1, 'ALREADY_EXIST');
  static const IsUsernameValidRes_Status REGEX_IS_WRONG = IsUsernameValidRes_Status._(2, 'REGEX_IS_WRONG');

  static const $core.List<IsUsernameValidRes_Status> values = <IsUsernameValidRes_Status> [
    OK,
    ALREADY_EXIST,
    REGEX_IS_WRONG,
  ];

  static final $core.Map<$core.int, IsUsernameValidRes_Status> _byValue = $pb.ProtobufEnum.initByValue(values);
  static IsUsernameValidRes_Status valueOf($core.int value) => _byValue[value];

  const IsUsernameValidRes_Status._($core.int v, $core.String n) : super(v, n);
}

class FetchMessagesReq_Type extends $pb.ProtobufEnum {
  static const FetchMessagesReq_Type FORWARD_FETCH = FetchMessagesReq_Type._(0, 'FORWARD_FETCH');
  static const FetchMessagesReq_Type BACKWARD_FETCH = FetchMessagesReq_Type._(1, 'BACKWARD_FETCH');

  static const $core.List<FetchMessagesReq_Type> values = <FetchMessagesReq_Type> [
    FORWARD_FETCH,
    BACKWARD_FETCH,
  ];

  static final $core.Map<$core.int, FetchMessagesReq_Type> _byValue = $pb.ProtobufEnum.initByValue(values);
  static FetchMessagesReq_Type valueOf($core.int value) => _byValue[value];

  const FetchMessagesReq_Type._($core.int v, $core.String n) : super(v, n);
}

