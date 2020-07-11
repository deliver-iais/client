import 'package:auto_route/auto_route_annotations.dart';
import 'package:deliver_flutter/screen/app-home/pages/homePage.dart';
import 'package:deliver_flutter/screen/app-intro/pages/introPage.dart';
import 'package:deliver_flutter/screen/app-auth/pages/loginPage.dart';
import 'package:deliver_flutter/screen/app-auth/pages/verificationPage.dart';
import 'package:deliver_flutter/screen/splashScreen/pages/splashScreen.dart';

@MaterialAutoRouter()
class $Router {
  @initial
  SplashScreen splashScreen;
  IntroPage introPage;
  HomePage homePage;
  LoginPage loginPage;
  VerificationPage verificationPage;
}
