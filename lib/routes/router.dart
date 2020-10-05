import 'package:auto_route/auto_route_annotations.dart';
import 'package:deliver_flutter/screen/app-room/pages/roomPage.dart';
import 'package:deliver_flutter/screen/home/pages/home_page.dart';
import 'package:deliver_flutter/screen/app-contacts/widgets/new_Contact.dart';

import 'package:deliver_flutter/screen/app-room/messageWidgets/forward_widgets/selection_to_forward_page.dart';
import 'package:deliver_flutter/screen/register/pages/login_page.dart';
import 'package:deliver_flutter/screen/register/pages/verification_page.dart';
import 'package:deliver_flutter/screen/app-room/widgets/showImage_Widget.dart';
import 'package:deliver_flutter/screen/app_profile/pages/media_details_page.dart';
import 'package:deliver_flutter/screen/intro/pages/intro_page.dart';
import 'package:deliver_flutter/screen/settings/account_settings.dart';
import 'package:deliver_flutter/screen/splash/pages/splash_screen.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    MaterialRoute(page: SplashScreen, initial: true),
    MaterialRoute(page: IntroPage),
    MaterialRoute(page: LoginPage),
    MaterialRoute(page: VerificationPage),
    MaterialRoute(page: HomePage),
    MaterialRoute(page: MediaDetailsPage),
    MaterialRoute(page: ShowImagePage),
    MaterialRoute(page: SelectionToForwardPage),
  ],
)
class $Router {}
