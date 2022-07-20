// import 'package:deliver/screen/register/pages/login_page.dart';
// import 'package:deliver/screen/register/widgets/intl_phone_field.dart';
// import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
// import 'package:fixnum/fixnum.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
//
// import '../helper/test_helper.dart';
//
// void main() {
//   // IntegrationTestWidgetsFlutterBinding.ensureInitialized();
//   group("test_login_page", () {
//     setUp(() => registerServices());
//     tearDown(() => unregisterServices());
//     testWidgets('login by phone  number', (tester) async {
//       await tester.pumpWidget(const MaterialApp(
//         home: LoginPage(),
//       ),);
//       final autRepo = getAndRegisterAuthRepo();
//       await tester.enterText(find.byType(IntlPhoneField), "9114583949");
//       await tester.tap(find.byKey(const Key('next')));
//       verify(autRepo.getVerificationCode(PhoneNumber(countryCode: 98,nationalNumber: Int64(9114583949))));
//     });
//     testWidgets('login qr code', (tester) async {
//       await tester.pumpWidget(const MaterialApp(
//         home: LoginPage(),
//       ),);
//       final autRepo = getAndRegisterAuthRepo();
//       verify(autRepo.checkQrCodeToken(any));
//     });
//   });
// }
