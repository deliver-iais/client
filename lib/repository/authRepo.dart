// ignore_for_file: file_names

import 'package:deliver/box/avatar.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/message.dart';
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
import 'package:synchronized/synchronized.dart';

class AuthRepo {
  static final _logger = GetIt.I.get<Logger>();
  static final _sharedDao = GetIt.I.get<SharedDao>();
  static final _authServiceClient = GetIt.I.get<AuthServiceClient>();
  static final requestLock = Lock();

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
      _localPassword = await _sharedDao.get(SHARED_DAO_LOCAL_PASSWORD) ?? "";
      final accessToken = await _sharedDao.get(SHARED_DAO_ACCESS_TOKEN_KEY);
      final refreshToken = await _sharedDao.get(SHARED_DAO_REFRESH_TOKEN_KEY);
      _setTokensAndCurrentUserUid(accessToken, refreshToken);
    } catch (_) {}
  }

  Future<void> setCurrentUserUid() async {
    init();
    final res = await _sharedDao.get(SHARED_DAO_CURRENT_USER_UID);
    if (res != null) currentUserUid = (res).asUid();
  }

  Future<bool> getVerificationCode(PhoneNumber p) async {
    final platform = await getPlatformPB();

    try {
      _tmpPhoneNumber = p;
      await _authServiceClient.getVerificationCode(
        GetVerificationCodeReq()
          ..phoneNumber = p
          ..type = VerificationType.SMS
          ..platform = platform,
      );
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<AccessTokenRes> sendVerificationCode(String code) async {
    final platform = await getPlatformPB();

    final device = await getDeviceName();

    final res = await _authServiceClient.verifyAndGetToken(
      VerifyCodeReq()
        ..phoneNumber = _tmpPhoneNumber
        ..code = code
        ..device = device
        ..platform = platform
        // TODO(dansi): add password mechanism, https://gitlab.iais.co/deliver/wiki/-/issues/419
        ..password = "",
    );

    if (res.status == AccessTokenRes_Status.OK) {
      _setTokensAndCurrentUserUid(res.accessToken, res.refreshToken);
    }

    return res;
  }

  Future<AccessTokenRes> checkQrCodeToken(String token) async {
    final platform = await getPlatformPB();

    final device = await getDeviceName();

    final res = await _authServiceClient.checkQrCodeIsVerifiedAndLogin(
      CheckQrCodeIsVerifiedAndLoginReq()
        ..token = token
        ..device = device
        ..platform = platform
        //  TODO add password mechanism
        ..password = "",
    );

    if (res.status == AccessTokenRes_Status.OK) {
      _setTokensAndCurrentUserUid(res.accessToken, res.refreshToken);
    }

    return res;
  }

  Future _getAccessToken(String refreshToken) async =>
      requestLock.synchronized(() async {
        try {
          return await _authServiceClient.renewAccessToken(
            RenewAccessTokenReq()
              ..refreshToken = refreshToken
              ..platform = await getPlatformPB(),
          );
        } on GrpcError catch (e) {
          _logger.e(e);
          if (_refreshToken != null && e.code == StatusCode.unauthenticated) {
            GetIt.I.get<RoutingService>().logout();
          }
        } catch (e) {
          _logger.e(e);
        }
      });

  Future<String> getAccessToken() async {
    if (_isExpired(_accessToken)) {
      if (_refreshToken == null) {
        return "";
      }
      final RenewAccessTokenRes renewAccessTokenRes =
          await _getAccessToken(_refreshToken!);
      _saveTokens(renewAccessTokenRes);
      return renewAccessTokenRes.accessToken;
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
    _sharedDao
      ..put(SHARED_DAO_REFRESH_TOKEN_KEY, refreshToken)
      ..put(SHARED_DAO_ACCESS_TOKEN_KEY, accessToken);
    _setCurrentUid(accessToken);
  }

  void _setCurrentUid(String accessToken) {
    final decodedToken = JwtDecoder.decode(accessToken);
    currentUserUid = Uid()
      ..category = Categories.USER
      ..node = decodedToken["sub"]
      ..sessionId = decodedToken["jti"];
    _logger.d(currentUserUid);
    _sharedDao.put(SHARED_DAO_CURRENT_USER_UID, currentUserUid.asString());
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

  void saveTestUserInfo() {
    currentUserUid = TEST_USER_UID;
    _sharedDao.put(SHARED_DAO_CURRENT_USER_UID, TEST_USER_UID.asString());
  }
}

class DeliverClientInterceptor implements ClientInterceptor {
  final _authRepo = GetIt.I.get<AuthRepo>();

  Future<void> metadataProvider(
    Map<String, String> metadata,
    String uri,
  ) async {
    final token = await _authRepo.isTestUser()
        ? TEST_USER_ACCESS_TOKEN
        : await _authRepo.getAccessToken();
    metadata['access_token'] = token;
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
