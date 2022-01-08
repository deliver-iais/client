// ignore_for_file: file_names

import 'dart:io';

import 'package:deliver/box/avatar.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/foundation.dart';

import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/platform.pb.dart'
    as platform_pb;
import 'package:deliver_public_protocol/pub/v1/models/session.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:device_info/device_info.dart';

import 'package:get_it/get_it.dart';

import 'package:grpc/grpc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';

import 'package:synchronized/synchronized.dart';
import 'package:deliver/web_classes/platform_detect.dart'
    if (dart.library.html) 'package:platform_detect/platform_detect.dart'
    as platform_detect;

class AuthRepo {
  final _logger = GetIt.I.get<Logger>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _authServiceClient = GetIt.I.get<AuthServiceClient>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final requestLock = Lock();

  var _password = "";

  String currentUsername = "";
  Uid currentUserUid = Uid.create()
    ..category = Categories.USER
    ..node = "";
  Avatar? avatar;
  String? _accessToken;
  String? _refreshToken;
  late String platformVersion;

  late PhoneNumber _tmpPhoneNumber;

  Future<bool> isTestUser() async {
    if (currentUserUid.node.isNotEmpty) {
      return currentUserUid.isSameEntity(TEST_USER_UID.asString());
    } else {
      currentUserUid =
          (await _sharedDao.get(SHARED_DAO_CURRENT_USER_UID))!.asUid();
      return currentUserUid.isSameEntity(TEST_USER_UID.asString());
    }
  }

  Future<void> init() async {
    try {
      _password = await _sharedDao.get(SHARED_DAO_LOCAL_PASSWORD) ?? "";
      var accessToken = await _sharedDao.get(SHARED_DAO_ACCESS_TOKEN_KEY);
      var refreshToken = await _sharedDao.get(SHARED_DAO_REFRESH_TOKEN_KEY);
      _setTokensAndCurrentUserUid(accessToken, refreshToken);
    } catch (_) {}
  }

