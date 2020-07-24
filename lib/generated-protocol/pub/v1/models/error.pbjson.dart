///
//  Generated code. Do not modify.
//  source: pub/v1/models/error.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

const ErrorCode$json = const {
  '1': 'ErrorCode',
  '2': const [
    const {'1': 'UNKNOWN', '2': 0},
    const {'1': 'BAD_REQUEST', '2': 1},
    const {'1': 'UNAUTHENTICATED', '2': 2},
    const {'1': 'PERMISSION_DENIED', '2': 3},
    const {'1': 'NOT_FOUND', '2': 4},
    const {'1': 'CONFLICT', '2': 5},
    const {'1': 'RESOURCE_EXHAUSTED', '2': 6},
    const {'1': 'INTERNAL', '2': 7},
    const {'1': 'UNIMPLEMENTED', '2': 8},
    const {'1': 'UNAVAILABLE', '2': 9},
    const {'1': 'DEADLINE_EXCEEDED', '2': 10},
  ],
};

const Error$json = const {
  '1': 'Error',
  '2': const [
    const {'1': 'code', '3': 1, '4': 1, '5': 14, '6': '.proto.pub.v1.models.ErrorCode', '10': 'code'},
    const {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
  ],
};

