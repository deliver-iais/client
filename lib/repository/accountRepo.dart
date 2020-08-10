import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixnum/fixnum.dart';

const ACCESS_TOKEN_KEY = "accessToken";
const REFRESH_TOKEN_KEY = "refreshToken";

class AccountRepo {
  // TODO add account name protocol to server
  String currentUserName = "John";
  Uid currentUserUid;
  Avatar avatar;
  PhoneNumber phoneNumber;
  SharedPreferences _prefs = GetIt.I.get<SharedPreferences>();
  String _accessToken;
  String _refreshToken;

  static ClientChannel _clientChannel = ClientChannel(
      ServicesDiscoveryRepo().authConnection.host,
      port: ServicesDiscoveryRepo().authConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  var authServiceStub = AuthServiceClient(_clientChannel);

  AccountRepo() {
    _accessToken = _prefs.getString(ACCESS_TOKEN_KEY);
    _refreshToken = _prefs.getString(REFRESH_TOKEN_KEY);
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

  Future getAccessToken() async {
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

  bool _isExpired(accessToken) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
    Fimber.d("exp=${decodedToken["exp"]}");
    double expTime = double.parse(decodedToken["exp"].toString());
    double now = new DateTime.now().millisecondsSinceEpoch / 1000;
    return now > expTime;
  }

  void _saveTokens(RenewAccessTokenRes res) {
    _accessToken = res.accessToken;
    _refreshToken = res.refreshToken;
    _prefs.setString(REFRESH_TOKEN_KEY, _refreshToken);
    _prefs.setString(ACCESS_TOKEN_KEY, _accessToken);
  }
}
