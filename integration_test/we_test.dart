import 'package:deliver/main.dart' as app;
import 'package:deliver/screen/register/widgets/intl_phone_field.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'end-to-end test',
    () {
      testWidgets('we', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.tap(find.byKey(const Key("skip")));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(IntlPhoneField), "3306332081");
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('next')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key("verificationCode")),
          "53358",
        );
        // await tester.pump(const Duration(seconds: 2));
        // await tester.pumpAndSettle();
        // await tester.enterText(find.byKey(const Key("username")), "fake_user");
        // await tester.pumpAndSettle();
        // await tester.enterText(
        //     find.byKey(const Key("firstname")), "first name");
        // await tester.pumpAndSettle();
        // await tester.enterText(find.byKey(const Key("lastname")), "last name");
        // await tester.pumpAndSettle();
        // await tester.enterText(
        //   find.byKey(const Key("description")),
        //   "description",
        // );
        // await tester.pumpAndSettle();
        // await tester.ensureVisible(find.byKey(const Key("save")));
        // await tester.pumpAndSettle();
        // await tester.tap(find.byKey(const Key('save')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("new_muc")));
        await tester.tap(find.byKey(const Key('dismiss')));
        await tester.tap(find.byKey(const Key('newGroup')));
        await tester.pumpAndSettle();
      });
    },
  );
}
