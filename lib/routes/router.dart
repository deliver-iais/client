import 'package:auto_route/auto_route_annotations.dart';
import 'package:deliver_flutter/screen/app-home/pages/homePage.dart';
import 'package:deliver_flutter/screen/app-intro/pages/introPage.dart';
import 'package:deliver_flutter/screen/app-auth/pages/loginPage.dart';
import 'package:deliver_flutter/screen/app-auth/pages/verificationPage.dart';
import 'package:deliver_flutter/screen/privateChat/pages/privateChat.dart';
import 'package:deliver_flutter/screen/splashScreen/pages/splashScreen.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    MaterialRoute(page: SplashScreen, initial: true),
    MaterialRoute(page: IntroPage),
    MaterialRoute(page: LoginPage),
    MaterialRoute(page: VerificationPage),
    MaterialRoute(path: '/users:id', page: HomePage),
    MaterialRoute(path: '/chat:chatId', page: PrivateChat),
  ],
)
class $Router {}
