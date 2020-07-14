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
import 'package:deliver_flutter/screen/app-home/pages/homePage.dart';
import 'package:deliver_flutter/screen/app-auth/pages/verificationPage.dart';
import 'package:deliver_flutter/screen/privateChat/pages/privateChat.dart';

class Routes {
  static const String splashScreen = '/';
  static const String introPage = '/intro-page';
  static const String loginPage = '/login-page';
  static const String _homePage = '/users:id';
  static homePage({@required id}) => '/users$id';
  static const all = <String>{
    splashScreen,
    introPage,
    loginPage,
    _homePage,
  };
}

class Router extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.splashScreen, page: SplashScreen),
    RouteDef(Routes.introPage, page: IntroPage),
    RouteDef(
      Routes.loginPage,
      page: LoginPage,
      innerRouter: () => LoginPageRouter(),
    ),
    RouteDef(
      Routes._homePage,
      page: HomePage,
      innerRouter: () => HomePageRouter(),
    ),
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
    HomePage: (RouteData data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => HomePage(),
        settings: data,
      );
    },
  };
}

class LoginPageRoutes {
  static const String verificationPage = '/verification';
  static const all = <String>{
    verificationPage,
  };
}

class LoginPageRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(LoginPageRoutes.verificationPage, page: VerificationPage),
  ];
  @override
  Map<Type, AutoRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, AutoRouteFactory>{
    VerificationPage: (RouteData data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => VerificationPage(),
        settings: data,
      );
    },
  };
}

class HomePageRoutes {
  static const String _privateChat = '/chat:chatId';
  static privateChat({@required chatId}) => '/chat$chatId';
  static const all = <String>{
    _privateChat,
  };
}

class HomePageRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(HomePageRoutes._privateChat, page: PrivateChat),
  ];
  @override
  Map<Type, AutoRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, AutoRouteFactory>{
    PrivateChat: (RouteData data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => PrivateChat(),
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
