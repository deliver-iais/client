// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../screen/app-contacts/widgets/new_Contact.dart';
import '../screen/app-room/messageWidgets/forward_widgets/selection_to_forward_page.dart';
import '../screen/app-room/widgets/showImage_Widget.dart';
import '../screen/app_group/pages/group_info_determination_page.dart';
import '../screen/app_group/pages/member_selection_page.dart';
import '../screen/app_profile/pages/media_details_page.dart';
import '../screen/home/pages/home_page.dart';
import '../screen/intro/pages/intro_page.dart';
import '../screen/register/pages/login_page.dart';
import '../screen/register/pages/verification_page.dart';
import '../screen/settings/accountSetting.dart';
import '../screen/splash/pages/splash_screen.dart';

class Routes {
  static const String splashScreen = '/';
  static const String introPage = '/intro-page';
  static const String loginPage = '/login-page';
  static const String verificationPage = '/verification-page';
  static const String homePage = '/home-page';
  static const String mediaDetailsPage = '/media-details-page';
  static const String showImagePage = '/show-image-page';
  static const String memberSelectionPage = '/member-selection-page';
  static const String groupInfoDeterminationPage =
      '/group-info-determination-page';
  static const String selectionToForwardPage = '/selection-to-forward-page';
  static const String newContact = '/new-contact';
  static const String accountInfo = '/account-info';
  static const all = <String>{
    splashScreen,
    introPage,
    loginPage,
    verificationPage,
    homePage,
    mediaDetailsPage,
    showImagePage,
    memberSelectionPage,
    groupInfoDeterminationPage,
    selectionToForwardPage,
    newContact,
    accountInfo,
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
    RouteDef(Routes.mediaDetailsPage, page: MediaDetailsPage),
    RouteDef(Routes.showImagePage, page: ShowImagePage),
    RouteDef(Routes.memberSelectionPage, page: MemberSelectionPage),
    RouteDef(Routes.groupInfoDeterminationPage,
        page: GroupInfoDeterminationPage),
    RouteDef(Routes.selectionToForwardPage, page: SelectionToForwardPage),
    RouteDef(Routes.newContact, page: NewContact),
    RouteDef(Routes.accountInfo, page: AccountInfo),
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
    MemberSelectionPage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => MemberSelectionPage(),
        settings: data,
      );
    },
    GroupInfoDeterminationPage: (data) {
      final args = data.getArgs<GroupInfoDeterminationPageArguments>(
        orElse: () => GroupInfoDeterminationPageArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => GroupInfoDeterminationPage(
          key: args.key,
          members: args.members,
        ),
        settings: data,
      );
    },
    SelectionToForwardPage: (data) {
      final args = data.getArgs<SelectionToForwardPageArguments>(
        orElse: () => SelectionToForwardPageArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => SelectionToForwardPage(
          key: args.key,
          forwardedMessages: args.forwardedMessages,
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
    AccountInfo: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => AccountInfo(),
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

/// GroupInfoDeterminationPage arguments holder class
class GroupInfoDeterminationPageArguments {
  final Key key;
  final List<dynamic> members;
  GroupInfoDeterminationPageArguments({this.key, this.members});
}

/// SelectionToForwardPage arguments holder class
class SelectionToForwardPageArguments {
  final Key key;
  final List<dynamic> forwardedMessages;
  SelectionToForwardPageArguments({this.key, this.forwardedMessages});
}

/// NewContact arguments holder class
class NewContactArguments {
  final Key key;
  NewContactArguments({this.key});
}