  setCurrentUserUid() async {
    init();
    String? res = await _sharedDao.get(SHARED_DAO_CURRENT_USER_UID);
    if (res != null) currentUserUid = (res).asUid();
  }

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Future getVerificationCode(PhoneNumber p) async {
    platform_pb.Platform platform = await getPlatformDetails();

    try {
      _tmpPhoneNumber = p;
      var verificationCode =
          await _authServiceClient.getVerificationCode(GetVerificationCodeReq()
            ..phoneNumber = p
            ..type = VerificationType.SMS
            ..platform = platform);
      return verificationCode;
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }

  Future<platform_pb.Platform> getPlatformDetails() async {
    platform_pb.Platform platform = platform_pb.Platform()
      ..clientVersion = VERSION;
    return await getPlatForm(platform);
  }

  getPlatForm(platform_pb.Platform platform) async {
    if (kIsWeb) {
      platform
        ..platformType = platform_pb.PlatformsType.WEB
        ..osVersion = platform_detect.browser.version.major.toString();
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      platform
        ..platformType = platform_pb.PlatformsType.ANDROID
        ..osVersion = androidInfo.version.release;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      platform
        ..platformType = platform_pb.PlatformsType.IOS
        ..osVersion = iosInfo.systemVersion;
    } else if (Platform.isLinux) {
      platform
        ..platformType = platform_pb.PlatformsType.LINUX
        ..osVersion = Platform.operatingSystemVersion;
    } else if (Platform.isMacOS) {
      platform
        ..platformType = platform_pb.PlatformsType.MAC_OS
        ..osVersion = Platform.operatingSystemVersion;
    } else if (Platform.isWindows) {
      platform
        ..platformType = platform_pb.PlatformsType.WINDOWS
        ..osVersion = Platform.operatingSystemVersion;
    } else {
      platform
        ..platformType = platform_pb.PlatformsType.ANDROID
        ..osVersion = Platform.operatingSystemVersion;
    }
    return platform;
  }

  Future<String> getDeviceName() async {
    String device;
    if (kIsWeb) {
      device = platform_detect.browser.name;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    } else if (Platform.isLinux) {
      device = "${Platform.operatingSystem}:${Platform.operatingSystemVersion}";
    } else if (Platform.isMacOS) {
      device = "${Platform.operatingSystem}:${Platform.operatingSystemVersion}";
    } else if (Platform.isWindows) {
      device = "${Platform.operatingSystem}:${Platform.operatingSystemVersion}";
    } else {
      device = "${Platform.operatingSystem}:${Platform.operatingSystemVersion}";
    }
    return device;
  }

  Future<AccessTokenRes> sendVerificationCode(String code) async {
    platform_pb.Platform platform = await getPlatformDetails();

    String device = await getDeviceName();

    var res = await _authServiceClient.verifyAndGetToken(VerifyCodeReq()
      ..phoneNumber = _tmpPhoneNumber
      ..code = code
      ..device = device
      ..platform = platform
      //  TODO add password mechanism
      ..password = "");

    if (res.status == AccessTokenRes_Status.OK) {
      _setTokensAndCurrentUserUid(res.accessToken, res.refreshToken);
    }

    return res;
  }

  Future<AccessTokenRes> checkQrCodeToken(String token) async {
    platform_pb.Platform platform = await getPlatformDetails();

    String device = await getDeviceName();

    var res = await _authServiceClient
        .checkQrCodeIsVerifiedAndLogin(CheckQrCodeIsVerifiedAndLoginReq()
          ..token = token
          ..device = device
          ..platform = platform
          //  TODO add password mechanism
          ..password = "");

    if (res.status == AccessTokenRes_Status.OK) {
      _setTokensAndCurrentUserUid(res.accessToken, res.refreshToken);
    }

    return res;
  }

  Future _getAccessToken(String refreshToken) async {
    return await requestLock.synchronized(() async {
      try {
        return await _authServiceClient.renewAccessToken(RenewAccessTokenReq()
          ..refreshToken = refreshToken
          ..platform = await getPlatformDetails());
      } on GrpcError catch (e) {
        _logger.e(e);
        if (_refreshToken != null && e.code == StatusCode.unauthenticated) {
          _routingServices.logout();
        }
      } catch (e) {
        _logger.e(e);
      }
    });
  }

  Future<String> getAccessToken() async {
    if (_isExpired(_accessToken)) {
      if (_refreshToken == null) {
        return "";
      }
      RenewAccessTokenRes renewAccessTokenRes =
          await _getAccessToken(_refreshToken!);
      _saveTokens(renewAccessTokenRes);
      return renewAccessTokenRes.accessToken;
    } else {
      return _accessToken!;
    }
  }

  bool isLocalLockEnabled() => _password != "";

  bool localPasswordIsCorrect(String pass) => _password == pass;

  String getLocalPassword() => _password;

  void setLocalPassword(String pass) {
    _password = pass;

    _sharedDao.put(SHARED_DAO_LOCAL_PASSWORD, pass);
  }

  bool isLoggedIn() =>
      _refreshToken != null &&
      _refreshToken!.isNotEmpty &&
      !_isExpired(_refreshToken);

  bool _isExpired(accessToken) =>
      accessToken == null || JwtDecoder.isExpired(accessToken);

  void _saveTokens(RenewAccessTokenRes res) {
    _setTokensAndCurrentUserUid(res.accessToken, res.refreshToken);
  }

  void _setTokensAndCurrentUserUid(String? accessToken, String? refreshToken) {
    if (accessToken == null ||
        refreshToken == null ||
        accessToken.isEmpty ||
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
    currentUserUid = Uid()
      ..category = Categories.USER
      ..node = decodedToken["sub"]
      ..sessionId = decodedToken["jti"];
    _logger.d(currentUserUid);
    _sharedDao.put(SHARED_DAO_CURRENT_USER_UID, currentUserUid.asString());
  }

  bool isCurrentUser(String uid) => uid.isSameEntity(currentUserUid);

  bool isCurrentUserSender(Message msg) => isCurrentUser(msg.from);

  bool isCurrentSession(Session session) =>
      currentUserUid.sessionId == session.sessionId &&
      currentUserUid.node == session.node;

  Future<void> deleteTokens() async {
    _refreshToken = null;
    _accessToken = null;
    await _sharedDao.remove(SHARED_DAO_REFRESH_TOKEN_KEY);
    await _sharedDao.remove(SHARED_DAO_REFRESH_TOKEN_KEY);
  }

  saveTestUserInfo() {
    currentUserUid = TEST_USER_UID;
    _sharedDao.put(SHARED_DAO_CURRENT_USER_UID, TEST_USER_UID.asString());
  }
}

class DeliverClientInterceptor implements ClientInterceptor {
  final _authRepo = GetIt.I.get<AuthRepo>();

  Future<void> metadataProvider(
      Map<String, String> metadata, String uri) async {
    var token = await _authRepo.isTestUser()
        ? TEST_USER_ACCESS_TOKEN
        : await _authRepo.getAccessToken();
    metadata['access_token'] = token;
  }

  @override
  ResponseFuture<R> interceptUnary<Q, R>(ClientMethod<Q, R> method, Q request,
      CallOptions options, ClientUnaryInvoker<Q, R> invoker) {
    return invoker(method, request,
        options.mergedWith(CallOptions(providers: [metadataProvider])));
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
      ClientMethod<Q, R> method,
      Stream<Q> requests,
      CallOptions options,
      ClientStreamingInvoker<Q, R> invoker) {
    return invoker(method, requests,
        options.mergedWith(CallOptions(providers: [metadataProvider])));
  }
}
