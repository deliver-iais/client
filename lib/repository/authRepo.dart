// ignore_for_file: file_names

import 'dart:async';

import 'package:deliver/box/avatar.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/routing_service.dart';
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
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

class AuthRepo {
  static final _logger = GetIt.I.get<Logger>();
  static final _sharedDao = GetIt.I.get<SharedDao>();
  static final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();
  static final requestLock = Lock();

  BehaviorSubject<bool> outOfDateObject = BehaviorSubject.seeded(false);

  BehaviorSubject<NewerVersionInformation?> newVersionInformation =
      BehaviorSubject();

  Uid currentUserUid = Uid.create()
    ..category = Categories.USER
    ..node = "";
  Avatar? avatar;
  String? _accessToken;
  String? _refreshToken;
  late PhoneNumber _tmpPhoneNumber;
  var _localPassword = "";

  String? get refreshToken => _refreshToken;

  String? get accessToken => _accessToken;

  Future<void> init({bool retry = false}) async {
    try {
      _localPassword = await _sharedDao.get(SHARED_DAO_LOCAL_PASSWORD) ?? "";
      final accessToken = await _sharedDao.get(SHARED_DAO_ACCESS_TOKEN_KEY);
      final refreshToken = await _sharedDao.get(SHARED_DAO_REFRESH_TOKEN_KEY);
      return _setTokensAndCurrentUserUid(accessToken, refreshToken);
    } catch (e) {
      _logger.e(e);
      if (retry) {
        return init();
      }
    }
  }

  Future<void> setCurrentUserUid() async {
    try {
      await init(retry: true);
      final res = await _sharedDao.get(SHARED_DAO_CURRENT_USER_UID);
      if (res != null) currentUserUid = (res).asUid();
    } catch (e) {
      _logger.e(e.toString());
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
      await _setTokensAndCurrentUserUid(res.accessToken, res.refreshToken);
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
      await _setTokensAndCurrentUserUid(res.accessToken, res.refreshToken);
    }

    return res;
  }

  Future<RenewAccessTokenRes> _getAccessToken(String refreshToken) =>
      requestLock.synchronized(() async {
        return await _sdr.authServiceClient.renewAccessToken(
          RenewAccessTokenReq()
            ..refreshToken = refreshToken
            ..platform = await getPlatformPB(),
        );
      });

  Future<String> getAccessToken() async {
    if (_isExpired(_accessToken)) {
      if (_refreshToken == null) {
        return "";
      }
      try {
        final renewAccessTokenRes = await _getAccessToken(_refreshToken!);
        _saveTokens(renewAccessTokenRes);
        if (!newVersionInformation.hasValue &&
            renewAccessTokenRes.newerVersionInformation.version.isNotEmpty &&
            renewAccessTokenRes.newerVersionInformation.version != VERSION) {
          newVersionInformation
              .add(renewAccessTokenRes.newerVersionInformation);
        }
        return renewAccessTokenRes.accessToken;
      } on GrpcError catch (e) {
        _logger.e(e);
        if (_refreshToken != null && e.code == StatusCode.unauthenticated) {
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
      return _accessToken!;
    }
  }

  bool isLocalLockEnabled() => _localPassword != "";

  bool localPasswordIsCorrect(String pass) => _localPassword == pass;

  String getLocalPassword() => _localPassword;

  void setLocalPassword(String pass) {
    _localPassword = pass;
    _sharedDao.put(SHARED_DAO_LOCAL_PASSWORD, pass);
  }


  Future<bool> isLoggedIn() async {
    return _sharedDao.getBoolean(SHARED_DAO_IS_LOGGED_IN);
  }

  Future<void> setAsLoggedIn() async =>
      _sharedDao.putBoolean(SHARED_DAO_IS_LOGGED_IN, true);

  Future<void> setAsLoggedOut() async =>
      _sharedDao.putBoolean(SHARED_DAO_IS_LOGGED_IN, false);

  bool _isExpired(accessToken) =>
      accessToken == null || JwtDecoder.isExpired(accessToken);

  void _saveTokens(RenewAccessTokenRes res) {
    _setTokensAndCurrentUserUid(res.accessToken, res.refreshToken);
  }

  Future<void> _setTokensAndCurrentUserUid(
    String? accessToken,
    String? refreshToken,
  ) async {
    if (accessToken == null ||
        refreshToken == null ||
        accessToken.isEmpty ||
        refreshToken.isEmpty) {
      return;
    }
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _sharedDao.put(SHARED_DAO_REFRESH_TOKEN_KEY, refreshToken);
    await _sharedDao.put(SHARED_DAO_ACCESS_TOKEN_KEY, accessToken);
    return _setCurrentUid(accessToken);
  }

  Future<void> _setCurrentUid(String accessToken) {
    final decodedToken = JwtDecoder.decode(accessToken);
    currentUserUid = Uid()
      ..category = Categories.USER
      ..node = decodedToken["sub"]
      ..sessionId = decodedToken["jti"];
    _logger.d(currentUserUid);
    return _sharedDao.put(
      SHARED_DAO_CURRENT_USER_UID,
      currentUserUid.asString(),
    );
  }

  bool isCurrentUser(String uid) => uid.isSameEntity(currentUserUid);

  bool isCurrentUserUid(Uid uid) =>
      uid.isUser() && uid.node == currentUserUid.node;

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
