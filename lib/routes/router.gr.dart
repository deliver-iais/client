// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/screen/splashScreen/pages/splashScreen.dart';
import 'package:deliver_flutter/screen/app-intro/pages/introPage.dart';
import 'package:deliver_flutter/screen/app-home/pages/homePage.dart';
import 'package:deliver_flutter/screen/app-auth/pages/loginPage.dart';
import 'package:deliver_flutter/screen/app-auth/pages/verificationPage.dart';
import 'package:deliver_flutter/screen/settings/settingsPage.dart';

abstract class Routes {
  static const splashScreen = '/';
  static const introPage = '/intro-page';
  static const homePage = '/home-page';
  static const loginPage = '/login-page';
  static const verificationPage = '/verification-page';
  static const settingsPage = '/settings-page';
  static const all = {
    splashScreen,
    introPage,
    homePage,
    loginPage,
    verificationPage,
    settingsPage,
  };
}

class Router extends RouterBase {
  @override
  Set<String> get allRoutes => Routes.all;

  @Deprecated('call ExtendedNavigator.ofRouter<Router>() directly')
  static ExtendedNavigatorState get navigator =>
      ExtendedNavigator.ofRouter<Router>();

  @override
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute<dynamic>(
          builder: (context) => SplashScreen(),
          settings: settings,
        );
      case Routes.introPage:
        if (hasInvalidArgs<IntroPageArguments>(args)) {
          return misTypedArgsRoute<IntroPageArguments>(args);
        }
        final typedArgs = args as IntroPageArguments ?? IntroPageArguments();
        return MaterialPageRoute<dynamic>(
          builder: (context) =>
              IntroPage(key: typedArgs.key, currentPage: typedArgs.currentPage),
          settings: settings,
        );
      case Routes.homePage:
        return MaterialPageRoute<dynamic>(
          builder: (context) => HomePage(),
          settings: settings,
        );
      case Routes.loginPage:
        return MaterialPageRoute<dynamic>(
          builder: (context) => LoginPage(),
          settings: settings,
        );
      case Routes.verificationPage:
        return MaterialPageRoute<dynamic>(
          builder: (context) => VerificationPage(),
          settings: settings,
        );
      case Routes.settingsPage:
        return MaterialPageRoute<dynamic>(
          builder: (context) => SettingsPage(),
          settings: settings,
        );
      default:
        return unknownRoutePage(settings.name);
    }
  }
}

// *************************************************************************
// Arguments holder classes
// **************************************************************************

//IntroPage arguments holder class
class IntroPageArguments {
  final Key key;
  final dynamic currentPage;
  IntroPageArguments({this.key, this.currentPage});
}
