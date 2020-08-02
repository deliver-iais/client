import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';

class ProfileRepo {
  static ClientChannel clientChannel = ClientChannel(
      ServicesDiscoveryRepo().AuthConnection.host,
      port: ServicesDiscoveryRepo().AuthConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  var AuthServiceStub = AuthServiceClient(clientChannel);

  Future getVerificationCode(int countryCode, String nationalNumber) async {
    PhoneNumber phoneNumber = PhoneNumber()
      ..countryCode = countryCode
      ..nationalNumber = Int64.parseInt(nationalNumber);
    var verificationCode =
        await AuthServiceStub.getVerificationCode(GetVerificationCodeReq()
          ..phoneNumber = phoneNumber
          ..type = VerificationType.SMS);
    return verificationCode;
  }
}
