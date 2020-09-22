import 'package:auto_route/auto_route_annotations.dart';
import 'package:deliver_flutter/screen/app-home/pages/homePage.dart';
import 'package:deliver_flutter/screen/app-home/widgets/forward.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/forward_widgets/selection_to_forward_page.dart';
import 'package:deliver_flutter/screen/register/pages/login_page.dart';
import 'package:deliver_flutter/screen/register/pages/verification_page.dart';
import 'package:deliver_flutter/screen/app-room/pages/roomPage.dart';
import 'package:deliver_flutter/screen/app-room/widgets/showImage_Widget.dart';
import 'package:deliver_flutter/screen/app_profile/pages/media_details_page.dart';
import 'package:deliver_flutter/screen/app_profile/pages/profile_page.dart';
import 'package:deliver_flutter/screen/intro/pages/intro_page.dart';
import 'package:deliver_flutter/screen/splash/pages/splash_screen.dart';
import 'package:deliver_flutter/screen/settings/settingsPage.dart';
import 'package:deliver_flutter/screen/app_group/pages/group_info_determination_page.dart';
import 'package:deliver_flutter/screen/app_group/pages/member_selection_page.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    MaterialRoute(page: SplashScreen, initial: true),
    MaterialRoute(page: IntroPage),
    MaterialRoute(page: LoginPage),
    MaterialRoute(page: VerificationPage),
    MaterialRoute(path: "/home-page", name: "homePage", page: HomePage),
    MaterialRoute(path: "/contacts-page", name: "contactsPage", page: HomePage),
    MaterialRoute(page: SettingsPage),
    MaterialRoute(page: RoomPage),
    MaterialRoute(page: ForwardMessage),
    MaterialRoute(page: ProfilePage),
    MaterialRoute(page: MediaDetailsPage),
    MaterialRoute(page: ShowImagePage),
    MaterialRoute(page: MemberSelectionPage),
    MaterialRoute(page: GroupInfoDeterminationPage),
    MaterialRoute(page: SelectionToForwardPage),
  ],
)
class $Router {}
