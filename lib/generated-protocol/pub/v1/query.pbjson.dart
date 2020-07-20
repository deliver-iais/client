///
//  Generated code. Do not modify.
//  source: pub/v1/query.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

const IsUsernameValidReq$json = const {
  '1': 'IsUsernameValidReq',
  '2': const [
    const {'1': 'username', '3': 1, '4': 1, '5': 9, '8': const {}, '10': 'username'},
  ],
};

const IsUsernameValidRes$json = const {
  '1': 'IsUsernameValidRes',
  '2': const [
    const {'1': 'status', '3': 1, '4': 1, '5': 14, '6': '.proto.pub.v1.api.IsUsernameValidRes.Status', '10': 'status'},
  ],
  '4': const [IsUsernameValidRes_Status$json],
};

const IsUsernameValidRes_Status$json = const {
  '1': 'Status',
  '2': const [
    const {'1': 'OK', '2': 0},
    const {'1': 'ALREADY_EXIST', '2': 1},
    const {'1': 'REGEX_IS_WRONG', '2': 2},
  ],
};

const FetchMessagesReq$json = const {
  '1': 'FetchMessagesReq',
  '2': const [
    const {'1': 'with', '3': 1, '4': 1, '5': 11, '6': '.proto.pub.v1.models.Uid', '8': const {}, '10': 'with'},
    const {'1': 'pointer', '3': 2, '4': 1, '5': 3, '10': 'pointer'},
    const {'1': 'type', '3': 3, '4': 1, '5': 14, '6': '.proto.pub.v1.api.FetchMessagesReq.Type', '10': 'type'},
    const {'1': 'limit', '3': 4, '4': 1, '5': 5, '8': const {}, '10': 'limit'},
  ],
  '4': const [FetchMessagesReq_Type$json],
};

const FetchMessagesReq_Type$json = const {
  '1': 'Type',
  '2': const [
    const {'1': 'FORWARD_FETCH', '2': 0},
    const {'1': 'BACKWARD_FETCH', '2': 1},
  ],
};

const FetchMessagesRes$json = const {
  '1': 'FetchMessagesRes',
  '2': const [
    const {'1': 'messages', '3': 1, '4': 3, '5': 11, '6': '.proto.pub.v1.models.Message', '10': 'messages'},
  ],
};

const GetAllUserRoomMetaReq$json = const {
  '1': 'GetAllUserRoomMetaReq',
};

const GetAllUserRoomMetaRes$json = const {
  '1': 'GetAllUserRoomMetaRes',
  '2': const [
    const {'1': 'roomsMeta', '3': 1, '4': 3, '5': 11, '6': '.proto.pub.v1.models.UserRoomMeta', '10': 'roomsMeta'},
  ],
};

