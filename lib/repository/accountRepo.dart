import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:fimber/fimber.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixnum/fixnum.dart';

const ACCESS_TOKEN_KEY = "accessToken";
const REFRESH_TOKEN_KEY = "refreshToken";

class AccountRepo {
  // TODO add account name protocol to server
  String currentUserName = "John Doe";
  Uid currentUserUid = Uid.create()
    ..category = Categories.User
    ..node = "john";
  Avatar avatar;
  PhoneNumber phoneNumber;
  String _accessToken;
  String _refreshToken;

  // Dependencies
  SharedPreferences _prefs = GetIt.I.get<SharedPreferences>();

  static ClientChannel _clientChannel = ClientChannel(
      ServicesDiscoveryRepo().authConnection.host,
      port: ServicesDiscoveryRepo().authConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  var authServiceStub = AuthServiceClient(_clientChannel);

  AccountRepo() {
    _setTokensAndCurrentUserUid(_prefs.getString(ACCESS_TOKEN_KEY),
        _prefs.getString(REFRESH_TOKEN_KEY));
  }

  Future getVerificationCode(int countryCode, String nationalNumber) async {
    PhoneNumber phone = PhoneNumber()
      ..countryCode = countryCode
      ..nationalNumber = Int64.parseInt(nationalNumber);
    this.phoneNumber = phone;
    var verificationCode =
        await authServiceStub.getVerificationCode(GetVerificationCodeReq()
          ..phoneNumber = phone
          ..type = VerificationType.SMS);
    return verificationCode;
  }

  Future sendVerificationCode(String code) async {
    var sendVerificationCode =
        await authServiceStub.verifyAndGetToken(VerifyCodeReq()
          ..phoneNumber = this.phoneNumber
          ..code = code
//          TODO add real device name
          ..device = "android/124"
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
      if (renewAccessTokenRes.status == RenewAccessTokenRes_Status.OK) {
        _saveTokens(renewAccessTokenRes);
        return renewAccessTokenRes.accessToken;
      } else if (renewAccessTokenRes.status ==
          RenewAccessTokenRes_Status.NOT_VALID) {
        return Future.error("Not Valid");
      }
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
    _prefs.setString(REFRESH_TOKEN_KEY, refreshToken);
    _prefs.setString(ACCESS_TOKEN_KEY, accessToken);
    setCurrentUid(accessToken);
  }

  setCurrentUid(String accessToken) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
    if (decodedToken != null) {
      currentUserUid = Uid()
        ..category = Categories.User
        ..node = decodedToken["sub"];
      print("UserId " + currentUserUid.getString());
    }
  }
}
