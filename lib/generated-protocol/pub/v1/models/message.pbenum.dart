///
//  Generated code. Do not modify.
//  source: pub/v1/models/message.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

// ignore_for_file: UNDEFINED_SHOWN_NAME,UNUSED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class PersistentEvent_Issue extends $pb.ProtobufEnum {
  static const PersistentEvent_Issue Kick = PersistentEvent_Issue._(0, 'Kick');
  static const PersistentEvent_Issue ADD_USER = PersistentEvent_Issue._(1, 'ADD_USER');
  static const PersistentEvent_Issue PIN_MESSAGE = PersistentEvent_Issue._(2, 'PIN_MESSAGE');
  static const PersistentEvent_Issue NAME_CHANGED = PersistentEvent_Issue._(3, 'NAME_CHANGED');
  static const PersistentEvent_Issue AVATAR_CHANGED = PersistentEvent_Issue._(4, 'AVATAR_CHANGED');

  static const $core.List<PersistentEvent_Issue> values = <PersistentEvent_Issue> [
    Kick,
    ADD_USER,
    PIN_MESSAGE,
    NAME_CHANGED,
    AVATAR_CHANGED,
  ];

  static final $core.Map<$core.int, PersistentEvent_Issue> _byValue = $pb.ProtobufEnum.initByValue(values);
  static PersistentEvent_Issue valueOf($core.int value) => _byValue[value];

  const PersistentEvent_Issue._($core.int v, $core.String n) : super(v, n);
}

