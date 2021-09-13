import 'dart:io';

import 'package:we/box/avatar.dart';
import 'package:we/box/dao/shared_dao.dart';
import 'package:we/box/message.dart';
import 'package:we/services/routing_service.dart';
import 'package:we/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/platform.pb.dart' as Pb;
import 'package:deliver_public_protocol/pub/v1/models/session.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:we/shared/extensions/uid_extension.dart';
import 'package:device_info/device_info.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:get_it/get_it.dart';

import 'package:grpc/grpc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import 'package:synchronized/synchronized.dart';

class AuthRepo {
  final _logger = GetIt.I.get<Logger>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _authServiceClient = GetIt.I.get<AuthServiceClient>();
  var _routingServices = GetIt.I.get<RoutingService>();
  final requestLock = Lock();

  String currentUsername = "";
  Uid currentUserUid = Uid.create()
    ..category = Categories.USER
    ..node = "";
  Avatar avatar;
  String _accessToken;
  String _refreshToken;

  PhoneNumber _tmpPhoneNumber;

  Future<void> init() async {
    var accessToken = await _sharedDao.get(SHARED_DAO_ACCESS_TOKEN_KEY);
    var refreshToken = await _sharedDao.get(SHARED_DAO_REFRESH_TOKEN_KEY);
    _setTokensAndCurrentUserUid(accessToken, refreshToken);
  }

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  String platformVersion;

  Future getVerificationCode(PhoneNumber p) async {
    Pb.Platform platform = await getPlatformDetails();

    try {
      this._tmpPhoneNumber = p;
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

  Future<Pb.Platform> getPlatformDetails() async {
    String version;
    try {
      var info = await PackageInfo.fromPlatform();
      version = info.version;
    } catch (e) {
      version = VERSION;
    }
    Pb.Platform platform = Pb.Platform()..clientVersion = version;
    return await getPlatForm(platform);
  }

  getPlatForm(Pb.Platform platform) async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      platform
        ..platformType = Pb.PlatformsType.ANDROID
        ..osVersion = androidInfo.version.release;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      platform
        ..platformType = Pb.PlatformsType.IOS
        ..osVersion = iosInfo.systemVersion;
    } else if (Platform.isLinux) {
      platform
        ..platformType = Pb.PlatformsType.LINUX
        ..osVersion = Platform.operatingSystemVersion;
    } else if (Platform.isMacOS) {
      platform
        ..platformType = Pb.PlatformsType.MAC_OS
        ..osVersion = Platform.operatingSystemVersion;
    } else if (Platform.isWindows) {
      platform
        ..platformType = Pb.PlatformsType.WINDOWS
        ..osVersion = Platform.operatingSystemVersion;
    } else {
      platform
        ..platformType = Pb.PlatformsType.ANDROID
        ..osVersion = Platform.operatingSystemVersion;
    }
    return platform;
  }

  Future<String> getDeviceName() async {
    String device;

    if (Platform.isAndroid) {
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
    Pb.Platform platform = await getPlatformDetails();

    String device = await getDeviceName();

    var res = await _authServiceClient.verifyAndGetToken(VerifyCodeReq()
      ..phoneNumber = this._tmpPhoneNumber
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
    Pb.Platform platform = await getPlatformDetails();

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
      }  on GrpcError catch (e) {
        _logger.e(e);
        if(e.message == GrpcError.unauthenticated().message){
          _routingServices.logout();
        }
      }catch(e){
        _logger.e(e);
      }
    });
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
        ..node = decodedToken["sub"]
        ..sessionId = decodedToken["jti"];
      _logger.d(currentUserUid);
      _sharedDao.put(SHARED_DAO_CURRENT_USER_UID, currentUserUid.asString());
    }
  }

  bool isCurrentUser(String uid) => uid.isSameEntity(currentUserUid);

  bool isCurrentUserSender(Message msg) => isCurrentUser(msg.from);

  bool isCurrentSession(Session session) =>
      currentUserUid.sessionId == session.sessionId &&
      currentUserUid.node == session.node;

  Future<void> deleteTokens() async {
    _refreshToken = "";
    _accessToken = "";
    await _sharedDao.remove(SHARED_DAO_REFRESH_TOKEN_KEY);
    await _sharedDao.remove(SHARED_DAO_REFRESH_TOKEN_KEY);
  }
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
