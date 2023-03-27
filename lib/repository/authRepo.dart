// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/session.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

const ACCESS_TOKEN_EXPIRATION_DELTA = Duration(seconds: 90);
const REFRESH_TOKEN_EXPIRATION_DELTA = Duration(days: 3);

class AuthRepo {
  static final _logger = GetIt.I.get<Logger>();
  static final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();
  static final _analyticsService = GetIt.I.get<AnalyticsService>();
  static final requestLock = Lock();

  final BehaviorSubject<bool> outOfDateObject = BehaviorSubject.seeded(false);

  BehaviorSubject<NewerVersionInformation?> newVersionInformation =
      BehaviorSubject();

  Uid currentUserUid = Uid.create()
    ..category = Categories.USER
    ..node = "";

  late PhoneNumber _tmpPhoneNumber;

  String get refreshToken => settings.refreshToken.value;

  String get accessToken => settings.accessToken.value;

  Future<void> init({bool retry = false}) async {
    try {
      if (accessToken.isNotEmpty) {
        _setCurrentUserUidFromAccessToken(accessToken);
      }
    } catch (e) {
      try {
        //delete shared pref file
        if (isWindowsNative || isLinuxNative) {
          final path =
              "${(await getApplicationSupportDirectory()).path}\\shared_preferences.json";
          if (File(path).existsSync()) {
            await (File(path)).delete(recursive: true);
            _logger.i("delete $path");
          }
        }
      } catch (e) {
        _logger.e(e);
      }

      _logger.e(e);
      if (retry) {
        return init();
      }
    }
  }

  Future<void> getVerificationCode(PhoneNumber p) async {
    final platform = await getPlatformPB();

    _tmpPhoneNumber = p;
    await _sdr.authServiceClient.getVerificationCode(
      GetVerificationCodeReq()
        ..phoneNumber = p
        ..type = VerificationType.SMS
        ..platform = platform,
      options: CallOptions(timeout: const Duration(seconds: 10)),
    );
  }

  Future<AccessTokenRes> sendVerificationCode(
    String code, {
    String? password,
  }) async {
    final platform = await getPlatformPB();
    final device = await getDeviceName();

    final res = await _sdr.authServiceClient.verifyAndGetToken(
      VerifyCodeReq()
        ..phoneNumber = _tmpPhoneNumber
        ..code = code
        ..device = device
        ..platform = platform
        ..password = password ?? "",
    );

    if (res.status == AccessTokenRes_Status.OK) {
      await _setTokensAndCurrentUserUid(
        accessToken: res.accessToken,
        refreshToken: res.refreshToken,
      );
    }

    return res;
  }

  Future<AccessTokenRes> checkQrCodeToken(
    String token, {
    String? password,
  }) async {
    final platform = await getPlatformPB();

    final device = await getDeviceName();

    final res = await _sdr.authServiceClient.checkQrCodeIsVerifiedAndLogin(
      CheckQrCodeIsVerifiedAndLoginReq()
        ..token = token
        ..device = device
        ..platform = platform
        ..password = password ?? "",
    );

    if (res.status == AccessTokenRes_Status.OK) {
      await _setTokensAndCurrentUserUid(
        accessToken: res.accessToken,
        refreshToken: res.refreshToken,
      );
    }

    return res;
  }

  Future<RenewAccessTokenRes> _renewTokensFromServer() =>
      requestLock.synchronized(() async {
        return await _sdr.authServiceClient.renewAccessToken(
          RenewAccessTokenReq()
            ..refreshToken = refreshToken
            ..platform = await getPlatformPB(),
        );
      });

