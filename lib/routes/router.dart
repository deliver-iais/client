import 'package:auto_route/auto_route_annotations.dart';
import 'package:deliver_flutter/screen/app-home/pages/homePage.dart';
import 'package:deliver_flutter/screen/app-intro/pages/introPage.dart';
import 'package:deliver_flutter/screen/app-auth/pages/loginPage.dart';
import 'package:deliver_flutter/screen/app-auth/pages/verificationPage.dart';

@MaterialAutoRouter()
class $Router {
  @initial
  IntroPage introPage;
  HomePage homePage;
  LoginPage loginPage;
  VerificationPage verificationPage;
}