

import 'package:auto_route/auto_route_annotations.dart';
import 'package:we/screen/room/pages/roomPage.dart';
import 'package:we/screen/home/pages/home_page.dart';
import 'package:we/screen/contacts/new_contact.dart';
import 'package:we/screen/register/pages/login_page.dart';
import 'package:we/screen/register/pages/verification_page.dart';
import 'package:we/screen/room/widgets/showImage_Widget.dart';
import 'package:we/screen/intro/pages/intro_page.dart';
import 'package:we/screen/settings/account_settings.dart';
import 'package:we/screen/share_input_file/share_input_file.dart';
import 'package:we/screen/splash/splash_screen.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    MaterialRoute(page: SplashScreen, initial: true),
    MaterialRoute(page: IntroPage),
    MaterialRoute(page: LoginPage),
    MaterialRoute(page: VerificationPage),
    MaterialRoute(page: HomePage),
    MaterialRoute(page: ShowImagePage),
    MaterialRoute(page: NewContact),
    MaterialRoute(page: AccountSettings),
    MaterialRoute(page: RoomPage),
    MaterialRoute(page: ShareInputFile),

  ],
)
class $Router {}
