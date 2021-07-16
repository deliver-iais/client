import 'dart:io';

import 'package:deliver_flutter/box/avatar.dart';
import 'package:deliver_flutter/box/dao/shared_dao.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:device_info/device_info.dart';

import 'package:get_it/get_it.dart';

import 'package:grpc/grpc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:fixnum/fixnum.dart';
import 'package:logger/logger.dart';

class AuthRepo {
  final _logger = GetIt.I.get<Logger>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _authServiceClient = GetIt.I.get<AuthServiceClient>();

  String currentUsername = "";
  Uid currentUserUid = Uid.create()
    ..category = Categories.USER
    ..node = "";
  Avatar avatar;
  PhoneNumber phoneNumber;
  String _accessToken;
  String _refreshToken;

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
      var verificationCode =
          await _authServiceClient.getVerificationCode(GetVerificationCodeReq()
            ..phoneNumber = phone
            ..type = VerificationType.SMS);
      return verificationCode;
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }

  Future sendVerificationCode(String code) async {
    String device;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      device = "Android/${androidInfo.model}";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      device = "Android/${iosInfo.identifierForVendor}";
    } else {
      device = "${Platform.operatingSystem}:${Platform.operatingSystemVersion}";
    }

    return await _authServiceClient.verifyAndGetToken(VerifyCodeReq()
      ..phoneNumber = this.phoneNumber
      ..code = code
      ..device = device
      //  TODO add password mechanism
      ..password = "");
  }

  Future _getAccessToken(String refreshToken) async {
    try {
      return await _authServiceClient
          .renewAccessToken(RenewAccessTokenReq()..refreshToken = refreshToken);
    } catch (e) {
      _logger.e(e);
    }
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
    _setCurrentUid(accessToken);
  }

  _setCurrentUid(String accessToken) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
    if (decodedToken != null) {
      currentUserUid = Uid()
        ..category = Categories.USER
        ..node = decodedToken["sub"];
      _logger.d(currentUserUid);
      _sharedDao.put(SHARED_DAO_CURRENT_USER_UID, currentUserUid.asString());
    }
  }

  _savePhoneNumber() {
    _sharedDao.put(
        SHARED_DAO_COUNTRY_CODE, this.phoneNumber.countryCode.toString());
    _sharedDao.put(
        SHARED_DAO_NATIONAL_NUMBER, this.phoneNumber.nationalNumber.toString());
  }

  bool isCurrentUser(String uid) => uid.isSameEntity(currentUserUid);
}

class DeliverClientInterceptor implements ClientInterceptor {
  final _authRepo = GetIt.I.get<AuthRepo>();

  Future<void> metadataProvider(
      Map<String, String> metadata, String uri) async {
    var token = await _authRepo.getAccessToken();
    metadata['access_token'] = token;
  }

  @override
  ResponseFuture<R> interceptUnary<Q, R>(ClientMethod<Q, R> method, Q request,
      CallOptions options, ClientUnaryInvoker<Q, R> invoker) {
    return invoker(method, request,
        options.mergedWith(CallOptions(providers: [this.metadataProvider])));
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
      ClientMethod<Q, R> method,
      Stream<Q> requests,
      CallOptions options,
      ClientStreamingInvoker<Q, R> invoker) {
    return invoker(method, requests,
        options.mergedWith(CallOptions(providers: [this.metadataProvider])));
  }
}
