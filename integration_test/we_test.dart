import 'package:deliver/main.dart' as app;
import 'package:deliver/screen/register/widgets/intl_phone_field.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('we4', (tester) async {
      // await tester.pump(const Duration(seconds: 8));
      app.main();
       await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key("skip")));
      // await tester.pumpAndSettle();
      await tester.enterText(find.byType(IntlPhoneField), "3306332081");
      // await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('next')));
      // await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key("verificationCode")),
        "53358",
      );
      await tester.pump(const Duration(seconds: 3));
      // await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key("username")), "fake_user");
      await tester.enterText(find.byKey(const Key("firstname")), "first name");
      await tester.enterText(find.byKey(const Key("lastname")), "last name");
      await tester.enterText(
          find.byKey(const Key("description")), "description");
    });
  });
}
