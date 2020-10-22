import 'dart:io';

import 'package:deliver_flutter/db/dao/SharedPreferencesDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/screen/register/pages/testing_environment_tokens.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/user.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:device_info/device_info.dart';

import 'package:get_it/get_it.dart';

import 'package:grpc/grpc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fixnum/fixnum.dart';

const ACCESS_TOKEN_KEY = "accessToken";
const REFRESH_TOKEN_KEY = "refreshToken";
const USERNAME = "username";
const LAST_NAME = "lastName";
const FIRST_NAME = "firstName";
const PASSWORD = "password";
const EMAIL = "email";
const DESCRIPTION = "description";
const PHONE_NUMBER = "phoneNumber";

class AccountRepo {
  // TODO add account name protocol to server
  String currentUsername = "@john_doe";
  Uid currentUserUid = Uid.create()
    ..category = Categories.USER
    ..node = "john";
  Avatar avatar;
  PhoneNumber phoneNumber;
  String _accessToken = TESTING_ENVIRONMENT_ACCESS_TOKEN;
  String _refreshToken = TESTING_ENVIRONMENT_REFRESH_TOKEN;

  // Dependencies
  SharedPreferencesDao _prefs = GetIt.I.get<SharedPreferencesDao>();

  static ClientChannel _clientChannel = ClientChannel(
      ServicesDiscoveryRepo().authConnection.host,
      port: ServicesDiscoveryRepo().authConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  var authServiceStub = AuthServiceClient(_clientChannel);
  var _userServices = UserServiceClient(_clientChannel);

  Future<void> init() async {
    var accessToken = await _prefs.get(ACCESS_TOKEN_KEY);
    var refreshToken = await _prefs.get(REFRESH_TOKEN_KEY);
    _setTokensAndCurrentUserUid(accessToken, refreshToken);
  }

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  String platformVersion;

  Future getVerificationCode(String countryCode, String nationalNumber) async {
    PhoneNumber phone = PhoneNumber()
      ..countryCode = int.parse(countryCode)
      ..nationalNumber = Int64.parseInt(nationalNumber);
    this.phoneNumber = phone;
    _savePhoneNumber();
    var verificationCode =
        await authServiceStub.getVerificationCode(GetVerificationCodeReq()
          ..phoneNumber = phone
          ..type = VerificationType.SMS);
    return verificationCode;
  }

  Future sendVerificationCode(String code) async {
    String device;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.androidId;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.identifierForVendor;
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
    return getAccessToken;
  }

  Future<String> getAccessToken() async {
    if (_isExpired(_accessToken)) {
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

  void saveTokens(AccessTokenRes res) {
    _setTokensAndCurrentUserUid(res.accessToken, res.refreshToken);
  }

  void _saveTokens(RenewAccessTokenRes res) {
    _setTokensAndCurrentUserUid(res.accessToken, res.refreshToken);
  }

  Future<bool> usernameIsSet() async {
    print('accountRepo/userNameIsSet/beforeGetUserProfile');
    var result = await _userServices.getUserProfile(GetUserProfileReq(),
        options:
            CallOptions(metadata: {'accessToken': await getAccessToken()}));
    print('accountRepo/userNameIsSet/afterGetUserProfile');
    if (result.profile.hasUsername()) {
      print('accountRepo/userNameIsSet/in if');
      _saveProfilePrivateDate(
          username: result.profile.username,
          firstName: result.profile.firstName,
          lastName: result.profile.lastName,
          email: result.profile.email);
      return true;
    } else {
      print('accountRepo/userNameIsSet/in else');
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
    _prefs.set(REFRESH_TOKEN_KEY, refreshToken);
    _prefs.set(ACCESS_TOKEN_KEY, accessToken);
    setCurrentUid(accessToken);
  }

  setCurrentUid(String accessToken) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
    if (decodedToken != null) {
      currentUserUid = Uid()
        ..category = Categories.USER
        ..node = decodedToken["sub"];
      print("UserId " + currentUserUid.getString());
    }
  }

  Future<Account> getAccount() async {
    return Account()
      ..phoneNumber = await _prefs.get(PHONE_NUMBER)
      ..userName = await _prefs.get(USERNAME)
      ..firstName = await _prefs.get(FIRST_NAME)
      ..lastName = await _prefs.get(LAST_NAME)
      ..email = await _prefs.get(EMAIL)
      ..password = await _prefs.get(PASSWORD)
      ..description = await _prefs.get(DESCRIPTION);
  }

  Future<bool> checkUserName(String username) async {
    CheckUsernameRes checkUsernameRes = await _userServices.checkUsername(
        CheckUsernameReq()..username = username,
        options:
            CallOptions(metadata: {'accessToken': await getAccessToken()}));
    switch (checkUsernameRes.status) {
      case CheckUsernameRes_Status.REGEX_IS_WRONG:
        return false;
        break;
      case CheckUsernameRes_Status.ALREADY_EXIST:
        //todo delete
        return true;
        break;
      case CheckUsernameRes_Status.OK:
        return true;
        break;
    }

    return false;
  }

  Future<bool> setAccountDetails(
    String username,
    String firstName,
    String lastName,
    String email,
  ) async {
    try {
      SaveUserProfileReq saveUserProfileReq = SaveUserProfileReq();
      if (username != null) {
        saveUserProfileReq.username = username;
      }
      if (firstName != null) {
        saveUserProfileReq.firstName = firstName;
      }
      if (lastName != null) {
        saveUserProfileReq.lastName = lastName;
      }
      if (email != null) {
        saveUserProfileReq.email = email;
      }

      await _userServices.saveUserProfile(saveUserProfileReq,
          options:
              CallOptions(metadata: {'accessToken': await getAccessToken()}));
      _saveProfilePrivateDate(
          username: username,
          firstName: firstName,
          lastName: lastName,
          email: email);

      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  _saveProfilePrivateDate(
      {String username, String firstName, String lastName, String email}) {
    if (username != null) {
      _prefs.set(USERNAME, username);
    }
    _prefs.set(FIRST_NAME, firstName);
    _prefs.set(LAST_NAME, lastName);
    _prefs.set(EMAIL, email);
  }

  _savePhoneNumber() {
    _prefs.set(PHONE_NUMBER,
        "${this.phoneNumber.countryCode}${this.phoneNumber.nationalNumber}");
  }
}
