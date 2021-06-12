

import 'package:auto_route/auto_route_annotations.dart';
import 'package:deliver_flutter/screen/app-room/pages/roomPage.dart';
import 'package:deliver_flutter/screen/home/pages/home_page.dart';
import 'package:deliver_flutter/screen/app-contacts/widgets/new_Contact.dart';
import 'package:deliver_flutter/screen/register/pages/login_page.dart';
import 'package:deliver_flutter/screen/register/pages/verification_page.dart';
import 'package:deliver_flutter/screen/app-room/widgets/showImage_Widget.dart';
import 'package:deliver_flutter/screen/intro/pages/intro_page.dart';
import 'package:deliver_flutter/screen/settings/account_settings.dart';
import 'package:deliver_flutter/screen/share_input_file/share_input_file.dart';
import 'package:deliver_flutter/screen/splash/pages/splash_screen.dart';

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
