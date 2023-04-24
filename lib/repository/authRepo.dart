// TODO(any): change file name
// ignore_for_file: file_names

import 'dart:async';

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
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

class AuthRepo {
  static final _logger = GetIt.I.get<Logger>();
  static final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();
  static final _analyticsService = GetIt.I.get<AnalyticsService>();
  static final _accessTokenLock = Lock();

  int _serverTimeDiff = 0;

  final BehaviorSubject<bool> isOutOfDate = BehaviorSubject.seeded(false);

  final newVersionInformation =
      BehaviorSubject<NewerVersionInformation?>.seeded(null);

  Uid currentUserUid = Uid.create()
    ..category = Categories.USER
    ..node = "";

  late PhoneNumber _tmpPhoneNumber;

  String refreshToken({bool checkDaoFirst = false}) {
    if (checkDaoFirst) {
      if (settings.refreshTokenDao.value.isNotEmpty) {
        return settings.refreshTokenDao.value;
      } else {
        return settings.refreshToken.value;
      }
    } else {
      if (settings.refreshToken.value.isNotEmpty) {
        return settings.refreshToken.value;
      } else {
        return settings.refreshTokenDao.value;
      }
    }
  }

  String get accessToken => settings.accessToken.value;

  Duration get serverTimeDiff => Duration(milliseconds: _serverTimeDiff);

  Future<void> init() async {
    if (accessToken.isNotEmpty) {
      _setCurrentUserUidFromAccessToken(accessToken);
    }
    // Run just first time...
    await syncTimeWithServer();
  }

  Future<void> getVerificationCode(PhoneNumber p) async {
    final platform = await getPlatformPB();

    _tmpPhoneNumber = p;
    final res = await _sdr.authServiceClient.getVerificationCode(
      GetVerificationCodeReq()
        ..phoneNumber = p
        ..type = VerificationType.SMS
        ..platform = platform,
      options: CallOptions(timeout: const Duration(seconds: 10)),
    );

    emitNewVersionInformationIfNeeded(res.newerVersionInformation);
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
      await login(
        accessToken: res.accessToken,
        refreshToken: res.refreshToken,
      );
    }

