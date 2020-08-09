// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/screen/splashScreen/pages/splashScreen.dart';
import 'package:deliver_flutter/screen/app-intro/pages/introPage.dart';
import 'package:deliver_flutter/screen/app-auth/pages/loginPage.dart';
import 'package:deliver_flutter/screen/app-auth/pages/verificationPage.dart';
import 'package:deliver_flutter/screen/settings/settingsPage.dart';
import 'package:deliver_flutter/screen/app-home/pages/homePage.dart';
import 'package:deliver_flutter/screen/app-room/pages/roomPage.dart';
import 'package:deliver_flutter/screen/app-home/widgets/forward.dart';

class Routes {
  static const String splashScreen = '/';
  static const String introPage = '/intro-page';
  static const String loginPage = '/login-page';
  static const String verificationPage = '/verification-page';
  static const String settingsPage = '/settings-page';
  static const String _homePage = '/users:id';
  static homePage({@required id}) => '/users$id';
  static const String roomPage = '/room-page';
  static const String forwardMessage = '/forward-message';
  static const all = <String>{
    splashScreen,
    introPage,
    loginPage,
    verificationPage,
    settingsPage,
    _homePage,
    roomPage,
    forwardMessage,
  };
}

class Router extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.splashScreen, page: SplashScreen),
    RouteDef(Routes.introPage, page: IntroPage),
    RouteDef(Routes.loginPage, page: LoginPage),
    RouteDef(Routes.verificationPage, page: VerificationPage),
    RouteDef(Routes.settingsPage, page: SettingsPage),
    RouteDef(Routes._homePage, page: HomePage),
    RouteDef(Routes.roomPage, page: RoomPage),
    RouteDef(Routes.forwardMessage, page: ForwardMessage),
  ];
  @override
  Map<Type, AutoRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, AutoRouteFactory>{
    SplashScreen: (RouteData data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SplashScreen(),
        settings: data,
      );
    },
    IntroPage: (RouteData data) {
      var args =
          data.getArgs<IntroPageArguments>(orElse: () => IntroPageArguments());
      return MaterialPageRoute<dynamic>(
        builder: (context) =>
            IntroPage(key: args.key, currentPage: args.currentPage),
        settings: data,
      );
    },
    LoginPage: (RouteData data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => LoginPage(),
        settings: data,
      );
    },
    VerificationPage: (RouteData data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => VerificationPage(),
        settings: data,
      );
    },
    SettingsPage: (RouteData data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SettingsPage(),
        settings: data,
      );
    },
    HomePage: (RouteData data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => HomePage(),
        settings: data,
      );
    },
    RoomPage: (RouteData data) {
      var args =
          data.getArgs<RoomPageArguments>(orElse: () => RoomPageArguments());
      return MaterialPageRoute<dynamic>(
        builder: (context) => RoomPage(key: args.key, roomId: args.roomId),
        settings: data,
      );
    },
    ForwardMessage: (RouteData data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ForwardMessage(),
        settings: data,
      );
    },
  };
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

//RoomPage arguments holder class
class RoomPageArguments {
  final Key key;
  final String roomId;
  RoomPageArguments({this.key, this.roomId});
}
