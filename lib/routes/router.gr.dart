// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';

import '../screen/contacts/new_contact.dart';
import '../screen/room/pages/roomPage.dart';
import '../screen/room/widgets/showImage_Widget.dart';
import '../screen/home/pages/home_page.dart';
import '../screen/intro/pages/intro_page.dart';
import '../screen/register/pages/login_page.dart';
import '../screen/register/pages/verification_page.dart';
import '../screen/settings/account_settings.dart';
import '../screen/share_input_file/share_input_file.dart';
import '../screen/splash/splash_screen.dart';

class Routes {
  static const String splashScreen = '/';
  static const String introPage = '/intro-page';
  static const String loginPage = '/login-page';
  static const String verificationPage = '/verification-page';
  static const String homePage = '/home-page';
  static const String showImagePage = '/show-image-page';
  static const String newContact = '/new-contact';
  static const String accountSettings = '/account-settings';
  static const String roomPage = '/room-page';
  static const String shareInputFile = '/share-input-file';
  static const all = <String>{
    splashScreen,
    introPage,
    loginPage,
    verificationPage,
    homePage,
    showImagePage,
    newContact,
    accountSettings,
    roomPage,
    shareInputFile,
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
    RouteDef(Routes.homePage, page: HomePage),
    RouteDef(Routes.showImagePage, page: ShowImagePage),
    RouteDef(Routes.newContact, page: NewContact),
    RouteDef(Routes.accountSettings, page: AccountSettings),
    RouteDef(Routes.roomPage, page: RoomPage),
    RouteDef(Routes.shareInputFile, page: ShareInputFile),
  ];
  @override
  Map<Type, AutoRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, AutoRouteFactory>{
    SplashScreen: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SplashScreen(),
        settings: data,
      );
    },
    IntroPage: (data) {
      final args = data.getArgs<IntroPageArguments>(
        orElse: () => IntroPageArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => IntroPage(
          key: args.key,
          currentPage: args.currentPage,
        ),
        settings: data,
      );
    },
    LoginPage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => LoginPage(),
        settings: data,
      );
    },
    VerificationPage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => VerificationPage(),
        settings: data,
      );
    },
    HomePage: (data) {
      final args = data.getArgs<HomePageArguments>(
        orElse: () => HomePageArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => HomePage(key: args.key),
        settings: data,
      );
    },
    ShowImagePage: (data) {
      final args = data.getArgs<ShowImagePageArguments>(
        orElse: () => ShowImagePageArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => ShowImagePage(
          key: args.key,
          imageFile: args.imageFile,
          roomUid: args.contactUid,
        ),
        settings: data,
      );
    },
    NewContact: (data) {
      final args = data.getArgs<NewContactArguments>(
        orElse: () => NewContactArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => NewContact(key: args.key),
        settings: data,
      );
    },
    AccountSettings: (data) {
      final args = data.getArgs<AccountSettingsArguments>(
        orElse: () => AccountSettingsArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => AccountSettings(
          key: args.key,
          forceToSetUsernameAndName: args.forceToSetUsernameAndName,
        ),
        settings: data,
      );
    },
    RoomPage: (data) {
      final args = data.getArgs<RoomPageArguments>(
        orElse: () => RoomPageArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => RoomPage(
          key: args.key,
          roomId: args.roomId,
          forwardedMessages: args.forwardedMessages,
          inputFilePath: args.inputFilePath,
          shareUid: args.shareUid,
        ),
        settings: data,
      );
    },
    ShareInputFile: (data) {
      final args = data.getArgs<ShareInputFileArguments>(
        orElse: () => ShareInputFileArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) =>
            ShareInputFile(inputSharedFilePath: args.inputSharedFilePath),
        settings: data,
      );
    },
  };
}

/// ************************************************************************
/// Arguments holder classes
/// *************************************************************************

/// IntroPage arguments holder class
class IntroPageArguments {
  final Key key;
  final dynamic currentPage;
  IntroPageArguments({this.key, this.currentPage});
}

/// HomePage arguments holder class
class HomePageArguments {
  final Key key;
  HomePageArguments({this.key});
}

/// ShowImagePage arguments holder class
class ShowImagePageArguments {
  final Key key;
  final File imageFile;
  final Uid contactUid;
  ShowImagePageArguments({this.key, this.imageFile, this.contactUid});
}

/// NewContact arguments holder class
class NewContactArguments {
  final Key key;
  NewContactArguments({this.key});
}

/// AccountSettings arguments holder class
class AccountSettingsArguments {
  final Key key;
  final bool forceToSetUsernameAndName;
  AccountSettingsArguments({this.key, this.forceToSetUsernameAndName = true});
}

/// RoomPage arguments holder class
class RoomPageArguments {
  final Key key;
  final String roomId;
  final List<dynamic> forwardedMessages;
  final List<String> inputFilePath;
  final ShareUid shareUid;
  RoomPageArguments(
      {this.key,
        this.roomId,
        this.forwardedMessages,
        this.inputFilePath,
        this.shareUid});
}

/// ShareInputFile arguments holder class
class ShareInputFileArguments {
  final List<String> inputSharedFilePath;
  ShareInputFileArguments({this.inputSharedFilePath});
}
