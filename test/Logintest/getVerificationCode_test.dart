import 'package:deliver_flutter/generated-protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_flutter/generated-protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/profileRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:mockito/mockito.dart';

import 'package:fixnum/fixnum.dart';

// test AuthServiceClient by Mock server

class MockAuthServiceClient extends Mock implements AuthServiceClient {}

void main() {

  PhoneNumber phoneNumber = PhoneNumber()
    ..countryCode = 98
    ..nationalNumber = Int64.parseInt("9121234567");



  test("AuthServiceClient ", () async {
    final mockClient = MockAuthServiceClient();
//
  var re = new GetVerificationCodeReq()
  ..phoneNumber=phoneNumber
  ..type=VerificationType.SMS;

    when(mockClient.getVerificationCode(GetVerificationCodeReq()
          ..phoneNumber = phoneNumber
          ..type = VerificationType.SMS))
        .thenAnswer((v) {
      print("code is send ");
    });

  var loginRequest =   mockClient.getVerificationCode(GetVerificationCodeReq()
    ..phoneNumber=phoneNumber
    ..type = VerificationType.SMS);

    expect(dynamic, dynamic);

  });

  test("Send Verification Code", () async {
    final mockClient = MockAuthServiceClient();

    var request = VerifyCodeReq()
      ..phoneNumber = phoneNumber
      ..device = "android/123"
      ..code = "12345"
      ..password = "12";

    when(mockClient.verifyAndGetToken(request))
        .thenAnswer((realInvocation) {
      print("code is verify");
    });

    var loginRequest = await mockClient.verifyAndGetToken(VerifyCodeReq()
      ..phoneNumber = phoneNumber
      ..device = "android/123"
      ..code = "12345"
      ..password = "12");

    expect(dynamic, dynamic);

  });
}

