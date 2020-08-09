import 'package:auto_route/auto_route_annotations.dart';
import 'package:deliver_flutter/screen/app-home/pages/homePage.dart';
import 'package:deliver_flutter/screen/app-intro/pages/introPage.dart';
import 'package:deliver_flutter/screen/app-auth/pages/loginPage.dart';
import 'package:deliver_flutter/screen/app-auth/pages/verificationPage.dart';
import 'package:deliver_flutter/screen/app-room/pages/roomPage.dart';
import 'package:deliver_flutter/screen/splashScreen/pages/splashScreen.dart';
import 'package:deliver_flutter/screen/settings/settingsPage.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    MaterialRoute(page: SplashScreen, initial: true),
    MaterialRoute(page: IntroPage),
    MaterialRoute(page: LoginPage),
    MaterialRoute(page: VerificationPage),
    MaterialRoute(page: SettingsPage),
    MaterialRoute(path: '/users:id', page: HomePage),
    MaterialRoute(page: RoomPage),
  ],
)
class $Router {}
