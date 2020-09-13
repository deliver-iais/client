// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';

import '../screen/app-auth/pages/loginPage.dart';
import '../screen/app-auth/pages/verificationPage.dart';
import '../screen/app-home/pages/homePage.dart';
import '../screen/app-home/widgets/forward.dart';
import '../screen/app-room/pages/roomPage.dart';
import '../screen/app-room/widgets/showImage_Widget.dart';
import '../screen/app_intro/pages/intro_page.dart';
import '../screen/app_profile/pages/media_details_page.dart';
import '../screen/app_profile/pages/profile_page.dart';
import '../screen/settings/settingsPage.dart';
import '../screen/splashScreen/pages/splashScreen.dart';

class Routes {
  static const String splashScreen = '/';
  static const String introPage = '/intro-page';
  static const String loginPage = '/login-page';
  static const String verificationPage = '/verification-page';
  static const String homePage = '/home-page';
  static const String contactsPage = '/contacts-page';
  static const String settingsPage = '/settings-page';
  static const String roomPage = '/room-page';
  static const String forwardMessage = '/forward-message';
  static const String profilePage = '/profile-page';
  static const String mediaDetailsPage = '/media-details-page';
  static const String showImagePage = '/show-image-page';
  static const all = <String>{
    splashScreen,
    introPage,
    loginPage,
    verificationPage,
    homePage,
    contactsPage,
    settingsPage,
    roomPage,
    forwardMessage,
    profilePage,
    mediaDetailsPage,
    showImagePage,
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
    RouteDef(Routes.contactsPage, page: HomePage),
    RouteDef(Routes.settingsPage, page: SettingsPage),
    RouteDef(Routes.roomPage, page: RoomPage),
    RouteDef(Routes.forwardMessage, page: ForwardMessage),
    RouteDef(Routes.profilePage, page: ProfilePage),
    RouteDef(Routes.mediaDetailsPage, page: MediaDetailsPage),
    RouteDef(Routes.showImagePage, page: ShowImagePage),
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
      return MaterialPageRoute<dynamic>(
        builder: (context) => HomePage(),
        settings: data,
      );
    },
    SettingsPage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SettingsPage(),
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
        ),
        settings: data,
      );
    },
    ForwardMessage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ForwardMessage(),
        settings: data,
      );
    },
    ProfilePage: (data) {
      final args = data.getArgs<ProfilePageArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => ProfilePage(args.userUid),
        settings: data,
      );
    },
    MediaDetailsPage: (data) {
      final args = data.getArgs<MediaDetailsPageArguments>(
        orElse: () => MediaDetailsPageArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => MediaDetailsPage(
          key: args.key,
          mediaUrl: args.mediaUrl,
          mediaListLenght: args.mediaListLenght,
          mediaPosition: args.mediaPosition,
          heroTag: args.heroTag,
          mediaList: args.mediaList,
          mediaSender: args.mediaSender,
          mediaTime: args.mediaTime,
        ),
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
          contactUid: args.contactUid,
        ),
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

/// RoomPage arguments holder class
class RoomPageArguments {
  final Key key;
  final String roomId;
  RoomPageArguments({this.key, this.roomId});
}

/// ProfilePage arguments holder class
class ProfilePageArguments {
  final Uid userUid;
  ProfilePageArguments({@required this.userUid});
}

/// MediaDetailsPage arguments holder class
class MediaDetailsPageArguments {
  final Key key;
  final String mediaUrl;
  final int mediaListLenght;
  final int mediaPosition;
  final String heroTag;
  final List<String> mediaList;
  final String mediaSender;
  final String mediaTime;
  MediaDetailsPageArguments(
      {this.key,
      this.mediaUrl,
      this.mediaListLenght,
      this.mediaPosition,
      this.heroTag,
      this.mediaList,
      this.mediaSender,
      this.mediaTime});
}

/// ShowImagePage arguments holder class
class ShowImagePageArguments {
  final Key key;
  final File imageFile;
  final String contactUid;
  ShowImagePageArguments({this.key, this.imageFile, this.contactUid});
}
