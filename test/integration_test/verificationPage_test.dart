import 'package:deliver/screen/register/pages/verification_page.dart';
import 'package:flutter/material.dart';

import '../helper/test_helper.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("test verification page  and check has  profile or not ", () {
    setUp(() => registerServices());
    tearDown(() => unregisterServices());
    testWidgets('insert verification code', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VerificationPage(),
        ),
      );
      final autRepo = getAndRegisterAuthRepo();
      getAndRegisterAccountRepo();
      getAndRegisterServicesDiscoveryRepo();
      await tester.enterText(
          find.byKey(const Key("verificationCode")), "12345");
      verify(autRepo.sendVerificationCode(any));
    });
  });
}