  Future<String> getAccessToken() async {
    if (!_hasValidAccessToken()) {
      if (!_hasValidRefreshToken()) {
        return "";
      }
      try {
        final renewAccessTokenRes = await _renewTokensFromServer();

        await _setTokensAndCurrentUserUid(
          accessToken: renewAccessTokenRes.accessToken,
          refreshToken: renewAccessTokenRes.refreshToken,
        );

        if (!newVersionInformation.hasValue &&
            renewAccessTokenRes.newerVersionInformation.version.isNotEmpty &&
            renewAccessTokenRes.newerVersionInformation.version != VERSION) {
          newVersionInformation
              .add(renewAccessTokenRes.newerVersionInformation);
        }

        return renewAccessTokenRes.accessToken;
      } on GrpcError catch (e) {
        _logger.e(e);
        if (e.code == StatusCode.unauthenticated) {
          unawaited(GetIt.I.get<RoutingService>().logout());
        } else if (e.code == StatusCode.aborted && !outOfDateObject.value) {
          outOfDateObject.add(true);
        }

        return "";
      } catch (e) {
        _logger.e(e);

        return "";
      }
    } else {
      return accessToken;
    }
  }

  bool isLocalLockEnabled() => settings.localPassword.value != "";

  Stream<bool> get isLocalLockEnabledStream =>
      settings.localPassword.stream.map((pass) => pass != "");

  bool localPasswordIsCorrect(String pass) =>
      settings.localPassword.value == pass;

  void setLocalPassword(String pass) {
    settings.localPassword.set(pass);
    _analyticsService.sendLogEvent("setLocalPassword");
  }

  bool isLoggedIn() => _hasValidRefreshToken();

  Future<bool> _setTokensAndCurrentUserUid({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (_isValidToken(accessToken, fromNow: ACCESS_TOKEN_EXPIRATION_DELTA) &&
        _isValidToken(
          accessToken,
          fromNow: REFRESH_TOKEN_EXPIRATION_DELTA,
        )) {
      throw Exception(
        "Not valid tokens - [accessToken: $accessToken] [refreshToken: $refreshToken]",
      );
    }

    settings.accessToken.set(accessToken);
    settings.refreshToken.set(refreshToken);
    _setCurrentUserUidFromAccessToken(accessToken);
    return true;
  }

  bool _hasValidAccessToken() => _isValidToken(accessToken);

  bool _hasValidRefreshToken() => _isValidToken(refreshToken);

  bool _isValidToken(String token, {Duration fromNow = Duration.zero}) {
    return token.isNotEmpty && !_isExpired(token, fromNow: fromNow);
  }

  bool isRefreshTokenEmpty() => refreshToken.isEmpty;

  bool isRefreshTokenExpired() =>
      refreshToken.isNotEmpty && _isExpired(refreshToken);

  bool _isExpired(token, {Duration fromNow = Duration.zero}) {
    final expirationDate = JwtDecoder.getExpirationDate(token);
    return clock.now().add(fromNow).isAfter(expirationDate);
  }

  void _setCurrentUserUidFromAccessToken(String accessToken) {
    final decodedToken = JwtDecoder.decode(accessToken);

    currentUserUid = Uid()
      ..category = Categories.USER
      ..node = decodedToken["sub"]
      ..sessionId = decodedToken["jti"];
    _logger.d(currentUserUid);
  }

  bool isCurrentUser(String uid) => uid.isSameEntity(currentUserUid);

  bool isCurrentUserUid(Uid uid) =>
      uid.isUser() && uid.node == currentUserUid.node;

  bool isCurrentUserSender(Message msg) => isCurrentUser(msg.from);

  bool isCurrentSession(Session session) =>
      currentUserUid.sessionId == session.sessionId &&
      currentUserUid.node == session.node;

  Future<void> logout() async {
    try {
      settings.accessToken.set("");
      settings.refreshToken.set("");
      settings.localPassword.set("");
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> sendForgetPasswordEmail(PhoneNumber phoneNumber) async {
    await _sdr.authServiceClient.sendErasePasswordEmail(
      SendErasePasswordEmailReq()
        ..platform = await getPlatformPB()
        ..phoneNumber = phoneNumber,
    );
  }
}

class DeliverClientInterceptor implements ClientInterceptor {
  final _authRepo = GetIt.I.get<AuthRepo>();

  Future<void> metadataProvider(
    Map<String, String> metadata,
    String uri,
  ) async {
    metadata['access_token'] = await _authRepo.getAccessToken();
  }

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) =>
      invoker(
        method,
        request,
        options.mergedWith(CallOptions(providers: [metadataProvider])),
      );

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) =>
      invoker(
        method,
        requests,
        options.mergedWith(CallOptions(providers: [metadataProvider])),
      );
}
