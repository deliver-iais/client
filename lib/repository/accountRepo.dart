import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/dao/SharedPreferencesDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/utils/log.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';

import 'package:get_it/get_it.dart';

import 'package:grpc/grpc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fixnum/fixnum.dart';

const ACCESS_TOKEN_KEY = "access_token";
const REFRESH_TOKEN_KEY = "refreshToken";
const USERNAME = "username";
const LAST_NAME = "lastName";
const FIRST_NAME = "firstName";
const PASSWORD = "password";
const EMAIL = "email";
const DESCRIPTION = "description";
const PHONE_NUMBER = "phoneNumber";
const NOTIFICATION = "notification";
const CURRENT_USER_UID = "current_user_uid";

class AccountRepo {
  final SharedPreferencesDao sharedPrefs;

  AccountRepo({@required this.sharedPrefs});

  // TODO add account name protocol to server
  String currentUsername = "@john_doe";
  Uid currentUserUid = Uid.create()
    ..category = Categories.USER
    ..node = "john";
  Avatar avatar;
  PhoneNumber phoneNumber;
  String _access_token;

  String _refreshToken;

  var authServiceStub = AuthServiceClient(ProfileServicesClientChannel);
  var _profile = UserServiceClient(ProfileServicesClientChannel);

  Future<void> init() async {
    var access_token = await sharedPrefs.get(ACCESS_TOKEN_KEY);
    var refreshToken = await sharedPrefs.get(REFRESH_TOKEN_KEY);
    _setTokensAndCurrentUserUid(access_token, refreshToken);
  }

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  String platformVersion;

  Future getVerificationCode(String countryCode, String nationalNumber) async {
    try {
      PhoneNumber phone = PhoneNumber()
        ..countryCode = int.parse(countryCode)
        ..nationalNumber = Int64.parseInt(nationalNumber);
      this.phoneNumber = phone;
      _savePhoneNumber();
      var verificationCode = await authServiceStub.getVerificationCode(
          GetVerificationCodeReq()
            ..phoneNumber = phone
            ..type = VerificationType.SMS,
          options: CallOptions(timeout: Duration(seconds: 3)));
      return verificationCode;
    } catch (e) {
      return null;
    }
  }

  Future sendVerificationCode(String code) async {
    String device;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.androidId;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.identifierForVendor;
    } else {
      device = "${Platform.operatingSystem}:${Platform.operatingSystemVersion}";
    }

    var sendVerificationCode =
        await authServiceStub.verifyAndGetToken(VerifyCodeReq()
          ..phoneNumber = this.phoneNumber
          ..code = code
          ..device = device
//          TODO add password mechanism
          ..password = "");

