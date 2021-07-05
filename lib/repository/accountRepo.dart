import 'dart:io';

import 'package:deliver_flutter/box/avatar.dart';
import 'package:deliver_flutter/box/dao/shared_dao.dart';
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/shared/functions.dart';
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
import 'package:flutter/foundation.dart';

import 'package:get_it/get_it.dart';

import 'package:grpc/grpc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fixnum/fixnum.dart';

import 'messageRepo.dart';

class AccountRepo {
  final _sharedDao = GetIt.I.get<SharedDao>();

  // TODO add account name protocol to server
  String currentUsername = "@john_doe";
  Uid currentUserUid = Uid.create()
    ..category = Categories.USER
    ..node = "john";
  Avatar avatar;
  PhoneNumber phoneNumber;
  String _accessToken;
  String _refreshToken;

  var _authServiceStub = AuthServiceClient(ProfileServicesClientChannel);
  var _profile = UserServiceClient(ProfileServicesClientChannel);

  Future<void> init() async {
    var accessToken = await _sharedDao.get(SHARED_DAO_ACCESS_TOKEN_KEY);
    var refreshToken = await _sharedDao.get(SHARED_DAO_REFRESH_TOKEN_KEY);
    _setTokensAndCurrentUserUid(accessToken, refreshToken);
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
      var verificationCode = await _authServiceStub.getVerificationCode(
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
        await _authServiceStub.verifyAndGetToken(VerifyCodeReq()
          ..phoneNumber = this.phoneNumber
          ..code = code
          ..device = device
//          TODO add password mechanism
          ..password = "");

    return sendVerificationCode;
  }

  Future _getAccessToken(String refreshToken) async {
    try {
      var getAccessToken = await _authServiceStub
          .renewAccessToken(RenewAccessTokenReq()..refreshToken = refreshToken);
      if (wrongAccessToken(getAccessToken.accessToken,
              getAccessToken.refreshToken, refreshToken) ||
          wrongRefreshToken(getAccessToken.refreshToken)) {
        _getAccessToken(refreshToken);
        return;
      }
      return getAccessToken;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> getAccessToken() async {
    if (_isExpired(_accessToken) || exp(_accessToken)) {
      RenewAccessTokenRes renewAccessTokenRes =
          await _getAccessToken(_refreshToken);
      _saveTokens(renewAccessTokenRes);
      return renewAccessTokenRes.accessToken;
    } else {
      return _accessToken;
    }
  }

  bool isLoggedIn() {
    return _refreshToken != null && !_isExpired(_refreshToken);
  }

  bool _isExpired(accessToken) {
    return JwtDecoder.isExpired(accessToken);
  }

  bool exp(String token) {
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final DateTime iaTirationDate = new DateTime.fromMillisecondsSinceEpoch(0)
        .add(new Duration(seconds: decodedToken["iat"]));
    if (((DateTime.now().millisecondsSinceEpoch -
            iaTirationDate.millisecondsSinceEpoch) >
        15 * 60 * 1000)) {
      return true;
    } else
      return false;
  }

  bool wrongAccessToken(
      String token, String refreshToken, String oldRefreshToken) {
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final DateTime iatTime = new DateTime.fromMillisecondsSinceEpoch(0)
        .add(new Duration(seconds: decodedToken["iat"]));
    final DateTime expTime = new DateTime.fromMillisecondsSinceEpoch(0)
        .add(new Duration(seconds: decodedToken["exp"]));
    if ((expTime.millisecondsSinceEpoch - iatTime.millisecondsSinceEpoch) >
        15 * 60 * 1000) {
      var messageRepo = GetIt.I.get<MessageRepo>();
      if (kDebugMode)
        messageRepo.sendErrorMessage_DEBUG_MODE_(
            "accessTonken = $token \n refrsh= $refreshToken \n oldRefreshToken $oldRefreshToken");
      return true;
    } else
      return false;
  }

  bool wrongRefreshToken(String token) {
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final DateTime iatTime = new DateTime.fromMillisecondsSinceEpoch(0)
        .add(new Duration(seconds: decodedToken["iat"]));
    final DateTime expTime = new DateTime.fromMillisecondsSinceEpoch(0)
        .add(new Duration(seconds: decodedToken["exp"]));
    if (((expTime.millisecondsSinceEpoch - iatTime.millisecondsSinceEpoch) <
        29 * 24 * 60 * 60 * 1000)) {
      var messageRepo = GetIt.I.get<MessageRepo>();
      if (kDebugMode) messageRepo.sendErrorMessage_DEBUG_MODE_("refreshTonken = $token");
      return true;
    }
    return false;
  }

  void saveTokens(AccessTokenRes res) {
    _setTokensAndCurrentUserUid(res.accessToken, res.refreshToken);
  }

  void _saveTokens(RenewAccessTokenRes res) {
    _setTokensAndCurrentUserUid(res.accessToken, res.refreshToken);
  }

  Future<bool> getProfile({bool retry = false}) async {
    if (null != await _sharedDao.get(SHARED_DAO_FIRST_NAME)) {
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
      if (retry)
        return getProfile();
      else
        return false;
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
        _sharedDao.put(SHARED_DAO_USERNAME, getIdRequest.id);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void _setTokensAndCurrentUserUid(String accessToken, String refreshToken) {
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return;
    }
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _sharedDao.put(SHARED_DAO_REFRESH_TOKEN_KEY, refreshToken);
    _sharedDao.put(SHARED_DAO_ACCESS_TOKEN_KEY, accessToken);
    setCurrentUid(accessToken);
  }

  setCurrentUid(String accessToken) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
    if (decodedToken != null) {
      currentUserUid = Uid()
        ..category = Categories.USER
        ..node = decodedToken["sub"];
      debug("UserId " + currentUserUid.asString());
      _sharedDao.put(SHARED_DAO_CURRENT_USER_UID, currentUserUid.asString());
    }
  }

  Future<Uid> getCurrentUserUid() async {
    return (await _sharedDao.get(SHARED_DAO_CURRENT_USER_UID)).asUid();
  }

  Future<Account> getAccount() async {
    return Account()
      ..phoneNumber = await _sharedDao.get(SHARED_DAO_PHONE_NUMBER)
      ..userName = await _sharedDao.get(SHARED_DAO_USERNAME)
      ..firstName = await _sharedDao.get(SHARED_DAO_FIRST_NAME)
      ..lastName = await _sharedDao.get(SHARED_DAO_LAST_NAME)
      ..email = await _sharedDao.get(SHARED_DAO_EMAIL)
      ..password = await _sharedDao.get(SHARED_DAO_PASSWORD)
      ..description = await _sharedDao.get(SHARED_DAO_DESCRIPTION);
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
    if (username != null) _sharedDao.put(SHARED_DAO_USERNAME, username);
    _sharedDao.put(SHARED_DAO_FIRST_NAME, firstName);
    _sharedDao.put(SHARED_DAO_LAST_NAME, lastName);
    _sharedDao.put(SHARED_DAO_EMAIL, email);
  }

  _savePhoneNumber() {
    _sharedDao.put(SHARED_DAO_PHONE_NUMBER,
        "${this.phoneNumber.countryCode}${this.phoneNumber.nationalNumber}");
  }

  setNotificationState(String n) {
    _sharedDao.put(SHARED_DAO_NOTIFICATION, n);
  }

  Future<String> get notification => _sharedDao.get(SHARED_DAO_NOTIFICATION);

  Future<void> fetchProfile() async {
    if (null == await _sharedDao.get(SHARED_DAO_USERNAME)) {
      await getUsername();
    } else if (null == await _sharedDao.get(SHARED_DAO_FIRST_NAME)) {
      await getProfile(retry: true);
    }
  }

  bool isCurrentUser(String uid) => uid.isSameEntity(currentUserUid);

  Future<String> getName() async {
    final account = await getAccount();

    return buildName(account.firstName, account.lastName);
  }
}
