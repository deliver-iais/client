import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';

import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class ProfileRepo {
  var accountRepo = GetIt.I.get<AccountRepo>();
  static ClientChannel clientChannel = ClientChannel(
      ServicesDiscoveryRepo().authConnection.host,
      port: ServicesDiscoveryRepo().authConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  var authServiceStub = AuthServiceClient(clientChannel);

  Future getVerificationCode(int countryCode, String nationalNumber) async {
    PhoneNumber phoneNumber = PhoneNumber()
      ..countryCode = countryCode
      ..nationalNumber = Int64.parseInt(nationalNumber);
    accountRepo.phoneNumber = phoneNumber;
    var verificationCode =
        await authServiceStub.getVerificationCode(GetVerificationCodeReq()
          ..phoneNumber = phoneNumber
          ..type = VerificationType.SMS);
    return verificationCode;
  }

  Future sendVerificationCode(String code) async {
    var sendVerificationCode =
        await authServiceStub.verifyAndGetToken(VerifyCodeReq()
          ..phoneNumber = accountRepo.phoneNumber
          ..code = code
          ..device = "android/124"
          ..password = "");
    return sendVerificationCode;
  }

  Future getAccessToken(String refreshToken) async {
    var getAccessToken = await authServiceStub
        .renewAccessToken(RenewAccessTokenReq()..refreshToken = refreshToken);
    return getAccessToken;
  }
}