    emitNewVersionInformationIfNeeded(res.newerVersionInformation);

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
      await login(
        accessToken: res.accessToken,
        refreshToken: res.refreshToken,
      );
    }

    emitNewVersionInformationIfNeeded(res.newerVersionInformation);

    return res;
  }

  Future<RenewAccessTokenRes> tryRenewTokens({
    String? refreshToken,
    bool checkDaoFirst = false,
  }) async {
    return _sdr.authServiceClient.renewAccessToken(
      RenewAccessTokenReq()
        ..refreshToken =
            refreshToken ?? this.refreshToken(checkDaoFirst: checkDaoFirst)
        ..platform = await getPlatformPB(),
      options: CallOptions(timeout: const Duration(seconds: 10)),
    );
  }

  Future<String> getAccessToken() async {
    if (isDeliverTokenValid(accessToken)) {
      return accessToken;
    }

    return _accessTokenLock.synchronized(() async {
      if (!isDeliverTokenValid(accessToken)) {
        if (!isDeliverTokenValid(refreshToken())) {
          unawaited(GetIt.I.get<RoutingService>().logout());
          return "";
        } else {
          await updateAndCheckTokens();
        }
      }

      return accessToken;
    });
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

  bool isLoggedIn() =>
      isDeliverTokenValid(refreshToken()) ||
      isDeliverTokenValid(refreshToken(checkDaoFirst: true));

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

  Future<void> syncTimeWithServer() async {
    try {
      return await calculateServerTimeDiff(timeout: const Duration(seconds: 1));
    } catch (_) {
      // Just ignore this option and set "Zero"
      _serverTimeDiff = 0;

      // Retry with more timeout duration
      try {
        unawaited(
          calculateServerTimeDiff(timeout: const Duration(seconds: 20)),
        );
      } catch (_) {
        // Ignore
      }
    }
  }

  Future<void> calculateServerTimeDiff({required Duration timeout}) async {
    final startTime = clock.now().millisecondsSinceEpoch; // eg. 1000

    final response = await _sdr.queryServiceClient.getTime(
      GetTimeReq(),
      options: CallOptions(timeout: timeout),
    ); // eg. 1100

    final now = clock.now().millisecondsSinceEpoch; // eg. 1200

    final estimatedRoundTripTime = (now - startTime) ~/ 2; // eg. 100

    _serverTimeDiff = (now - estimatedRoundTripTime) -
        response.currentTime.toInt(); // eg. 1200 - 100 - 1100
  }

  Future<bool> login({
    required String accessToken,
    required String refreshToken,
  }) async {
    storeTokens(accessToken: accessToken, refreshToken: refreshToken);

    if (!checkTokensTimes() ||
        !(await checkAccessToken()) ||
        !(await checkRefreshToken())) {
      await updateAndCheckTokens();
    }

    if (!checkTokensTimes() ||
        !(await checkAccessToken()) ||
        !(await checkRefreshToken())) {
      return false;
    }

    return true;
  }

  Future<void> updateAndCheckTokens() async {
    try {
      final r = await tryRenewTokens();
      final info = r.newerVersionInformation;

      emitNewVersionInformationIfNeeded(info);

      if (checkTokensTimes(
            accessToken: r.accessToken,
            refreshToken: r.refreshToken,
          ) &&
          await checkAccessToken(
            accessToken: r.accessToken,
          ) &&
          await checkRefreshToken(
            refreshToken: r.refreshToken,
          )) {
        // All things are good.

        storeTokens(accessToken: r.accessToken, refreshToken: r.refreshToken);
        return;
      }
    } on GrpcError catch (e) {
      _logger.e(e);
      handleGrpcError(e);
    } catch (e) {
      _logger.e(e);
    }

    try {
      final r2 = await tryRenewTokens(checkDaoFirst: true);
      // Save anyway
      storeTokens(accessToken: r2.accessToken, refreshToken: r2.refreshToken);
    } on GrpcError catch (e) {
      _logger.e(e);
      handleGrpcError(e);
    } catch (e) {
      _logger.e(e);
    }

    return;
  }

  void handleGrpcError(GrpcError e) {
    if (e.code == StatusCode.unauthenticated) {
      unawaited(GetIt.I.get<RoutingService>().logout());
    } else if (e.code == StatusCode.aborted) {
      emitOutOfDateIfNeeded();
    }
  }

  void emitNewVersionInformationIfNeeded(NewerVersionInformation info) {
    if (newVersionInformation.value == null &&
        info.version.isNotEmpty &&
        info.version != VERSION) {
      newVersionInformation.add(info);
    }
  }

  void emitOutOfDateIfNeeded() {
    if (!isOutOfDate.value) {
      isOutOfDate.add(true);
    }
  }

  void storeTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    settings.accessToken.set(accessToken);
    settings.refreshToken.set(refreshToken);
    settings.refreshTokenDao.set(refreshToken);
    _setCurrentUserUidFromAccessToken(accessToken);
  }

  bool checkTokensTimes({
    String? accessToken,
    String? refreshToken,
  }) {
    if (isDeliverTokenValid(accessToken ?? this.accessToken) &&
        isDeliverTokenValid(refreshToken ?? this.refreshToken())) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkAccessToken({
    String? accessToken,
  }) async {
    try {
      await _sdr.queryServiceClient.getUserLastDeliveryAck(
        GetUserLastDeliveryAckReq(),
        options: CallOptions(
          timeout: const Duration(seconds: 5),
          metadata: {"access_token": accessToken ?? this.accessToken},
        ),
      );

      // TODO(bitbeter): use last delivery ack
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkRefreshToken({
    String? refreshToken,
  }) async {
    try {
      await tryRenewTokens(refreshToken: refreshToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool isDeliverTokenValid(String token) {
    return token.isNotEmpty && !isDeliverTokenExpired(token);
  }

  bool isDeliverTokenExpired(String token) {
    final expirationDate = JwtDecoder.getExpirationDate(token);

    final now = clock.now();

    final diffDuration = Duration(milliseconds: _serverTimeDiff.abs());

    if (_serverTimeDiff > 0) {
      return now.subtract(diffDuration).isAfter(expirationDate);
    } else {
      return now.add(diffDuration).isAfter(expirationDate);
    }
  }
}

class DeliverClientInterceptor implements ClientInterceptor {
  final _authRepo = GetIt.I.get<AuthRepo>();

  Future<void> metadataProvider(
    Map<String, String> metadata,
    String uri,
  ) async {
    if (metadata['access_token']?.isEmpty ?? true) {
      metadata['access_token'] = await _authRepo.getAccessToken();
    }
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