    return sendVerificationCode;
  }

  Future _getAccessToken(String refreshToken) async {
    var getAccessToken = await authServiceStub
        .renewAccessToken(RenewAccessTokenReq()..refreshToken = refreshToken);
    if (wrongAccessToken(getAccessToken.accessToken) ||
        wrongRefreshToken(getAccessToken.refreshToken)) {
      _getAccessToken(refreshToken);
      return;
    }
    return getAccessToken;
  }

  Future<String> getAccessToken() async {
    if (_isExpired(_access_token) || exp(_access_token)) {
      RenewAccessTokenRes renewAccessTokenRes =
          await _getAccessToken(_refreshToken);
      _saveTokens(renewAccessTokenRes);
      return renewAccessTokenRes.accessToken;
    } else {

      return _access_token;
    }
  }

  bool isLoggedIn() {
    return _refreshToken != null && !_isExpired(_refreshToken);
  }

  bool _isExpired(access_token) {
    return JwtDecoder.isExpired(access_token);
  }

  bool exp(String token) {
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final DateTime iaTirationDate = new DateTime.fromMillisecondsSinceEpoch(0)
        .add(new Duration(seconds: decodedToken["iat"]));
    return ((DateTime.now().millisecondsSinceEpoch -
            iaTirationDate.millisecondsSinceEpoch) >
        5 * 60 * 1000);
  }

  bool wrongAccessToken(String token) {
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final DateTime iatTime = new DateTime.fromMillisecondsSinceEpoch(0)
        .add(new Duration(seconds: decodedToken["iat"]));
    final DateTime expTime = new DateTime.fromMillisecondsSinceEpoch(0)
        .add(new Duration(seconds: decodedToken["exp"]));
    return ((expTime.millisecondsSinceEpoch - iatTime.millisecondsSinceEpoch) >
        15 * 60 * 1000);
  }

  bool wrongRefreshToken(String token) {
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final DateTime iatTime = new DateTime.fromMillisecondsSinceEpoch(0)
        .add(new Duration(seconds: decodedToken["iat"]));
    final DateTime expTime = new DateTime.fromMillisecondsSinceEpoch(0)
        .add(new Duration(seconds: decodedToken["exp"]));
    return ((expTime.millisecondsSinceEpoch - iatTime.millisecondsSinceEpoch) <
        29 * 24 * 60 * 60 * 1000);
  }

  void saveTokens(AccessTokenRes res) {
    _setTokensAndCurrentUserUid(res.accessToken, res.refreshToken);
  }

  void _saveTokens(RenewAccessTokenRes res) {
    _setTokensAndCurrentUserUid(res.accessToken, res.refreshToken);
  }

  Future<bool> getProfile({bool retry = false}) async {
    if (null != await sharedPrefs.get(FIRST_NAME)) {
      return true;
    }
    try {
      var result = await _profile.getUserProfile(GetUserProfileReq(),
          options: CallOptions(
              metadata: {'access_token': await getAccessToken()},
              timeout: Duration(seconds: 2)));
      if (result.hasProfile() && result.profile.firstName.isNotEmpty) {
        _saveProfilePrivateDate(
            firstName: result.profile.firstName,
            lastName: result.profile.lastName,
            email: result.profile.email);
        return true;
      } else
        return getUsername();
    } catch (e) {
      if (retry) return getProfile();
    }
  }

  Future<bool> getUsername() async {
    try {
      final QueryServiceClient _queryServiceClient =
          GetIt.I.get<QueryServiceClient>();
      var getIdRequest = await _queryServiceClient.getIdByUid(
          GetIdByUidReq()..uid = currentUserUid,
          options: CallOptions(
              metadata: {'access_token': await getAccessToken()},
              timeout: Duration(seconds: 2)));
      if (getIdRequest != null && getIdRequest.id.isNotEmpty) {
        sharedPrefs.set(USERNAME, getIdRequest.id);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void _setTokensAndCurrentUserUid(String access_token, String refreshToken) {
    if (access_token == null ||
        access_token.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return;
    }
    _access_token = access_token;
    _refreshToken = refreshToken;
    sharedPrefs.set(REFRESH_TOKEN_KEY, refreshToken);
    sharedPrefs.set(ACCESS_TOKEN_KEY, access_token);
    setCurrentUid(access_token);
  }

  setCurrentUid(String access_token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(access_token);
    if (decodedToken != null) {
      currentUserUid = Uid()
        ..category = Categories.USER
        ..node = decodedToken["sub"];
      debug("UserId " + currentUserUid.asString());
      sharedPrefs.set(CURRENT_USER_UID, currentUserUid.asString());
    }
  }

  Future<Uid> getCurrentUserUid() async {
    return (await sharedPrefs.get(CURRENT_USER_UID)).getUid();
  }

  Future<Account> getAccount() async {
    return Account()
      ..phoneNumber = await sharedPrefs.get(PHONE_NUMBER)
      ..userName = await sharedPrefs.get(USERNAME)
      ..firstName = await sharedPrefs.get(FIRST_NAME)
      ..lastName = await sharedPrefs.get(LAST_NAME)
      ..email = await sharedPrefs.get(EMAIL)
      ..password = await sharedPrefs.get(PASSWORD)
      ..description = await sharedPrefs.get(DESCRIPTION);
  }

  Future<bool> checkUserName(String username) async {
    final QueryServiceClient _queryServiceClient =
        GetIt.I.get<QueryServiceClient>();
    var checkUsernameRes = await _queryServiceClient.idIsAvailable(
        IdIsAvailableReq()..id = username,
        options:
            CallOptions(metadata: {'access_token': await getAccessToken()}));
    return checkUsernameRes.isAvailable;
  }

  Future<bool> setAccountDetails(
    String username,
    String firstName,
    String lastName,
    String email,
  ) async {
    final QueryServiceClient _queryServiceClient =
        GetIt.I.get<QueryServiceClient>();
    try {
      _queryServiceClient.setId(SetIdReq()..id = username,
          options:
              CallOptions(metadata: {"access_token": await getAccessToken()}));

      SaveUserProfileReq saveUserProfileReq = SaveUserProfileReq();
      if (firstName != null) {
        saveUserProfileReq.firstName = firstName;
      }
      if (lastName != null) {
        saveUserProfileReq.lastName = lastName;
      }
      if (email != null) {
        saveUserProfileReq.email = email;
      }

      _profile.saveUserProfile(saveUserProfileReq,
          options:
              CallOptions(metadata: {'access_token': await getAccessToken()}));
      _saveProfilePrivateDate(
          username: username,
          firstName: firstName,
          lastName: lastName,
          email: email);

      return true;
    } catch (e) {
      debug(e.toString());
      return false;
    }
  }

  _saveProfilePrivateDate(
      {String username, String firstName, String lastName, String email}) {
    if (username != null) sharedPrefs.set(USERNAME, username);
    sharedPrefs.set(FIRST_NAME, firstName);
    sharedPrefs.set(LAST_NAME, lastName);
    sharedPrefs.set(EMAIL, email);
  }

  _savePhoneNumber() {
    sharedPrefs.set(PHONE_NUMBER,
        "${this.phoneNumber.countryCode}${this.phoneNumber.nationalNumber}");
  }

  setNotificationState(String notif) {
    sharedPrefs.set(NOTIFICATION, notif);
  }

  Future<String> get notification => sharedPrefs.get(NOTIFICATION);

  void fetchProfile() async {
    if (null == await sharedPrefs.get(USERNAME)) {
      await getUsername();
    } else if (null == await sharedPrefs.get(FIRST_NAME)) {
      await getProfile(retry: true);
    }
  }

  bool isCurrentUser(String uid) => uid.isSameEntity(currentUserUid);
}
