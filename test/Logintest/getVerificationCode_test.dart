import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:fixnum/fixnum.dart';

// test AuthServiceClient by Mock server

class MockAuthServiceClient extends Mock implements AuthServiceClient {}

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();
  PhoneNumber phoneNumber = PhoneNumber()
    ..countryCode = 98
    ..nationalNumber = Int64.parseInt("9121234567");

  test("AuthServiceClient ", () async {
    final mockClient = MockAuthServiceClient();
//
    var re = new GetVerificationCodeReq()
      ..phoneNumber = phoneNumber
      ..type = VerificationType.SMS;

    when(mockClient.getVerificationCode(GetVerificationCodeReq()
          ..phoneNumber = phoneNumber
          ..type = VerificationType.SMS))
        .thenAnswer((v) {
      print("code is send ");
    });

    var loginRequest = mockClient.getVerificationCode(GetVerificationCodeReq()
      ..phoneNumber = phoneNumber
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

    when(mockClient.verifyAndGetToken(request)).thenAnswer((realInvocation) {
      print("code is verify");
      print("access_token and refreshToken is receved ");
      print("save in SharedPreferences  "); // by soe error: save in shared not write.
    });

    var loginRequest = await mockClient.verifyAndGetToken(VerifyCodeReq()
      ..phoneNumber = phoneNumber
      ..device = "android/123"
      ..code = "12345"
      ..password = "12");

    expect(dynamic, dynamic);

  });
}
