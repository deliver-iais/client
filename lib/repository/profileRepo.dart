import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:fixnum/fixnum.dart';

import 'package:deliver_flutter/generated-protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_flutter/generated-protocol/pub/v1/profile.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class ProfileRepo {
  var accountRepo = GetIt.I.get<AccountRepo>();
  static ClientChannel clientChannel = ClientChannel(
      ServicesDiscoveryRepo().AuthConnection.host,
      port: ServicesDiscoveryRepo().AuthConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  var AuthServiceStub = AuthServiceClient(clientChannel);

  Future getVerificationCode(int countryCode, String nationalNumber) async {
    PhoneNumber phoneNumber = PhoneNumber()
      ..countryCode = countryCode
      ..nationalNumber = Int64.parseInt(nationalNumber);
    accountRepo.phoneNumber = phoneNumber;
    var verificationCode = await AuthServiceStub.getVerificationCode(GetVerificationCodeReq()
          ..phoneNumber = phoneNumber
          ..type = VerificationType.SMS);
    return verificationCode;
  }

  Future sendVerificationCode(String code) async {
    var sendVerificationCode = await AuthServiceStub.verifyAndGetToken(VerifyCodeReq()
    ..phoneNumber= accountRepo.phoneNumber
    ..code = code
    ..device = "android/124"
    ..password = "");
    return sendVerificationCode;

  }
}
