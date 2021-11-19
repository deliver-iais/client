

import 'package:auto_route/auto_route.dart';
import 'package:deliver/screen/room/pages/roomPage.dart';
import 'package:deliver/screen/home/pages/home_page.dart';
import 'package:deliver/screen/register/pages/login_page.dart';
import 'package:deliver/screen/register/pages/verification_page.dart';
import 'package:deliver/screen/intro/pages/intro_page.dart';
import 'package:deliver/screen/settings/account_settings.dart';
import 'package:deliver/screen/share_input_file/share_input_file.dart';
import 'package:deliver/screen/splash/splash_screen.dart';



@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(page: SplashScreen, initial: true),
    AutoRoute(page: IntroPage),
    AutoRoute(page: LoginPage),
    AutoRoute(page: VerificationPage),
    AutoRoute(page: HomePage),
    AutoRoute(page: RoomPage),
    AutoRoute(page: AccountSettings),
    AutoRoute(page: ShareInputFile),

  ],
)
class $AppRouter{}
