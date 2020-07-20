///
//  Generated code. Do not modify.
//  source: pub/v1/profile.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

const VerificationType$json = const {
  '1': 'VerificationType',
  '2': const [
    const {'1': 'MESSAGE', '2': 0},
    const {'1': 'SMS', '2': 1},
  ],
};

const GetVerificationCodeReq$json = const {
  '1': 'GetVerificationCodeReq',
  '2': const [
    const {'1': 'phone_number', '3': 1, '4': 1, '5': 11, '6': '.proto.pub.v1.models.PhoneNumber', '10': 'phoneNumber'},
    const {'1': 'type', '3': 2, '4': 1, '5': 14, '6': '.proto.pub.v1.profile.VerificationType', '10': 'type'},
  ],
};

const GetVerificationCodeRes$json = const {
  '1': 'GetVerificationCodeRes',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.proto.pub.v1.profile.VerificationType', '10': 'type'},
  ],
};

const VerifyCodeReq$json = const {
  '1': 'VerifyCodeReq',
  '2': const [
    const {'1': 'phone_number', '3': 1, '4': 1, '5': 11, '6': '.proto.pub.v1.models.PhoneNumber', '10': 'phoneNumber'},
    const {'1': 'code', '3': 2, '4': 1, '5': 9, '10': 'code'},
    const {'1': 'device', '3': 3, '4': 1, '5': 9, '10': 'device'},
    const {'1': 'password', '3': 4, '4': 1, '5': 9, '10': 'password'},
  ],
};

const AccessTokenRes$json = const {
  '1': 'AccessTokenRes',
  '2': const [
    const {'1': 'status', '3': 1, '4': 1, '5': 14, '6': '.proto.pub.v1.profile.AccessTokenRes.Status', '10': 'status'},
    const {'1': 'access_token', '3': 2, '4': 1, '5': 9, '10': 'accessToken'},
    const {'1': 'refresh_token', '3': 3, '4': 1, '5': 9, '10': 'refreshToken'},
    const {'1': 'password_hint', '3': 4, '4': 1, '5': 9, '10': 'passwordHint'},
    const {'1': 'forgot_email_hint', '3': 5, '4': 1, '5': 9, '10': 'forgotEmailHint'},
  ],
  '4': const [AccessTokenRes_Status$json],
};

const AccessTokenRes_Status$json = const {
  '1': 'Status',
  '2': const [
    const {'1': 'OK', '2': 0},
    const {'1': 'PASSWORD_PROTECTED', '2': 1},
    const {'1': 'NOT_VALID', '2': 2},
  ],
};

const RenewAccessTokenReq$json = const {
  '1': 'RenewAccessTokenReq',
  '2': const [
    const {'1': 'refresh_token', '3': 1, '4': 1, '5': 9, '10': 'refreshToken'},
  ],
};

const RenewAccessTokenRes$json = const {
  '1': 'RenewAccessTokenRes',
  '2': const [
    const {'1': 'status', '3': 1, '4': 1, '5': 14, '6': '.proto.pub.v1.profile.RenewAccessTokenRes.Status', '10': 'status'},
    const {'1': 'access_token', '3': 2, '4': 1, '5': 9, '10': 'accessToken'},
    const {'1': 'refresh_token', '3': 3, '4': 1, '5': 9, '10': 'refreshToken'},
  ],
  '4': const [RenewAccessTokenRes_Status$json],
};

const RenewAccessTokenRes_Status$json = const {
  '1': 'Status',
  '2': const [
    const {'1': 'OK', '2': 0},
    const {'1': 'NOT_VALID', '2': 1},
  ],
};

const SaveContactsReq$json = const {
  '1': 'SaveContactsReq',
  '2': const [
    const {'1': 'contactList', '3': 2, '4': 3, '5': 11, '6': '.proto.pub.v1.models.Contact', '10': 'contactList'},
  ],
};

const SaveContactsRes$json = const {
  '1': 'SaveContactsRes',
  '2': const [
    const {'1': 'errors', '3': 1, '4': 3, '5': 11, '6': '.proto.pub.v1.models.Error', '10': 'errors'},
  ],
};

const GetContactListUsersReq$json = const {
  '1': 'GetContactListUsersReq',
  '2': const [
    const {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    const {'1': 'page_number', '3': 3, '4': 1, '5': 5, '10': 'pageNumber'},
  ],
};

const GetContactListUsersRes$json = const {
  '1': 'GetContactListUsersRes',
  '2': const [
    const {'1': 'userList', '3': 1, '4': 3, '5': 11, '6': '.proto.pub.v1.models.UserAsContact', '10': 'userList'},
    const {'1': 'next_page_number', '3': 2, '4': 1, '5': 5, '10': 'nextPageNumber'},
    const {'1': 'total_size', '3': 3, '4': 1, '5': 5, '10': 'totalSize'},
  ],
};

const GetContactListReq$json = const {
  '1': 'GetContactListReq',
  '2': const [
    const {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    const {'1': 'page_number', '3': 3, '4': 1, '5': 5, '10': 'pageNumber'},
  ],
};

const GetContactListRes$json = const {
  '1': 'GetContactListRes',
  '2': const [
    const {'1': 'contactList', '3': 1, '4': 3, '5': 11, '6': '.proto.pub.v1.models.Contact', '10': 'contactList'},
    const {'1': 'next_page_number', '3': 2, '4': 1, '5': 5, '10': 'nextPageNumber'},
    const {'1': 'total_size', '3': 3, '4': 1, '5': 5, '10': 'totalSize'},
  ],
};

const GetUserProfileReq$json = const {
  '1': 'GetUserProfileReq',
};

const GetUserProfileRes$json = const {
  '1': 'GetUserProfileRes',
  '2': const [
    const {'1': 'profile', '3': 1, '4': 1, '5': 11, '6': '.proto.pub.v1.models.UserPrivateData', '10': 'profile'},
  ],
};

const SaveUserProfileReq$json = const {
  '1': 'SaveUserProfileReq',
  '2': const [
    const {'1': 'username', '3': 3, '4': 1, '5': 9, '10': 'username'},
    const {'1': 'password_hash', '3': 4, '4': 1, '5': 9, '10': 'passwordHash'},
    const {'1': 'first_name', '3': 5, '4': 1, '5': 9, '10': 'firstName'},
    const {'1': 'last_name', '3': 6, '4': 1, '5': 9, '10': 'lastName'},
    const {'1': 'description', '3': 7, '4': 1, '5': 9, '10': 'description'},
    const {'1': 'email', '3': 9, '4': 1, '5': 9, '10': 'email'},
  ],
};

const SaveUserProfileRes$json = const {
  '1': 'SaveUserProfileRes',
  '2': const [
    const {'1': 'errors', '3': 1, '4': 3, '5': 11, '6': '.proto.pub.v1.models.Error', '10': 'errors'},
  ],
};

const GetMySessionsReq$json = const {
  '1': 'GetMySessionsReq',
};

const GetMySessionsRes$json = const {
  '1': 'GetMySessionsRes',
  '2': const [
    const {'1': 'sessions', '3': 1, '4': 3, '5': 11, '6': '.proto.pub.v1.models.Session', '10': 'sessions'},
  ],
};

const RevokeSessionReq$json = const {
  '1': 'RevokeSessionReq',
  '2': const [
    const {'1': 'session_ids', '3': 1, '4': 3, '5': 9, '10': 'sessionIds'},
  ],
};

const RevokeSessionRes$json = const {
  '1': 'RevokeSessionRes',
};

