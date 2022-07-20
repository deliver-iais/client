// import 'package:deliver/screen/register/pages/verification_page.dart';
// import 'package:flutter/material.dart';
//
// import '../helper/test_helper.dart';
// import 'package:mockito/mockito.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   group("test verification page  and check has  profile or not ", () {
//     setUp(() => registerServices());
//     tearDown(() => unregisterServices());
//     final autRepo = getAndRegisterAuthRepo();
//     testWidgets('insert', (tester) async {
//       await tester.pumpWidget(
//         const MaterialApp(
//           home:  VerificationPage(),
//         ),
//       );
//       await tester.pumpAndSettle();
//       await tester.enterText(
//         find.byKey(const Key("verificationCode")),
//         "12345",
//       );
//       verify(await autRepo.sendVerificationCode("12345"));
//     });
//   });
// }
